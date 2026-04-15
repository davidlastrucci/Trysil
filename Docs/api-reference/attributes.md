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
| `TJoin(kind, table, ...)` | Class | Declares a JOIN for multi-table SELECT |
| `TColumn(alias, name)` | Field | Maps field to a joined table column (2-param overload) |
| `TCreatedAt` | Field | Timestamp set on insert (`TTNullable<TDateTime>`) |
| `TCreatedBy` | Field | User name set on insert (`String`) |
| `TUpdatedAt` | Field | Timestamp set on update (`TTNullable<TDateTime>`) |
| `TUpdatedBy` | Field | User name set on update (`String`) |
| `TDeletedAt` | Field | Timestamp set on delete — enables soft delete (`TTNullable<TDateTime>`) |
| `TDeletedBy` | Field | User name set on delete (`String`) |

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

A two-parameter overload maps a field to a column from a joined table:

```pascal
[TColumn('Customers', 'CompanyName')]
FCustomerName: String;
```

The first parameter is the **alias** of the joined table (must match the alias from `[TJoin]`), the second is the **column name**. See [JOIN Queries](../guide/joins.md).

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

### TJoin

Declares a JOIN for multi-table SELECT queries. Three overloads:

**Simple JOIN** -- join using FROM table columns:

```pascal
[TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
```

Parameters: JoinKind, TableName, SourceColumnName, TargetColumnName.

**Self-JOIN with alias** -- required when joining the same table multiple times:

```pascal
[TJoin(TJoinKind.Inner, 'PianoDeiConti', 'ContoDare', 'ContoDareID', 'ID')]
```

Parameters: JoinKind, TableName, Alias, SourceColumnName, TargetColumnName.

**Chained JOIN** -- join using a column from a previous join:

```pascal
[TJoin(TJoinKind.Left, 'Countries', 'Countries', 'Customers', 'CountryID', 'ID')]
```

Parameters: JoinKind, TableName, Alias, SourceTableOrAlias, SourceColumnName, TargetColumnName.

`TJoinKind` is a scoped enum: `Inner`, `Left`, `Right`.

Join entities are **read-only**: `Insert`, `Update`, and `Delete` raise `ETException`. The identity map is bypassed for join entities. See [JOIN Queries](../guide/joins.md) for full documentation.

### Change Tracking Attributes

```pascal
[TCreatedAt]
[TColumn('CreatedAt')]
FCreatedAt: TTNullable<TDateTime>;

[TCreatedBy]
[TColumn('CreatedBy')]
FCreatedBy: String;

[TUpdatedAt]
[TColumn('UpdatedAt')]
FUpdatedAt: TTNullable<TDateTime>;

[TUpdatedBy]
[TColumn('UpdatedBy')]
FUpdatedBy: String;

[TDeletedAt]
[TColumn('DeletedAt')]
FDeletedAt: TTNullable<TDateTime>;

[TDeletedBy]
[TColumn('DeletedBy')]
FDeletedBy: String;
```

The resolver automatically populates these fields:

- **`TCreatedAt` / `TCreatedBy`** — set during `Insert` with `Now` and the value from `TTContext.OnGetCurrentUser`.
- **`TUpdatedAt` / `TUpdatedBy`** — set during `Update`.
- **`TDeletedAt` / `TDeletedBy`** — set during `Delete`. When `TDeletedAt` is present, delete becomes a **soft delete** (UPDATE instead of DELETE). All SELECT queries automatically add `DeletedAt IS NULL` to exclude soft-deleted records.

Type constraints:

- `*At` fields must be `TTNullable<TDateTime>` — validated at mapping time.
- `*By` fields must be `String` — validated at mapping time.
- Duplicate attributes of the same kind on the same entity raise `ETException`.

See [Entity Mapping — Change Tracking](../guide/entities.md#change-tracking) for a full example.

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
