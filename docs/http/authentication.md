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
| `TTHttpJWTRS256Payload` | `Trysil.Http.JWT.Payload.RS256` | `RS256` (RSA-SHA256) | RSA key pair (`GetPrivateKey` / `GetPublicKey`) |

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

```pascal
uses
  Trysil.Http.JWT,
  Trysil.Http.JWT.Payload.RS256;

type
  TMyPayload = class(TTHttpJWTRS256Payload)
  strict protected
    function GetPrivateKey: String; override;   // PEM, issuer only
    function GetPublicKey: String; override;    // PEM, issuer and verifiers
  public
    // same ToJSon / FromJSon as above
  end;
```

Both keys are PEM strings. Overriding `GetPrivateKey` is optional: a verifier that only validates tokens can leave it out, and `Sign` then raises `ETHttpJWTException`.

!!! note "OpenSSL requirement"
    RS256 uses OpenSSL `libcrypto`, loaded dynamically at first sign or verify. The unit compiles on every platform, and raises `ETHttpJWTException` at runtime if the library is missing. On Windows deploy `libcrypto-3-x64.dll` (or `libcrypto-1_1-x64.dll`) next to the executable; on Linux and macOS the system or Homebrew OpenSSL 3 is used. `HS256` has no external dependency.

### Key Rotation (`kid`)

Rotating a key means old tokens must still verify while new ones are signed with the new key. The standard `kid` header identifies which key a token was signed with:

```pascal
type
  TMyPayload = class(TTHttpJWTHS256Payload)
  strict protected
    function GetSigningKeyID: String; override;
    function GetSecret: String; override;
  end;

function TMyPayload.GetSigningKeyID: String;
begin
  Result := '2026-07';   // key currently used to sign
end;

function TMyPayload.GetSecret: String;
begin
  // TokenKeyID is the kid of the incoming token, empty on a payload
  // created to sign. SecretOf is your own key lookup (config, vault, ...)
  if TokenKeyID.IsEmpty then
    Result := SecretOf(GetSigningKeyID)
  else
    Result := SecretOf(TokenKeyID);
end;
```

Keep the retired keys in the lookup as long as tokens signed with them can still be presented, and drop them once the longest token lifetime has elapsed.

| Member | Direction | Meaning |
|---|---|---|
| `SigningKeyID` | outgoing | when not empty, written as `kid` in the token header |
| `TokenKeyID` | incoming | the `kid` read from the token header, set before `Verify` runs |

The same pattern works for RS256, returning the public key that matches `TokenKeyID`. Leave `GetSigningKeyID` alone and no `kid` is emitted, exactly as before.

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
