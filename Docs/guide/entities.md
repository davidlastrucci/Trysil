# Entity Mapping

Trysil maps Delphi classes to database tables using custom attributes. Entities are plain classes decorated with attributes from `Trysil.Attributes.pas` and `Trysil.Validation.Attributes.pas`.

## Table and Sequence

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
TPerson = class
```

- **TTable** maps the class to a database table. The string parameter is the table name.
- **TSequence** specifies the database sequence (or auto-increment source) used for generating primary key values on insert.

## Field Mapping

```pascal
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TColumn('Firstname')]
  FFirstname: String;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
```

- **TPrimaryKey** marks the primary key field. The field type must be `TTPrimaryKey` (alias for `Int32`). Each entity must have exactly one primary key.
- **TColumn** maps a field to a database column. The string parameter is the column name.
- **TVersionColumn** enables optimistic locking. The field type must be `TTVersion` (alias for `Int32`). The version is automatically incremented on each update, and the resolver checks it during UPDATE and DELETE to detect concurrent modifications.
- All mapped fields **must** be declared `strict private` for RTTI to work correctly.

## Supported Field Types

Trysil supports the following field types for column mapping:

| Type | Description |
|---|---|
| `String` | Text values |
| `Integer` | 32-bit integer |
| `Int64` | 64-bit integer |
| `Double` | Floating-point number |
| `Boolean` | True/False |
| `TDateTime` | Date and time |
| `TGUID` | Globally unique identifier |
| `TBytes` | Binary data (BLOB) |
| `TTNullable<T>` | Nullable wrapper for any supported type |
| `TTLazy<T>` | Lazy-loaded single related entity |
| `TTLazyList<T>` | Lazy-loaded collection of related entities |

For nullable columns, see [Nullable Types](nullable.md). For lazy loading, see [Lazy Loading](lazy-loading.md).

## Relations

```pascal
[TTable('Companies')]
[TSequence('CompaniesID')]
[TRelation('Employees', 'CompanyID', False)]
TCompany = class
```

`TRelation` declares a parent-child relationship and controls referential integrity behavior on delete:

- First parameter: the **child table name**
- Second parameter: the **foreign key column** in the child table
- Third parameter: **cascade delete** flag
    - `True` -- deleting the parent automatically deletes all children
    - `False` -- delete is blocked if children exist (the resolver checks before executing)

A class can have multiple `TRelation` attributes if it is referenced by several child tables.

## Detail Columns

```pascal
[TDetailColumn('CompanyID', 'CompanyName')]
FCompanyName: String;
```

`TDetailColumn` maps a read-only field that is resolved from a related table:

- First parameter: the **foreign key column** linking to the related table
- Second parameter: the **column name** to read from the related table

Detail columns are populated during SELECT operations but are not included in INSERT or UPDATE commands.

## Where Clause (Static Filters)

```pascal
[TTable('Users')]
[TSequence('UsersID')]
[TWhereClause('Active = :Active')]
[TWhereClauseParameter('Active', True)]
TActiveUser = class
```

- **TWhereClause** adds a fixed WHERE clause to every query generated for this entity.
- **TWhereClauseParameter** supplies named parameter values for the clause. Multiple parameters are supported by adding multiple attributes.
- Parameters are **compile-time constants** only. Supported types: `String`, `Integer`, `Int64`, `Double`, `Boolean`, `TDateTime`.
- For dynamic, runtime-constructed filters, use [TTFilterBuilder\<T\>](filtering.md) instead.

## Change Tracking

Trysil can automatically set timestamp and user-name fields when entities are inserted, updated, or soft-deleted. Decorate columns with the change tracking attributes:

| Attribute | Set on | Required field type |
|---|---|---|
| `TCreatedAt` | Insert | `TTNullable<TDateTime>` |
| `TCreatedBy` | Insert | `String` |
| `TUpdatedAt` | Update | `TTNullable<TDateTime>` |
| `TUpdatedBy` | Update | `String` |
| `TDeletedAt` | Delete (soft) | `TTNullable<TDateTime>` |
| `TDeletedBy` | Delete (soft) | `String` |

```pascal
[TTable('Articles')]
[TSequence('ArticlesID')]
TArticle = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TColumn('Title')]
  FTitle: String;

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

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
public
  property ID: TTPrimaryKey read FID;
  property Title: String read FTitle write FTitle;
end;
```

### How It Works

- The resolver automatically populates `*At` fields with `Now` and `*By` fields with the value returned by `TTContext.OnGetCurrentUser` (empty string if not assigned).
- `[TCreatedAt]` / `[TCreatedBy]` are set during `Insert`.
- `[TUpdatedAt]` / `[TUpdatedBy]` are set during `Update`.
- `[TDeletedAt]` / `[TDeletedBy]` are set during `Delete`.

### Soft Delete

When an entity has a `[TDeletedAt]` column, calling `Delete<T>` does **not** execute a SQL `DELETE`. Instead, it executes an `UPDATE` that sets the `DeletedAt` (and optionally `DeletedBy`) column and increments `[TVersionColumn]` if present. Relation checks (`TRelation`) are skipped for soft deletes.

All SELECT queries automatically add `DeletedAt IS NULL` to the WHERE clause, so soft-deleted records are excluded by default. To include them, use `TTFilter.IncludeDeleted` or `TTFilterBuilder<T>.IncludeDeleted` — see [Filtering](filtering.md#including-soft-deleted-records).

### Providing the Current User

Set `OnGetCurrentUser` on the context to supply the user name for `*By` fields:

```pascal
LContext := TTContext.Create(LConnection);
LContext.OnGetCurrentUser :=
  function: String
  begin
    Result := GetCurrentUserName;  // your application logic
  end;
```

If `OnGetCurrentUser` is not assigned, an empty string is written to `*By` fields.

## RTTI Warning

Always add this compiler directive at the top of units that define entities with Trysil attributes:

```pascal
{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}
```

This turns unknown attribute references into compile-time errors, catching typos such as `[TColum('Name')]` instead of `[TColumn('Name')]` before they become silent runtime failures.

## Complete Example

A full entity with primary key, validation attributes, a version column, and a lazy-loaded relation:

```pascal
unit Model.Employee;

interface

uses
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Lazy,

  Model.Company;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

type

  [TTable('Employees')]
  [TSequence('EmployeesID')]
  TEmployee = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Lastname')]
    FLastname: String;

    [TMaxLength(255)]
    [TEmail]
    [TColumn('Email')]
    FEmail: String;

    [TRequired]
    [TDisplayName('Company')]
    [TColumn('CompanyID')]
    FCompany: TTLazy<TCompany>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;

    function GetCompany: TCompany;
    procedure SetCompany(const AValue: TCompany);
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property Email: String read FEmail write FEmail;
    property Company: TCompany read GetCompany write SetCompany;
  end;

implementation

function TEmployee.GetCompany: TCompany;
begin
  Result := FCompany.Entity;
end;

procedure TEmployee.SetCompany(const AValue: TCompany);
begin
  FCompany.Entity := AValue;
end;

end.
```

Key points in this example:

- `TRequired` ensures `Firstname`, `Lastname`, and the `Company` relation are not empty on insert/update.
- `TMaxLength` limits string length and is validated before the SQL command is executed.
- `TEmail` validates that the email address matches a standard email pattern.
- `TDisplayName` provides a human-readable field name used in validation error messages.
- `TTLazy<TCompany>` defers loading of the related company until first access.
- The `ID` property is read-only because the primary key is assigned by the sequence on insert.
