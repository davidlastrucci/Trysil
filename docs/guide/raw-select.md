# Raw Select

For queries that attributes cannot express -- subqueries, UNIONs, GROUP BY, aggregations, CTEs -- `RawSelect<T>` maps raw SQL results to DTO classes.

## Method Signature

```pascal
procedure RawSelect<T: class>(
  const ASQL: String; const AResult: TTList<T>);
```

Defined on `TTContext` (`Trysil.Context.pas`), delegated to `TTProvider`.

## DTO Classes

DTO classes only need `[TColumn]` attributes matching the SQL result column names. `[TTable]`, `[TPrimaryKey]`, and `[TSequence]` are **not required**:

```pascal
type
  TOrderSummary = class
  strict private
    [TColumn('CustomerName')]
    FCustomerName: String;

    [TColumn('OrderCount')]
    FOrderCount: Integer;

    [TColumn('Total')]
    FTotal: Currency;
  public
    property CustomerName: String read FCustomerName;
    property OrderCount: Integer read FOrderCount;
    property Total: Currency read FTotal;
  end;
```

The column names in `[TColumn]` must match the column names (or aliases) in the SQL result set exactly.

## Usage

```pascal
LResult := TTObjectList<TOrderSummary>.Create;
try
  LContext.RawSelect<TOrderSummary>(
    'SELECT c.CompanyName AS CustomerName, ' +
    '       COUNT(*) AS OrderCount, ' +
    '       SUM(o.Amount) AS Total ' +
    'FROM Orders o ' +
    'JOIN Customers c ON o.CustomerID = c.ID ' +
    'GROUP BY c.CompanyName ' +
    'ORDER BY Total DESC',
    LResult);

  for LItem in LResult do
    WriteLn(Format('%s: %d orders, total %.2f', [
      LItem.CustomerName, LItem.OrderCount, LItem.Total]));
finally
  LResult.Free;
end;
```

## Behavior

| Aspect | Behavior |
|---|---|
| **Read-only** | Results must not be written - inserted, updated, deleted or undeleted: nothing stops a row whose class carries a key and a version column, or only a key under `KeyOnly` (and a `[TDeletedAt]` column for an undelete), see [the context](context.md#rawselect) |
| **Identity map** | Not used |
| **Lazy loading** | Lazy members are mapped as on any read: a row that carries one goes in a `TTList<T>` that owns nothing and is freed with `FreeClone<T>` (see [who frees what](context.md#who-frees-what)) |
| **Validation** | Not executed |
| **Events** | Not fired |
| **Mapping** | Based on `[TColumn]` -- SQL column name must match exactly |

## When to Use

Use `RawSelect<T>` when you need:

- **Aggregations**: `SUM`, `COUNT`, `AVG`, `MIN`, `MAX` with `GROUP BY`
- **Subqueries**: correlated or derived-table subqueries
- **UNION / UNION ALL**: combining results from multiple tables
- **CTEs**: `WITH` clauses for recursive or staged queries
- **Database-specific functions**: window functions, pivots, etc.

For simple multi-table queries (one-to-one or one-to-many joins), prefer [JOIN Queries](joins.md) with declarative attributes instead.

## Compared to CreateDataset

`TTContext.CreateDataset` also executes raw SQL but returns a raw `TDataset`. `RawSelect<T>` adds automatic RTTI-based mapping to typed objects, so you get type-safe access to result fields instead of calling `FieldByName` manually.

```pascal
// CreateDataset -- manual field access
LDataset := LContext.CreateDataset('SELECT COUNT(*) AS Total FROM Orders');
try
  Writeln(LDataset.FieldByName('Total').AsInteger);
finally
  LDataset.Free;
end;

// RawSelect -- typed access
LContext.RawSelect<TCountResult>(
  'SELECT COUNT(*) AS Total FROM Orders', LResult);
Writeln(LResult[0].Total);
```

## See Also

- [JOIN Queries](joins.md) -- declarative multi-table queries via attributes
- [Context](context.md) -- CRUD operations
- [Filtering](filtering.md) -- WHERE clauses for single-table queries
