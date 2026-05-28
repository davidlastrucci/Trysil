---
title: Database Setup
---

# Database Setup

Trysil requires a specific schema structure to map entities correctly. This page covers the rules and provides working examples for each supported database.

## Schema Rules

Every table used with Trysil must follow these rules:

1. **Integer primary key** -- every table needs an `INTEGER` (or `INT`) primary key column. Trysil uses `TTPrimaryKey` which is `Int32`.

2. **Version column** -- every table should have an integer version column for optimistic locking. Trysil increments this value on every update and checks it before writing, preventing lost updates in concurrent scenarios.

3. **Sequence for ID generation** -- Trysil uses database sequences (or autoincrement in SQLite) to generate primary key values. The `[TSequence('...')]` attribute on the entity class tells Trysil which sequence to use.

## SQL Server

SQL Server uses named sequences for ID generation.

```sql
-- Create the sequence
CREATE SEQUENCE [dbo].[PersonsID] AS [int] START WITH 1 INCREMENT BY 1;

-- Create the table
CREATE TABLE [dbo].[Persons](
  [ID] [int] NOT NULL,
  [Firstname] [nvarchar](50) NULL,
  [Lastname] [nvarchar](50) NULL,
  [Email] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Persons] PRIMARY KEY CLUSTERED([ID] ASC)
);

-- Default constraints
ALTER TABLE [dbo].[Persons] ADD CONSTRAINT [DF_Persons_ID] DEFAULT ((0)) FOR [ID];
ALTER TABLE [dbo].[Persons] ADD CONSTRAINT [DF_Persons_VersionID] DEFAULT ((0)) FOR [VersionID];
```

The entity maps to this table with `[TSequence('PersonsID')]`. Before inserting, Trysil calls `NEXT VALUE FOR [dbo].[PersonsID]` to obtain the new ID.

## SQLite

SQLite uses `AUTOINCREMENT` instead of named sequences. Trysil handles this internally -- the `[TSequence]` attribute is still required on the entity but SQLite ignores the sequence name and uses its built-in autoincrement mechanism.

```sql
CREATE TABLE IF NOT EXISTS [Persons] (
  [ID] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  [Firstname] TEXT,
  [Lastname] TEXT,
  [Email] TEXT,
  [VersionID] INTEGER NOT NULL DEFAULT 0
);
```

## PostgreSQL

PostgreSQL uses named sequences similar to SQL Server.

```sql
-- Create the sequence
CREATE SEQUENCE PersonsID START WITH 1 INCREMENT BY 1;

-- Create the table
CREATE TABLE Persons (
  ID INTEGER NOT NULL DEFAULT nextval('PersonsID'),
  Firstname VARCHAR(50),
  Lastname VARCHAR(50),
  Email VARCHAR(255),
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (ID)
);
```

Trysil calls `nextval('PersonsID')` before inserting to obtain the new ID.

## Firebird

Firebird uses sequences (formerly called generators).

```sql
-- Create the sequence
CREATE SEQUENCE PersonsID;

-- Create the table
CREATE TABLE Persons (
  ID INTEGER NOT NULL,
  Firstname VARCHAR(50),
  Lastname VARCHAR(50),
  Email VARCHAR(255),
  VersionID INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT PK_Persons PRIMARY KEY (ID)
);
```

Trysil calls `NEXT VALUE FOR PersonsID` before inserting to obtain the new ID.

## Entity-to-Schema Mapping

The `[TSequence]` attribute on the entity class tells Trysil the name of the database sequence that generates primary key values:

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
TPerson = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
  // ...
end;
```

| Attribute | Maps to |
|---|---|
| `[TTable('Persons')]` | Table name |
| `[TSequence('PersonsID')]` | Sequence name for ID generation |
| `[TPrimaryKey]` + `[TColumn('ID')]` | Primary key column |
| `[TColumn('Firstname')]` | Regular column |
| `[TVersionColumn]` + `[TColumn('VersionID')]` | Version column for optimistic locking |

## Tables Without Version Columns

If you are working with a legacy table that does not have a version column, you can disable optimistic locking by setting the update mode to `KeyOnly` on the connection:

```pascal
LConnection.UpdateMode := TTUpdateMode.KeyOnly;
```

With `TTUpdateMode.KeyOnly`, UPDATE and DELETE statements use only the primary key in the WHERE clause instead of checking both the primary key and the version column.

The default mode is `TTUpdateMode.KeyAndVersionColumn`, which includes the version column for optimistic locking. This is the recommended setting for all new tables.

## Foreign Keys and Relationships

For related entities, add standard foreign key columns to your tables:

```sql
CREATE TABLE [dbo].[Orders](
  [ID] [int] NOT NULL,
  [CustomerID] [int] NOT NULL,
  [OrderDate] [datetime] NOT NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED([ID] ASC),
  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
    REFERENCES [dbo].[Customers]([ID])
);
```

On the entity side, use `[TRelation]` and `TTLazy<T>` or `TTLazyList<T>` to map relationships. See the [Guide](../guide/) for details on lazy loading and relationship mapping.
