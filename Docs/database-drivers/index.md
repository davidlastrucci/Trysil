---
title: Database Drivers
---

# Database Drivers

Trysil supports four relational databases. All drivers use **FireDAC** internally for database connectivity.

## Supported Databases

| Database | Connection Class | Unit | Delphi Edition |
|---|---|---|---|
| SQLite | `TTSQLiteConnection` | `Trysil.Data.FireDAC.SQLite` | Community |
| SQL Server | `TTSqlServerConnection` | `Trysil.Data.FireDAC.SqlServer` | Enterprise |
| PostgreSQL | `TTPostgreSQLConnection` | `Trysil.Data.FireDAC.PostgreSQL` | Community |
| Firebird | `TTFirebirdConnection` | `Trysil.Data.FireDAC.FirebirdSQL` | Community |

!!! note
    SQL Server support requires the **Enterprise** edition of Delphi. All other databases work with the Community edition.

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

You do not need to interact with these units directly. The correct syntax is selected automatically based on the connection class you use.

## Connection Hierarchy

All connection classes inherit from `TTConnection` (defined in `Trysil.Data.pas`), which declares the full contract: transaction management, `CreateReader`, `CreateInsertCommand`, `CreateUpdateCommand`, `CreateDeleteCommand`, `GetSequenceID`, `SelectCount`, and `CheckRelations`.

`TTGenericConnection` (defined in `Trysil.Data.Connection.pas`) extends `TTConnection` and adds:

- A UUID-based `ConnectionID` for log correlation across threads.
- `TTSyntaxClasses` -- the pluggable SQL-generation strategy.

All four FireDAC drivers extend `TTGenericConnection`.
