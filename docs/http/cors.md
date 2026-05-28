---
title: CORS
---

# CORS

Cross-Origin Resource Sharing (CORS) allows web browsers to make requests to your Trysil HTTP server from a different origin (domain, protocol, or port).

## Configuration

```pascal
LServer.CorsConfig.AllowHeaders := 'Content-Type, Authorization';
LServer.CorsConfig.AllowOrigin := '*';
```

To restrict access to a specific origin:

```pascal
LServer.CorsConfig.AllowOrigin := 'https://myapp.com';
```

## Configuration Properties

| Property | Type | Description |
|---|---|---|
| `AllowOrigin` | `String` | Allowed origin(s). Use `'*'` for any origin, or a specific URL. |
| `AllowHeaders` | `String` | Comma-separated list of allowed request headers. |

## How It Works

CORS headers are automatically added to all HTTP responses. The `TTHttpCors` module handles this transparently:

1. **Preflight requests:** When a browser sends an `OPTIONS` request to check CORS policy, Trysil responds automatically with the configured headers. You do not need to define `OPTIONS` endpoints in your controllers.

2. **Regular requests:** The `Access-Control-Allow-Origin` and `Access-Control-Allow-Headers` headers are added to every response.

3. **Controller registration:** When you register your controllers, `TTHttpCors` internally registers matching CORS controllers for their URI patterns. This ensures that preflight requests are handled for every endpoint you define.

## Typical Setup

```pascal
var LServer := TTHttpServer<TAPIContext>.Create;
try
  LServer.BaseUri := 'http://localhost';
  LServer.Port := 8080;

  // Allow requests from any origin during development
  LServer.CorsConfig.AllowOrigin := '*';
  LServer.CorsConfig.AllowHeaders := 'Content-Type, Authorization';

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
