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
