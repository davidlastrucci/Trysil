# Nullable Types

`TTNullable<T>` is a generic record that wraps a value to represent nullable database columns. It is defined in `Trysil.Types.pas`.

## Declaring Nullable Fields

```pascal
[TColumn('MiddleName')]
FMiddleName: TTNullable<String>;

[TColumn('BirthDate')]
FBirthDate: TTNullable<TDateTime>;

[TColumn('Score')]
FScore: TTNullable<Integer>;
```

## Creating Values

### Set a Value

```pascal
LPerson.MiddleName := TTNullable<String>.Create('John');

// Or use implicit conversion from T
LPerson.MiddleName := 'John';
```

### Set to Null

```pascal
LPerson.MiddleName := nil;
```

Assigning `nil` clears the value and sets the nullable to its null state.

## Reading Values

### Direct Access

Accessing `.Value` when the nullable is null raises `ETException`:

```pascal
LName := LPerson.MiddleName.Value;  // raises if null
```

### Safe Access

```pascal
if not LPerson.MiddleName.IsNull then
  ShowMessage(LPerson.MiddleName.Value);
```

### With Default Value

```pascal
// Type default (empty string, 0, etc.)
LName := LPerson.MiddleName.GetValueOrDefault;

// Custom default
LName := LPerson.MiddleName.GetValueOrDefault('N/A');
```

## Supported Types

`TTNullable<T>` can wrap any of the standard Trysil field types:

- `String`
- `Integer`
- `Int64`
- `Double`
- `Boolean`
- `TDateTime`
- `TGUID`

## Operators

### Implicit Conversion

```pascal
// T -> TTNullable<T>
var LNullable: TTNullable<Integer>;
LNullable := 42;

// TTNullable<T> -> T (raises if null)
var LValue: Integer;
LValue := LNullable;
```

### Equality

```pascal
if LNullable1 = LNullable2 then
  WriteLn('Equal');

if LNullable1 <> LNullable2 then
  WriteLn('Not equal');
```

Two nullables are equal if both are null or both have the same value.

## Key Points

- **No default constructor** -- An uninitialized `TTNullable<T>` is null. This is by design: you do not need to explicitly set a field to null.
- **Use `Create` to set a value** -- Always use `TTNullable<T>.Create(value)` or implicit assignment to set a non-null value.
- **Validation** -- `TRequired` validation recognizes `TTNullable<T>` and will fail if the nullable is in null state.
- **Internal mechanism** -- The null state is tracked via an internal string marker field (`'@@@'`). When this marker is present, the value is non-null. When empty, the value is null. This approach works with Delphi's RTTI system for serialization and database mapping.

## Complete Example

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
TPerson = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TRequired]
  [TColumn('Firstname')]
  FFirstname: String;

  [TColumn('MiddleName')]
  FMiddleName: TTNullable<String>;

  [TColumn('BirthDate')]
  FBirthDate: TTNullable<TDateTime>;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
public
  property ID: TTPrimaryKey read FID;
  property Firstname: String read FFirstname write FFirstname;
  property MiddleName: TTNullable<String> read FMiddleName write FMiddleName;
  property BirthDate: TTNullable<TDateTime> read FBirthDate write FBirthDate;
end;
```

Usage:

```pascal
LPerson := LContext.CreateEntity<TPerson>();
LPerson.Firstname := 'Alice';
LPerson.MiddleName := 'Marie';               // non-null
LPerson.BirthDate := EncodeDate(1990, 5, 15); // implicit conversion
LContext.Insert<TPerson>(LPerson);

// Later, set middle name to null
LPerson.MiddleName := nil;
LContext.Update<TPerson>(LPerson);
```
