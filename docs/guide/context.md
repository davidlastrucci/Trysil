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

All read operations support entities with `[TJoin]` attributes -- the generated SQL automatically includes JOIN clauses and column aliases. See [JOIN Queries](joins.md).

### SelectAll

Load all entities of a given type:

```pascal
LPersons := LContext.CreateEntityList<TPerson>();
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
LPersons := LContext.CreateEntityList<TPerson>();
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

The result is an `Int64`. A count is not a primary key, so it is not capped at
32 bits - but Delphi assigns an `Int64` to an `Integer` without a word, so on a
table large enough to need it, declare the variable `Int64` or it truncates in
silence.

### Get

Load a single entity by primary key. Returns `nil` if not found:

```pascal
LPerson := LContext.Get<TPerson>(42);
```

Soft-deleted records are excluded by default. Pass `IncludeDeleted` to load an entity even when it has been soft-deleted:

```pascal
LPerson := LContext.Get<TPerson>(42, True);   // include soft-deleted
```

### TryGet

Safe alternative that returns a Boolean:

```pascal
if LContext.TryGet<TPerson>(42, LPerson) then
  WriteLn(LPerson.Firstname);
```

The `IncludeDeleted` overload applies here too:

```pascal
if LContext.TryGet<TPerson>(42, True, LPerson) then
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
  if Assigned(LOld) and (LOld.Lastname <> LPerson.Lastname) then
    WriteLn('Lastname changed');
finally
  LContext.FreeClone<TPerson>(LOld);
end;
```

`OldEntity` creates a clone and refreshes it, so the caller owns the returned object and frees it with [`FreeClone<T>`](#freeclone). It returns `nil` when the row is no longer in the database. Inside an event use the event's own `OldEntity` property instead, which the event frees.

### RawSelect

Execute arbitrary SQL and map results to typed DTO classes. DTO classes only need `[TColumn]` attributes -- `[TTable]`, `[TPrimaryKey]`, and `[TSequence]` are not required:

```pascal
LResult := TTObjectList<TOrderSummary>.Create;
try
  LContext.RawSelect<TOrderSummary>(
    'SELECT c.CompanyName AS CustomerName, SUM(o.Amount) AS Total ' +
    'FROM Orders o JOIN Customers c ON o.CustomerID = c.ID ' +
    'GROUP BY c.CompanyName',
    LResult);
finally
  LResult.Free;
