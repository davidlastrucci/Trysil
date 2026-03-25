# Transactions

`TTTransaction` wraps explicit transaction management in Trysil. It is defined in `Trysil.Transaction.pas`.

## Basic Usage

```pascal
var LTransaction := LContext.CreateTransaction;
try
  LContext.Insert<TOrder>(LOrder);
  LContext.Insert<TOrderLine>(LLine1);
  LContext.Insert<TOrderLine>(LLine2);
  // Auto-commits when LTransaction is freed
finally
  LTransaction.Free;
end;
```

The transaction starts automatically on construction (`AfterConstruction`) and commits automatically on destruction (`BeforeDestruction`). There is no need to call a `Commit` method explicitly.

## Rollback

To abort a transaction, call `Rollback` before the transaction is freed:

```pascal
var LTransaction := LContext.CreateTransaction;
try
  try
    LContext.Insert<TOrder>(LOrder);
    LContext.Insert<TOrderLine>(LLine);
    // Something fails...
  except
    LTransaction.Rollback;
    raise;
  end;
finally
  LTransaction.Free;
end;
```

After `Rollback` is called, the auto-commit on destruction is skipped.

## Behavior

- **Auto-start**: The transaction starts in `AfterConstruction`. If the connection already has an active transaction, a new local transaction is not started (nested transaction support depends on the database driver).
- **Auto-commit**: The transaction commits in `BeforeDestruction`, unless `Rollback` was called or the connection does not support transactions.
- **Internal use**: The resolver uses `TTTransaction` internally for write operations (`Insert`, `Update`, `Delete`). When you use `InsertAll`, `UpdateAll`, `DeleteAll`, or `ApplyAll`, the context wraps the batch in a transaction automatically.

## Checking Transaction State

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

## Transaction with Session

When using `TTSession<T>.ApplyChanges`, the session creates its own transaction if one is not already active. You can wrap the session in an explicit transaction to combine it with other operations:

```pascal
var LTransaction := LContext.CreateTransaction;
try
  try
    LSession.ApplyChanges;
    LContext.Insert<TAuditLog>(LAuditEntry);
  except
    LTransaction.Rollback;
    raise;
  end;
finally
  LTransaction.Free;
end;
```
