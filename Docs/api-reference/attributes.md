# Attributes

Complete reference of all Trysil attributes.

## Entity Mapping

Unit: `Trysil.Attributes`

| Attribute | Target | Description |
|---|---|---|
| `TTable(name)` | Class | Maps class to database table |
| `TSequence(name)` | Class | Sequence for ID generation |
| `TPrimaryKey` | Field | Marks primary key field |
| `TColumn(name)` | Field | Maps field to database column |
| `TDetailColumn(fk, name)` | Field | Maps a detail/lookup column |
| `TVersionColumn` | Field | Enables optimistic locking |
| `TRelation(table, fk, cascade)` | Class | Declares child relationship |
| `TWhereClause(sql)` | Class | Adds fixed WHERE clause to all queries |
| `TWhereClauseParameter(name, value)` | Class | Parameter for `TWhereClause` |

### TTable

```pascal
[TTable('Persons')]
TPerson = class
```

Maps the entity class to a database table. Required on every entity.

### TSequence

```pascal
[TSequence('PersonsID')]
TPerson = class
```

Names the database sequence used for ID generation. Behavior varies by database:

- **SQL Server**: `NEXT VALUE FOR [dbo].[PersonsID]`
- **PostgreSQL**: `nextval('PersonsID')`
- **Firebird**: `NEXT VALUE FOR PersonsID`
- **SQLite**: `AUTOINCREMENT` (sequence name used as reference)

### TPrimaryKey

```pascal
[TPrimaryKey]
[TColumn('ID')]
FID: TTPrimaryKey;
```

Marks the primary key field. Must be `TTPrimaryKey` (`Int32`). One per entity.

### TColumn

```pascal
[TColumn('Firstname')]
FFirstname: String;
```

Maps a field to a database column by name. The field must be `strict private`.

### TDetailColumn

```pascal
[TDetailColumn('CompanyID', 'CompanyName')]
FCompanyName: String;
```

Maps a read-only column from a related table. First parameter is the foreign key column, second is the detail column name.

### TVersionColumn

```pascal
[TVersionColumn]
[TColumn('VersionID')]
FVersionID: TTVersion;
```

Enables optimistic locking. The version is incremented on each update. If another transaction has modified the record (version mismatch), `ETConcurrentUpdateException` is raised.

### TRelation

```pascal
[TRelation('Employees', 'CompanyID', False)]
TCompany = class
```

Parameters:

1. **Child table name** — the table that references this entity
2. **Foreign key column** — the column in the child table
3. **Cascade delete** — `True`: auto-delete children; `False`: block delete if children exist (raises `ETDataIntegrityException`)

Multiple `TRelation` attributes can be applied to the same class.

### TWhereClause / TWhereClauseParameter

```pascal
[TTable('Users')]
[TWhereClause('Active = :Active AND Role = :Role')]
[TWhereClauseParameter('Active', True)]
[TWhereClauseParameter('Role', 'admin')]
TActiveAdmin = class
```

Adds a fixed WHERE clause to every query on this entity. Parameters are **compile-time constants only**. For dynamic filtering, use [`TTFilterBuilder<T>`](../guide/filtering.md).

`TWhereClauseParameter` constructors accept: `String`, `Integer`, `Int64`, `Double`, `Boolean`, `TDateTime`.

---

## Validation

Unit: `Trysil.Validation.Attributes`

| Attribute | Description | Signature |
|---|---|---|
| `TRequired` | Not empty, null, or zero | `Create` or `Create(errorMsg)` |
| `TMaxLength(n)` | Maximum string length | `Create(length)` or `Create(length, errorMsg)` |
| `TMinLength(n)` | Minimum string length | `Create(length)` or `Create(length, errorMsg)` |
| `TMaxValue(n)` | Maximum numeric value | `Create(Integer\|Double)` or with `errorMsg` |
| `TMinValue(n)` | Minimum numeric value | `Create(Integer\|Double)` or with `errorMsg` |
| `TGreater(n)` | Greater than n | `Create(Integer\|Double)` or with `errorMsg` |
| `TLess(n)` | Less than n | `Create(Integer\|Double)` or with `errorMsg` |
| `TRange(min, max)` | Value in range | `Create(min, max)` or with `errorMsg` |
| `TRegex(pattern)` | Matches regex pattern | `Create(regex)` or `Create(regex, errorMsg)` |
| `TEmail` | Valid email format | `Create` or `Create(errorMsg)` |
| `TDisplayName(name)` | Human-readable field name for errors | `Create(displayName)` |
| `TValidator` | Marks custom validator method | Marker attribute |