end;
```

Results are read-only and the identity map is not used. A row of a class that carries a lazy member is freed differently from a plain DTO: see [who frees what](#who-frees-what). Nothing stops you passing a row to `Insert<T>`, `Update<T>`, `Delete<T>` or `Undelete<T>` when its class carries a key and a version column, or only a key when the connection's update mode is `KeyOnly` (and, for `Undelete<T>`, a `[TDeletedAt]` column), so keep to the rule: a row of a raw select is not written. The owning list it is collected into does not tell the context what it frees, and a row written inside a transaction can leave the context holding its address: freed before that transaction ends, a rollback writes into it; inserted, a rollback puts it among the new entities, where it stays after the list frees it and makes the next object allocated there read as new. See [Raw Select](raw-select.md) for details.

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

If the entity has a `[TDeletedAt]` column, `Delete` performs a **soft delete** (UPDATE) instead of a SQL DELETE. See [Entity Mapping — Soft Delete](entities.md#soft-delete) for details.

### DeleteAll

```pascal
LContext.DeleteAll<TPerson>(LPersonList);
```

### Undelete

Reverse a soft delete. `Undelete` issues an `UPDATE` that clears `[TDeletedAt]` and `[TDeletedBy]`, bringing the record back into normal queries. Unlike every other `UPDATE`, it writes **only** those two columns, the update audit pair (`[TUpdatedAt]` / `[TUpdatedBy]`, so the restore is recorded like any other change) and the version increment, so an entity that carries unrelated changes does not smuggle them into the database:

```pascal
LPerson := LContext.Get<TPerson>(42, True);  // load the soft-deleted record
LContext.Undelete<TPerson>(LPerson);
```

Calling `Undelete` on an entity that has no `[TDeletedAt]` column raises `ETException`. See [Entity Mapping — Soft Delete](entities.md#soft-delete).

`Undelete` is the only operation that reaches a soft-deleted row **through the entity that declares the soft delete**: every `UPDATE` on such an entity carries `DeletedAt IS NULL` in its `WHERE` clause, so a deleted record cannot be modified, nor resurrected by writing a null over its `DeletedAt`. An `Update` on one raises `ETConcurrentUpdateException`, the same exception a version conflict raises.

The guard is built from the mapping, not from the table. It is on the soft delete too, so deleting a row that is already deleted raises `ETConcurrentUpdateException` instead of restamping the audit of the first delete. A second class mapped on the same table that does not declare `[TDeletedAt]` - the lightweight entity for lists and lookups is the usual case - carries no guard, so writing through it edits a soft-deleted row. It cannot resurrect one, because the column is not in its `SET` list either, but if you write through that entity, declare the delete pair on it too.

### UndeleteAll

```pascal
LContext.UndeleteAll<TPerson>(LPersonList);
```

Wraps all undeletes in a single transaction.

## Save Operations

### Save

`Save` automatically determines whether to insert or update. Entities created via `CreateEntity<T>` are tracked in an internal `TTNewEntityCache` and will be inserted. All other entities are updated, unless a rollback undid their insert (see below).

The cache holds the **instances** the context created and has not written yet - and any instance whose `Insert<T>` returned inside a transaction opened through Trysil, and which that transaction's rollback undid - so the question `Save` answers is about this object's history with this context, not about the value its key happens to carry.

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

!!! warning "Save is for the direct application, not for a REST request"
    An entity filled from a JSON body is not one the context created: it allocated the object and the body supplied the state, key included. There is no history to consult, so `Save` on it means "the body names the row", that is an update - and a body carrying no key gets an update against key zero, which finds nothing and raises.

    On a `TTHttpContext` the question has no answer at all, because that context lives one request: `Save` and `SaveAll` raise there. Call `Insert<T>` or `Update<T>`, as the [REST example](../examples/rest-api.md) does.

    `Insert<T>` also refuses an entity whose primary key is still zero. In the direct application that cannot happen, because `CreateEntity<T>` takes the key from the sequence; on a body that carried no key it is the reminder to call `SetSequenceID<T>` first.

### ApplyAll

Execute inserts, updates, and deletes for separate lists in a single transaction:

```pascal
LContext.ApplyAll<TPerson>(LInsertList, LUpdateList, LDeleteList);
```

The three lists are processed in order: inserts first, then updates, then deletes. If any operation fails, the entire transaction is rolled back.

`ApplyAll` starts a transaction only when the write connection does not already have one. Called inside a transaction you opened yourself, it joins it instead of nesting: the whole unit of work stays atomic, and commit or rollback remains the caller's decision.

```pascal
LContext.RunInTransaction(
  procedure
  begin
    LContext.ApplyAll<TPerson>(LInsertList, LUpdateList, LDeleteList);
    LContext.ApplyAll<TOrder>(LOrderInserts, LOrderUpdates, LOrderDeletes);
  end);
```

## Factory Methods

### CreateEntity

Create a new empty entity. The entity is registered in the new-entity cache so that `Save` knows to insert it:

```pascal
LPerson := LContext.CreateEntity<TPerson>();
```

!!! note "CreateEntity costs one round trip"
    The primary key is read from the sequence here, not at `Insert`, so that the entity carries a real id before it is saved and foreign keys between in-memory entities can be wired up without a second pass. The price is one database round trip per entity created, paid even for an entity that is later discarded, and on the six drivers backed by a real sequence that discarded value leaves a gap in the numbering.

    For ordinary request traffic this is one extra round trip per write. It becomes visible when creating entities in bulk, where saving `N` rows costs `2N` round trips: create them as late as you can, and do not call `CreateEntity` for a row you may not insert.

### CloneEntity

Deep-clone an existing entity:

```pascal
LClone := LContext.CloneEntity<TPerson>(LPerson);
```

The clone is the caller's, with the identity map on or off - the map never
holds it - and is freed with [`FreeClone<T>`](#freeclone), unless a container
adopts it: see [who frees what](#who-frees-what).

### CreateEntityList

Create the list a read fills. It owns its entities when the identity map does
not, and it tells the context about every entity it frees:

```pascal
LPersons := LContext.CreateEntityList<TPerson>();
try
  LContext.SelectAll<TPerson>(LPersons);
finally
  LPersons.Free;
end;
```

### FreeEntity

Free an entity the context read or created - a clone goes through
[`FreeClone<T>`](#freeclone). This is the way to free one: the context forgets
it before it is destroyed - the rewind of a transaction that rolls back, the lazy
members it loaded, the new-entity cache - and leaves it alone when the identity
map holds entities of its type, which is a type with a primary key and no
`[TJoin]`:

```pascal
LPerson := LContext.Get<TPerson>(AID);
try
  LContext.Update<TPerson>(LPerson);
finally
  LContext.FreeEntity<TPerson>(LPerson);
