---
title: Database Drivers
---

# Database Drivers

Trysil supports seven relational databases. All drivers use **FireDAC** internally for database connectivity.

!!! note "All seven are exercised by the test suite"
    The suite runs the same set of abstract tests against every engine, and the
    2.0.0 release was validated with all seven turned on. Which ones run on a
    given machine is a matter of configuration - each has to be enabled and
    given credentials - so a green run on one engine says nothing about the
    others, and the release runs are done with all of them on.

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

// Pooling is on by default: this is what you get without saying anything
TTFireDACConnectionPool.Instance.Config.Enabled := True;

// Turn it off for a desktop application that holds one connection open
TTFireDACConnectionPool.Instance.Config.Enabled := False;
```

Pooling is **enabled by default**, because the shape that suffers most from it being off is the one Trysil is written for: an HTTP server builds a context per request, a context that opens a connection in its constructor opens one per request, and without a pool that is a TCP connection and an authentication handshake per request. A desktop application that keeps a single connection for its whole life gains nothing from the pool and can turn it off.

When pooling is enabled, calling `Create` on a connection class borrows a connection from the pool instead of opening a new one. The connection is returned to the pool when freed - which also means that freeing it does not close it: the physical connection stays open until the pool expires it or the pool itself is closed. On a file database like SQLite that is the difference between the file being released at once and being released later.

!!! warning "Configure pooling before registering the connection"
    `Config` is read when a connection is **registered**, not when one is opened: `RegisterConnection` bakes the pool settings into the FireDAC connection definition. Changing `Config` afterwards applies to connections registered from that point on, and never to a definition that already exists.

    In a single-database application every registration happens at start-up, so `Config` must be set before the first `RegisterConnection` or it will do nothing at all. Putting it in a per-request context constructor - which runs after start-up - is the common mistake.

    In a multi-tenant application, where `TTTenantConnection` registers each tenant lazily on first use, a later change is honoured for every tenant registered after it. Set it at start-up anyway, so that all tenants get the same treatment.

### Per-connection pool parameters

`Config` is the **default**, applied to every connection definition that does not declare its own. An application that hosts databases with different load profiles -- an application database fed by N request threads and a log database fed by one -- needs different limits per definition.

Pool parameters therefore travel inside `TTFireDACConnectionParameters`, the record you already build to register a connection:

```pascal
LParameters := Default(TTFireDACConnectionParameters);
LParameters.Driver := 'SQLite';
LParameters.DatabaseName := 'log.db';
LParameters.PoolParameters := TTFireDACPoolParameters.Create(True, 2);

