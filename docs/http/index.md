---
title: HTTP Module
---

# HTTP Module

The HTTP module (`Trysil.Http/`) provides a REST endpoint hosting framework built on top of the Trysil ORM and JSON modules.

## Key Features

- **Attribute-based routing** -- define endpoints with `[TGet]`, `[TPost]`, `[TPut]`, `[TDelete]` attributes.
- **Generic controllers** -- build reusable CRUD controllers with type parameters.
- **Authentication** -- pluggable support for Basic, Bearer, Digest schemes and JWT.
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
  LServer.BaseUri := 'http://localhost';
  LServer.Port := 8080;

  LServer.RegisterController<TMyController>();
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
| `Trysil.Http.Log` | Structured HTTP logging |
| `Trysil.Http.MultiTenant` | Multi-tenant support |

## Sections

- [Server Setup](server.md) -- creating and configuring the HTTP server.
- [Controllers & Routing](controllers.md) -- defining endpoints and handling requests.
- [Authentication](authentication.md) -- securing endpoints with JWT and other schemes.
- [CORS](cors.md) -- cross-origin resource sharing configuration.
- [Multi-Tenant](multi-tenant.md) -- tenant isolation and configuration.
