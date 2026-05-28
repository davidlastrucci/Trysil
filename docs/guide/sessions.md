# Sessions (Unit of Work)

`TTSession<T>` implements the Unit of Work pattern in Trysil. It tracks changes to a set of entities and applies all insertions, updates, and deletions in a single transaction. It is defined in `Trysil.Session.pas`.

## Basic Usage

```pascal
var LSession := LContext.CreateSession<TPerson>(LPersons);
try
  // Modify cloned entities
  for LPerson in LSession.Entities do
    LPerson.Lastname := UpperCase(LPerson.Lastname);

  // Insert a new entity
  LNewPerson := LContext.CreateEntity<TPerson>();
  LNewPerson.Firstname := 'New';
  LNewPerson.Lastname := 'Person';
  LSession.Insert(LNewPerson);

  // Delete an existing entity
  LSession.Delete(LSession.Entities[0]);

  // Apply all changes in one transaction
  LSession.ApplyChanges;
finally
  LSession.Free;
end;
```

## How It Works

1. **Clone on creation** -- When `CreateSession<T>` is called, the session clones every entity from the source list. You work with clones, not the originals.
2. **Work with clones** -- Access cloned entities via `LSession.Entities`. Modifications to these clones are tracked by comparing them against the originals.
3. **Track state** -- Each entity has a `TTSessionState`:

    | State | Meaning |
    |---|---|
    | `Original` | Unmodified clone from the source list |
    | `Inserted` | New entity added via `Insert` |
    | `Updated` | Clone modified and marked via `Update` |
    | `Deleted` | Clone marked for deletion via `Delete` |

4. **Apply changes** -- `ApplyChanges` processes all entities in order: inserts first, then updates, then deletes. The entire batch runs in a single transaction.
5. **One-time apply** -- `ApplyChanges` can only be called once per session. Calling it a second time raises `ETException`.

## Session Operations

### Insert

Add a new entity to the session. The entity must not be a clone from the original list:

```pascal
LNewPerson := LContext.CreateEntity<TPerson>();
LNewPerson.Firstname := 'Alice';
LSession.Insert(LNewPerson);
```

Validation runs immediately on `Insert` to catch errors early.

### Update

Mark a cloned entity as updated:

```pascal
LPerson := LSession.Entities[0];
LPerson.Lastname := 'NewName';
LSession.Update(LPerson);
```

Validation runs immediately on `Update`. If the entity was already in `Inserted` state, it stays as `Inserted` (it will still be inserted, not updated, when changes are applied).

### Delete

Mark an entity for deletion:

```pascal
LSession.Delete(LSession.Entities[0]);
```

The entity is removed from `LSession.Entities` but kept internally for processing during `ApplyChanges`. If a newly inserted entity is deleted before applying, it reverts to `Original` state and is effectively ignored.

## GetOriginalEntity

Retrieve the original (pre-clone) entity for a given clone:

```pascal
LOriginal := LSession.GetOriginalEntity(LClone);
```

Returns `nil` if the clone was not part of the original list (e.g., a newly inserted entity).

## Why Full Cloning?

Trysil uses full entity cloning to detect changes. This is the only correct approach in Delphi because:

- **Field-level dirty tracking** requires dynamic proxies that intercept property writes.
- Delphi does not support dynamic proxies (unlike Java or C#).
- Full cloning ensures reliable change detection without language-level proxy support.

The trade-off is memory usage: every entity in the session is duplicated. For large datasets, consider working with smaller batches or using direct `Insert`/`Update`/`Delete` calls on `TTContext` instead.

## Complete Example

```pascal
LPersons := TTList<TPerson>.Create;
try
  LContext.SelectAll<TPerson>(LPersons);

  var LSession := LContext.CreateSession<TPerson>(LPersons);
  try
    // Update all existing
    for LPerson in LSession.Entities do
    begin
      LPerson.Lastname := UpperCase(LPerson.Lastname);
      LSession.Update(LPerson);
    end;

    // Add new
    LNew := LContext.CreateEntity<TPerson>();
    LNew.Firstname := 'Bob';
    LNew.Lastname := 'JONES';
    LSession.Insert(LNew);

    // Apply everything
    LSession.ApplyChanges;
  finally
    LSession.Free;
  end;
finally
  LPersons.Free;
end;
```
