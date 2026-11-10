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

SQLite has no sequences. Trysil keeps a counter for each connection name and table, for as long as the application runs, and registering the same name on another file does not reset it. The first time a connection reads entities from the table, counts its rows or writes to it, it reads the highest key (`SELECT IFNULL(MAX([ID]), 0) + 1 FROM [Persons]`). From then on `CreateEntity<T>` hands out the higher of that query and one past the last key it gave, so a key deleted while the application runs is never handed out again. The `[TSequence]` attribute is still required on the entity, but its name is not used.

!!! tip "One application per database file"
    Without a real sequence a key can only be worked out from the rows already saved, so two applications writing the same file at the same time can give the same key to two new rows. SQLite also locks the whole file on every write. Use SQLite for a database that belongs to one application; when several applications or users write the same data, use a server database.

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