end;
```

A bare `LPerson.Free` skips all of that, and inside a transaction that rolls
back it makes the rollback write into freed memory. See
[Transactions](transactions.md).

With the identity map on the decision is taken on the type, not on the object:
an entity with a primary key and no `[TJoin]` is never freed here. That is
right for what the context read or created, and it leaves alive a clone from
`CloneEntity` or `OldEntity`, a row of a raw select or an object you built
yourself, of the same type. It is a declared limit of this release, and those
are freed with `FreeClone<T>`: see [who frees what](#who-frees-what).

### FreeClone

Free an entity nothing else holds. It goes through the same disposal as
`FreeEntity<T>`, and then it frees the object whether the identity map is on
or off. It is meant for:

- what `CloneEntity` or `OldEntity` returned to you;
- a row of a raw select kept in a `TTList<T>` that owns nothing;
- an object you built yourself that no container holds.

```pascal
LClone := LContext.CloneEntity<TPerson>(LPerson);
try
  LClone.Lastname := 'Rossi';
finally
  LContext.FreeClone<TPerson>(LClone);
end;
```

A container that adopts an entity frees it itself, and then `FreeClone<T>` is
a double free; which container adopts what is in the table below.

### Who frees what

This table is the rule; every other page that talks about freeing an entity
points here. The columns are the three answers a context can give: no identity
map; the identity map on and a type it holds, which is a type with a primary
key and no `[TJoin]`; the identity map on and any other type. A JSON or an HTTP
context refuses the identity map, so there only the first column applies.

| What you hold | Map off | Map on, a type with a primary key and no `[TJoin]` | Map on, any other type |
|---|---|---|---|
| 1. An entity from `Get`, `TryGet`, `CreateEntity` or `EntityFromJSon` | `FreeEntity<T>` | `FreeEntity<T>`, which leaves it to the map | `FreeEntity<T>` |
| 2. The rows `Select`, `SelectAll` or `ListFromJSon` put in a list from `CreateEntityList<T>` | free the list | free the list, which leaves them to the map | free the list |
| 3. The rows of a `RawSelect<T>` into a plain DTO | free the `TTObjectList<T>.Create(True)` they are in | the same | the same |
| 4. The rows of a `RawSelect<T>` into a class with a lazy member or a `[TDetailColumn]` | keep them in a `TTList<T>`, `FreeClone<T>` each, then free the list | the same | the same |
| 5. A clone from `CloneEntity`, or from `OldEntity` you called yourself | `FreeClone<T>` | `FreeClone<T>` | `FreeClone<T>` |
| 6. An object you built yourself | `FreeClone<T>` | `FreeClone<T>` | `FreeClone<T>` |
| 7. An entity of rows 1, 5 or 6 handed to `TTSession<T>.Insert`, or to `Save` when it is not one of the session's clones, once the call returned; or added to a list from `CreateEntityList<T>` | the session or the list frees it: do not free it, and do not read it or hand it on after the session or the list is gone | from row 1 the map keeps it; from rows 5 or 6, `FreeClone<T>` after the session or the list | as in the first column |
| 8. An entity that still belongs to someone else: a row of a list, the `.Entity` of a lazy member, a clone or an entity of a session, the `OldEntity` of an event | do not hand it to a session or to a list | the same | the same |
| 9. An entity `Insert` refused, because it does not validate or is already in the session | its owner does not change; a second `Insert`, or `Save` again, of an entity already inserted still leaves it twice in `Entities`, so avoid it rather than catch it | the same | the same |
| 10. A clone the session holds in `Entities` | the session frees it | the same | the same |
| 11. The `OldEntity` property of an event | the event frees it | the same | the same |
| 12. The `.Entity` of a lazy member, the list a `TTLazyList<T>` exposes and its rows, what `GetOriginalEntity` returns | never free it | never free it | never free it |
| 13. A list handed to `CreateSession<T>` | a list of yours: free it after the session, never before; the list of a lazy member: never free it, and keep the entity that carries it alive until after the session, whoever owns that entity | the same | the same |

Two mistakes the table rules out do not show at once. `FreeClone<T>` on an
entity the map keeps is a double free that does not wait for the context to go
down: the map still holds the address, and the next read of the same key writes
into freed memory. `FreeEntity<T>` on a clone of a type the map holds, with the
map on, frees nothing, which is the leak declared for this release.

What you did not free yourself you do not keep either. A row of a list and the
`.Entity` of a lazy member live until the next thing that touches their owner -
the next read into that list, a `Clear`, a `Remove` or a `Delete`, a session
applying its changes to it, a new id or a new `.Entity` on the lazy member, a
`Refresh<T>` or JSON read into the entity that carries it - or until their
owner is gone. Do not keep a pointer past that: read it again. A list handed
to `CreateSession<T>` outlives the session (row 13). What
`GetOriginalEntity` returns is a row of the source list and cannot be read
again: the session answers with the same address after that list has been
reloaded, so reload the source list only after the session is freed. To
reorder a list that owns its rows use `Exchange` or `Move`, never an assignment
of one item over another. And before filling again a `TTList<T>` of raw select
rows (row 4), `FreeClone<T>` each row it holds, or they are lost.

Assigning to the `.Entity` of a lazy member hands nothing over with the map
off, or for a type the map does not hold: the lazy member stores a clone. With
the map on and a type the map holds it keeps the instance you pass, so assign
only an entity the map of this context holds - from `Get`, `TryGet`, `Select`, `CreateEntity`
or a lazy load: see [Lazy Loading](lazy-loading.md#behavior).

### RunInTransaction

Run a procedure inside a transaction: it commits on clean exit, rolls back and
re-raises on an exception, and joins the current transaction if one is already
active. See [Transactions](transactions.md):

```pascal
LContext.RunInTransaction(
  procedure
  begin
    LContext.Insert<TOrder>(LOrder);
  end);
