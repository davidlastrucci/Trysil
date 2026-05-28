---
title: JSON Module
---

# JSON Module

The JSON module (`Trysil.JSon/`) adds serialization and deserialization capabilities on top of the core ORM.

## Main Class

`TTJSonContext` extends `TTContext` and serves as the primary API for all JSON operations.

```pascal
uses
  Trysil.JSon.Context,
  Trysil.JSon.Types;

LContext := TTJSonContext.Create(LConnection);
try
  // Serialize, deserialize, and perform all standard ORM operations
finally
  LContext.Free;
end;
```

Since `TTJSonContext` extends `TTContext`, you can use all standard ORM methods (`SelectAll`, `Insert`, `Update`, `Delete`, etc.) alongside JSON operations.

## Key Capabilities

| Capability | Methods |
|---|---|
| Serialize entity to JSON | `EntityToJSon<T>`, `EntityToJSonObject<T>` |
| Serialize list to JSON | `ListToJSon<T>`, `ListToJSonArray<T>` |
| Deserialize JSON to entity | `EntityFromJSon<T>`, `EntityFromJSonObject<T>` |
| Deserialize JSON to list | `ListFromJSon<T>`, `ListFromJSonArray<T>` |
| Dataset to JSON | `DatasetToJSon` |
| Entity metadata | `MetadataToJSon<T>` |

## Units

| Unit | Description |
|---|---|
| `Trysil.JSon.Context` | `TTJSonContext` -- main API class |
| `Trysil.JSon.Types` | `TTJSonSerializerConfig` and type definitions |
| `Trysil.JSon.Attributes` | `TJSonIgnore` attribute |
| `Trysil.JSon.Events` | Custom serialization/deserialization hooks |
| `Trysil.JSon.Serializer` | Internal serializer implementation |
| `Trysil.JSon.Deserializer` | Internal deserializer implementation |

## Quick Example

```pascal
uses
  Trysil.JSon.Context,
  Trysil.JSon.Types;

var
  LContext: TTJSonContext;
  LConfig: TTJSonSerializerConfig;
  LPersons: TTList<TPerson>;
  LJson: String;
begin
  LContext := TTJSonContext.Create(LConnection);
  try
    LConfig := TTJSonSerializerConfig.Create(-1, False);

    // Load all persons
    LPersons := TTList<TPerson>.Create;
    try
      LContext.SelectAll<TPerson>(LPersons);

      // Serialize to JSON
      LJson := LContext.ListToJSon<TPerson>(LPersons, LConfig);
    finally
      LPersons.Free;
    end;
  finally
    LContext.Free;
  end;
end;
```
