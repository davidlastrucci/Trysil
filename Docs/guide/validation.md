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
- **TTLazy\<T\>** (object): fails if the referenced entity is `nil`

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

Validation runs automatically before every `Insert` and `Update` operation inside the resolver. You do not need to call `Validate` manually unless you want to check the entity before submitting -- for example, to display errors in a UI before the user confirms the save.

## Custom Validators

For validation logic that cannot be expressed with attributes, use event method attributes directly on the entity class:

```pascal
TPerson = class
strict private
  // fields...

  [TBeforeInsert]
  procedure ValidateOnInsert;

  [TBeforeUpdate]
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
