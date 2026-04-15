# Cookbook

Practical, copy-paste recipes for common Trysil tasks. Each recipe is self-contained -- jump to what you need.

## Pagination

Load a page of results with offset and limit:

```pascal
var LBuilder := LContext.CreateFilterBuilder<TPerson>();
try
  var LFilter := LBuilder
    .Where('Active').Equal(True)
    .OrderByAsc('Lastname')
    .Limit(20)
    .Offset(40)   // skip first 2 pages
    .Build;

  LContext.Select<TPerson>(LPersons, LFilter);
finally
  LBuilder.Free;
end;
```

Count total records for the pager UI:

```pascal
var LBuilder := LContext.CreateFilterBuilder<TPerson>();
try
  var LFilter := LBuilder
    .Where('Active').Equal(True)
    .Build;

  LTotal := LContext.SelectCount<TPerson>(LFilter);
finally
  LBuilder.Free;
end;
```

## Combining AND / OR Conditions

```pascal
var LBuilder := LContext.CreateFilterBuilder<TPerson>();
try
  var LFilter := LBuilder
    .Where('Lastname').Equal('Smith')
    .OrWhere('Lastname').Equal('Jones')
    .AndWhere('Active').Equal(True)
    .Build;

  LContext.Select<TPerson>(LPersons, LFilter);
finally
  LBuilder.Free;
end;
```

!!! note
    Conditions are combined in declaration order. The builder does not support explicit grouping with parentheses. For complex grouping, use `TTFilter.Create` with a raw WHERE clause.

## Raw WHERE with Parameters

When the fluent builder is not enough, use `TTFilter` directly:

```pascal
var LFilter := TTFilter.Create(
  '(Lastname = :Name OR Firstname = :Name) AND Age >= :MinAge');
LFilter.AddParameter('Name', ftWideString, 'David');
LFilter.AddParameter('MinAge', ftInteger, 18);

LContext.Select<TPerson>(LPersons, LFilter);
```

Always use named parameters (`:ParamName`) -- never concatenate values into SQL strings.

## Insert and Read Back the ID

```pascal
var LPerson := LContext.CreateEntity<TPerson>();
try
  LPerson.Firstname := 'David';
  LPerson.Lastname := 'Lastrucci';
  LContext.Insert<TPerson>(LPerson);

  Writeln(Format('New ID: %d', [LPerson.ID]));  // ID is populated after insert
finally
  LPerson.Free;
end;
```

`CreateEntity<T>` initializes the entity with a sequence-generated ID. Always use it instead of calling `TPerson.Create` directly.

## Save (Insert or Update Automatically)

`Save<T>` determines whether to insert or update based on the internal new-entity cache:

```pascal
var LPerson := LContext.CreateEntity<TPerson>();
try
  LPerson.Firstname := 'Alice';
  LContext.Save<TPerson>(LPerson);    // INSERT (new entity)

  LPerson.Lastname := 'Smith';
  LContext.Save<TPerson>(LPerson);    // UPDATE (already persisted)
finally
  LPerson.Free;
end;
```

## Batch Operations with ApplyAll

Insert, update, and delete multiple entities in a single transaction:

```pascal
var
  LInsertList: TTList<TPerson>;
  LUpdateList: TTList<TPerson>;
  LDeleteList: TTList<TPerson>;
begin
  LInsertList := TTList<TPerson>.Create;
  LUpdateList := TTList<TPerson>.Create;
  LDeleteList := TTList<TPerson>.Create;
  try
    // Prepare inserts
    LPerson := LContext.CreateEntity<TPerson>();
    LPerson.Firstname := 'New';
    LInsertList.Add(LPerson);

    // Prepare updates
    LUpdateList.Add(LExistingPerson);
    LExistingPerson.Lastname := 'Updated';

    // Prepare deletes
    LDeleteList.Add(LObsoletePerson);

    // Execute all in one transaction
    LContext.ApplyAll<TPerson>(LInsertList, LUpdateList, LDeleteList);
  finally
    LDeleteList.Free;
    LUpdateList.Free;
    LInsertList.Free;
  end;
end;
```

## Explicit Transactions

Wrap multiple operations in a transaction with automatic commit/rollback:

```pascal
var LTransaction := LContext.CreateTransaction;
try
  LContext.Insert<TOrder>(LOrder);
  LContext.Insert<TOrderDetail>(LDetail1);
  LContext.Insert<TOrderDetail>(LDetail2);
  // auto-commits on Free
finally
  LTransaction.Free;
end;
```

