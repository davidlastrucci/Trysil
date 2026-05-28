---
title: JSON Configuration
---

# JSON Configuration

## TTJSonSerializerConfig

`TTJSonSerializerConfig` is a record that controls how entities are serialized to JSON.

```pascal
var LConfig := TTJSonSerializerConfig.Create(AMaxLevels, ADetails);
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `AMaxLevels` | `Integer` | How deep to serialize nested objects. `-1` = unlimited, `0` = current level only (no nested), `1` = one level of nesting, etc. |
| `ADetails` | `Boolean` | When `True`, includes detail columns (child collections). When `False`, skips them. |

### Common Configurations

```pascal
// Full serialization (all levels, with details)
LConfig := TTJSonSerializerConfig.Create(-1, True);

// Flat serialization (no nesting, no details)
LConfig := TTJSonSerializerConfig.Create(0, False);

// One level of nesting, no details
LConfig := TTJSonSerializerConfig.Create(1, False);

// Default config (unlimited depth, no details)
LConfig := TTJSonSerializerConfig.Create(-1, False);
```

!!! warning "No Default Constructor"
    `TTJSonSerializerConfig` is a record with **no default constructor**. You must always initialize it explicitly with `Create(AMaxLevels, ADetails)`. An uninitialized config will have undefined behavior.

## MaxLevels in Detail

The `MaxLevels` parameter controls how deep the serializer traverses related entities:

| Value | Behavior |
|---|---|
| `-1` | Serialize all levels (unlimited depth) |
| `0` | Serialize only the current entity's scalar fields -- no nested objects |
| `1` | Serialize the current entity and one level of related entities |
| `2` | Current entity + two levels of nesting |
| `n` | Current entity + `n` levels of nesting |

### Example

Given an entity hierarchy `Company -> Department -> Employee`:

```pascal
// Only Company fields
LConfig := TTJSonSerializerConfig.Create(0, False);
// {"ID":1,"Name":"Acme"}

// Company + Departments
LConfig := TTJSonSerializerConfig.Create(1, True);
// {"ID":1,"Name":"Acme","Departments":[{"ID":1,"Name":"Engineering"},...]}

// Company + Departments + Employees
LConfig := TTJSonSerializerConfig.Create(2, True);
// Full tree serialized
```

## Details Parameter

When `ADetails` is `True`, the serializer includes fields marked with `TDetailColumn` -- typically child collections. When `False`, these fields are omitted from the output.

This is useful for API responses where you want to return a flat list without loading and serializing the entire object graph:

```pascal
// List endpoint: flat, no details
LConfig := TTJSonSerializerConfig.Create(0, False);
FResponse.Content := LContext.ListToJSon<TCompany>(LCompanies, LConfig);

// Detail endpoint: full tree with children
LConfig := TTJSonSerializerConfig.Create(-1, True);
FResponse.Content := LContext.EntityToJSon<TCompany>(LCompany, LConfig);
```
