---
title: MariaDB
---

# MariaDB

MariaDB is an open-source, MySQL-compatible relational database. Trysil targets **MariaDB 10.3 or later**, which provides native sequences (`CREATE SEQUENCE` / `NEXTVAL`) — required because Trysil assigns the primary key from a sequence *before* the `INSERT`.

**Unit:** `Trysil.Data.FireDAC.MariaDB`
**Delphi Edition:** Community (localhost/embedded) · Enterprise/Architect for full client/server

!!! note
    The driver connects through FireDAC's MySQL driver (MariaDB is wire-compatible with the MySQL protocol). The MariaDB client library (`libmariadb.dll`) must be available at runtime. With the **Professional / Community** edition FireDAC connects to a **localhost** server (or embedded) only; connecting to a **remote** MariaDB server requires the **Enterprise** or **Architect** edition.

## Setup

```pascal
uses
  Trysil.Data.FireDAC.MariaDB;

// Default port (3306)
TTMariaDBConnection.RegisterConnection(
  'Main', 'localhost', 'user', 'password', 'mydb');

// Explicit port
TTMariaDBConnection.RegisterConnection(
  'Main', 'localhost', 3306, 'user', 'password', 'mydb');

LConnection := TTMariaDBConnection.Create('Main');
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

## Connection Pooling

Enable connection pooling for server applications:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

TTFireDACConnectionPool.Instance.Config.Enabled := True;
```

## Sequences

MariaDB 10.3+ supports native sequences:

```sql
CREATE SEQUENCE PersonsID START WITH 1;
```

The sequence value is retrieved using `NEXTVAL`:

```sql
SELECT NEXTVAL(PersonsID);
```

Map it to the entity:

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
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
  ID INT NOT NULL,
  Firstname VARCHAR(100) NOT NULL,
  Lastname VARCHAR(100) NOT NULL,
  VersionID INT NOT NULL,
  PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID START WITH 1;
```
