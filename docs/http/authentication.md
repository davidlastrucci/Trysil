---
title: Authentication
---

# Authentication

Trysil HTTP supports pluggable authentication with built-in handlers for the most common schemes.

## Authentication Types

| Scheme | Description | Use Case |
|---|---|---|
| **Basic** | Username/password in Base64-encoded header | Simple internal tools |
| **Bearer** | Token-based (typically JWT) | REST APIs, SPAs |
| **Digest** | Challenge-response | Legacy systems |

## Bearer Authentication (JWT)

Bearer authentication with JWT is the most common choice for REST APIs.

### Signing Algorithms

The payload class is also the signer: it decides how the token is signed and verified. Pick a base class according to the algorithm.

| Base class | Unit | Algorithm | Keys |
|---|---|---|---|
| `TTHttpJWTHS256Payload` | `Trysil.Http.JWT.Payload.HS256` | `HS256` (HMAC-SHA256) | one shared secret (`GetSecret`) |
| `TTHttpJWTRS256Payload` | `Trysil.Http.JWT.Payload.RS256` | `RS256` (RSA-SHA256) | RSA key objects (`GetSigningKey` / `GetVerificationKey`) |

`TTHttpJWTAbstractPayload` (`Trysil.Http.JWT.Payload`) declares only the contract, so it cannot be inherited from directly.

!!! warning "Breaking change"
    Payloads previously inherited from `TTHttpJWTAbstractPayload` and provided a `GetSecret` override. Change the ancestor to `TTHttpJWTHS256Payload` to keep the same behavior, or to `TTHttpJWTRS256Payload` to move to asymmetric signing.

Choose `HS256` when the same application both issues and validates tokens. Choose `RS256` when they are separate: the issuer holds the private key, every resource server only needs the public key, so a compromised resource server cannot mint tokens.

### Step 1: Define a JWT Payload

The payload class carries the authenticated user's identity and permissions:

```pascal
uses
  Trysil.Http.JWT,
  Trysil.Http.JWT.Payload.HS256;

type
  TMyPayload = class(TTHttpJWTHS256Payload)
  strict private
    FUsername: String;
    FAreas: TList<String>;
    FExpireTime: Int64;
  strict protected
    function GetSecret: String; override;
  public
    constructor Create;
    destructor Destroy; override;
    function IsValid: Boolean;
    function ToJSon: String; override;
    procedure FromJSon(const AData: String); override;
    property Username: String read FUsername write FUsername;
    property Areas: TList<String> read FAreas;
  end;

function TMyPayload.GetSecret: String;
begin
  Result := 'your-secret-key';
end;

function TMyPayload.IsValid: Boolean;
begin
  Result := FExpireTime > DateTimeToUnix(Now, False);
end;
```

`ToJSon` and `FromJSon` define the token claims: Trysil does not impose a claim set, the payload writes and reads its own JSON.

#### RS256 Variant

RSA keys are **objects, not strings**: `TTHttpJWTRSAPrivateKey` and `TTHttpJWTRSAPublicKey` (`Trysil.Http.JWT.RSAKey`) parse their PEM once, in the constructor, and hold the parsed key for their whole lifetime. Create them **once at startup**, keep them in your configuration object, and let the payload borrow them:

```pascal
uses
  Trysil.Http.JWT,
  Trysil.Http.JWT.Payload.RS256,
  Trysil.Http.JWT.RSAKey;

// once, at startup
FSigningKey := TTHttpJWTRSAPrivateKey.Create(LPrivatePem, '2026-07');

type
  TMyPayload = class(TTHttpJWTRS256Payload)
  strict protected
    function GetSigningKey: TTHttpJWTRSAPrivateKey; override;
    function GetVerificationKey(
      const AKeyID: String): TTHttpJWTRSAAbstractKey; override;
  public
    // same ToJSon / FromJSon as above
  end;

function TMyPayload.GetSigningKey: TTHttpJWTRSAPrivateKey;
begin
  Result := TMyConfig.Instance.SigningKey;
end;

function TMyPayload.GetVerificationKey(
  const AKeyID: String): TTHttpJWTRSAAbstractKey;
begin
  Result := TMyConfig.Instance.KeyFor(AKeyID);   // AKeyID is the token's kid
end;
```

The payload **borrows** the keys: your application owns them and frees them at shutdown. A payload is created per request, so a key created inside it would be parsed on every request, which is exactly what this API is shaped to avoid.

A verify-only server is expressed by the type, not by a runtime check: hand it a `TTHttpJWTRSAPublicKey`, which has no `Sign` method at all. `GetSigningKey` is optional (it defaults to `nil`) and signing without it raises `ETHttpJWTException`. `GetVerificationKey` is called at verify time and can return `nil` for an unknown `kid`: verification then fails closed, returning `False` rather than raising.

Both key classes take an optional key ID (`Create(APem, AKeyID)`), which the payload emits as the `kid` header, so a key and its identifier are declared together.

!!! note "OpenSSL requirement"
    RS256 uses OpenSSL `libcrypto`, loaded dynamically when the first key is constructed. The unit compiles on every platform, and raises `ETHttpJWTException` at runtime if the library is missing. On Windows deploy `libcrypto-3-x64.dll` (or `libcrypto-1_1-x64.dll`) next to the executable; on Linux and macOS the system or Homebrew OpenSSL 3 is used. `HS256` has no external dependency.

!!! tip "Thread safety"
    One key instance can sign and verify from several threads at once: the constructor runs a warm-up operation while still single-threaded, so nothing inside OpenSSL is initialized lazily under concurrency. Share one key across the server, do not create one per request or per thread.

