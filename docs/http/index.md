---
title: HTTP Module
---

# HTTP Module

The HTTP module (`Trysil.Http/`) provides a REST endpoint hosting framework built on top of the Trysil ORM and JSON modules.

## Key Features

- **Attribute-based routing** -- define endpoints with `[TGet]`, `[TPost]`, `[TPut]`, `[TDelete]` attributes.
- **Generic controllers** -- build reusable CRUD controllers with type parameters.
- **Authentication** -- pluggable support for Basic, Bearer and JWT (Digest is deprecated).
- **CORS** -- configurable cross-origin resource sharing.
- **Structured logging** -- HTTP request/response logging with pluggable writers.
- **Multi-tenant** -- built-in tenant isolation with per-tenant configuration and connections.

## Architecture

```
TTHttpServer<C>
  |-- Controllers (registered via attributes)
  |-- Authentication (pluggable)
  |-- CORS (configurable)
  |-- Logging (pluggable writers)
  +-- Request/Response pipeline
```

## Main Class

`TTHttpServer<C>` is the entry point, where `C` is a context class that is instantiated per request. The context class provides the connection and ORM context for each request.

```pascal
uses
  Trysil.Http;

var LServer := TTHttpServer<TMyContext>.Create;
try
  LServer.BaseUri := '/api';
  LServer.Port := 8080;

  LServer.RegisterController<TMyController>();

  // A route without [TAuthorizationType] requires authentication, so a server
  // that registers no authentication class must say so explicitly.
  LServer.AllowAnonymous := True;

  LServer.Start;

  ReadLn; // Keep server running

  LServer.Stop;
finally
  LServer.Free;
end;
```

## Module Units

| Unit | Description |
|---|---|
| `Trysil.Http` | `TTHttpServer<C>` main server class |
| `Trysil.Http.Attributes` | Routing and authorization attributes |
| `Trysil.Http.Controller` | Base controller class |
| `Trysil.Http.Cors` | CORS configuration and handling |
| `Trysil.Http.Exceptions` | HTTP-specific exceptions (400, 401, 403, 404, 500) |
| `Trysil.Http.Authentication` | Authentication base classes |
| `Trysil.Http.Authentication.Bearer` | Bearer/JWT authentication |
| `Trysil.Http.JWT` | JWT token generation and validation |
| `Trysil.Http.JWT.Payload` | JWT payload contract (`TTHttpJWTAbstractPayload`) |
| `Trysil.Http.JWT.Payload.HS256` | HS256 payload base class (HMAC-SHA256) |
| `Trysil.Http.JWT.Payload.RS256` | RS256 payload base class (RSA-SHA256, OpenSSL) |
| `Trysil.Http.JWT.RSAKey` | RSA key objects (`TTHttpJWTRSAPrivateKey` / `PublicKey`) |
| `Trysil.Http.Log` | Structured HTTP logging |
| `Trysil.Http.MultiTenant` | Multi-tenant support |

## What an exception becomes

An exception that escapes a controller is answered by the listener, and which
status it gets depends on its class:

| Raised | Status | Body |
|---|---|---|
| `ETHttpException` and descendants | its own (400, 401, 403, 404, 405, 409, 413, 422, 500) | `status` + `message` |
| `ETConcurrentUpdateException` | **409** | `status` + the ORM message |
| `ETValidationException` | **422** | `status` + the validation message |
| `ETJSonServerException` | **500** | a constant plus the task id, nothing more |
| `ETJSonException` | **400** | `status` + the JSON message |
| anything else | **500** | a constant plus the task id, nothing more |

The three ORM exceptions are mapped because the caller can act on them: a 409
says the row moved, a 422 says the body is wrong, a 400 says the JSON is. They
are logged with `LogAction`, not `LogError`: they are the caller's problem, not
a server fault. `ETDataIntegrityException` is deliberately **not** mapped,
because whether a broken constraint is the caller's fault or the schema's is
not something the library can decide, and neither is `ETException` itself.

`ETJSonServerException` derives from `ETJSonException` and is matched first. It is raised by the three JSON failures that are the server's fault, not the caller's: a serializer or deserializer never registered for a member of the model, a serialization re-entered by the host's own event, a field type the dataset converter does not know. Those three are the whole list: other configuration faults that surface as JSON errors still raise `ETJSonException` and answer 400. A value in the body that cannot be converted raises `ETJSonException` too and answers 400; a body that does not parse answers 400 as well, through `ETHttpBadRequest` when it is read with `JSonContent` and through `ETJSonException` when a string is handed to `TTJSonContext`.

A 500 never carries a detail: the message goes to the registered log writer and
only there. Without a writer, a 5xx leaves no trace at all - see
[Server Setup](server.md).

!!! warning "A refused token is 403, not 401"
    `401` means "you sent no credential, or one of the wrong scheme", and it
    carries `WWW-Authenticate`. A credential that was understood and refused -
    a token that does not verify, a password that does not match, a user the
    application rejects - is **403**. A client that renews its token on a 401
    will therefore not renew: renew on **403** with an expired token, or check
    expiry before calling.

## Sections

- [Server Setup](server.md) -- creating and configuring the HTTP server.
- [Controllers & Routing](controllers.md) -- defining endpoints and handling requests.
- [Authentication](authentication.md) -- securing endpoints with JWT and other schemes.
- [CORS](cors.md) -- cross-origin resource sharing configuration.
- [Multi-Tenant](multi-tenant.md) -- tenant isolation and configuration.
