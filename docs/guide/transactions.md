# Transactions

Transactions are implemented by `TTTransaction` (`Trysil.Transaction.pas`) and exposed through `TTContext`.

## RunInTransaction

The recommended form. It is a method of `TTContext`:

```pascal
LContext.RunInTransaction(
  procedure
  begin
    LContext.Insert<TOrder>(LOrder);
    LContext.Insert<TOrderLine>(LLine1);
    LContext.Insert<TOrderLine>(LLine2);
  end);
```

It commits when the procedure returns normally, and on an exception it rolls back and re-raises.

If a transaction is already active on the connection, the procedure **joins it** instead of opening a second one. A domain method that wraps itself in `RunInTransaction` is therefore atomic both when called on its own and when called from inside a larger transaction, without having to know which case it is in:

```pascal
procedure TOrderService.Confirm(const AOrder: TOrder);
begin
  FContext.RunInTransaction(
    procedure
    begin
      // ...
    end);
end;
```

## Explicit transactions

`CreateTransaction` takes a `TTTransactionMode` that decides what destruction means when neither `Commit` nor `Rollback` has been called:

| Mode | On destroy |
|---|---|
| `TTTransactionMode.RollbackOnDestroy` | rolls back |
| `TTTransactionMode.CommitOnDestroy` | commits |

```pascal
var LTransaction := LContext.CreateTransaction(
  TTTransactionMode.RollbackOnDestroy);
try
  LContext.Insert<TOrder>(LOrder);
  LContext.Insert<TOrderLine>(LLine);

  LTransaction.Commit;
finally
  LTransaction.Free;
end;
```

Prefer `RollbackOnDestroy`. Any path that leaves the block without reaching `Commit` — an exception included — rolls back, which makes the ordinary `try..finally` correct. With `CommitOnDestroy` the same `try..finally` commits partial work when the block is left through an exception, because there destruction is what commits.

`CreateTransaction` with no arguments is deprecated and maps to `CommitOnDestroy`.

## Behaviour

- **Start**: the transaction starts in `AfterConstruction`. If the connection is already in a transaction no local transaction is started, and the object does nothing for the rest of its life. Trysil does not use savepoints, so an inner transaction is not independent of the outer one. Creating a `RollbackOnDestroy` transaction inside another one raises, because it could not honour what it declares.
- **Commit and Rollback**: both clear the internal flag, so destruction never repeats work already done. A failed `Commit` attempts a rollback and re-raises, leaving the connection clean.
- **A failed commit puts the entities back among the new ones.** An entity created with `CreateEntity<T>` and inserted inside a transaction is tracked as already inserted; if the physical commit fails, that tracking is undone with the transaction, so a later `Save<T>` on the same instance issues an `INSERT` again rather than an `UPDATE`. Before 2.0.0 the tracking survived, and the next `Save<T>` updated a row that had never been written, failing with `ETConcurrentUpdateException` and blaming a concurrent change that had not happened.

!!! warning "What a failed commit assumes"
    Trysil reads a `Commit` that raises as a commit that did not happen, and
    the paragraph above is the consequence. A driver that raises **after** the
    database actually committed therefore leaves the entities marked as new,
    and the next `Save<T>` inserts a row that is already there - a primary key
    violation instead of a silent duplicate. If you write your own driver, do
    not raise from `InternalCommitTransaction` once the commit has gone
    through.
- **A rollback undoes what was written to the entities, not only to the rows.** Trysil writes to the entity as it writes to the database: `Insert` sets the creation audit and resets the version, `Update` and `Undelete` set the update audit and increment the version, `Undelete` also clears the delete audit, a soft `Delete` sets the delete audit and increments the version. Those writes are recorded for the duration of the transaction and reversed if it rolls back, so an entity never survives a failed unit of work carrying a version or a timestamp that no row has. It matters most in a batch: when the fifth `Update` of an `ApplyAll` fails, the four that succeeded have already been incremented in memory, and without the rewind every later `Update` on those four would raise `ETConcurrentUpdateException` for ever.

!!! warning "Free an entity with FreeEntity<T>, never with Free"
    The rewind holds a reference to every entity it has written to until the
    transaction ends. `FreeEntity<T>` tells it to forget the entity before
    freeing it, and so does a list built by `CreateEntityList<T>` - which is
    every list the framework owns, the one inside a `TTLazyList<T>` included.
    A bare `LEntity.Free`, or an owning list you built yourself with
    `TTObjectList<T>.Create(True)`, does not: if the transaction then rolls
    back, the rewind writes into freed memory, with no exception and no
    message. The usual `try..finally` frees the inner objects before the outer
    transaction ends, so this is the ordinary shape of the code, not a corner
    case. And it does not take a transaction of your own: an event that writes
    another entity runs inside the transaction Trysil opened for the write
    that fired it. **Free entities with `FreeEntity<T>` and build lists with
    `CreateEntityList<T>`**, everywhere, with the exceptions in
    [who frees what](context.md#who-frees-what): a clone and an object you
    built yourself go through `FreeClone<T>`, and the result of a
    `RawSelect<T>` stays yours. And do it
    through the context that read or created the entity: two contexts on one connection share the transaction
    but not the rewind, and an entity written by one and freed by the other
    is the same fault.
- **Destruction**: whatever happens there is silent by design. An exception escaping a destructor would replace the error that caused the unwind with a less useful one, and would stop the instance from being freed.
- **Internal use**: single writes (`Insert`, `Update`, `Delete`), the batch methods (`InsertAll`, `UpdateAll`, `DeleteAll`, `ApplyAll`) and `TTSession<T>.ApplyChanges` are already wrapped. You need a transaction of your own only to make several of those atomic together.

## Checking transaction state

```pascal
if LContext.InTransaction then
  WriteLn('Transaction is active');

if LContext.SupportTransaction then
  WriteLn('Connection supports transactions');
```

| Property | Description |
|---|---|
| `InTransaction` | `True` if the write connection currently has an active transaction |
| `SupportTransaction` | `True` if the write connection supports transaction management |

## Transactions with a session

`TTSession<T>.ApplyChanges` opens its own transaction only when none is active, so it joins the surrounding one:

```pascal
LContext.RunInTransaction(
  procedure
  begin
    LSession.ApplyChanges;
    LContext.Insert<TAuditLog>(LAuditEntry);
  end);
```