### Examples

```pascal
[TRequired]
[TMaxLength(50)]
[TColumn('Firstname')]
FFirstname: String;

[TMinValue(0)]
[TMaxValue(100)]
[TColumn('Score')]
FScore: Integer;

[TEmail('Please enter a valid email')]
[TColumn('Email')]
FEmail: String;

[TRange(1, 999)]
[TDisplayName('Order Number')]
[TColumn('OrderNo')]
FOrderNo: Integer;

[TRegex('^\+?[0-9\s\-]+$', 'Invalid phone number')]
[TColumn('Phone')]
FPhone: String;
```

All validation attributes optionally accept a custom error message as the last parameter. If omitted, a default message is generated using the `TDisplayName` (if present) or the column name.

---

## Events

Unit: `Trysil.Events.Attributes`

### Class-Level Event Attributes

Register an event class for an entity:

| Attribute | Description |
|---|---|
| `TInsertEvent(eventClass)` | Event class for insert operations |
| `TUpdateEvent(eventClass)` | Event class for update operations |
| `TDeleteEvent(eventClass)` | Event class for delete operations |

```pascal
[TInsertEvent(TPersonInsertEvent)]
[TUpdateEvent(TPersonUpdateEvent)]
[TDeleteEvent(TPersonDeleteEvent)]
TPerson = class
```

### Method-Level Event Attributes

Declare event methods directly on the entity:

| Attribute | Description |
|---|---|
| `TBeforeInsert` | Method called before insert |
| `TAfterInsert` | Method called after insert |
| `TBeforeUpdate` | Method called before update |
| `TAfterUpdate` | Method called after update |
| `TBeforeDelete` | Method called before delete |
| `TAfterDelete` | Method called after delete |

```pascal
TPerson = class
strict private
  [TBeforeInsert]
  procedure OnBeforeInsert;
  [TAfterUpdate]
  procedure OnAfterUpdate;
end;
```

See [Events](../guide/events.md) for detailed usage.

---

## JSON

Unit: `Trysil.JSon.Attributes`

| Attribute | Description |
|---|---|
| `TJSonIgnore` | Exclude field from JSON serialization/deserialization |

```pascal
[TJSonIgnore]
[TColumn('InternalHash')]
FInternalHash: String;
```

See [JSON Module](../json/index.md) for serialization documentation.

---

## HTTP

Unit: `Trysil.Http.Attributes`

### Routing

| Attribute | Description |
|---|---|
| `TUri(path)` | Controller base URI |
| `TGet` / `TGet(path)` | GET endpoint |
| `TPost` / `TPost(path)` | POST endpoint |
| `TPut` / `TPut(path)` | PUT endpoint |
| `TDelete` / `TDelete(path)` | DELETE endpoint |

URL parameters use `?` as placeholder:

```pascal
[TUri('/api/persons')]
TPersonController = class(TTHttpController<TAPIContext>)
public
  [TGet]            // GET /api/persons
  procedure GetAll;

  [TGet('/?')]      // GET /api/persons/123
  procedure GetById(const AID: TTPrimaryKey);

  [TPost]           // POST /api/persons
  procedure Insert;

  [TPut]            // PUT /api/persons
  procedure Update;

  [TDelete('/?/?')] // DELETE /api/persons/123/1
  procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);
end;
```

### Authentication & Authorization

| Attribute | Description |
|---|---|
| `TAuthorizationType(type)` | Authentication requirement for controller |
| `TArea(name)` | Required authorization area for method |

```pascal
// No authentication required
[TAuthorizationType(TTHttpAuthorizationType.None)]
TLogonController = class(TTHttpController<TAPIContext>)

// Require 'admin' area
[TGet]
[TArea('admin')]
procedure GetSettings;
```

`TTHttpAuthorizationType` values:

- `None` — no authentication required
- `Authentication` — authentication required (default)

See [HTTP Module](../http/index.md) for full documentation.
