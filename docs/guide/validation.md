# Validation

Trysil provides attribute-based validation for entity fields. Validation attributes are defined in `Trysil.Validation.Attributes.pas` and the error collection infrastructure is in `Trysil.Validation.pas`.

## Validation Attributes

Decorate entity fields with one or more validation attributes:

| Attribute | Description | Example |
|---|---|---|
| `TRequired` | Field cannot be empty, null, or zero | `[TRequired]` |
| `TMaxLength(n)` | Maximum string length | `[TMaxLength(50)]` |
| `TMinLength(n)` | Minimum string length | `[TMinLength(3)]` |
| `TMaxValue(n)` | Maximum numeric value (Integer or Double) | `[TMaxValue(100)]` |
| `TMinValue(n)` | Minimum numeric value (Integer or Double) | `[TMinValue(0)]` |
| `TGreater(n)` | Must be strictly greater than n | `[TGreater(0)]` |
| `TLess(n)` | Must be strictly less than n | `[TLess(1000)]` |
| `TRange(min, max)` | Value must be within range (inclusive) | `[TRange(1, 100)]` |
| `TRegex(pattern)` | Must match a regular expression | `[TRegex('^[A-Z]')]` |
| `TEmail` | Must be a valid email address | `[TEmail]` |
| `TDisplayName(name)` | Human-readable field name for error messages | `[TDisplayName('First Name')]` |

The comparison reads the **value of the field**, not the shape of the literal:
`[TGreater(0)]` on a `Currency` or `Double` field works, and so does
`[TGreater(0.0)]` on an `Integer` one. What decides is the type of the two
values, not whether the number is whole: the integer comparison runs only when
the field **and** the literal are both integers, otherwise both go through the
float one - so `[TMinValue(0.0)]` on an `Int64` is compared as a float, and
above 2^53 that loses digits. Write an integer literal for an integer field.
The attribute has both overloads, `Integer` and `Double`, and no `Currency`
one, which is not needed. *Type not valid for validation* is what you get when
the member holds something that is not a number at all.

### Example

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
TPerson = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TRequired]
  [TMaxLength(100)]
  [TDisplayName('First Name')]
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

  [TMinValue(0)]
  [TMaxValue(150)]
  [TColumn('Age')]
  FAge: Integer;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
public
  property ID: TTPrimaryKey read FID;
  property Firstname: String read FFirstname write FFirstname;
  property Lastname: String read FLastname write FLastname;
  property Email: String read FEmail write FEmail;
  property Age: Integer read FAge write FAge;
end;
```

## Custom Error Messages

All validation attributes accept an optional error message parameter. When omitted, a default message is generated using the column name:

```pascal
[TRequired('Firstname is mandatory')]
[TMaxLength(50, 'Name must be 50 characters or fewer')]
[TEmail('Please enter a valid email address')]
[TRange(1, 100, 'Value must be between 1 and 100')]
```

## TRequired Behavior

`TRequired` validates different types as follows:

- **String**: fails if the value is empty (`''`)
- **TDateTime**: fails if the value is zero (`0`)
- **TTNullable\<T\>**: fails if the nullable is in null state
- **TTLazy\<T\>** (object): fails if the foreign key is not set, with *cannot be empty*, and fails if the key is set and the row it names does not load, with *refers to a row that does not exist*. A soft-deleted row **does** load - a lazy member asks for it with `Get<T>(ID, True)`, so that an entity can still show a master that was archived - and the validation accepts it: an archived row exists, and whether a record may point at one is a question about your data rather than about the mapping. Write that rule in a `[TValidator]` if you want it, where you have the entity and the context in hand. In 1.0.0 the attribute refused it, which also meant that archiving a master stopped every record pointing at it from being saved. The check costs one `SELECT` per validated relation that carries the attribute, the same one the lazy member would have paid. That `SELECT` goes through the **read** connection, because a lazy member loads through the provider: with a context built on two connections, a master inserted in the same unit of work and not yet committed is not visible to it, and the relation is refused. A context on a single connection does not have that problem. It is not new: in 1.0.0 the attribute loaded the relation the same way, and through the same read connection

## Explicit Validation

Call `Validate<T>` on the context to check an entity before submitting. If validation fails, `ETValidationException` is raised:

```pascal
try
  LContext.Validate<TPerson>(LPerson);
