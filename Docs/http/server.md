---
title: Server Setup
---

# Server Setup

## Creating a Server

```pascal
uses
  Trysil.Http;

type
  TMyContext = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

var LServer := TTHttpServer<TMyContext>.Create;
try
  LServer.BaseUri := 'http://localhost';
  LServer.Port := 8080;
  LServer.CorsConfig.AllowOrigin := '*';
  LServer.CorsConfig.AllowHeaders := 'Content-Type, Authorization';

  LServer.RegisterAuthentication<TMyAuthentication>();
  LServer.RegisterController<TMyController>();
  LServer.RegisterController<TMyEntityController>('/entity');
  LServer.RegisterLogWriter<TMyLogWriter>();

  LServer.Start;
  // Server is running...
  ReadLn;
  LServer.Stop;
finally
  LServer.Free;
end;
```

## Context Class

The type parameter `C` in `TTHttpServer<C>` defines the **per-request context**. A new instance of this class is created for every incoming HTTP request and destroyed when the response is sent.

The context class should create its own database connection and ORM context:

```pascal
type
  TAPIContext = class
  strict private
    FConnection: TTConnection;
    FContext: TTHttpContext;
  public
    constructor Create;
    destructor Destroy; override;
    property Context: TTHttpContext read FContext;
  end;

constructor TAPIContext.Create;
begin
  inherited Create;
  TTFireDACConnectionPool.Instance.Config.Enabled := True;
  FConnection := TTSqlServerConnection.Create('Main');
  FContext := TTHttpContext.Create(FConnection);
end;

destructor TAPIContext.Destroy;
begin
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;
```

`TTHttpContext` extends `TTJSonContext` with HTTP-specific convenience methods:

| Method | Description |
|---|---|
| `GetID` | Extract entity ID from request |
| `SetSequenceID` | Set the sequence ID on an entity |
| `Delete(ID, Version)` | Delete an entity by primary key and version |

## Server Configuration

| Property | Type | Description |
|---|---|---|
| `BaseUri` | `String` | Base URI for the server (e.g., `'http://localhost'`) |
| `Port` | `Integer` | Listening port |
| `CorsConfig` | `TTHttpCorsConfig` | CORS configuration (see [CORS](cors.md)) |

## Registration Methods

| Method | Description |
|---|---|
| `RegisterController<T>()` | Register a controller using its `[TUri]` attribute |
| `RegisterController<T>(AUri)` | Register a controller with a custom base URI |
| `RegisterAuthentication<T>()` | Register an authentication handler |
| `RegisterLogWriter<T>()` | Register a log writer |

## Lifecycle

1. **Startup:** Call `LServer.Start` to begin listening for HTTP requests.
2. **Per-request:** For each request, the server creates a new context instance `C`, routes the request to the appropriate controller method, and destroys the context when done.
3. **Shutdown:** Call `LServer.Stop` to stop accepting requests and shut down gracefully.

## Connection Pooling

Since a new connection is created per request, **connection pooling is essential** for server applications:

```pascal
TTFireDACConnectionPool.Instance.Config.Enabled := True;
```

Without pooling, every request opens and closes a database connection, which adds significant latency.
