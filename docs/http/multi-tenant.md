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

The `Create` constructor receives the tenant name. `GetConnectionName` must return a unique FireDAC connection name. `GetParameters` provides the database connection details.

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

`GetOrAdd` is thread-safe. If the tenant does not exist, it is created atomically: the configuration is read outside the write lock, and only the thread that wins the race registers the connection.

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

`Remove` means "forget the cache", not "revoke the customer": the FireDAC connection definition stays registered, and a `GetOrAdd` on the same name afterwards rebuilds the tenant rather than failing. Registering a definition that already exists **unchanged is a no-op** - it is not replaced - so the name never burns and nothing is torn down under a request thread. Registering a *different* definition under a name already in use still raises, as it always did: the name is the identity, and silently swapping the database behind it would turn a configuration mistake into a runtime one.

"Unchanged" is compared on the **exact text** of the parameter lines Trysil passed - `DriverID` first, then the ones your `TTTenantConfig` produced - sorted and matched byte for byte, values and parameter names alike. Two lists that FireDAC would consider the same definition but that differ in the case of a key, or in the spacing around the `=`, count as a conflict. Build the list the same way on every call and this never comes up; build it from user-facing text and it will.

Revoking a customer for real would mean closing the pool and deregistering the connection, which needs a use count on the borrowed references: that is design, and it is not what `Remove` does today.

### Deregistering a connection

`TTFireDACConnection.UnregisterConnection(AName)` is the other half, and it is a hard teardown, not the inverse of a cache miss. It closes **every open connection** on that definition, destroys the physical connection host and its pool, and only then deletes the definition.

That is what makes it the way to replace a definition - registration refuses to overwrite one, so `UnregisterConnection` followed by `RegisterConnection` is the sequence - but it is also why it must not run with requests in flight on that name. A `TTConnection` another thread resolved an instant earlier keeps its object, and loses the FireDAC connection underneath it: the next statement on it raises. Quiesce the tenant first, the same way you would before any other destructive maintenance.

## Integration with HTTP Server

In a typical multi-tenant REST API, resolve the tenant from the request (e.g., from a header, subdomain, or JWT claim) in your per-request context:

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

## Thread Safety

- `TTMultiTenant<T>` operations (`GetOrAdd`, `GetAll`, `Remove`) are protected by a critical section
- `TTIdentityMap` is scoped to `TTContext`, not global — no cross-tenant cache collision
- Each request creates its own `TTContext` with its own connection — full tenant isolation

## Key Points

- Tenant names are case-insensitive (stored as lowercase internally)
- `TTTenantConfig` is abstract — you must provide `GetConnectionName` and `GetParameters`
- The singleton is per-generic-type: `TTMultiTenant<TConfigA>` and `TTMultiTenant<TConfigB>` are separate instances
- Connection registration happens once per tenant, on first `GetOrAdd`
