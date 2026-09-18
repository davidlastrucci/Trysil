# Multi-Tenant

The multi-tenant module (`Trysil.Http.MultiTenant/`) provides tenant isolation for HTTP applications. Each tenant gets its own configuration and database connection, managed through a thread-safe singleton.

## Architecture

The module consists of three classes:

| Class | Unit | Description |
|---|---|---|
| `TTTenantConfig` | `Trysil.Http.MultiTenant.Config` | Abstract base for tenant configuration |
| `TTTenantConnection` | `Trysil.Http.MultiTenant.Connection` | Creates connections for a tenant |
| `TTMultiTenant<T>` | `Trysil.Http.MultiTenant` | Thread-safe singleton tenant registry |
| `TTTenant<T>` | `Trysil.Http.MultiTenant` | Holds a tenant's name, config, and connection |

## Defining a Tenant Configuration

Extend `TTTenantConfig` to provide tenant-specific connection parameters:

```pascal
type
  TMyTenantConfig = class(TTTenantConfig)
  strict protected
    function GetConnectionName: String; override;
    function GetParameters: TTFireDACConnectionParameters; override;
  public
    constructor Create(const AName: String); override;
  end;

function TMyTenantConfig.GetConnectionName: String;
begin
  Result := 'tenant_' + FName;
end;

function TMyTenantConfig.GetParameters: TTFireDACConnectionParameters;
begin
  // Load connection parameters for this tenant
  // e.g., from a configuration file, database, or environment
  Result.Server := 'db-server';
  Result.DatabaseName := 'db_' + FName;
  Result.Username := 'app_user';
  Result.Password := 'secret';
end;
```

The `Create` constructor receives the tenant name. `GetConnectionName` must return a unique FireDAC connection name. `GetParameters` provides the database connection details. The constructor and `GetParameters` run outside any lock, and two requests for a new tenant can run them at once, twice for the same name: they have to be thread-safe, and `GetParameters` has to return the same parameters every time.

## Using TTMultiTenant

`TTMultiTenant<T>` is a class-level singleton — it is created automatically on unit initialization and destroyed on finalization.

### Get or Create a Tenant

```pascal
var LTenant := TTMultiTenant<TMyTenantConfig>.Instance.GetOrAdd('acme');

// Access tenant properties
LTenant.Name;        // 'acme'
LTenant.Config;      // TMyTenantConfig instance
LTenant.Connection;  // TTTenantConnection instance
```

`GetOrAdd` is thread-safe, and nothing of yours runs while it holds the write lock. Your `TTTenantConfig` is built and its connection registered **before** the lock is taken; the lock is then held only long enough to publish the tenant in the dictionary. That matters because `GetParameters` is where a host reads a file, queries a directory or asks a configuration service: while the write lock is held every other tenant's first access waits, readers included, so a slow `GetParameters` for one tenant used to be a stall for all of them.

The price is that two threads racing on the same new tenant both build a config and both register the connection, and only the winner's tenant is published. Registering the same name twice with the same parameters is a no-op - `TTFireDACConnectionPool.RegisterConnection` compares the signature and refuses only a *different* one - so the loser's work is discarded, not conflicting. If the parameters differ, the loser's registration is refused: that request raises `ETTenantUnavailable`, and the failure it records refuses the requests for that tenant that arrive before the winner has published it.

