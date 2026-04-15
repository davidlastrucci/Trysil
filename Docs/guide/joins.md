# JOIN Queries

Trysil supports declarative multi-table SELECT queries using `[TJoin]` attributes. Join entities are **read-only** -- `Insert`, `Update`, and `Delete` raise `ETException`.

## TJoinKind

```pascal
TJoinKind = (Inner, Left, Right);
```

A scoped enum defined in `Trysil.Attributes.pas` that specifies the type of SQL JOIN.

## TJoinAttribute

Apply one or more `[TJoin]` attributes to the entity class. Three overloads are available.

### Simple JOIN

Join another table using columns from the FROM table:

```pascal
[TTable('Orders')]
[TSequence('OrdersID')]
[TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
TOrderReport = class
```

Parameters:

1. **JoinKind** -- `Inner`, `Left`, or `Right`
2. **TableName** -- the table to join (also used as the alias)
3. **SourceColumnName** -- column from the FROM table
4. **TargetColumnName** -- column from the joined table

Generated SQL:

```sql
SELECT ... FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.ID
```

### Self-JOIN with Alias

When joining the same table twice, provide an explicit alias:

```pascal
[TTable('Movimenti')]
[TSequence('MovimentiID')]
[TJoin(TJoinKind.Inner, 'PianoDeiConti', 'ContoDare', 'ContoDareID', 'ID')]
[TJoin(TJoinKind.Inner, 'PianoDeiConti', 'ContoAvere', 'ContoAvereID', 'ID')]
TMovimentoContabile = class
```

Parameters:

1. **JoinKind** -- join type
2. **TableName** -- the table to join
3. **Alias** -- unique alias for this join instance
4. **SourceColumnName** -- column from the FROM table
5. **TargetColumnName** -- column from the joined table

Generated SQL:

```sql
SELECT ... FROM Movimenti
INNER JOIN PianoDeiConti ContoDare ON Movimenti.ContoDareID = ContoDare.ID
INNER JOIN PianoDeiConti ContoAvere ON Movimenti.ContoAvereID = ContoAvere.ID
```

### Chained JOIN

Join a table using a column from a **previous join** instead of the FROM table:

```pascal
[TTable('Orders')]
[TSequence('OrdersID')]
[TJoin(TJoinKind.Inner, 'Customers', 'Customers', 'CustomerID', 'ID')]
[TJoin(TJoinKind.Left, 'Countries', 'Countries', 'Customers', 'CountryID', 'ID')]
TOrderWithCountry = class
```

Parameters:

1. **JoinKind** -- join type
2. **TableName** -- the table to join
3. **Alias** -- unique alias
4. **SourceTableOrAlias** -- table name or alias of a previous join
5. **SourceColumnName** -- column from the source table/alias
6. **TargetColumnName** -- column from the joined table

Generated SQL:

```sql
SELECT ... FROM Orders
INNER JOIN Customers Customers ON Orders.CustomerID = Customers.ID
LEFT JOIN Countries Countries ON Customers.CountryID = Countries.ID
```

## Mapping Joined Columns

Use the two-parameter overload of `[TColumn]` to map a field to a column from a joined table:

```pascal
[TColumn('Customers', 'CompanyName')]
FCustomerName: String;
```

- First parameter: the **alias** of the joined table (must match the alias from `[TJoin]`)
- Second parameter: the **column name** in that table

Fields without a table parameter are mapped to the FROM table as usual:

```pascal
[TColumn('OrderDate')]
FOrderDate: TDateTime;
```

## Complete Example

```pascal
unit Model.OrderReport;

interface

uses
  Trysil.Types,
  Trysil.Attributes;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

type

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TOrderReport = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('OrderDate')]
    FOrderDate: TDateTime;

    [TColumn('Amount')]
    FAmount: Double;

    [TColumn('Customers', 'CompanyName')]
    FCustomerName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property OrderDate: TDateTime read FOrderDate;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
  end;

implementation

end.
```

Generated SQL:

```sql
SELECT Orders.ID AS Orders_ID,
       Orders.OrderDate AS Orders_OrderDate,
       Orders.Amount AS Orders_Amount,
       Customers.CompanyName AS Customers_CompanyName,
       Orders.VersionID AS Orders_VersionID
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.ID
ORDER BY Orders.ID
```

## Querying Join Entities

Join entities are queried exactly like single-table entities:

```pascal
LOrders := TTObjectList<TOrderReport>.Create;
try
  // Load all
  LContext.SelectAll<TOrderReport>(LOrders);

  // With filter
  LContext.Select<TOrderReport>(LOrders, LFilter);

  // Count
  LCount := LContext.SelectCount<TOrderReport>(LFilter);
finally
  LOrders.Free;
end;
```

## Behavior

### Read-Only

Join entities cannot be written. Calling `Insert<T>`, `Update<T>`, or `Delete<T>` on a join entity raises `ETException` with the message *"Join entities are read-only: Insert, Update, and Delete are not supported."*

### Identity Map

The identity map is **bypassed** for join entities. The same primary key can appear in multiple result rows with different joined data, so caching by PK would produce incorrect results.

### Soft Delete

When the FROM-table entity has a `[TDeletedAt]` column, the automatic `DeletedAt IS NULL` filter is qualified with the FROM table name to avoid ambiguity:

```sql
-- Without joins
WHERE DeletedAt IS NULL

-- With joins
WHERE Orders.DeletedAt IS NULL
```

### Backward Compatibility

All join-related changes are behind `HasJoins` checks. Existing single-table entities are completely unaffected.

## Limitations (v1)

- **TTFilterBuilder\<T\>** does not resolve join aliases. For filtered queries on join entities, use `TTFilter.Create(whereClause)` with manually qualified column names:

```pascal
var LFilter := TTFilter.Create('Customers.CompanyName LIKE :Name');
LFilter.AddParameter('Name', ftWideString, 'Acme%');
LContext.Select<TOrderReport>(LOrders, LFilter);
```

- **TWhereClause** on join entities requires manually qualified column names.

## See Also

- [Raw Select](raw-select.md) -- for queries that attributes cannot express
- [Entity Mapping](entities.md) -- standard attribute-based mapping
- [Filtering](filtering.md) -- WHERE clauses and query builder
- [Context](context.md) -- CRUD operations