except
  on E: ETValidationException do
    ShowMessage(E.Message);
end;
```

## TTValidationErrors

Validation errors are collected in a `TTValidationErrors` instance. Each error is a `TTValidationError` record containing:

- `ColumnName` -- the field/column that failed validation
- `ErrorMessage` -- the human-readable error description

### Formatting Errors

```pascal
// Human-readable text (one line per error)
LErrors.ToString;
// Example output:
// - Firstname: First Name is required.
// - Email: Invalid email address.

// JSON format (for APIs)
LErrors.ToJSon;
// Example output:
// [{"columnName":"Firstname","errorMessage":"First Name is required."},
//  {"columnName":"Email","errorMessage":"Invalid email address."}]
```

### Checking for Errors

```pascal
if not LErrors.IsEmpty then
  ShowMessage(LErrors.ToString);
```

## Automatic Validation

Validation runs automatically before every `Insert`, `Update` and `Undelete` operation inside the resolver. You do not need to call `Validate` manually unless you want to check the entity before submitting -- for example, to display errors in a UI before the user confirms the save.

## The Last Guard: a String Longer Than Its Column

A string that no validation attribute stopped still meets one check on the way to the database: a value longer than the column is **refused**, naming the column, the size it holds and the length it was given. It used to be trimmed to the column and written short - and written back into the entity too, so the caller could not even find out afterwards what it had asked for.

That check reads the width the driver reports for the column, and **what that width counts is the engine's business**. On most of them it is characters and the check is exact. On InterBase and Firebird with a Unicode character set it is bytes: a `VARCHAR(100)` in a `UTF8` database is 400 bytes, and 150 characters fit in it - the engine accepts them, and so does the check. It is a ceiling, never a false positive, because one character is never less than one byte; it is not a substitute for `[TMaxLength]`, which is the check that says what **your application** accepts, in characters, on every engine, and reports it as a validation error listing every offending field at once rather than an exception on the first.

## Custom Validators

A method marked `[TValidator]` runs with the entity, and the resolver accepts
three shapes: no parameters, the errors alone, or **the context and the
errors**, in that order. Only the third gets the context, which is what you
need when the rule has to ask the database - for instance to refuse a master
that was archived, which `[TRequired]` accepts by design:

```pascal
TOrder = class
strict private
  [TColumn('CustomerID')]
  [TRequired]
  FCustomer: TTLazy<TCustomer>;
public
  [TValidator]
  procedure ValidateCustomerIsNotArchived(
    const AContext: TTContext;
    const AErrors: TTValidationErrors);
end;

procedure TOrder.ValidateCustomerIsNotArchived(
  const AContext: TTContext;
  const AErrors: TTValidationErrors);
var
  LCustomer: TCustomer;
begin
  LCustomer := FCustomer.Entity;
  if Assigned(LCustomer) and (not LCustomer.DeletedAt.IsNull) then
    AErrors.Add('Customer', 'The customer was archived.');
end;
```

A method of any other shape is refused with `SNotValidValidator` when the
entity is validated, so a wrong signature is a message and not a silent skip.

For validation logic that cannot be expressed with attributes, use event method attributes directly on the entity class:

```pascal
TPerson = class
strict private
  // fields...
public
  [TBeforeInsertEvent]
  procedure ValidateOnInsert;

  [TBeforeUpdateEvent]
  procedure ValidateOnUpdate;
end;

procedure TPerson.ValidateOnInsert;
begin
  if FFirstname = FLastname then
    raise ETException.Create('Firstname and Lastname cannot be the same');
end;

procedure TPerson.ValidateOnUpdate;
begin
  ValidateOnInsert; // reuse the same logic
end;
```

These methods are called by the resolver during the event lifecycle, after attribute-based validation has passed. See [Events](events.md) for the full lifecycle.