### Key Rotation (`kid`)

Rotating a key means old tokens must still verify while new ones are signed with the new key. The standard `kid` header identifies which key a token was signed with:

Say you signed with one secret until June, you switched to a new one in July, and June tokens must keep working until they expire:

```pascal
const
  SecretJune = 'old-secret';
  SecretJuly = 'new-secret';

type
  TMyPayload = class(TTHttpJWTHS256Payload)
  strict protected
    function GetSigningKeyID: String; override;
    function GetSecret: String; override;
    function GetSecretFor(const AKeyID: String): String; override;
  end;

// the name of the key I am signing with now
function TMyPayload.GetSigningKeyID: String;
begin
  Result := 'july';
end;

// the secret I am signing with now
function TMyPayload.GetSecret: String;
begin
  Result := SecretJuly;
end;

// a token claims it was signed with key X: give me the secret of X
function TMyPayload.GetSecretFor(const AKeyID: String): String;
begin
  if AKeyID = 'june' then
    Result := SecretJune
  else
    Result := SecretJuly;
end;
```

What happens at runtime:

1. **Login.** `Sign` uses `GetSecret`, so the token is signed with `SecretJuly`, and the header carries `kid: july` from `GetSigningKeyID`.
2. **A request with a new token.** The header says `kid: july`, `GetSecretFor('july')` returns `SecretJuly`, the signature matches.
3. **A request with a June token.** The header says `kid: june`, `GetSecretFor('june')` returns `SecretJune`, the signature matches.
4. **Once every June token has expired**, delete the `june` branch and the constant.

The three methods answer three different questions, which is why there are three of them:

| Method | Question | Called by |
|---|---|---|
| `GetSecret` | which secret do I sign with? | `Sign`, at login |
| `GetSigningKeyID` | what is that key called? | header construction |
| `GetSecretFor` | given this name, which secret is it? | `Verify`, on every request |

Rotating means changing `GetSigningKeyID` and `GetSecret` together, leaving the retired secret reachable from `GetSecretFor` until the tokens signed with it have expired.

| Member | Direction | Meaning |
|---|---|---|
| `SigningKeyID` | outgoing | when not empty, written as `kid` in the token header |
| `AKeyID` argument | incoming | the `kid` read from the token header, passed to `GetSecretFor` (HS256) or `GetVerificationKey` (RS256) |

The `kid` of an incoming token is an **argument**, not payload state: `GetSecretFor` and `GetVerificationKey` receive it at verification time. Overriding `GetSecretFor` is optional and it defaults to `GetSecret`, so an application that does not rotate keys is unaffected.

The example above is HS256. With RS256 you do not override `GetSigningKeyID` at all: the key ID travels with the key object (`Create(APem, AKeyID)`) and the payload emits the `kid` of the key it signs with. In both cases, leaving the signing key ID empty emits no `kid`.

The header `alg` is always matched against the payload's own algorithm, so a token signed with a different algorithm is rejected before its signature is checked.

### Step 2: Implement Authentication Handler

```pascal
type
  TMyAuth = class(TTHttpAuthenticationBearer<TMyContext, TMyPayload>)
  strict protected
    function CreatePayload: TMyPayload; override;
    function IsValid(const APayload: TMyPayload): Boolean; override;
  public
    procedure Check(const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

function TMyAuth.CreatePayload: TMyPayload;
begin
  Result := TMyPayload.Create;
end;

function TMyAuth.IsValid(const APayload: TMyPayload): Boolean;
begin
  Result := APayload.IsValid;
end;
```

### Step 3: Create a Login Controller

The login endpoint is excluded from authentication so clients can obtain a token:

```pascal
[TUri('/logon')]
[TAuthorizationType(TTHttpAuthorizationType.None)]
TLogonController = class(TTHttpController<TMyContext>)
public
  [TPost]
  procedure Logon;
end;

procedure TLogonController.Logon;
var
  LJWT: TTHttpJWT<TMyPayload>;
  LPayload: TMyPayload;
begin
  // 1. Validate credentials from FRequest.Content
  // 2. Create payload with username and areas
  LPayload := TMyPayload.Create;
  try
    LPayload.Username := 'david';
    LPayload.Areas.Add('read');
    LPayload.Areas.Add('write');

    // 3. Generate token
    LJWT := TTHttpJWT<TMyPayload>.Create(LPayload);
    try
      FResponse.Content := Format('{"token":"%s"}', [LJWT.ToToken]);
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;
```

### Step 4: Register

```pascal
FServer.RegisterAuthentication<TMyAuth>();
```

## Areas (Authorization)

Areas provide fine-grained access control. The flow is:

1. The JWT payload carries the list of areas granted to the user.
2. Controller methods declare required areas via `[TArea('...')]`.
3. The authentication handler checks that the user's areas include the required area.

```pascal
// Controller declares required areas
[TGet]
[TArea('read')]
procedure GetAll;

[TPost]
[TArea('admin')]
procedure Insert;
```

A user with `['read']` can access `GetAll` but not `Insert`. A user with `['read', 'admin']` can access both.

## Skipping Authentication

Use `[TAuthorizationType(TTHttpAuthorizationType.None)]` on a controller class to make all its endpoints public:

```pascal
[TUri('/health')]
[TAuthorizationType(TTHttpAuthorizationType.None)]
THealthController = class(TTHttpController<TMyContext>)
public
  [TGet]
  procedure Check;
end;
```

This is essential for login endpoints, health checks, and public resources.
