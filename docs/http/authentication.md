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
| **Digest** | Challenge-response | Deprecated, see below |

!!! warning "Digest is deprecated"
    `TTHttpAuthenticationDigest<C>` implements RFC 2069, the 1997 form of the scheme: no `qop`, no `nc`, no `cnonce`, and a captured response stays replayable for as long as `IsValidNonce` accepts its nonce. It is not being brought up to RFC 7616. Use **Bearer** with JWT, or **Basic** over TLS for an internal tool. The TLS comes from the reverse proxy in front of the server, not from the server: see [TLS](server.md#tls).

    That is the reason you can repair. The one you cannot is in [Storing passwords](#storing-passwords): Digest cannot be used with passwords stored the way passwords should be stored, and no revision of the scheme changes that.

## Storing passwords

How a password is hashed and compared is the application's, and it has to be:
Trysil does not know where your users are kept or how the passwords already in
that table were written, and a framework that picked the algorithm would force
every application on earth to reissue its passwords the day it changed its mind.

`TTHttpAuthenticationBasic<C>` decodes the header and hands you the two values,
and the whole decision is inside the method you implement:

```pascal
function TMyAuth.IsValid(const AUser: TTHttpUser): Boolean;
```

Three rules, none of them specific to Trysil:

- Hash with a **deliberately slow, salted** function - Argon2id or bcrypt - and
  never with a bare SHA-256, which a GPU computes by the billion per second.
- Compare in **constant time**. `LStored = LComputed` on two strings stops at
  the first byte that differs, and how long it took is measurable over enough
  requests.
- Answer the **same way** whether the user does not exist or the password is
  wrong, and take the same time doing it. A login that fails faster for an
  unknown name is a way to enumerate your users.

### What the scheme decides for you

The scheme is not only a wire format: it dictates what the server has to know,
and therefore what you are able to keep in the database.

| Scheme | What the server must hold | Can you store a slow salted hash? |
|---|---|---|
| **Bearer (JWT)** | Nothing. The password is checked once, by your login endpoint | **Yes** |
| **Basic** | Nothing. The password arrives, you compare it your way | **Yes** |
| **Digest** | `HA1 = MD5(username:realm:password)` | **No** |

Digest computes `MD5(HA1:nonce:HA2)`, so the server needs `HA1`, so your
`GetUserMD5` has to produce it - and to produce it you must have kept the
password itself or `HA1`, which is an unsalted MD5. There is no way to derive
`HA1` from a bcrypt: being one-way is what the slow hash is for. The constraint
is in the algorithm, not in this implementation, and RFC 7616 keeps it word for
word.

So a leak of that table is not a leak of unusable hashes. It is unsalted MD5 of
`username:realm:password`, attacked with tables precomputed for your realm -
which is public, because the server sends it in the `WWW-Authenticate` header -
and what comes out is reused by your users on other sites.

**Use Bearer with JWT.** The password appears once, at the login endpoint,
which is your code: compare it against the slow hash there, issue the token,
and no request after that carries a password at all.

**Basic over TLS** is a reasonable second choice when the caller is a machine -
a scheduled job, a webhook - because then the secret is long and random, there
is nothing to guess, and the cost of the hash matters much less.

### What Trysil does

One thing, and it is the part that belongs to the framework: the request log
never writes the credential. `Authorization`, `Proxy-Authorization`, `Cookie`,
`Set-Cookie` and `X-Api-Key` are replaced with `<redacted>`
(`Trysil.Http.Log.Types.pas`). With Basic that header **is** the password in
Base64, so logging headers verbatim would be keeping a file of plaintext
passwords.

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

!!! warning "The framework never checks the expiry"
    Trysil does not impose a claim set: `TTHttpJWTAbstractPayload` declares
    only `ToJSon` and `FromJSon`, so it knows nothing about `exp`, `nbf` or
    `iat`. It verifies the **signature** and nothing else. If your `IsValid`
    does not compare against the clock, the token never expires, and a
    signature stays valid for as long as the key does.

    Two things to get right in it. Work in **UTC**: `DateTimeToUnix(Now,
    False)` converts local time correctly, while comparing two locally
    formatted timestamps breaks at every daylight-saving transition, where a
    thirty-minute token can last ninety or be born expired. And allow a few
    seconds of **clock skew** between the machine that mints the token and the
    one that validates it, as the `APIRest` demo does with its
    `ClockSkewSeconds`.

!!! warning "Never hardcode the secret"
    `'your-secret-key'` above is a placeholder. The HMAC secret **is** the
    signing key: anyone who has it can forge a token for any user. Read it
    from configuration or from the environment, keep it out of version
    control, and reject a secret that is missing or shorter than 32
    characters instead of falling back to a default. The `APIRest` demo
    shows the shape: `GetSecret` reads
    `TAPIConfig.Instance.Authentication.Secret` and raises if it is too
    short.

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

The constructor also checks that the PEM carries an **RSA** key, and raises `ETHttpJWTException` if it does not. A PEM public key header says `BEGIN PUBLIC KEY` whatever the algorithm underneath, and OpenSSL signs and verifies with whatever the key names, so an EC key configured here by mistake would have verified perfectly good ECDSA signatures while the token header said `RS256` - a server verifying an algorithm nobody chose, with nothing to show for it in any log.

!!! note "OpenSSL requirement"
    RS256 uses OpenSSL `libcrypto`, loaded dynamically when the first key is constructed. The unit compiles on every platform, and raises `ETHttpJWTException` at runtime if the library is missing. On Windows deploy `libcrypto-3-x64.dll` (or `libcrypto-1_1-x64.dll`) next to the executable; on Linux and macOS the system or Homebrew OpenSSL 3 is used. `HS256` has no external dependency.

!!! tip "Thread safety"
    One key instance can sign and verify from several threads at once: the constructor runs a warm-up operation while still single-threaded, so nothing inside OpenSSL is initialized lazily under concurrency. Share one key across the server, do not create one per request or per thread.

### Key Rotation (`kid`)

Rotating a key means old tokens must still verify while new ones are signed with the new key.

!!! warning "The `kid` comes from the token, before the token is trusted"
    `GetSecretFor` and `GetVerificationKey` are called with the `kid` read
    from the header of a token nobody has verified yet - that is what the
    header is for, since the key has to be chosen before the signature can
    be checked. Treat it as a string the caller chose: look it up in a table
    you control, and never build a file name, a path or a query out of it.

The standard `kid` header identifies which key a token was signed with:

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
  strict private
    FRequest: TTHttpRequest;
  strict protected
    function CreatePayload: TMyPayload; override;
    function IsValid(const APayload: TMyPayload): Boolean; override;
  public
    procedure Check(const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

procedure TMyAuth.Check(const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  FRequest := ARequest;
  inherited Check(ARequest, AResponse);
end;

function TMyAuth.CreatePayload: TMyPayload;
begin
  Result := TMyPayload.Create;
end;

function TMyAuth.IsValid(const APayload: TMyPayload): Boolean;
var
  LArea: String;
begin
  Result := APayload.IsValid;
  if Result then
  begin
    FRequest.User.Username := APayload.Username;
    for LArea in APayload.Areas do
      FRequest.User.Areas.Add(LArea);
  end;
end;
```

!!! warning "Key a revocation or replay list on the token, not on the header"
    `GetValue` returns the token already extracted from the `Authorization`
    header and trimmed, and that string is the only stable identity of the
    credential. The header itself is not: the scheme is matched
    case-insensitively, so `Bearer`, `bearer` and `BeArEr` all reach the same
    token, and the whitespace around it is not part of it either.

    An application that stores raw header values in a revocation table at
    logout and compares them on the next request lets the same token back in
    under a different capitalisation, for as long as it has left to live. Store
    what `GetValue` returned, or a hash of it.

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
3. Your authentication class puts the areas on `Request.User.Areas`: Trysil does not read them from the payload. The listener compares them against `[TArea]` and raises `ETHttpForbidden` when one is missing. Do not repeat the check inside `Check`: declaring `[TArea]` is what enforces it.
4. `Start` refuses a declaration of areas that cannot work: `[TArea]` with no authentication class registered, or `[TArea]` on a route marked `[TAuthorizationType(TTHttpAuthorizationType.None)]`.

The area check itself does not ask whether an authentication class exists: with no user there are no areas, so a route carrying `[TArea]` answers `403`. To drive such a route in a test without issuing tokens, register an authentication class that fills `Request.User.Areas` and returns - not one that is missing.

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
