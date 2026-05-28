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

`GetOrAdd` is thread-safe (uses a critical section). If the tenant does not exist, it is created atomically using double-checked locking.

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

### Remove a Tenant

```pascal
TTMultiTenant<TMyTenantConfig>.Instance.Remove('acme');
```

Removing a tenant frees its `TTTenant<T>` instance (and its config and connection) via the internal `TObjectList` with `OwnsObjects = True`.

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
