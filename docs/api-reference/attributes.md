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
| `TDetailColumn(local, childFk)` | Field | Maps a `TTLazyList<T>` detail collection |
| `TVersionColumn` | Field | Enables optimistic locking |
| `TNotFilterable` | Field | Excludes the column from the HTTP JSON filter |
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

| Database | Form of the statement |
|---|---|
| SQL Server | `SELECT NEXT VALUE FOR [PersonsID] AS ID` |
| PostgreSQL | `SELECT NEXTVAL('PersonsID') AS ID` |
| Oracle | `SELECT "PERSONSID".NEXTVAL ID FROM DUAL` |
| Firebird | `SELECT GEN_ID("PERSONSID", 1) ID FROM RDB$DATABASE` |
| InterBase | `SELECT GEN_ID("PERSONSID", 1) ID FROM RDB$DATABASE` |
| MariaDB | `SELECT NEXTVAL(PersonsID) AS ID` (MariaDB 10.3+) |
| SQLite | `SELECT IFNULL(MAX([ID]), 0) + 1 FROM [Persons]` |

SQLite has no sequences, so it reads the highest key in the table and adds one,
or one past the last key it handed out on this connection name if that is higher: the
name in `[TSequence]` is required by the mapping but unused there, and two
processes writing the same file can still get the same key. Every other engine
reads a real sequence, which must exist in the database - Trysil never creates
it. The identifier is quoted and case-folded per engine, which is why the
uppercase forms appear above: see the note on quoting in
[Database Drivers](../database-drivers/index.md).

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
[TDetailColumn('ID', 'OrderID')]
FDetails: TTLazyList<TOrderDetail>;
```

Maps a **detail collection**: the field is a `TTLazyList<T>` of the child entity, loaded on first access. First parameter is the column on this entity the children are matched against - normally the primary key - and second is the column in the child table that points back to it. It is never part of an INSERT or an UPDATE.

The field must be a `TTLazyList<T>`, and nothing checks it. Another owning list is accepted by the mapper and even loaded, but every reload of the master - a `Refresh`, or with the identity map on any read that finds it again - clears it without telling the context, so a detail row written inside a transaction that then rolls back makes the rollback write into freed memory, and the lazy members of the rows it frees stay registered on addresses nobody holds.

### TVersionColumn

```pascal
[TVersionColumn]
[TColumn('VersionID')]
FVersionID: TTVersion;
```

Enables optimistic locking. The version is incremented on each update. If another transaction has modified the record (version mismatch), `ETConcurrentUpdateException` is raised.

### TNotFilterable

```pascal
[TColumn('Password')]
[TNotFilterable]
FPassword: String;
```

Excludes the column from the JSON filter of the HTTP module: `where` and `orderBy` naming it answer `400`. A mapped column is filterable unless it is annotated, or unless no response ever returns it: a column carrying `[TJSonIgnore]` or `[TJSonIgnoreSerialize]` is refused by the filter and by the `orderBy` as well, because `LIKE` plus the row count of the answer reads a value one character at a time.

Put it on the columns a caller must not be able to probe. A column the client cannot read is the case that matters: `LIKE` plus the row count in the response is enough to recover a value one character at a time without it ever being serialized, so excluding a field from the payload is not by itself enough to protect it.

**`[TJSonIgnore]` without `[TNotFilterable]` used to be the combination to look for**, and from 2.0.0 the framework closes it for you: a column kept out of every response but still filterable is exactly the target described above, and it is the shape a `PasswordHash` naturally takes if you stop at the first attribute. Marking both is still the clearer declaration of intent, and it is what keeps the column out of a filter written by your own code with `TTFilterBuilder<T>`, which the framework does not police.

It is a property of the mapping, so it is resolved once per entity and costs nothing per request. `MetadataToJSon<T>` reports `"filterable": false` for the columns it does describe - and from 2.0.0 it leaves out the columns the entity neither serializes nor deserializes, so a client that builds its filter UI from the metadata can hide the column instead of discovering it through a `400`. See also the ceilings in `TTHttpFilterParameters`, described in [REST API](../examples/rest-api.md).

### TRelation

```pascal
[TRelation('Employees', 'CompanyID', False)]
TCompany = class
```

Parameters:

1. **Child table name** — the table that references this entity
2. **Foreign key column** — the column in the child table
3. **Cascade delete** — `True`: auto-delete children; `False`: block delete if children exist (raises `ETException`, not `ETDataIntegrityException`)

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

`TWhereClauseParameter` constructors accept: `String`, `Integer`, `Int64`, `Double`, `Boolean`, `TDateTime`. For a `Currency` column, pass the constant as a `Double`.

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
- **`TUpdatedAt` / `TUpdatedBy`** — set during `Update`, and during `Undelete`, which is an update like any other as far as the audit is concerned.
- **`TDeletedAt` / `TDeletedBy`** — set during `Delete`. When `TDeletedAt` is present, delete becomes a **soft delete** (UPDATE instead of DELETE). All SELECT queries automatically add `DeletedAt IS NULL` to exclude soft-deleted records, and so does every `UPDATE` and every soft `DELETE`, so a soft-deleted row cannot be modified through the entity that declares the pair. The guard is built from the mapping, not from the table: a second class mapped on the same table without `[TDeletedAt]` still reaches the row.


!!! warning "These columns are the framework's, not the client's"
    Two rules protect them, both added in 2.0.0. `Update<T>` writes only
    `[TUpdatedAt]` and `[TUpdatedBy]`: the creation pair is set once, on
    `Insert`, and the delete pair only by `Delete` and `Undelete`, so setting
    any of the four by hand on an existing entity has no effect - an import or
    a migration that needs to backdate a row has to go through raw SQL. And no
    deserialization entry point reads any of the six from JSON, so a value for
    them in a body never reaches the entity.

Type constraints:

- `*At` fields must be `TTNullable<TDateTime>` — validated at mapping time.
- `*By` fields must be `String` — validated at mapping time.
- Duplicate attributes of the same kind on the same entity raise `ETException`.
- `[TDeletedBy]` requires `[TDeletedAt]` on the same entity — validated at mapping time. Without it the column would be mapped and read but never written by any path, since `Delete` would take the hard-delete branch and neither `Update` nor `Undelete` writes it. The other two pairs may be declared half: a lone `[TCreatedBy]` or `[TUpdatedBy]` is still written by `Insert` and `Update`.

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
| `TBeforeInsertEvent` | Method called before insert |
| `TAfterInsertEvent` | Method called after insert |
| `TBeforeUpdateEvent` | Method called before update |
| `TAfterUpdateEvent` | Method called after update |
| `TBeforeDeleteEvent` | Method called before delete |
| `TAfterDeleteEvent` | Method called after delete |

```pascal
TPerson = class
public
  [TBeforeInsertEvent]
  procedure OnBeforeInsert;
  [TAfterUpdateEvent]
  procedure OnAfterUpdate;
