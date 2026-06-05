---
title: Oracle
---

# Oracle

Oracle Database is a widely-deployed enterprise relational database. Trysil's Oracle driver uses sequences and `OFFSET/FETCH` pagination (Oracle 12c or later).

**Unit:** `Trysil.Data.FireDAC.Oracle`
**Delphi Edition:** Enterprise / Architect

!!! note
    FireDAC's Oracle driver is available only in the **Enterprise** and **Architect** editions of Delphi — this applies both to building the `Trysil.Oracle` package and to connecting at runtime. The Oracle client (OCI / Instant Client) must also be available at runtime.

## Setup

The connection uses an EZConnect descriptor (`//host:port/service`) built from the supplied parameters:

```pascal
uses
  Trysil.Data.FireDAC.Oracle;

// Default port (1521)
TTOracleConnection.RegisterConnection(
  'Main', 'localhost', 'user', 'password', 'ORCLPDB1');

// Explicit port
TTOracleConnection.RegisterConnection(
  'Main', 'localhost', 1521, 'user', 'password', 'ORCLPDB1');

LConnection := TTOracleConnection.Create('Main');
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

The last parameter is the Oracle **service name**.

## Connection Pooling

Enable connection pooling for server applications:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

TTFireDACConnectionPool.Instance.Config.Enabled := True;
```

## Sequences

Oracle uses sequences for primary key generation:

```sql
CREATE SEQUENCE PersonsID START WITH 1;
```

The sequence value is retrieved using `NEXTVAL`:

```sql
SELECT PersonsID.NEXTVAL FROM DUAL;
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
  ID NUMBER(10) NOT NULL,
  Firstname VARCHAR2(100) NOT NULL,
  Lastname VARCHAR2(100) NOT NULL,
  VersionID NUMBER(10) NOT NULL,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID START WITH 1;
```
