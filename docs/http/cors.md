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

1. **Preflight requests:** When a browser sends an `OPTIONS` request to check CORS policy, Trysil answers automatically with `Access-Control-Allow-Headers`, `Access-Control-Allow-Methods` and `Access-Control-Max-Age`. The answer is **the same for every URI**, whether or not a controller is registered for it: `Content-Type` and `Authorization` among the headers, and every method of `TTHttpMethodType` among the verbs. It is deliberately not accurate - a preflight that described the route would tell an anonymous caller which routes exist and which verbs they answer, and the browser needs none of that: it sends the preflight and then the real request, and it is there that the router decides `405` and authentication decides `401`. You do not need to define `OPTIONS` endpoints in your controllers, and you cannot: no attribute produces one.

2. **Regular requests:** Only `Access-Control-Allow-Origin` is added, since the other CORS headers are meaningful on preflight responses alone.

3. **Controller registration:** Registering a controller also registers it with `TTHttpCors`. Since 2.0.0 the preflight answer does not depend on that registry - it is the same for every URI - so nothing about it varies with what you register.

## Typical Setup

```pascal
var LServer := TTHttpServer<TAPIContext>.Create;
try
  LServer.BaseUri := '/api';
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