end;
```

Event methods must be `public`: the default RTTI does not emit private or protected methods, so an attribute on one of those is never seen and the method is never called.

See [Events](../guide/events.md) for detailed usage.

---

## JSON

Unit: `Trysil.JSon.Attributes`

| Attribute | Description |
|---|---|
| `TJSonIgnore` | Exclude field from JSON serialization **and** deserialization |
| `TJSonIgnoreSerialize` | Field is read from JSON but never written to it (a password on creation) |
| `TJSonIgnoreDeserialize` | Field is written to JSON but never read from it (a computed total, a server-side status, a tenant column) |

It is read on every mapped member, a `TTLazy<T>` foreign key and a `[TDetailColumn]` collection included, which is what makes it the way to close a relation the client must not repoint - see [Restricting what the body may write](../json/deserialization.md#restricting-what-the-body-may-write).

The three share one polarity: every name says *ignore*, and the qualifier says only where. Change tracking columns are excluded from deserialization without any attribute, see [Change Tracking](../guide/entities.md#change-tracking).

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
| `TAuthorizationType(type)` | Authentication requirement, on class or method |
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

`TAuthorizationType` is read on the **class and on the method**, and the method wins. A controller opened at class level is almost always the authentication controller, so a method added to it must state its own answer rather than inherit the file's.

`TTHttpAuthorizationType` values:

- `None` — no authentication required
- `Authentication` — authentication required (default)

See [HTTP Module](../http/index.md) for full documentation.
