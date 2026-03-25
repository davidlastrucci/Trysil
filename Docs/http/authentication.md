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

### Step 1: Define a JWT Payload

The payload class carries the authenticated user's identity and permissions:

```pascal
type
  TMyPayload = class(TTHttpJWTAbstractPayload)
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
