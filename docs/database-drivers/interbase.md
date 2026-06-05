---
title: InterBase
---

# InterBase

InterBase is Embarcadero's lightweight, embeddable SQL database. Trysil's InterBase driver shares the same SQL idioms as Firebird (generators and `FIRST/SKIP` pagination).

**Unit:** `Trysil.Data.FireDAC.InterBase`
**Delphi Edition:** Community

## Setup

```pascal
uses
  Trysil.Data.FireDAC.InterBase;

TTInterBaseConnection.RegisterConnection(
  'Main', 'localhost', 'SYSDBA', 'masterkey', 'C:\data\database.ib');

LConnection := TTInterBaseConnection.Create('Main');
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

InterBase uses generators (sequences) for primary key generation:

```sql
CREATE SEQUENCE PersonsID;
```

The sequence value is retrieved using `GEN_ID`:

```sql
SELECT GEN_ID(PersonsID, 1) FROM RDB$DATABASE;
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
  VersionID INTEGER NOT NULL,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID;
```
