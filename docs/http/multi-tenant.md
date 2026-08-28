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
    // E.OriginalClassName says what failed underneath
end;
```

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

It does not deregister the FireDAC connection definition either, so re-adding the same name after a `Remove` raises a duplicate key.

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
