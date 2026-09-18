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

## Booleans

Oracle has no `BOOLEAN` column type before 23ai. A `Boolean` member is mapped to
`NUMBER(1)`, and the driver declares that mapping to FireDAC, so the same schema
works from 12c to 23ai.

```sql
IsActive NUMBER(1) NOT NULL
```

The rule is keyed on precision and scale, not on the column name: **every**
`NUMBER(1)` on an Oracle connection is read as a boolean. A column of that width
holding a small number - a status code, a count - must be widened to `NUMBER(2)`
to keep coming back as an integer.

## Text LOBs

A `CLOB` maps to a plain `String` member and is bound as a LOB, so a value longer than the 4000 bytes an Oracle `VARCHAR2` bind accepts travels whole. Before 2.0.0 Oracle reported the column as `ftOraClob`, which was not registered at all among the parameter types: an entity mapping a `CLOB` could not be written.

## Configuring the connection

These rules live in `TTOracleConnection.ConfigureMapRules`. To configure the
connection yourself, override **`DoConfigureConnection`**, which the framework
calls after them and which is empty in every driver of this repository:
`ConfigureConnection` is no longer virtual, so a descendant cannot replace the
rules by forgetting `inherited` - which used to cost a `NUMBER(1)` read back
as a number, with no error anywhere.

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
