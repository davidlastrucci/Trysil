---
title: SQLite
---

# SQLite

SQLite is a lightweight, file-based database engine. It requires no server setup and is ideal for prototyping, embedded applications, testing, and single-user desktop apps.

**Unit:** `Trysil.Data.FireDAC.SQLite`
**Delphi Edition:** Community

## Setup

```pascal
uses
  Trysil.Data.FireDAC.SQLite,
  Trysil.Data.FireDAC.ConnectionPool;

// Disable pooling for desktop apps (optional)
TTFireDACConnectionPool.Instance.Config.Enabled := False;

// Register connection
TTSQLiteConnection.RegisterConnection('Main', 'database.db');

// Create connection
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

The database file path can be absolute or relative. If the file does not exist, SQLite creates it automatically.

## Sequences

SQLite has no sequences. `CreateEntity<T>` reads the highest key in the table and adds one (`SELECT IFNULL(MAX([ID]), 0) + 1 FROM [Persons]`), or one past the last key it handed out on this connection name if that is higher: the `[TSequence]` attribute is still required on the entity, but its name is not used, and two processes writing the same file can still get the same key.

```pascal
[TTable('Persons')]
[TSequence('Persons')]
type
  TPerson = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;
    // ...
  end;
```

## Schema Example

```sql
CREATE TABLE Persons (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Firstname TEXT NOT NULL,
  Lastname TEXT NOT NULL,
  VersionID INTEGER NOT NULL DEFAULT 1
);
```

## Good For

- **Prototyping** -- zero configuration, no server required.
- **Embedded apps** -- single-file database ships with the application.
- **Testing** -- in-memory databases (`:memory:`) for fast integration tests.
- **Single-user desktop apps** -- no concurrent write contention.

## Limitations

- Not suitable for high-concurrency server applications (SQLite uses file-level locking).
- No built-in user authentication or access control.
- Limited ALTER TABLE support compared to server databases.
- No decimal column type. A `DECIMAL(19,4)` column mapped to a `Currency` field gets NUMERIC affinity, but the value is stored as a float, so exactness is bounded by what a double can hold. Every other engine stores it as a true decimal.
