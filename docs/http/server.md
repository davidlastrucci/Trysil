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
  LServer.BaseUri := '/api';
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

### The context is built before the route is known and before authentication

Every request that is not a CORS preflight builds one, in this order: **context**, then route resolution, then authentication, then areas, then the handler. So `C.Create` runs for a URI that does not exist, and for a caller carrying no token at all.

That order is not an oversight. Authentication is your code and it is handed the context, because deciding who the caller is usually means asking the database - and the same holds for an address that does not exist, where the `401` has to be decided before the `404` so an anonymous caller cannot learn which routes exist by reading status codes.

What it means for you is that **whatever `C.Create` does is reachable anonymously**. In the shape above it opens a database connection: `TTFireDACConnection` calls `Open` in its `AfterConstruction`, so that is one pooled connection taken and returned per request, including every `404`.

If your authentication does not need the database - a JWT signature check does not - build the connection on first use instead of in the constructor, and an unauthenticated request that never reaches a handler costs nothing:

```pascal
function TAPIContext.GetContext: TTHttpContext;
begin
  if not Assigned(FContext) then
  begin
    FConnection := TTSqlServerConnection.Create('Main');
    FContext := TTHttpContext.Create(FConnection);
  end;
  result := FContext;
end;

destructor TAPIContext.Destroy;
begin
  if Assigned(FContext) then
    FContext.Free;
  if Assigned(FConnection) then
    FConnection.Free;
  inherited Destroy;
end;
```

In a multi-tenant server the same applies to resolving the tenant, which is heavier: see [Multi-tenant](multi-tenant.md).

`TTHttpContext` extends `TTJSonContext` with HTTP-specific convenience methods:

| Method | Description |
|---|---|
| `GetID` | Extract entity ID from request |
| `SetSequenceID` | Set the sequence ID on an entity |
| `Delete(ID, Version)` | Delete an entity by primary key and version |

## Server Configuration

| Property | Type | Description |
|---|---|---|
| `BaseUri` | `String` | Path prefix prepended to every registered route (e.g. `'/api'`). A leading `/` is added if missing, and an empty string registers the routes as the controllers declare them. It is **not** an address: the address the server listens on comes from the port and the bindings, and a value carrying a scheme is refused. |
| `Port` | `Integer` | Listening port |
| `CorsConfig` | `TTHttpCorsConfig` | CORS configuration (see [CORS](cors.md)) |
| `OnCanLog` | `TFunc<TTHttpRequest, Boolean>` | Asked on the request thread before a log entry is built. Returning `False` skips the entry entirely. |
| `OnRedactContent` | `TFunc<TTHttpRequest, String, String>` | Asked on the request thread for the request body and the response body. Receives the request and the content, returns what gets logged. |
| `AllowAnonymous` | `Boolean` | Declares that this server serves every route without authentication, so `Start` does not require an authentication class. It does not switch areas off: a route carrying `[TArea]` still refuses to start without an authentication class. |
| `AllowMethodOverride` | `Boolean` | Default `False`. Whether a `POST` may declare itself another method through a header. See below. |
| `MaxRequestContentLength` | `Int64` | Default `1048576` (1 MB). Largest request body the server reads. `0` accepts any size. See below. |
| `TTHttpResponse.ServerHeader` | `String` | Class property, not a server one. The `Server:` header written into every response, by default `API REST made simple by Trysil Delphi ORM` and the repository URL. Assign an empty string to leave the header out. |
### Request Body Ceiling

A request body is read into memory whole before anything looks at it, and `Content` then materializes it as a `String`, so a body of *n* bytes costs several times *n* while it is being handled. Until this version nothing bounded that, on any route: one client could ask the process for as much memory as it liked.

`MaxRequestContentLength` is the ceiling, 1 MB by default. A request that declares more is answered `413` before a single byte of the body is read. Raise it where the application really does accept larger payloads:

```pascal
LServer.MaxRequestContentLength := 16 * 1024 * 1024;
```

`0` restores the old behaviour and accepts any size.

The declared length is not the only way in: a client can send a chunked body with no length at all, or simply lie. So with a ceiling set the server also hands Indy a stream that stops growing at it, and a body that gets past the header check has its connection dropped instead of the process paying for it. That backstop bounds memory rather than counting bytes exactly - it can overshoot the ceiling by a few kilobytes of allocation slack before it refuses - and it is not the path an honest client takes: an honest client declares its length and reads a `413`.

### Method Override

