# Sessions (Unit of Work)

`TTSession<T>` implements the Unit of Work pattern in Trysil. It works on clones of a set of entities, collects the insertions, updates and deletions you mark, and applies them in a single transaction. It is defined in `Trysil.Session.pas`.

## Basic Usage

```pascal
var LSession := LContext.CreateSession<TPerson>(LPersons);
try
  // Modify cloned entities
  for LPerson in LSession.Entities do
  begin
    LPerson.Lastname := UpperCase(LPerson.Lastname);
    LSession.Update(LPerson);
  end;

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

## Creating from a Lazy List

A lazy collection exposes its children as a `TTList<T>`, which you can pass straight to `CreateSession<T>`. This is convenient for editing the children of a parent entity loaded through [lazy loading](lazy-loading.md):

```pascal
var LSession := LContext.CreateSession<TEmployee>(LDepartment.Employees);
```

When `ApplyChanges` completes, the session invalidates the underlying lazy list, so the parent's collection reloads from the database on next access and stays in sync with the persisted state. That reload frees the originals - without the identity map; with it, it overwrites those it reads again with the database state - so do not call `GetOriginalEntity` after it: free the session first.

## How It Works

1. **Clone on creation** -- When `CreateSession<T>` is called, the session clones every entity from the source list. You work with clones, not the originals.
2. **Work with clones** -- Access cloned entities via `LSession.Entities`. A modified clone is written only if you mark it with `Update`: the session does not compare clones against the originals.
3. **Track state** -- Each entity has a `TTSessionState`:

    | State | Meaning |
    |---|---|
    | `Original` | Unmodified clone from the source list |
    | `Inserted` | New entity added via `Insert` |
    | `Updated` | Clone modified and marked via `Update` |
    | `Deleted` | Clone marked for deletion via `Delete` |

4. **Apply changes** -- `ApplyChanges` processes the entities in the order they entered the session: first the clones of the source list, in the order of that list, each updated or deleted as it was marked, then the inserted entities in the order they were inserted. An update that points at an entity inserted in the same session therefore runs before that insert. The entire batch runs in a single transaction.
5. **One-time apply** -- `ApplyChanges` can only be called once per session **successfully**: after an exception a second call runs again, and when the session joined a transaction of yours that did not roll back, it writes again what the first call already wrote. Calling it a second time raises `ETException`.

!!! warning "Free the session before the context that created it"
    `CreateSession<T>` hands the session three borrowed references - the
    connection, the provider and the resolver - and none of them tells it
    when they die. From 2.0.0 the session **uses two of them while it is
    being destroyed**, to release its clones through the same disposal path
    every other entity goes through. So the order matters now, where before
    it did not: destroy the session first, then the context.

    An application that keeps both as fields and frees them in declaration
    order, context first, reads a destroyed `TTProvider` and then calls into
    it. Nothing in the type system stops it. `try..finally LSession.Free`
    around the block that uses it is the shape that is always right.

!!! warning "The list you pass to CreateSession<T> outlives the session"
    The session keeps the list you hand to `CreateSession<T>`: it clones it
    when it is created, marks it as no longer valid when `ApplyChanges`
    completes, and `GetOriginalEntity` answers with its rows. Free that list
    after the session, never before. The list of a lazy member such as
    `LDepartment.Employees` is not yours to free at all: keep the entity that
    carries it alive until after the session. Freeing either first makes
    `ApplyChanges` read freed memory, and write into it when the list is a
    `TTObjectList<T>`.
    A `try..finally LSession.Free` nested inside the block that owns the list
    is the shape that is always right.

!!! warning "Your original entities are not updated by ApplyChanges"
    The session writes the **clones**. The objects in the list you passed to `CreateSession<T>` are the state as it was when the session started, and they stay that way: a version column incremented by an update, a key assigned to an insert, a change tracking column stamped by the framework - none of it reaches them.

    `ApplyChanges` says so rather than pretending otherwise: when the source list is a `TTObjectList<T>`, which is what `CreateEntityList<T>` returns, it sets `IsValid := False` on it, which is what makes a lazy list reload. Reload the list yourself after applying - after `LSession.Free`, because the reload frees the originals `GetOriginalEntity` answers with, or with the identity map overwrites those it reads again. Do not go on using the originals as if they described the database.

## Session Operations

### Insert

Add a new entity to the session. The entity must not be a clone from the original list:

```pascal
LNewPerson := LContext.CreateEntity<TPerson>();
LNewPerson.Firstname := 'Alice';
LSession.Insert(LNewPerson);
```

Validation runs immediately on `Insert` to catch errors early.

!!! warning "The session adopts the entity you insert"
    Everything else in Trysil follows one rule: without an identity map the caller owns what it created, and frees it. `Insert` is where that rule stops. The entity you hand over - to `Insert`, or to `Save` when it is not one of the session's clones - is the session's from then on, and the session frees it when it is destroyed - so **do not free it yourself**, and do not read it or hand it on after `LSession.Free`. Hand over only an entity that is yours, never a row of a list. `Insert` raises before taking it when the entity does not validate or is one of the session's clones, and its owner does not change. A second `Insert` of an entity inserted before raises only after adding it a second time to `Entities`: its owner does not change either, but avoid it rather than catch it: if you do catch it, `ApplyChanges` walks the list where the entity now sits twice and tries two `INSERT` - the second one carries the same primary key, so it fails inside the transaction and takes the whole `ApplyChanges` with it. In 1.0.0 the session did not free what it was handed, so code that freed it after the session has to drop that free. [Who frees what](context.md#who-frees-what) has every case.

    That is deliberate, not an oversight: a consumer can post a new row by building an entity and handing it to the session, with no later moment at which it could free it. With an identity map in play the map owns the entity instead and the session's list does not, which is the same arrangement as everywhere else - for a type with a primary key and no `[TJoin]`, which is what the map holds; any other type the session still frees. The exception is an entity of such a type that the map does not hold, a clone or one you built yourself: with the map on the session does not free it, and you free it with `FreeClone<T>` after `LSession.Free`. That is a declared limit of this release.

    Entities that came from the source list are not affected: those are the originals, the session works on clones of them, and you free a list of yours after the session, which from 2.0.0 it has to outlive; the list of a lazy member you never free. Do not hand them to `Insert` or `Save`: the session would adopt an entity the source list still owns. `Update` and `Delete` take the clones in `Entities`; `Save` updates a clone and inserts anything else.

### Save

Update a clone of the session, or insert anything else:

```pascal
LSession.Save(LPerson);
```

`Save` is `Update` for a clone of the session - a deleted one included, which
then raises - and `Insert` for any other entity, with everything `Insert`
implies: the session adopts it. Do not call it again on an entity already
inserted: the second call raises `EListError` and still leaves the entity
twice in `Entities`, so an `ApplyChanges` after catching it runs the insert twice with the same key: on a table with a primary key the whole batch fails, and rolls back unless it joined a transaction of yours.
Changes made to an inserted entity before `ApplyChanges` are written by the
insert anyway.

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

The entity is removed from `LSession.Entities` but kept internally for processing during `ApplyChanges`. If a newly inserted entity is deleted before applying, it reverts to `Original` state and is not written. It is still handed over as by `Insert`: do not free it yourself, and see row 7 of [who frees what](context.md#who-frees-what) for the one case the session does not free it.

## GetOriginalEntity

Retrieve the original (pre-clone) entity for a given clone:

```pascal
LOriginal := LSession.GetOriginalEntity(LClone);
```

Returns `nil` if the clone was not part of the original list (e.g., a newly inserted entity). The original is a row of the source list: once that list has been reloaded, the address returned is freed memory without the identity map, and with it an entity that may already hold the state read again, so reload it only after the session is freed.

## Why Full Cloning?

Trysil clones every entity to isolate the changes, not to find them: you work on the clones, the originals stay as they were, and `ApplyChanges` writes only what you marked with `Insert`, `Update` or `Delete`. There is no automatic change detection, and cloning is still the only correct approach in Delphi because:

- **Field-level dirty tracking** requires dynamic proxies that intercept property writes.
- Delphi does not support dynamic proxies (unlike Java or C#).
- A clone gives the isolation without language-level proxy support, and you say what changed.

The trade-off is memory usage: every entity in the session is duplicated. For large datasets, consider working with smaller batches or using direct `Insert`/`Update`/`Delete` calls on `TTContext` instead.

## Complete Example

```pascal
LPersons := LContext.CreateEntityList<TPerson>();
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
    // From here on you must not free LNew: the session or the map does
    LSession.Insert(LNew);

    // Apply everything
    LSession.ApplyChanges;
  finally
    LSession.Free;
  end;
finally
  // LPersons still holds the state as it was: reload it if you go on
  LPersons.Free;
end;
```
