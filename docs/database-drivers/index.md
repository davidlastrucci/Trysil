---
title: Database Drivers
---

# Database Drivers

Trysil supports seven relational databases. All drivers use **FireDAC** internally for database connectivity.

## Supported Databases

| Database | Connection Class | Unit | Delphi Edition |
|---|---|---|---|
| SQLite | `TTSQLiteConnection` | `Trysil.Data.FireDAC.SQLite` | Community |
| InterBase | `TTInterBaseConnection` | `Trysil.Data.FireDAC.InterBase` | Community |
| PostgreSQL | `TTPostgreSQLConnection` | `Trysil.Data.FireDAC.PostgreSQL` | Community (localhost) / Enterprise (server) |
| Firebird | `TTFirebirdSQLConnection` | `Trysil.Data.FireDAC.FirebirdSQL` | Community (localhost/embedded) / Enterprise (server) |
| MariaDB | `TTMariaDBConnection` | `Trysil.Data.FireDAC.MariaDB` | Community (localhost/embedded) / Enterprise (server) |
| SQL Server | `TTSqlServerConnection` | `Trysil.Data.FireDAC.SqlServer` | Enterprise |
| Oracle | `TTOracleConnection` | `Trysil.Data.FireDAC.Oracle` | Enterprise |

!!! note "Edition matrix (FireDAC)"
    Driver availability follows the FireDAC edition matrix. **Professional / Community** provides local/embedded connectivity: SQLite, InterBase, plus *localhost-only* access to PostgreSQL, MySQL/MariaDB and Firebird. Full client/server connectivity — and **SQL Server** and **Oracle** in any form — requires the **Enterprise** or **Architect** edition. Building the `Trysil.SqlServer` and `Trysil.Oracle` packages also requires Enterprise/Architect, since their FireDAC driver units ship only with those editions.

## Connection Pattern

Every driver follows the same two-step pattern:

1. **Register** the connection definition (class method, called once at startup).
2. **Create** connection instances as needed.

```pascal
// Step 1: Register (once, at application startup)
TTSQLiteConnection.RegisterConnection('Main', 'database.db');

// Step 2: Create (as many times as needed)
LConnection := TTSQLiteConnection.Create('Main');
try
  LContext := TTContext.Create(LConnection);
  try
    // Use the context...
  finally
    LContext.Free;
  end;
finally
  LConnection.Free;
end;
```

The connection name (`'Main'` in the example) is a logical identifier. You can register multiple connections with different names to connect to different databases simultaneously.

## Connection Pooling

Connection pooling is managed by FireDAC through a global singleton:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

// Enable pooling (recommended for server applications)
TTFireDACConnectionPool.Instance.Config.Enabled := True;

// Disable pooling (suitable for desktop applications)
TTFireDACConnectionPool.Instance.Config.Enabled := False;
```

When pooling is enabled, calling `Create` on a connection class borrows a connection from the pool instead of opening a new one. The connection is returned to the pool when freed.

## Update Mode

`TTUpdateMode` controls the WHERE clause generated for UPDATE and DELETE statements:

| Mode | WHERE Clause | Use Case |
|---|---|---|
| `KeyAndVersionColumn` | Primary key + version column | Default. Enables optimistic locking. |
| `KeyOnly` | Primary key only | Tables without a `[TVersionColumn]` field. |

```pascal
LConnection := TTSQLiteConnection.Create('Main');
LConnection.UpdateMode := TTUpdateMode.KeyOnly;
```

With `KeyAndVersionColumn` (the default), an UPDATE includes the current version in the WHERE clause. If another transaction has modified the row, the version will not match and `ETConcurrentUpdateException` is raised.

## SQL Syntax Generation

Database-specific SQL (pagination, sequences, identity columns) is auto-generated per database engine via `TTSyntaxClasses` -- a pluggable strategy pattern. Each driver registers its own syntax classes at startup.

The SQL syntax implementations live in the `Trysil/Data/SqlSyntax/` directory:

| Database | Syntax Unit |
|---|---|
| SQLite | `Trysil.Data.SqlSyntax.SQLite` |
| SQL Server | `Trysil.Data.SqlSyntax.SqlServer` |
| PostgreSQL | `Trysil.Data.SqlSyntax.PostgreSQL` |
| Firebird | `Trysil.Data.SqlSyntax.FirebirdSQL` |
| InterBase | `Trysil.Data.SqlSyntax.InterBase` |
| MariaDB | `Trysil.Data.SqlSyntax.MariaDB` |
| Oracle | `Trysil.Data.SqlSyntax.Oracle` |

You do not need to interact with these units directly. The correct syntax is selected automatically based on the connection class you use.

## Connection Hierarchy

All connection classes inherit from `TTConnection` (defined in `Trysil.Data.pas`), which declares the full contract: transaction management, `CreateReader`, `CreateInsertCommand`, `CreateUpdateCommand`, `CreateDeleteCommand`, `GetSequenceID`, `SelectCount`, and `CheckRelations`.

`TTGenericConnection` (defined in `Trysil.Data.Connection.pas`) extends `TTConnection` and adds:

- A UUID-based `ConnectionID` for log correlation across threads.
- `TTSyntaxClasses` -- the pluggable SQL-generation strategy.

All seven FireDAC drivers extend `TTGenericConnection`.
