---
title: CORS
---

# CORS

Cross-Origin Resource Sharing (CORS) allows web browsers to make requests to your Trysil HTTP server from a different origin (domain, protocol, or port).

## Configuration

```pascal
LServer.CorsConfig.AllowOrigin := '*';
```

To restrict access to a specific origin:

```pascal
LServer.CorsConfig.AllowOrigin := 'https://myapp.com';
```

`Content-Type` is always allowed, and `Authorization` is added automatically for every controller that requires authentication. Set `AllowHeaders` only when your client sends additional custom headers:

```pascal
LServer.CorsConfig.AllowHeaders := 'X-Tenant, X-Request-ID';
```

## Configuration Properties

| Property | Type | Description |
|---|---|---|
| `AllowOrigin` | `String` | Allowed origin(s). Use `'*'` for any origin, or a specific URL. |
| `AllowHeaders` | `String` | Comma-separated list of **additional** allowed request headers. `Content-Type` and `Authorization` are handled automatically; duplicates are ignored. |

## How It Works

The `TTHttpCors` module handles CORS transparently:

1. **Preflight requests:** When a browser sends an `OPTIONS` request to check CORS policy, Trysil responds automatically with `Access-Control-Allow-Headers` and `Access-Control-Allow-Methods` built from the registered controller for that URI. You do not need to define `OPTIONS` endpoints in your controllers.

2. **Regular requests:** Only `Access-Control-Allow-Origin` is added, since the other CORS headers are meaningful on preflight responses alone.

3. **Controller registration:** When you register your controllers, `TTHttpCors` internally registers matching CORS controllers for their URI patterns. Each one collects the HTTP methods of the endpoint plus the request headers it accepts. This ensures that preflight requests are handled for every endpoint you define.

## Typical Setup

```pascal
var LServer := TTHttpServer<TAPIContext>.Create;
try
  LServer.BaseUri := 'http://localhost';
  LServer.Port := 8080;

  // Allow requests from any origin during development
  LServer.CorsConfig.AllowOrigin := '*';

  LServer.RegisterAuthentication<TMyAuth>();
  LServer.RegisterController<TPersonController>();
  LServer.Start;

  ReadLn;
  LServer.Stop;
finally
  LServer.Free;
end;
```

!!! tip
    During development, use `'*'` for `AllowOrigin` to avoid CORS issues. In production, restrict it to your application's actual origin for security.
