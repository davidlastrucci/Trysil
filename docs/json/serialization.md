---
title: JSON Serialization
---

# JSON Serialization

Serialize Trysil entities and lists to JSON strings or Delphi JSON objects.

## Entity to JSON String

```pascal
var LConfig := TTJSonSerializerConfig.Create(-1, False);
var LJson := LContext.EntityToJSon<TPerson>(LPerson, LConfig);
// Returns: {"ID":1,"Firstname":"David","Lastname":"Lastrucci","VersionID":1}
```

## Entity to TJSonObject

When you need to manipulate the JSON object before converting to a string:

```pascal
var LJsonObj := LContext.EntityToJSonObject<TPerson>(LPerson, LConfig);
try
  // Work with TJSonObject directly
  LJsonObj.AddPair('ComputedField', 'value');
  LResult := LJsonObj.ToJSON;
finally
  LJsonObj.Free;
end;
```

## List to JSON String

```pascal
var LJson := LContext.ListToJSon<TPerson>(LPersons, LConfig);
// Returns: [{"ID":1,...},{"ID":2,...}]
```

## List to TJSonArray

```pascal
var LArray := LContext.ListToJSonArray<TPerson>(LPersons, LConfig);
try
  // Work with TJSonArray directly
finally
  LArray.Free;
end;
```

## Dataset to JSON

Convert any `TDataset` to a JSON string, regardless of whether it comes from Trysil:

```pascal
var LJson := LContext.DatasetToJSon(LDataset);
```

## Metadata to JSON

Export entity column metadata (names, types, sizes) as JSON:

```pascal
var LJson := LContext.MetadataToJSon<TPerson>();
// Returns column metadata: names, types, sizes
```

This is useful for building dynamic UIs or generating documentation from entity definitions.

## Ignoring Fields

Use the `TJSonIgnore` attribute to exclude specific fields from serialization:

```pascal
type
  [TTable('Persons')]
  [TSequence('PersonsID')]
  TPerson = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Firstname')]
    FFirstname: String;

    [TColumn('Lastname')]
    FLastname: String;

    [TJSonIgnore]
    [TColumn('InternalField')]
    FInternalField: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property InternalField: String read FInternalField write FInternalField;
    property VersionID: TTVersion read FVersionID;
  end;
```

When serialized, `InternalField` will not appear in the JSON output.

## Serialization Config

The `TTJSonSerializerConfig` record controls serialization depth and detail inclusion. See [JSON Configuration](configuration.md) for details.