!!! warning "Resolving a tenant is on the anonymous path"
    The per-request context is built before the route is resolved and before authentication - see [The context is built before the route is known](server.md#the-context-is-built-before-the-route-is-known-and-before-authentication) - so a `GetOrAdd` called from its constructor is reached by an anonymous caller asking for a URI that does not exist, with a tenant header.

    Three things keep that bounded, and the first two are yours. Resolve the name against the tenants you have before calling `GetOrAdd`. Build the connection on first use rather than in the constructor, if your authentication does not need it. The third is here: a name that cannot be a name is refused before anything is opened, and a tenant that failed to open is remembered for `FailureCooldown` so the second attempt costs nothing.

!!! warning "Validate the tenant name against a closed list"
    A tenant name is almost always request data - a header, a subdomain, a claim - and it ends up as a FireDAC connection definition name and, in most applications, as a database name or a path. Resolve it against the tenants you actually have before calling `GetOrAdd`; do not hand it whatever arrived.

    `GetOrAdd` refuses a name that cannot be one at all, with `ETTenantNameNotValid`: it must start with a letter or a digit and hold at most 63 of those plus `_`, `-` and `.`. That stops `../`, a separator smuggled into a connection string, and an empty name. It is a floor, not the check you owe: `acme` and `wilecoyote` both pass it, and only you know which of them exists. `TTTenantName.IsValid` is the same test, callable before you get there.

    `ETTenantNameNotValid` descends from `ETTenantUnavailable`, so a host that already catches the latter keeps working; catch it first to answer `400` rather than `404`.

A failed creation always raises **`ETTenantUnavailable`**, which carries `TenantName` and `OriginalClassName` and keeps the original message. `GetOrAdd` never lets the underlying exception through, so the class a host catches does not depend on timing:

```pascal
try
  LTenant := TTMultiTenant<TMyTenantConfig>.Instance.GetOrAdd(LName);
except
  on E: ETTenantUnavailable do
    raise ETHttpNotFound.CreateFmt('Unknown tenant %s', [E.TenantName]);
end;
```

That `try..except` is not decoration. `ETTenantUnavailable` descends from `ETException`, not from `ETHttpException`, so without it an unresolvable tenant answers **500 with the fixed body** and the reason reaches the log only. If your `TTTenantConfig` used to raise an `ETHttp*` to turn an unknown host into a 404, that status no longer reaches the client on its own: catch and re-raise where you resolve the tenant. `E.OriginalClassName` says what failed underneath.

The reason it is a class of its own rather than the original exception re-raised: an exception cannot be faithfully reconstructed from a class reference in Delphi, because constructors are not virtual - rebuilding an `ETHttpNotFound` that way would call `Exception.Create` and leave its status code at zero.

Failures are **rate limited**. `GetOrAdd` records the name with a cooldown (`FailureCooldown`, 5000 ms by default, settable, `0` disables it), and calls inside that window fail without touching the disk. Failures are still not memoized permanently -- a tenant repaired by dropping its folder in place must not stay broken until restart -- but the cost of an anonymous caller rotating the `Host` header stops being a function of traffic. The failure table is capped at 128 names: expired entries are swept on every insert, and when it is full the entry closest to expiry is evicted, so a full table never means an unprotected one.

### A tenant whose schema is behind

Column metadata are read from the database **lazily**, the first time an entity is used on a connection, and cached per connection and per type. In a per-database multi-tenant application that means a tenant that missed a migration **starts normally** and fails later in the day, on the first request that touches the entity whose column is not there.

The framework cannot check it for you: it does not know which entities your application has. You do, so ask for them where you resolve the tenant:

```pascal
procedure TMyTenantConfig.WarmUp(const AContext: TTContext);
begin
  AContext.GetMetadata<TOrder>();
  AContext.GetMetadata<TCustomer>();
end;
```

Each call probes the table once and fills the cache, and a tenant whose schema is behind fails **on that call**, with the name of the entity in the message.

### Create a Connection

```pascal
var LConnection := LTenant.Connection.CreateConnection;
try
  var LContext := TTContext.Create(LConnection);
  try
    // Per-tenant ORM operations...
  finally
    LContext.Free;
  end;
finally
  LConnection.Free;
end;
```

`TTTenantConnection.CreateConnection` uses `TTFireDACConnectionFactory` internally. The connection is registered automatically when the tenant is first created (`AfterConstruction`).

### List All Tenants

```pascal
var LNames := TTMultiTenant<TMyTenantConfig>.Instance.GetAll;
for var LName in LNames do
  WriteLn(LName);
```

The order is not guaranteed and is not the order of registration: sort the result if you display it.

### Remove a Tenant

```pascal
TTMultiTenant<TMyTenantConfig>.Instance.Remove('acme');
```

`Remove` detaches the tenant from the registry -- `TryGet` and `GetAll` stop seeing it -- but does **not** destroy the instance. Tenants handed out by `TryGet` and `GetOrAdd` are borrowed references, and a thread that resolved one an instant earlier may be about to call `Connection.CreateConnection` on it; the write lock protects the structure, not the references already given away. The instance is released with the registry, on finalization.

Each `Remove` therefore costs one instance for the life of the process, because
a later `GetOrAdd` on the same name builds a new one rather than reviving the
old: reviving it would hand back the configuration read the first time, and
that is the one thing you are replacing when you go through the deregistration
sequence below. `Remove` is for a tenant that has gone away, or whose
definition you are about to replace -- not for a periodic sweep of the cache.

`Remove` means "forget the cache", not "revoke the customer": the FireDAC connection definition stays registered, and a `GetOrAdd` on the same name afterwards rebuilds the tenant rather than failing. Registering a definition that already exists **unchanged is a no-op** - it is not replaced - so the name never burns and nothing is torn down under a request thread. Registering a *different* definition under a name already in use still raises, as it always did: the name is the identity, and silently swapping the database behind it would turn a configuration mistake into a runtime one.

"Unchanged" is compared on the **exact text** of the parameter lines Trysil passed - `DriverID` first, then the ones your `TTTenantConfig` produced - sorted and matched byte for byte, values and parameter names alike. Two lists that FireDAC would consider the same definition but that differ in the case of a key, or in the spacing around the `=`, count as a conflict. Build the list the same way on every call and this never comes up; build it from user-facing text and it will.

Revoking a customer for real would mean closing the pool and deregistering the connection, which needs a use count on the borrowed references: that is design, and it is not what `Remove` does today.

### Deregistering a connection

`TTFireDACConnection.UnregisterConnection(AName)` is the other half, and it is a hard teardown, not the inverse of a cache miss. It closes **every open connection** on that definition, destroys the physical connection host and its pool, and only then deletes the definition.

That is what makes it the way to replace a definition - registration refuses to overwrite one, so `UnregisterConnection` followed by `RegisterConnection` is the sequence - but it is also why it must not run with requests in flight on that name. A `TTConnection` another thread resolved an instant earlier keeps its object, and loses the FireDAC connection underneath it: the next statement on it raises. Quiesce the tenant first, the same way you would before any other destructive maintenance.

## Integration with HTTP Server

In a typical multi-tenant REST API, resolve the tenant from the request -- a header, a subdomain, the first segment of the URI -- in your per-request context:

```pascal
type
  TAPIContext = class
  strict private
    FTenant: TTTenant<TMyTenantConfig>;
    FConnection: TTConnection;
    FContext: TTHttpContext;
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TAPIContext.Create;
begin
  inherited Create;
  // Tenant name would come from the request
  // (set during authentication, for example)
  FTenant := TTMultiTenant<TMyTenantConfig>.Instance.GetOrAdd(FTenantName);
  FConnection := FTenant.Connection.CreateConnection;
  FContext := TTHttpContext.Create(FConnection);
end;
```

### Putting the tenant in the log

`TTHttpUser` carries a writable `Tenant`, and `TTHttpLogUser` copies it into the
response log line as `"Tenant"`. Nothing fills it for you: write it where you
already write `Username` and the areas, which is the `Check` of your
authentication class, and in the constructor of your base controller for the
anonymous routes.

It matters more than it looks. After an incident on an installation with one
database per tenant, the log says *who*, *what* and *when*, and without this it
does not say **on which database**. The only correlation left is `Host`, which
works for whoever separates tenants by subdomain and for nobody else - and the
two ways this page recommends, a header and a JWT claim, leave no trace at all.
A thread variable cannot stand in for it either: `LogRequest` and `LogResponse`
enqueue, and the writer runs on the log thread pool.

## One Secret Per Tenant

Whatever carries the tenant name -- header, subdomain, URI -- it arrives from the
client, and the context is built **before** the request is authenticated: the
listener calls `C.Create` and only then the authentication class. So the tenant
that will serve the request is chosen from something nobody has verified yet.

With one signing secret shared by every tenant, that is a hole. A user of tenant
`acme` sends their own valid token with the header changed to `globex`: the token
verifies, because the secret is the same, and the request runs against another
customer's database with that user's privileges.

Give each tenant its own secret and the hole closes by itself, with no comparison
to write and no ordering to fix. The unverified tenant name no longer decides who
you are: it only decides **which key you are verified against**, and a token
signed for another tenant fails that check.

The secret does not have to be stored per tenant -- derive it:

```pascal
type
  TJWTPayload = class(TTHttpJWTHS256Payload)
  strict private
    FTenant: String;
  strict protected
    function GetSecret: String; override;
  public
    property Tenant: String read FTenant write FTenant;
  end;

function TJWTPayload.GetSecret: String;
begin
  result := THashSHA2.GetHMAC(FTenant, TConfig.Instance.Authentication.Secret);
end;
```

Set `Tenant` from the request before verifying the token, in your `Check`, and
set it the same way when you issue one. Derive with an HMAC rather than
concatenating the two strings, so that no pair of tenant names can produce the
same key.

!!! warning "With RS256, choose the key from the tenant, not from the `kid`"
    `GetVerificationKey(AKeyID)` receives the `kid` **read out of the token**,
    which is chosen by whoever sent the request. Returning the key that the
    `kid` names reopens the hole this section closes: a user of `acme` sends
    their own valid token, `kid` and all, with `X-Tenant: globex`, the
    signature verifies against `acme`'s public key, and the request runs on
    `globex`.

    Pick the key from the resolved tenant, exactly as `GetSecret` does above,
    and let the `kid` select only among **that tenant's** key versions. A `kid`
    that belongs to no key of that tenant is not an error to raise: return
    `nil`, which `Verify` already turns into `False`.

    The same applies to HS256 if you override `GetSecretFor(AKeyID)`: it
    receives that same untrusted `kid`. The example above is safe because the
    default override delegates to `GetSecret`, which derives from the tenant -
    an override that keys on the `kid` alone reopens the hole.

## Thread Safety

- `TTMultiTenant<T>` operations (`GetOrAdd`, `GetAll`, `Remove`) are protected by a multi-read exclusive-write lock
- `TTIdentityMap` is scoped to `TTContext`, not global — no cross-tenant cache collision
- The listener builds a new context `C` for each request and frees it afterwards, so what `C` creates - a `TTContext`, a connection - lives one request. This is isolation of **state**, not of authorization: nothing leaks between two requests, and which tenant a request ends up serving is decided by the name you resolve and by the key that name selects

## Key Points

- Tenant names are case-insensitive (stored as lowercase internally)
- `TTTenantConfig` is abstract — you must provide `GetConnectionName` and `GetParameters`
- The singleton is per-generic-type: `TTMultiTenant<TConfigA>` and `TTMultiTenant<TConfigB>` are separate instances
- Connection registration runs on the first `GetOrAdd` of a tenant, on every thread racing on it
