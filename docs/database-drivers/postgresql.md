---
title: PostgreSQL
---

# PostgreSQL

PostgreSQL is a powerful, open-source relational database system with strong standards compliance and extensibility.

**Unit:** `Trysil.Data.FireDAC.PostgreSQL`
**Delphi Edition:** Community

## Setup

```pascal
uses
  Trysil.Data.FireDAC.PostgreSQL;

TTPostgreSQLConnection.RegisterConnection(
  'Main', 'localhost', 'Username', 'Password', 'DatabaseName');

LConnection := TTPostgreSQLConnection.Create('Main');
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

PostgreSQL uses database sequences for primary key generation:

```sql
CREATE SEQUENCE PersonsID
  START WITH 1
  INCREMENT BY 1;
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

CREATE SEQUENCE PersonsID
  START WITH 1
  INCREMENT BY 1;
```
