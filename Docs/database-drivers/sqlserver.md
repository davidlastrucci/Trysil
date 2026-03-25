---
title: SQL Server
---

# SQL Server

Microsoft SQL Server is a full-featured relational database for enterprise applications.

**Unit:** `Trysil.Data.FireDAC.SqlServer`
**Delphi Edition:** Enterprise

!!! warning
    The SQL Server driver requires the **Enterprise** edition of Delphi. It is not available in the Community edition.

## Setup

### OS Authentication (Windows)

```pascal
uses
  Trysil.Data.FireDAC.SqlServer;

TTSqlServerConnection.RegisterConnection('Main', 'ServerName', 'DatabaseName');

LConnection := TTSqlServerConnection.Create('Main');
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

### Database Authentication (SQL Login)

```pascal
TTSqlServerConnection.RegisterConnection(
  'Main', 'ServerName', 'Username', 'Password', 'DatabaseName');

LConnection := TTSqlServerConnection.Create('Main');
```

## Connection Pooling

Connection pooling is recommended for server applications to avoid the overhead of opening and closing connections on every request:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

TTFireDACConnectionPool.Instance.Config.Enabled := True;
```

## Sequences

SQL Server uses database sequences for primary key generation. Create the sequence in your database schema:

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
  Firstname NVARCHAR(100) NOT NULL,
  Lastname NVARCHAR(100) NOT NULL,
  VersionID INTEGER NOT NULL DEFAULT 1,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);

CREATE SEQUENCE PersonsID
  START WITH 1
  INCREMENT BY 1;
```