Indy reads three headers on a `POST` - `X-HTTP-Method-Override`, `X-HTTP-Method` and `X-METHOD-OVERRIDE` - and replaces the command with what they name, before Trysil sees the request. The route is then resolved as if the client had sent that method.

Anything that filters on the request line sees only the `POST`. A reverse proxy configured to allow `POST` and block `DELETE`, a WAF rule, a log-based alert on deletions: all of them are walked past by one header.

Trysil refuses the swap with a `400` unless the server says otherwise:

```pascal
LServer.AllowMethodOverride := True;
```

Turn it on when a client that genuinely cannot send the method is part of the picture - an old proxy, a corporate gateway - and know that the filtering has to move to the application in exchange. `TTHttpRequest` carries both readings either way: `Method` is what the route was resolved with, `SentMethod` is what came on the request line, and `IsMethodOverridden` says whether they differ.

### TLS

`TTHttpServer<C>` serves HTTP and does not terminate TLS. That is a decision, not a gap: put IIS, Apache, nginx or any other reverse proxy in front of it and let that terminate.

The reason is that TLS is not one feature, it is a standing obligation - cipher suites, protocol versions, certificate renewal, OCSP stapling, HTTP/2 - and a proxy does all of it better and keeps doing it without a rebuild. Owning it here would also mean owning the OpenSSL version the Indy SSL handler happens to want, in a process that already has a database driver's opinion about its libraries.

The server is written for that deployment. `TTHttpRequest` carries `RemoteIP`, the TCP peer, and `ClientIP`, which resolves the **last** `X-Forwarded-For` entry when the peer is loopback, so a proxy on the same host gives you the caller and a header from an outside caller cannot forge it. Configure the proxy to pass `X-Forwarded-For` and terminate on the loopback interface.

Bind the server to loopback when a proxy is in front of it, so nothing reaches it in clear from outside the host.

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

!!! warning "The tenant reaches the log as you wrote it"
    `TTHttpUser.Tenant` is copied into every log entry whole. It is not
    capped the way `Host` is, and neither `RedactedNames`, which covers
    headers, nor `OnRedactContent`, which covers bodies, reaches it. Put
    an identifier there - a name, a code - and never a connection string
    or a credential, or it is written in clear on every request.

Request and response entries are queued to background log threads; action entries are written inline. In both paths an exception raised inside the writer is caught and discarded, so a log destination that is full, locked, or unreachable never breaks the request being served, and never crashes a log thread. The writer's **constructor** is the one place where a failure is loud: `RegisterLogWriter` creates one writer and frees it right away, so a destination that cannot be opened at all stops the application at start-up instead of leaving it running with no log. On a log thread the same failure is not fatal - the writer is created on first use and retried on the next cycle, so a destination that comes back resumes writing by itself. A writer meant to survive a destination that is missing at start-up must therefore not open it in its constructor.

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

Every value left unsaid means the same thing, whether you use a registration overload that does not take the record or one of the short constructors of the record itself: **no body at all**, 128 items, one thread, a queue of 10 000. They are readable as `TTHttpLogParameters.DefaultMaxContentLength` and the three beside it. Unlimited is available for the queue, the body and the item count, but you have to ask for it with a negative value: it is a decision, so it is written down. A `0` is a decision on `MaxContentLength`, where it means no body, and is **not** one on `MaxItemCount`, where it reads as the default of 128 - there is no way to spell *no headers and no parameters* with a count, and the way to have none is not to log at all.

!!! warning "Bodies are not logged unless you ask"
    `MaxContentLength` defaults to `0`, so the body of a request and of a
    response are left out of the log until you raise it. The reason is that
    Trysil cannot know what is sensitive in your payloads: a password may be
    called `password`, or `pwd`, or `p`. Redaction is the host's job, and
    `OnRedactContent` is where it goes.

    What the default decides is only what happens when nobody has decided:
    with bodies off, an application that never heard of `OnRedactContent`
    does not put credentials in its log. Raise `MaxContentLength` when you
    want the bodies, and assign `OnRedactContent` in the same breath - by
    raising it you are taking on what it captures. Note that `LogRequest`
    runs **before** authentication, so the body of a `POST /logon` is
    captured with the credentials in it.

