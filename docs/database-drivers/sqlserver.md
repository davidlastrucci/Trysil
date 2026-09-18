---
title: SQL Server
---

# SQL Server

Microsoft SQL Server is a full-featured relational database for enterprise applications. Trysil targets **SQL Server 2012 or later**: both `SELECT NEXT VALUE FOR` for the sequences and `OFFSET n ROWS FETCH FIRST m ROWS ONLY` for the paging were introduced in that version, so on 2008 R2 the first insert fails.

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

## Encryption

Trysil says nothing about encryption unless you ask it to, so the ODBC driver
applies its own default: Driver 18 encrypts, Driver 17 and older do not, so on
a machine where Driver 18 is installed the default in force is `Encrypt=Yes`. Until
2.0.0 Trysil wrote `Encrypt=No` on every connection, which cancelled Driver
18's default and left the traffic between application server and database in
clear with no way to opt out.

Which generation is in use is not Trysil's decision either. FireDAC picks the
ODBC driver through `TFDPhysMSSQLDriverLink.ODBCDriver`, which Trysil never
sets: the setter is there, on `TTSqlServerConnection.Driver`, and nothing in
the library calls it. Read the machine's installed drivers before assuming
which default applies.

To decide instead of the driver, set it before registering the connection:

```pascal
uses
  Trysil.Data.FireDAC.SqlServer;

TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.Yes;

TTSqlServerConnection.RegisterConnection(
  'Main', 'ServerName', 'UserName', 'Password', 'DatabaseName');
```

| `TTSqlServerEncrypt` | Emitted | Meaning |
|---|---|---|
| `DriverDefault` | nothing | The ODBC driver decides. The default |
| `Yes` | `Encrypt=Yes` | Encryption required |
| `No` | `Encrypt=No` | Encryption off, explicitly |

Both values are read when a connection is registered, and `Encrypt` does not
overwrite a parameter the caller already wrote: if the `TStrings` you pass to
`RegisterConnection` already carries `Encrypt`, that is what is used, and the
process-wide value is ignored for that connection. The lookup is by name and
case-insensitive, so `encrypt=` counts too.

They are one setting for the process, not one per connection: a host that
connects to several SQL Servers applies the same choice to all of them. Set them
at start-up, before the first registration - including in a multi-tenant host,
where registrations keep happening at runtime, one per tenant on its first
request, on a request thread.

| `TTSqlServerTrustServerCertificate` | Emitted | Meaning |
|---|---|---|
| `DriverDefault` | nothing | The ODBC driver decides. The default |
| `Yes` | `ODBCAdvanced=TrustServerCertificate=yes` | The certificate is not validated |
| `No` | `ODBCAdvanced=TrustServerCertificate=no` | The certificate is validated, explicitly |

!!! warning "Encrypt=Yes needs a certificate the client trusts"
    Requiring encryption against a **self-signed** certificate fails
    validation, which is the reason `Encrypt=No` was hardcoded in the first
    place. `TrustServerCertificate=yes` waives the check, and it is not an
    ODBC keyword FireDAC knows: the connection string is built from a closed
    list of keywords per driver, `TrustServerCertificate` is not in the MSSQL
    one, and the string does not appear anywhere in the FireDAC sources. A
    parameter outside that list is dropped **without an error**, so writing it
    as a plain connection parameter does nothing at all.

    What reaches the driver is `ODBCAdvanced`, which FireDAC appends to the
    connection string verbatim, outside the keyword filter. That is what the
    tri-state emits, and it is the one setting here that **appends** instead of
    yielding: `ODBCAdvanced` is a single string carrying many settings, so if
    the `TStrings` you pass already has one, ours is joined to it with a `;`
    rather than skipped. Running the same registration twice does not append it
    twice.

    Setting `TTSqlServerConnection.Driver.ODBCAdvanced` works too, but only
    before the driver is loaded, which in practice means before the first
    connection is opened: the driver reads that value once, in `InternalLoad`.
    The per-connection value is read at every open and takes precedence.

## Connection Pooling

Connection pooling is recommended for server applications to avoid the overhead of opening and closing a connection for every context a request builds:

```pascal
uses
  Trysil.Data.FireDAC.ConnectionPool;

TTFireDACConnectionPool.Instance.Config.Enabled := True;
```

## Transactions

The driver never sends `BEGIN TRANSACTION`. `StartTransaction` turns the ODBC
autocommit attribute off, which on SQL Server means **implicit transactions**:
the server opens one on the first statement that follows, and `Commit` and
`Rollback` are the ODBC `SQLEndTran` call rather than statements of their own.

Two consequences worth knowing before you read a profiler trace or a
`@@TRANCOUNT` of your own:

- A `BEGIN TRANSACTION` you are looking for will not be there, and
  `SELECT @@TRANCOUNT` inside a Trysil transaction is itself a statement that
  can open the implicit transaction it then counts, so it is not a way to ask
  whether the previous statement left one open.
- `SQLEndTran` succeeds whether or not a transaction is open, so a rollback
  after the server has already ended the transaction - a deadlock victim, an
  error under `SET XACT_ABORT ON` - is not refused, and the connection is not
  left believing it is in a transaction it no longer has.

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
