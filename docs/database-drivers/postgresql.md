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

## Data Types

`Currency` columns need one adjustment, which the driver makes for you.
FireDAC sends a currency parameter as PostgreSQL `money`, and `money` keeps only
the fraction digits of the server's `lc_monetary` - two in the common case - so
an amount on its way into a `DECIMAL(19,4)` column would be rounded by the type
it travelled in, silently. `TTPostgreSQLConnection.ConfigureMapRules` declares
BCD and currency interchangeable on the connection, so the parameter is sent as
`numeric`:

```pascal
AConnection.FormatOptions.OwnMapRules := True;
AConnection.FormatOptions.MapRules.Add(dtBCD, dtCurrency);
```

Nothing changes on the read side, and nothing is required of application code.

To configure the connection yourself, override **`DoConfigureConnection`**,
which the framework calls after the rules of the driver are in place and which
is empty in every driver of this repository. It is deliberately not the same
method: until 2.0.0 the hook was `ConfigureConnection`, and a descendant that
overrode it without calling `inherited` lost this rule with no error and no
warning - only an amount rounded to two decimals. `ConfigureConnection` is no
longer virtual, so that override does not compile any more.

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
