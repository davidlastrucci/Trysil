# Core Types

## Type Aliases

| Type | Definition | Unit | Description |
|---|---|---|---|
| `TTPrimaryKey` | `Int32` | `Trysil.Types` | Primary key type (single integer) |
| `TTVersion` | `Int32` | `Trysil.Types` | Version column for optimistic locking |

### TTPrimaryKeyHelper

Class helper for `TTPrimaryKey`:

```pascal
TTPrimaryKeyHelper.SqlValue(AValue: TTPrimaryKey): String
```

Converts a primary key value to its SQL string representation.

## TTNullable&lt;T&gt;

Generic nullable wrapper for entity fields. See [Nullable Types](../guide/nullable.md) for full documentation.

```pascal
// Declaration
[TColumn('MiddleName')]
FMiddleName: TTNullable<String>;

// Create with value
LValue := TTNullable<String>.Create('John');

// Check and read
if not LValue.IsNull then
  ShowMessage(LValue.Value);

// Default values
LName := LValue.GetValueOrDefault;           // type default
LName := LValue.GetValueOrDefault('N/A');     // custom default

// Equality
if LValue1.Equals(LValue2) then ...

// Set to null
LValue := nil;
```

**Key points:**

- No default constructor — uninitialized state is null
- Supports implicit conversion from `T`
- Operators: `=`, `<>`
- Supported types: `String`, `Integer`, `Int64`, `Double`, `Boolean`, `TDateTime`, `TGUID`

## TTValue

Alias for `TValue` from `System.Rtti`. Used throughout the framework for filter parameters and column values.

## TTEventMethodType

Enum defining lifecycle event types:

| Value | Description |
|---|---|
| `BeforeInsert` | Before inserting a new record |
| `AfterInsert` | After inserting a new record |
| `BeforeUpdate` | Before updating an existing record |
| `AfterUpdate` | After updating an existing record |
| `BeforeDelete` | Before deleting a record |
| `AfterDelete` | After deleting a record |

## TTUpdateMode

Controls the WHERE clause strategy on UPDATE and DELETE commands:

| Value | Description |
|---|---|
| `KeyAndVersionColumn` | Default. Includes version column for optimistic locking |
| `KeyOnly` | Uses only the primary key (for tables without `[TVersionColumn]`) |

Set on the connection:

```pascal
LConnection.UpdateMode := TTUpdateMode.KeyOnly;
```

## Collections

### TTList&lt;T&gt;

Generic list with LINQ-style filtering. Unit: `Trysil.Generics.Collections`.

```pascal
var LPersons := TTList<TPerson>.Create;
try
  LContext.SelectAll<TPerson>(LPersons);

  // Filter with predicate
  var LPredicate: TTPredicate<TPerson> :=
    function(const AItem: TPerson): Boolean
    begin
      Result := AItem.Firstname = 'David';
    end;

  for var LPerson in LPersons.Where(LPredicate) do
    WriteLn(LPerson.Lastname);
finally
  LPersons.Free;
end;
```

Supports `ITEnumerable<T>` / `ITEnumerator<T>` for `for..in` loops.

### TTObjectList&lt;T&gt;

Owned list (`OwnsObjects = True`). Used internally by the framework for managing object lifetimes.

```pascal
// Default: OwnsObjects = True
var LList := TTObjectList<TPerson>.Create;

// Explicit OwnsObjects
var LList := TTObjectList<TPerson>.Create(False);
```

### TTHashList&lt;T&gt;

Hash-based set for fast lookups:

```pascal
var LSet := TTHashList<String>.Create;
try
  LSet.Add('value');
  if LSet.Contains('value') then ...
  LSet.Remove('value');
finally
  LSet.Free;
end;
```

## TTCache&lt;K, V&gt;

Generic key-value cache. Unit: `Trysil.Cache`.

Used internally by `TTMapper` and other components for caching computed results.

## TTRoundRobin&lt;T&gt;

Generic round-robin load balancer. Unit: `Trysil.LoadBalancing`.

```pascal
var LBalancer := TTRoundRobin<TTConnection>.Create;
try
  LBalancer.CreateItems(
    function: TTConnection
    begin
      Result := TTSqlServerConnection.Create('Main');
    end,
    4);  // pool of 4 connections

  // Each call returns the next item in rotation
  var LConnection := LBalancer.Next;
finally
  LBalancer.Free;
end;
```

Used by the HTTP layer to distribute requests across multiple backend nodes.