```

### CreateTransaction

Create an explicit transaction when you need to decide commit and rollback
yourself. See [Transactions](transactions.md):

```pascal
LTransaction := LContext.CreateTransaction(
  TTTransactionMode.RollbackOnDestroy);
```

### CreateSession

Create a Unit of Work session. See [Sessions](sessions.md):

```pascal
LSession := LContext.CreateSession<TPerson>(LPersonList);
```

When the list comes from a lazy collection (a `TTLazyList<T>` field exposed as `TTList<T>`), `ApplyChanges` invalidates the underlying lazy list so it reloads from the database on next access:

```pascal
LSession := LContext.CreateSession<TOrder>(LCustomer.Orders);
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

Execute raw SQL and return a `TDataset`. For most use cases, prefer `RawSelect<T>` which also handles mapping automatically:

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

Validation also runs automatically before every `Insert`, `Update` and `Undelete` operation inside the resolver. See [Validation](validation.md) for details.

## Properties

| Property | Type | Description |
|---|---|---|
| `InTransaction` | `Boolean` | Whether the write connection has an active transaction |
| `SupportTransaction` | `Boolean` | Whether the write connection supports transactions |
| `UseIdentityMap` | `Boolean` | Whether the identity map is enabled for this context |
| `OnGetCurrentUser` | `TFunc<String>` | Callback that returns the current user name for change tracking `*By` fields |

### OnGetCurrentUser

Assign this property to provide the current user name for change tracking attributes (`[TCreatedBy]`, `[TUpdatedBy]`, `[TDeletedBy]`):

```pascal
LContext.OnGetCurrentUser :=
  function: String
  begin
    Result := GetCurrentUserName;
  end;
```

If not assigned, an empty string is written to `*By` fields. See [Entity Mapping — Change Tracking](entities.md#change-tracking) for details.

## Typical Usage Pattern

```pascal
LConnection := TTSQLiteConnection.Create('Main');
try
  LContext := TTContext.Create(LConnection);
  try
    // Read
    LPersons := LContext.CreateEntityList<TPerson>();
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

!!! note "Two contexts on one connection"
    From 2.0.0 a connection keeps a **list** of transaction observers, and a
    context registers its own on construction and removes them on
    destruction. Two contexts on the same connection are therefore both
    notified, and destroying one leaves the other working. Until 2.0.0 there
    was a single slot: the second context took it over and destroying it left
    it empty, so the first context's cache stopped hearing about commits and
    rollbacks, and an entity inserted inside a rolled-back transaction stayed
    marked as inserted.

    They still share one physical transaction, since the transaction belongs
    to the connection: a `RunInTransaction` on one context wraps what the
    other writes as well. Give each context its own connection when you want
    them independent. A context created while the connection is already in a
    transaction - inside a `RunInTransaction` of the other context, or after
    the host opened one - is told that the transaction has started, so its
    rollback rewinds its own entities too.

    **An entity belongs to the context that read or created it**: write it
    and free it through that context, never through the other one. Each
    context keeps its own rewind of the shared transaction and `FreeEntity<T>`
    tells only its own, so an entity read by one context, saved by the other
    and freed by the first makes a rollback write into freed memory. With the
    identity map on, `FreeEntity<T>` frees nothing, and the same fault comes
    when the first context is destroyed before the transaction ends. Nothing
    checks this today.

!!! warning "The context must be freed before the connection"
    The nesting above is not just tidiness. From 2.0.0 the context unhooks
    itself from the connection as it is destroyed: `BeforeDestruction` calls
    `RemoveTransactionObserver` on the connection. Freeing the connection
    first therefore touches memory that is already gone. Before 2.0.0 nothing
    in the context's destruction reached the connection, so the reverse order
    was harmless; it is not any more.
