---
title: Firebird
---

# Firebird

Firebird is an open-source relational database with a small footprint, well-suited for embedded and server deployments.

**Unit:** `Trysil.Data.FireDAC.FirebirdSQL`
**Delphi Edition:** Community

## Character set

A database created with a Unicode default character set - `UTF8`, or `UNICODE_FSS` on older files - must be told to the connection:

```pascal
TTFirebirdSQLConnection.RegisterConnection(
  'Main', 'localhost', 'SYSDBA', 'masterkey', 'C:\data\database.fdb', 'UTF8');
```

Without it the connection opens with no character set, and the server stops transliterating. Two things follow, and both are quiet. Text travels as raw bytes in each direction, so anything outside ASCII comes back changed. And the server stops counting **characters** in a `VARCHAR(n)`, counting the bytes behind it instead: a column declared for 100 characters accepts 300 ASCII ones on a UTF8 database, and the column metadata Trysil reads reports that width too, so the guard that refuses a string longer than its column has nothing to refuse.

The parameter is optional and defaults to the previous behaviour, so an application that has been storing raw bytes keeps reading them back the same way. Declare it on a new database, or after checking what is really stored in an old one - `SELECT RDB$CHARACTER_SET_NAME FROM RDB$DATABASE` says what the database was created with.

## Setup

```pascal
uses
  Trysil.Data.FireDAC.FirebirdSQL;

TTFirebirdSQLConnection.RegisterConnection(
  'Main', 'localhost', 'SYSDBA', 'masterkey', '/path/to/database.fdb');

LConnection := TTFirebirdSQLConnection.Create('Main');
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

Pooling is on by default. A desktop application holding a single connection can turn it off:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

TTFireDACConnectionPool.Instance.Config.Enabled := False;
```

## Sequences

Firebird uses database sequences (generators) for primary key generation:

```sql
CREATE SEQUENCE PersonsID;
```

The sequence value is retrieved using `GEN_ID`:

```sql
SELECT GEN_ID("PERSONSID", 1) ID FROM RDB$DATABASE;
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

## Type notes

- **Money** (`Currency`): `DECIMAL(18,4)`. Firebird 3 caps numeric precision at 18 digits, so the `DECIMAL(19,4)` used on most other engines is rejected (Firebird 4 raises the cap to 38). 18 digits still cover any realistic amount.

## Schema Example

```sql
CREATE TABLE Persons (
  ID INTEGER NOT NULL,
  Firstname VARCHAR(100) NOT NULL,
  Lastname VARCHAR(100) NOT NULL,
  VersionID INTEGER NOT NULL DEFAULT 1,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID;
```