TTFireDACConnectionFactory.Instance.RegisterConnection('Log', LParameters);
```

`TTFireDACPoolParameters` is immutable and assigned whole. The two-argument constructor takes the FireDAC defaults for the timeouts; a four-argument overload sets them explicitly.

`IsAssigned` separates "I said nothing, use the global `Config`" from "I decided". `Create(False, 1)` therefore **disables** pooling for that one connection rather than letting it inherit the global setting.

The driver-level `RegisterConnection` overloads that take a `TStrings` do not go through the record and keep using the global `Config`.

!!! warning "Zero the record"
    A **local** record variable in Delphi only initialises its managed fields: strings yes, integers and booleans no. Without `Default(...)`, `PoolParameters.IsAssigned` can come out `True` by accident and the connection picks up garbage pool settings.

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

## Sequences and the 32-bit Ceiling

`TTPrimaryKey` is `Int32`, so the largest identifier Trysil can hold is
2147483647. A sequence is a 64-bit object on most engines and will happily walk
past that number, and what comes back then does not fit.

Trysil reads the value as `Int64` and raises if it is out of range, naming the
table and the value. That is the last line of defence, and it fires after the
sequence has already been consumed. **Declare the ceiling in the sequence
itself** wherever the engine allows it, so the database refuses the value at the
source:

| Engine | Declaration | What happens at the ceiling |
|---|---|---|
| SQL Server | `CREATE SEQUENCE ... AS int` | error 11728, the insert is refused |
| PostgreSQL | `CREATE SEQUENCE ... AS integer` | `nextval: reached maximum value` |
| MariaDB | `MAXVALUE 2147483647` | error, `NOCYCLE` is the default |
| Oracle | `... MAXVALUE 2147483647` | ORA-08004, `NOCYCLE` is the default |
| Firebird | not available, generators are 64-bit | only the Trysil guard |
| InterBase | not available, generators are 64-bit | only the Trysil guard |
| SQLite | no sequence object at all | only the Trysil guard |

`AS int` works on MariaDB too, but only from 11.5: on 10.3 to 11.4 - and 11.4 is the current LTS - it is a syntax error, so `MAXVALUE` is the form to reach for. Trysil supports MariaDB from 10.3, which is where native sequences arrive.

Do not add `CYCLE` to buy yourself room. It restarts from the minimum, which for
`AS int` is -2147483648, and the database then serves you negative identifiers
that are perfectly unique - which is exactly the failure the ceiling exists to
prevent.

!!! warning "What the ceiling protects you from"
    Without it, the value comes back truncated to its low 32 bits read as
    signed: after 2147483647 the next identifier is **-2147483648**, and it
    counts up from there. Negative identifiers are unique, so the primary key
    raises no objection and the rows are written. The damage is silent for
    another 2.1 billion rows, until the sequence reaches zero - which `Insert<T>`
    refuses since 2.0.0 - and then re-enters the positive range, where every
    identifier collides with one already in the table.

On an engine where the ceiling cannot be declared, an application that expects to
live that long should read the current value of its sequences at startup and warn
well before the limit.

## Connection Hierarchy

All connection classes inherit from `TTConnection` (defined in `Trysil.Data.pas`), which declares the full contract: transaction management, `CreateReader`, `CreateInsertCommand`, `CreateUpdateCommand`, `CreateSoftDeleteCommand`, `CreateUndeleteCommand`, `CreateDeleteCommand`, `GetSequenceID`, `SelectCount`, and `CheckRelations`. `CreateUndeleteCommand` is `virtual` with a body that raises, not `abstract`: a driver written before 2.0.0 still compiles, and only an `Undelete<T>` on it fails, at runtime, saying which method is missing.

`TTGenericConnection` (defined in `Trysil.Data.Connection.pas`) extends `TTConnection` and adds:

- A UUID-based `ConnectionID` for log correlation across threads.
- `TTSyntaxClasses` -- the pluggable SQL-generation strategy.

All seven FireDAC drivers extend `TTGenericConnection`.

!!! warning "A driver implements the transaction methods, it does not override them"
    From 2.0.0 `TTGenericConnection` owns the order of a transaction: it checks
    the state, logs, runs the physical operation, and only then notifies the
    observer that keeps the new-entity cache honest. The physical part is
    yours, in three `strict protected` abstract methods:

    ```pascal
    procedure InternalStartTransaction; override;
    procedure InternalCommitTransaction; override;
    procedure InternalRollbackTransaction; override;
    ```

    Do **not** override `StartTransaction`, `CommitTransaction` or
    `RollbackTransaction`: a driver that does keeps compiling and keeps being
    called, but never reaches the `Internal*` methods, so the observer is never
    notified and nothing warns you. Leaving the three unimplemented does not
    fail the build either - it is `W1020` where the driver is constructed and
    `EAbstractError` at the first transaction.

!!! warning "A custom `TTParam` gained three methods in 2.0.0"
    `TTParam` (in `Trysil.Data.pas`) is the parameter contract, and a driver
    written outside this repository brings its own descendant of it. Three
    `virtual abstract` methods were added to it in this release:

    ```pascal
    function GetDataType: TFieldType; override;
    function GetAsCurrency: Currency; override;
    procedure SetAsCurrency(const Value: Currency); override;
    ```

    A descendant that does not implement them **still compiles**: it is
    `W1020` where it is constructed and `EAbstractError` in production. The
    first two are the obvious ones, on a `Currency` column. `GetDataType` is
    the insidious one, because it is not read only for `Currency`:
    `TTGuidParameter` reads it on every `TGuid` parameter, and the string
    parameter reads it on **every string** to decide whether the column is a
    text LOB. A driver with neither a money column nor a Guid anywhere still
    fails on the first write of almost any entity.

    A fourth method was added beside them, `SetAsText`, and that one is
    **`virtual` with a body**: it calls `SetAsString`, so a descendant that
    ignores it behaves exactly as it did. Override it if your engine needs a
    text LOB bound as a LOB rather than as a string - the FireDAC driver does,
    because an Oracle `VARCHAR2` bind stops at 4000 bytes.