To roll back explicitly:

```pascal
var LTransaction := LContext.CreateTransaction;
try
  try
    LContext.Insert<TOrder>(LOrder);
    LContext.Update<TProduct>(LProduct);
  except
    LTransaction.Rollback;
    raise;
  end;
finally
  LTransaction.Free;
end;
```

## Lazy Loading a Related Entity

Define a lazy field on the entity:

```pascal
type
  [TTable('Orders')]
  [TSequence('OrdersID')]
  TOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FCustomer: TTLazy<TCustomer>;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Customer: TTLazy<TCustomer> read FCustomer;
  end;
```

Use it -- the related entity is loaded on first access:

```pascal
LContext.SelectAll<TOrder>(LOrders);
for LOrder in LOrders do
  Writeln(LOrder.Customer.Value.Name);  // loads TCustomer on first call
```

!!! warning
    Each `TTLazy<T>` access triggers a separate SELECT. Loading a lazy field inside a loop causes N+1 queries. For bulk operations, consider loading related entities upfront with a separate `SelectAll`.

## Lazy Loading a Detail List

```pascal
type
  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TRelation('OrderDetails', 'OrderID', True)]
  TOrder = class
  strict private
    // ...
    [TDetailColumn('ID', 'OrderID')]
    FDetails: TTLazyList<TOrderDetail>;
  public
    property Details: TTLazyList<TOrderDetail> read FDetails;
  end;
```

```pascal
LOrder := LContext.Get<TOrder>(LOrderID);
for LDetail in LOrder.Details.Value do
  Writeln(Format('  %s x%d', [LDetail.ProductName, LDetail.Quantity]));
```

## Nullable Fields

Use `TTNullable<T>` for columns that can be NULL:

```pascal
type
  [TTable('Persons')]
  TPerson = class
  strict private
    [TColumn('Email')]
    FEmail: TTNullable<String>;
  public
    property Email: TTNullable<String> read FEmail write FEmail;
  end;
```

```pascal
// Set a value
LPerson.Email := TTNullable<String>.Create('david@example.com');

// Check and read
if not LPerson.Email.IsNull then
  Writeln(LPerson.Email.Value);

// Set to null (default state)
LPerson.Email := Default(TTNullable<String>);
```

## Validation with Attributes

```pascal
type
  [TTable('Products')]
  TProduct = class
  strict private
    [TRequired]
    [TMaxLength(100)]
    [TColumn('Name')]
    FName: String;

    [TRequired]
    [TRange(0.01, 99999.99)]
    [TColumn('Price')]
    FPrice: Double;

    [TEmail]
    [TColumn('ContactEmail')]
    FContactEmail: String;

    [TRegex('^[A-Z]{2}-\d{4}$')]
    [TColumn('Code')]
    FCode: String;
  end;
```

Validation runs automatically on `Insert` and `Update`. To validate manually:

```pascal
var LErrors := LContext.Validate<TProduct>(LProduct);
if LErrors.Count > 0 then
  for LError in LErrors do
    Writeln(LError);
```

## Custom Validation with Event Methods

```pascal
type
  [TTable('Orders')]
  TOrder = class
  strict private
    FTotal: Double;
    FDiscount: Double;
  public
    [TBeforeInsertEvent]
    [TBeforeUpdateEvent]
    procedure ValidateDiscount;
  end;

procedure TOrder.ValidateDiscount;
begin
  if FDiscount > FTotal then
    raise ETValidationException.Create('Discount cannot exceed total');
end;
```

## JOIN Query

Define a join entity and query it:

```pascal
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

    [TColumn('Customers', 'CompanyName')]
    FCustomerName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property OrderDate: TDateTime read FOrderDate;
    property CustomerName: String read FCustomerName;
  end;
```

```pascal
LOrders := TTObjectList<TOrderReport>.Create;
try
  LContext.SelectAll<TOrderReport>(LOrders);
  for LOrder in LOrders do
    WriteLn(Format('Order %d: %s (%s)', [
      LOrder.ID,
      LOrder.CustomerName,
      DateToStr(LOrder.OrderDate)]));
finally
  LOrders.Free;
end;
```

Join entities are read-only. See [JOIN Queries](joins.md) for all overloads and details.

## Raw Select with GROUP BY

Map aggregation results to a DTO class:

```pascal
type
  TOrderSummary = class
  strict private
    [TColumn('CustomerName')]
    FCustomerName: String;

    [TColumn('OrderCount')]
    FOrderCount: Integer;

    [TColumn('Total')]
    FTotal: Double;
  public
    property CustomerName: String read FCustomerName;
    property OrderCount: Integer read FOrderCount;
    property Total: Double read FTotal;
  end;
```

```pascal
LResult := TTObjectList<TOrderSummary>.Create;
try
  LContext.RawSelect<TOrderSummary>(
    'SELECT c.CompanyName AS CustomerName, ' +
    '       COUNT(*) AS OrderCount, ' +
    '       SUM(o.Amount) AS Total ' +
    'FROM Orders o ' +
    'JOIN Customers c ON o.CustomerID = c.ID ' +
    'GROUP BY c.CompanyName',
    LResult);

  for LItem in LResult do
    WriteLn(Format('%s: %d orders, total %.2f', [
      LItem.CustomerName, LItem.OrderCount, LItem.Total]));
finally
  LResult.Free;
end;
```

DTO classes only need `[TColumn]` attributes -- no `[TTable]`, `[TPrimaryKey]`, or `[TSequence]` required. See [Raw Select](raw-select.md).

## JSON Round-Trip

Serialize an entity to JSON and back:

```pascal
var
  LJSonContext: TTJSonContext;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LPerson: TPerson;
begin
  LJSonContext := TTJSonContext.Create(LConnection);
  try
    LConfig := TTJSonSerializerConfig.Create(-1, False);

    // Entity to JSON
    LJson := LJSonContext.EntityToJSon<TPerson>(LPerson, LConfig);

    // JSON to Entity
    LPerson := LJSonContext.EntityFromJSon<TPerson>(LJson);
  finally
    LJSonContext.Free;
  end;
end;
```

Serialize a list:

```pascal
LJson := LJSonContext.ListToJSon<TPerson>(LPersons, LConfig);
```

## Exclude Fields from JSON

```pascal
type
  [TTable('Users')]
  TUser = class
  strict private
    [TColumn('Username')]
    FUsername: String;

    [TJSonIgnore]
    [TColumn('PasswordHash')]
    FPasswordHash: String;
  end;
```

Fields decorated with `[TJSonIgnore]` are excluded from serialization.

## SQLite In-Memory Database for Testing

```pascal
TTSQLiteConnection.RegisterConnection('Test', ':memory:');
LConnection := TTSQLiteConnection.Create('Test');
try
  // Create schema
  LConnection.Execute(
    'CREATE TABLE Persons (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  Firstname TEXT,' +
    '  Lastname TEXT,' +
    '  VersionID INTEGER DEFAULT 0)');

  LContext := TTContext.Create(LConnection);
  try
    // ... run tests against in-memory database
  finally
    LContext.Free;
  end;
finally
  LConnection.Free;
end;
```

This is the recommended approach for integration tests -- fast, isolated, no cleanup needed.

## Structured Logging

Register a custom logger to capture SQL activity:

```pascal
type
  TMyLogger = class(TTAbstractLogger)
  public
    procedure LogEvent(const AEvent: TTLoggerEvent;
      const AItem: TTLoggerItem); override;
  end;

procedure TMyLogger.LogEvent(const AEvent: TTLoggerEvent;
  const AItem: TTLoggerItem);
begin
  case AEvent of
    TTLoggerEvent.Syntax:
      Writeln(Format('[SQL] %s', [AItem.Text]));
    TTLoggerEvent.Parameter:
      Writeln(Format('[PARAM] %s = %s', [AItem.Name, AItem.Text]));
    TTLoggerEvent.Error:
      Writeln(Format('[ERR] %s', [AItem.Text]));
  end;
end;
```

```pascal
TTLogger.Instance.RegisterLogger(TMyLogger.Create);
```

Log items carry a `TTLoggerItemID` (connection ID + thread ID) for multi-threaded correlation.

## Optimistic Locking

Add a `[TVersionColumn]` field to your entity:

```pascal
type
  [TTable('Products')]
  TProduct = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  end;
```

Trysil automatically increments `VersionID` on each update and includes it in the WHERE clause. If another user has modified the record since it was loaded, the update raises `ETConcurrentUpdateException`.

```pascal
try
  LContext.Update<TProduct>(LProduct);
except
  on E: ETConcurrentUpdateException do
    ShowMessage('Record modified by another user. Please reload and try again.');
end;
```
