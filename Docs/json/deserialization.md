---
title: JSON Deserialization
---

# JSON Deserialization

Deserialize JSON strings and objects into Trysil entity instances and lists.

## JSON String to Entity

```pascal
var LPerson := LContext.EntityFromJSon<TPerson>(LJsonString);
try
  // LPerson is a new entity populated from JSON
  LContext.Insert<TPerson>(LPerson);
finally
  LPerson.Free;
end;
```

The returned entity is a newly created instance. The caller is responsible for freeing it.

## TJSonValue to Entity

When you already have a parsed JSON value (e.g., from an HTTP request body):

```pascal
var LPerson := LContext.EntityFromJSonObject<TPerson>(LJsonValue);
try
  // Work with the entity
finally
  LPerson.Free;
end;
```

## JSON String to List

```pascal
var LPersons := TTList<TPerson>.Create;
try
  LContext.ListFromJSon<TPerson>(LJsonString, LPersons);

  // LPersons now contains all deserialized entities
  for var LPerson in LPersons do
    WriteLn(LPerson.Firstname);
finally
  LPersons.Free;
end;
```

The list must be created before calling `ListFromJSon`. Deserialized entities are added to the existing list.

## TJSonArray to List

```pascal
var LPersons := TTList<TPerson>.Create;
try
  LContext.ListFromJSonArray<TPerson>(LJsonArray, LPersons);
finally
  LPersons.Free;
end;
```

## Typical REST Workflow

A common pattern in HTTP controllers is deserializing a request body, performing an operation, and returning the result:

```pascal
procedure TPersonController.Insert;
var
  LPerson: TPerson;
  LConfig: TTJSonSerializerConfig;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);
  LPerson := FContext.Context.EntityFromJSon<TPerson>(FRequest.Content);
  try
    FContext.Context.Insert<TPerson>(LPerson);
    FResponse.Content := FContext.Context.EntityToJSon<TPerson>(LPerson, LConfig);
  finally
    LPerson.Free;
  end;
end;
```