!!! warning "Sensitive names are redacted, and you can add your own"
    A value whose name is on the redaction list reaches the writer with the
    name intact and `<redacted>` in place of the value. Names matter for
    diagnosis, values do not, and with Basic authentication the value is the
    credentials.

    The list ships with the header names - `Authorization`,
    `Proxy-Authorization`, `Cookie`, `Set-Cookie`, `X-Api-Key` - and with the
    names a secret takes in a query string: `token`, `access_token`,
    `refresh_token`, `id_token`, `api_key`, `key`, `password`, `signature`.
    One list covers headers and parameters, because a link a browser opens
    cannot set a header and carries the token in the url instead.

    Name your own at startup, before `Start`:

    ```pascal
    TTHttpLogRedactedNames.Instance.Add('X-Tenant-Key');
    ```

    The comparison ignores case and does not follow the locale of the
    machine. `key` is on the list deliberately: a parameter genuinely called
    `key` is redacted as well, which costs a log line some detail and never
    costs a secret.

    `Add` is refused while a server is running, with `ETHttpServerException`. The
    list is read on every header and every parameter of every request, so
    adding to it under those readers would be a race - and refusing there is
    what lets the read path carry no lock at all. Stop the server and the
    list opens again, so an application that starts, stops and reconfigures
    is not painted into a corner.

    For bodies, and for anything a name cannot describe, use
    `OnRedactContent`; `OnCanLog` remains the blunt instrument, per request
    and all-or-nothing.

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

`ContentOmitted` covers the other case where the body cannot be written too: a
request body that is not valid JSON. Reading it raises, and the log drops the
body rather than the record - losing the record would take the uri, the caller
IP, the headers and the counts with it, and the caller is named in the request
row only.

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

A repeated header keeps the **first** occurrence: names collapse regardless of case, and the later ones are dropped from the lookup and from the enumeration alike. The policy is positional, so nothing should be built on a second `Authorization` being visible - a proxy in front of the application is the right place to reject a duplicate.

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

### The server must stop before the process ends

Trysil keeps a number of process-wide singletons - the entity mapper, the
language table, the column and parameter factories, the logger, the
serializers and deserializers, and the redaction list
(`TTHttpLogRedactedNames`, read on every header and every parameter of every
request) - created when their unit initializes and destroyed when it
finalizes. Every request reads several of them, from an Indy worker thread.

Finalization does not wait for those threads. A process that ends while
requests are still being served runs the destructors under them, and what
follows is an access violation at an address that tells you nothing about the
cause.

Destroying the server is enough, and normally you get it for free:
`TTHttpServer<C>.Destroy` calls `Stop` when the server is still active, and
Delphi finalizes units in reverse order of initialization, so the unit holding
your server - which depends on Trysil - is finalized first. Hold the server in
a unit variable, or in an object you free on the way out, and the shutdown is
ordered correctly without you thinking about it.

What breaks the ordering is ending the process without destroying the server:
`Halt`, a service killed rather than stopped, an instance created and never
freed. Call `Stop` yourself on every path that ends the process, including the
console handler or the service stop request.

The same applies to `TTLogger` when you have registered a logger with a thread
pool, and to the connection pool: both are torn down by the same finalization.

## Registering before the server starts

`TTFactory`, `TTColumnFactory`, `TTParameterFactory`, `TTJSonSerializers`, `TTJSonDeserializers`,
`TTJSonEventFactory` and `TTLanguage` keep plain dictionaries, written by their
public `Register*` methods and read without a lock. Concurrent reads of a
dictionary nobody is writing are safe, which is why this works, but it is only
true while registration is over.

Call every `Register*` - custom column classes, parameter classes,
serializers, translations - **before** `Server.Start`, from the main thread.
Registering one while requests are being served can rehash a dictionary another
thread is reading.

Two settings belong to the same rule without saying so in their signature,
because unlike every other one they carry no guard: **`CorsConfig`**
(`AllowOrigin`, `AllowHeaders`, `MaxAge`) and **`TTHttpResponse.ServerHeader`**.
Both are read on the Indy thread while a request is being answered - the CORS
values on every preflight and on the fallback error response, the server header
on **every** response - so assigning one from the main thread with the server
running races the read of a string the request thread is copying. Every other
setting refuses to change after `Start`; these two do not, so the rule is
yours to keep.

## Connection Pooling

A context `C` is built for every request, so a connection it opens in its constructor is opened once per request: **connection pooling is essential** for server applications:

```pascal
TTFireDACConnectionPool.Instance.Config.Enabled := True;

TTSqlServerConnection.RegisterConnection('Main', ...);
```

Without pooling, a context that opens a connection in its constructor opens and closes one on every request, which adds significant latency.

The order matters: pool settings are baked into the FireDAC connection definition by `RegisterConnection`, so enabling the pool afterwards does nothing for definitions that already exist. Put it in the server start-up, not in the per-request context constructor, and see [Connection Pooling](../database-drivers/index.md#connection-pooling).
