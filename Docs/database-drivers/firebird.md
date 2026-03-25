---
title: Firebird
---

# Firebird

Firebird is an open-source relational database with a small footprint, well-suited for embedded and server deployments.

**Unit:** `Trysil.Data.FireDAC.FirebirdSQL`
**Delphi Edition:** Community

## Setup

```pascal
uses
  Trysil.Data.FireDAC.FirebirdSQL;

TTFirebirdConnection.RegisterConnection(
  'Main', 'localhost', 'SYSDBA', 'masterkey', '/path/to/database.fdb');

LConnection := TTFirebirdConnection.Create('Main');
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

Firebird uses database sequences (generators) for primary key generation:

```sql
CREATE SEQUENCE PersonsID;
```

The sequence value is retrieved using `NEXT VALUE FOR`:

```sql
SELECT NEXT VALUE FOR PersonsID FROM RDB$DATABASE;
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
  ID INTEGER NOT NULL,
  Firstname VARCHAR(100) NOT NULL,
  Lastname VARCHAR(100) NOT NULL,
  VersionID INTEGER NOT NULL DEFAULT 1,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID;
```
