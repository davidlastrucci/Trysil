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
| `OnCanLog` | `TFunc<TTHttpRequest, Boolean>` | Asked on the request thread before a log entry is built. Returning `False` skips the entry entirely. |

## Registration Methods

| Method | Description |
|---|---|
| `RegisterController<T>()` | Register a controller using its `[TUri]` attribute |
| `RegisterController<T>(AUri)` | Register a controller with a custom base URI |
| `RegisterAuthentication<T>()` | Register an authentication handler |
| `RegisterLogWriter<T>()` | Register a log writer with one log thread |
| `RegisterLogWriter<T>(APoolSize)` | Register a log writer with `APoolSize` log threads |
| `RegisterLogWriter<T>(AParameters)` | Register a log writer with a `TTHttpLogParameters` record |

### Log Writers

A log writer receives a `TTHttpLogAction`, a `TTHttpLogRequest`, or a `TTHttpLogResponse` and persists it wherever you choose (file, database, external collector).

- `TTHttpLogRequest` carries `Host`, `Uri`, `MethodType`, `ContentLength`, `ContentOmitted`, `Content`, `ParamsCount`, `ParamsOmitted`, `Params`, `HeadersCount`, `HeadersOmitted`, `Headers`, `RemoteIP` and `ClientIP` (see [Caller IP address](controllers.md#caller-ip-address)).
- `TTHttpLogResponse` carries `Host`, `Uri`, `User`, `StatusCode`, `ContentType`, `ContentEncoding`, `ContentLength`, `ContentOmitted` and the content. `Uri` lets a writer decide by route -- redacting the response of an `/auth/*` endpoint by endpoint rather than by scanning every payload for sensitive keys.

Request and response entries are queued to background log threads; action entries are written inline. In both paths an exception raised inside the writer is caught and discarded, so a log destination that is full, locked, or unreachable never breaks the request being served, and never crashes a log thread.

#### Tuning: TTHttpLogParameters

```pascal
LServer.RegisterLogWriter<TMyLogWriter>(
  TTHttpLogParameters.Create(4, 10000, 65536));
```

| Parameter | Meaning | Unlimited |
|---|---|---|
| `ThreadPoolSize` | Number of log threads | -- |
| `QueueCapacity` | Cap on the per-thread queue | negative value |
| `MaxContentLength` | Cap on the captured body, in bytes | negative value |
| `MaxItemCount` | Cap on captured parameters and headers, in items | negative value |

The registration overloads that do not take the record apply finite defaults: 64 KB of content and 128 items. Unlimited is available, but you have to ask for it with a negative value.

!!! warning "Sensitive headers are redacted"
    `Authorization`, `Proxy-Authorization`, `Cookie`, `Set-Cookie` and `X-Api-Key` reach the writer with their name intact and `<redacted>` in place of the value. Names matter for diagnosis, values do not, and with Basic authentication the value is the credentials. `OnCanLog` is not an alternative: it is per request and all-or-nothing, so keeping a token out of the log would mean losing the endpoint's log entirely.

!!! warning "MaxContentLength alone does not keep the body out of the log"
    With `Content-Type: application/x-www-form-urlencoded` Indy reads the **whole body** into `FormParams`, glues it to the query string and decodes it into `Params`. The parameters *are* the body. `Params` is therefore omitted whenever `Content` is: capping the body now caps both, and `ParamsOmitted` declares it the way `ContentOmitted` does.

    `MaxItemCount` is the other half, because a cap in bytes does not bound a count: tens of thousands of short, distinct parameter names fit in a body of about a megabyte. Above the cap `Params` and `Headers` are omitted, with `ParamsCount` and `HeadersCount` still recorded.

#### Deciding before you pay: OnCanLog

`OnCanLog` is asked **on the request thread, before** the log record is built. Returning `False` costs nothing at all: no body serialization, no copy, no queue, no INSERT. Without it, a 500 KB response is paid for three times even for a tenant that has logging turned off.

```pascal
LServer.OnCanLog :=
  function(ARequest: TTHttpRequest): Boolean
  begin
    Result := TenantLogEnabled(ARequest.Host);
  end;
```

Assign it before `Start`. It runs on **every** request thread, so it must be thread-safe; resolve the tenant with `TTMultiTenant<T>.TryGet`, which does not construct.

!!! warning "LogRequest runs before routing and authentication"
    When the writer receives a request, it is not yet known whether the route exists or who the caller is: `WriteRequest` is invoked for a 404 and for a 401 too. In a per-database multi-tenant application this means an anonymous caller can place two rows of arbitrary content into the log database of whichever tenant it names in the `Host` header. `OnCanLog` is where you reject or divert those requests.

#### Capping the captured body

When a body is larger than `MaxContentLength` it is not captured at all. The size is measured **without touching the body**, so an oversized request is never parsed nor re-serialized, and an oversized binary response skips Base64 encoding entirely.

The omission is declared rather than silent. `ToJSon` always writes `ContentLength`, and `ContentOmitted: true` appears in place of `Content`:

```json
{ "TaskID": "...", "ContentLength": 524288, "ContentOmitted": true }
```

!!! note "Wire format change"
    `ContentLength` and `ContentOmitted` are new keys, and `Content` may be absent. Downstream consumers of log rows need updating.

#### Queue cap and discarded entries

Each log thread owns its queue, and the queue has a capacity. When it is full the **newest** entry is rejected and counted, rather than the oldest being dropped: the audit trail keeps a contiguous prefix of history instead of being punched full of holes.

Discards are not left in a counter nobody reads. The log thread reports them through the writer, aggregated **per host**, on a timer as well as at the end of every drain -- under sustained load the queue never runs dry, so waiting for it to empty would mean never reporting at all:

```pascal
procedure TMyLogWriter.WriteDiscarded(
  const ADiscarded: TTHttpLogDiscarded);
begin
  WriteToTenantLog(ADiscarded.Host, ADiscarded.Count);
end;
```

`WriteDiscarded` is virtual but **not abstract**, so existing writers keep compiling. Its default implementation is not empty: it forwards to `WriteAction` with a formatted message, so discards are visible even without an override. Overriding it lets a multi-tenant writer put the row in the right tenant's log database.

The `Host` is the client's own text, so it is bounded before it becomes a key: lowercased, truncated to 64 characters, and stripped of anything outside `a-z 0-9 . - : _`. Distinct hosts are capped at 64, and everything past that accumulates under `<other>` -- which is also where a request that sent no `Host` header lands. Without the cap the counters would be a dictionary keyed by a value the caller chooses.

#### Unhandled errors

Every response of status 500 or above -- routed by status code, not by exception class -- has a body of a constant plus the task id. The detail goes to the writer instead, and **only** there: without a registered writer a 5xx leaves no trace at all.

```pascal
procedure TMyLogWriter.WriteError(const ALogError: TTHttpLogError);
begin
  WriteToTenantLog(ALogError.Host, ALogError.ToJSon);
end;
```

`TTHttpLogError` carries `TaskID`, `Host`, `Uri`, `ExceptionClassName` and `ExceptionMessage`, plus `NestedExceptionClassName` and `NestedExceptionMessage` when the exception is an `ETException` raised while another one was in flight. Like `WriteDiscarded` it is virtual and not abstract, and its default forwards to `WriteAction`.

The exception is rendered to strings **on the request thread**, before the entry is queued: the object dies when the handler exits, so only strings can be handed to the log thread. `WriteError` is not gated by `OnCanLog` -- an error row is always worth writing.

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
