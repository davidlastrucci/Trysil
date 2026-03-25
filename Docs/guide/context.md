# Context (CRUD Operations)

`TTContext` is the primary API entry point for all ORM operations. It is defined in `Trysil.Context.pas`.

## Creating a Context

```pascal
// Single connection (identity map enabled by default)
LContext := TTContext.Create(LConnection);

// Single connection with explicit identity map control
LContext := TTContext.Create(LConnection, True);   // enabled
LContext := TTContext.Create(LConnection, False);  // disabled

// Read/write split (identity map enabled by default)
LContext := TTContext.Create(LReadConnection, LWriteConnection);

// Read/write split with explicit identity map control
LContext := TTContext.Create(LReadConnection, LWriteConnection, False);
```

When using read/write split, SELECT operations go through the read connection and INSERT/UPDATE/DELETE operations go through the write connection. This supports primary/replica database topologies.

## Read Operations

### SelectAll

Load all entities of a given type:

```pascal
LPersons := TTList<TPerson>.Create;
try
  LContext.SelectAll<TPerson>(LPersons);
  for LPerson in LPersons do
    WriteLn(LPerson.Firstname);
finally
  LPersons.Free;
end;
```

### Select (Filtered)

Load entities matching a filter:

```pascal
LPersons := TTList<TPerson>.Create;
try
  LContext.Select<TPerson>(LPersons, LFilter);
finally
  LPersons.Free;
end;
```

See [Filtering](filtering.md) for how to build filters.

### SelectCount

Count matching records without loading entities:

```pascal
LCount := LContext.SelectCount<TPerson>(LFilter);
```

### Get

Load a single entity by primary key. Returns `nil` if not found:

```pascal
LPerson := LContext.Get<TPerson>(42);
```

### TryGet

Safe alternative that returns a Boolean:

```pascal
if LContext.TryGet<TPerson>(42, LPerson) then
  WriteLn(LPerson.Firstname);
```

### Refresh

Reload an entity from the database, overwriting in-memory changes:

```pascal
LContext.Refresh<TPerson>(LPerson);
```

### OldEntity

Get a snapshot of the entity as it exists in the database (before any in-memory changes):

```pascal
LOld := LContext.OldEntity<TPerson>(LPerson);
try
  if LOld.Lastname <> LPerson.Lastname then
    WriteLn('Lastname changed');
finally
  LOld.Free;
end;
```

`OldEntity` creates a clone and refreshes it, so the caller owns the returned object and must free it.

## Write Operations

### Insert

```pascal
LPerson := LContext.CreateEntity<TPerson>();
LPerson.Firstname := 'John';
LPerson.Lastname := 'Smith';
LContext.Insert<TPerson>(LPerson);
// LPerson.ID is now assigned by the sequence
```

### InsertAll

```pascal
LContext.InsertAll<TPerson>(LPersonList);
```

Wraps all inserts in a single transaction. If any insert fails, the entire batch is rolled back.

### Update

```pascal
LPerson.Lastname := 'Johnson';
LContext.Update<TPerson>(LPerson);
```

### UpdateAll

```pascal
LContext.UpdateAll<TPerson>(LPersonList);
```

### Delete

```pascal
LContext.Delete<TPerson>(LPerson);
```

### DeleteAll

```pascal
LContext.DeleteAll<TPerson>(LPersonList);
```

## Save Operations

### Save

`Save` automatically determines whether to insert or update. Entities created via `CreateEntity<T>` are tracked in an internal `TTNewEntityCache` and will be inserted. All other entities are updated.

```pascal
LPerson := LContext.CreateEntity<TPerson>();
LPerson.Firstname := 'New';
LContext.Save<TPerson>(LPerson);  // INSERT (tracked as new)

LPerson.Firstname := 'Updated';
LContext.Save<TPerson>(LPerson);  // UPDATE (no longer in new cache)
```

### SaveAll

```pascal
LContext.SaveAll<TPerson>(LPersonList);
```

### ApplyAll

Execute inserts, updates, and deletes for separate lists in a single transaction:

```pascal
LContext.ApplyAll<TPerson>(LInsertList, LUpdateList, LDeleteList);
```

The three lists are processed in order: inserts first, then updates, then deletes. If any operation fails, the entire transaction is rolled back.

## Factory Methods

### CreateEntity

Create a new empty entity. The entity is registered in the new-entity cache so that `Save` knows to insert it:

```pascal
LPerson := LContext.CreateEntity<TPerson>();
```

### CloneEntity

Deep-clone an existing entity:

```pascal
LClone := LContext.CloneEntity<TPerson>(LPerson);
```

### CreateTransaction

Create an explicit transaction. See [Transactions](transactions.md):

```pascal
LTransaction := LContext.CreateTransaction;
```

### CreateSession

Create a Unit of Work session. See [Sessions](sessions.md):

```pascal
LSession := LContext.CreateSession<TPerson>(LPersonList);
```

### CreateFilterBuilder

Create a fluent filter builder. See [Filtering](filtering.md):

```pascal
LBuilder := LContext.CreateFilterBuilder<TPerson>();
```

### GetMetadata

Retrieve table metadata for an entity type:

```pascal
LMetadata := LContext.GetMetadata<TPerson>();
```

### CreateDataset

Execute raw SQL and return a `TDataset`. Use this as a fallback for complex queries that cannot be expressed through the ORM:

```pascal
LDataset := LContext.CreateDataset('SELECT COUNT(*) FROM Persons');
```

## Validation

Validate an entity explicitly before submitting. Raises `ETValidationException` on failure:

```pascal
try
  LContext.Validate<TPerson>(LPerson);
except
  on E: ETValidationException do
    ShowMessage(E.Message);
end;
```

Validation also runs automatically before every `Insert` and `Update` operation inside the resolver. See [Validation](validation.md) for details.

## Properties

| Property | Type | Description |
|---|---|---|
| `InTransaction` | `Boolean` | Whether the write connection has an active transaction |
| `SupportTransaction` | `Boolean` | Whether the write connection supports transactions |
| `UseIdentityMap` | `Boolean` | Whether the identity map is enabled for this context |

## Typical Usage Pattern

```pascal
LConnection := TTSQLiteConnection.Create('Main');
try
  LContext := TTContext.Create(LConnection);
  try
    // Read
    LPersons := TTList<TPerson>.Create;
    try
      LContext.SelectAll<TPerson>(LPersons);
      for LPerson in LPersons do
        WriteLn(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
    finally
      LPersons.Free;
    end;

    // Write
    LPerson := LContext.CreateEntity<TPerson>();
    LPerson.Firstname := 'Alice';
    LPerson.Lastname := 'Smith';
    LContext.Insert<TPerson>(LPerson);
  finally
    LContext.Free;
  end;
finally
  LConnection.Free;
end;
```
