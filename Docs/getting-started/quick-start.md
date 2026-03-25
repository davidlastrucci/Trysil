---
title: Quick Start
---

# Quick Start

This guide walks through a complete minimal example: define an entity, connect to a database, and perform CRUD operations.

## 1. Define an Entity

Create a unit for your model class. Each entity maps to a database table using Trysil attributes.

```pascal
unit App.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type
  [TTable('Persons')]
  [TSequence('PersonsID')]
  TPerson = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(50)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(50)]
    [TColumn('Lastname')]
    FLastname: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
  end;

implementation

end.
```

Key points:

- `[TTable('Persons')]` maps the class to the `Persons` table.
- `[TSequence('PersonsID')]` tells Trysil which sequence generates the primary key.
- `[TPrimaryKey]` marks the primary key field.
- `[TColumn('...')]` maps each field to a database column.
- `[TVersionColumn]` enables optimistic locking on this field.
- `[TRequired]` and `[TMaxLength]` are validation attributes checked before insert/update.
- Fields must be `strict private` for RTTI-based attribute mapping to work.

## 2. Create Connection and Context

```pascal
uses
  Trysil.Data.FireDAC.SQLite,
  Trysil.Context;

var
  LConnection: TTSQLiteConnection;
  LContext: TTContext;
begin
  // Register the connection profile
  TTSQLiteConnection.RegisterConnection('Main', 'mydb.db');

  // Create connection and context
  LConnection := TTSQLiteConnection.Create('Main');
  try
    LContext := TTContext.Create(LConnection);
    try

      // ... your code here ...

    finally
      LContext.Free;
    end;
  finally
    LConnection.Free;
  end;
end;
```

Replace `TTSQLiteConnection` with the appropriate driver for your database:

| Database | Unit | Class |
|---|---|---|
| SQLite | `Trysil.Data.FireDAC.SQLite` | `TTSQLiteConnection` |
| SQL Server | `Trysil.Data.FireDAC.SqlServer` | `TTSqlServerConnection` |
| PostgreSQL | `Trysil.Data.FireDAC.PostgreSQL` | `TTPostgreSQLConnection` |
| Firebird | `Trysil.Data.FireDAC.FirebirdSQL` | `TTFirebirdSQLConnection` |

## 3. CRUD Operations

### Create

```pascal
var
  LPerson: TPerson;
begin
  LPerson := LContext.CreateEntity<TPerson>();
  try
    LPerson.Firstname := 'David';
    LPerson.Lastname := 'Lastrucci';
    LContext.Insert<TPerson>(LPerson);
  finally
    LPerson.Free;
  end;
end;
```

`CreateEntity<T>` allocates a new instance. `Insert<T>` validates the entity and executes the INSERT statement. The primary key is assigned automatically from the sequence.

### Read All

```pascal
uses
  Trysil.Generics.Collections;

var
  LPersons: TTList<TPerson>;
begin
  LPersons := TTList<TPerson>.Create;
  try
    LContext.SelectAll<TPerson>(LPersons);

    for var LPerson in LPersons do
      ShowMessage(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
  finally
    LPersons.Free;
  end;
end;
```

### Read by ID

```pascal
var
  LPerson: TPerson;
begin
  LPerson := LContext.Get<TPerson>(1);
  try
    ShowMessage(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
  finally
    LPerson.Free;
  end;
end;
```

### Update

```pascal
LPerson.Firstname := 'John';
LContext.Update<TPerson>(LPerson);
```

The version column is checked automatically. If another user has modified the record since it was loaded, the update raises an exception (optimistic locking).

### Delete

```pascal
LContext.Delete<TPerson>(LPerson);
```

## 4. Filtered Query

Use `TTFilterBuilder<T>` to build WHERE clauses, ordering, and paging without writing raw SQL.

```pascal
var
  LFilter: TTFilter;
  LPersons: TTList<TPerson>;
begin
  LPersons := TTList<TPerson>.Create;
  try
    LFilter := LContext.CreateFilterBuilder<TPerson>()
      .Where('Lastname').Equal('Lastrucci')
      .OrderByAsc('Firstname')
      .Build;

    LContext.Select<TPerson>(LPersons, LFilter);

    for var LPerson in LPersons do
      ShowMessage(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
  finally
    LPersons.Free;
  end;
end;
```

The filter builder resolves column names from the entity metadata, so you get an exception at runtime if a column name is misspelled.

You can chain multiple conditions:

```pascal
LFilter := LContext.CreateFilterBuilder<TPerson>()
  .Where('Lastname').Equal('Lastrucci')
  .AndWhere('Firstname').Like('D%')
  .OrderByAsc('Lastname')
  .OrderByAsc('Firstname')
  .Limit(10)
  .Offset(0)
  .Build;
```

## Important Notes

- **Always** add `{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}` in units that declare entities. This turns misspelled attribute names into compile-time errors instead of silent failures.
- Entity fields **must** be `strict private` with Trysil attributes. The ORM accesses them via RTTI.
- `TTPrimaryKey` is `Int32`. Trysil supports single-integer primary keys only.
- `TTVersion` is `Int32`. Every table should have a version column for optimistic locking.
- Use `TTList<T>` from `Trysil.Generics.Collections` for owned object lists.
- Always free entities, lists, contexts, and connections in the correct order.
