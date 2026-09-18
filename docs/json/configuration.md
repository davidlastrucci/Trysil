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
| `AMaxLevels` | `Integer` | How deep to serialize nested objects **and detail collections**. `-1` = unlimited, `0` = current level only (no nested), `1` = one level of nesting, etc. |
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
| `0` | Serialize only the current entity's scalar fields -- no nested objects, no detail collections |
| `1` | Serialize the current entity and one level of related entities or detail collections |
| `2` | Current entity + two levels of nesting |
| `n` | Current entity + `n` levels of nesting |

!!! note "MaxLevels bounds queries, not just payload"
    When the current level is past `MaxLevels`, the serializer does **not** resolve the lazy reference: it emits the foreign key id and moves on. The contract towards the client is unchanged, because the id is still written. What changes is the cost: on a list endpoint, `Create(0, False)` used to pay `rows x N:1 relations` queries whose results were then discarded. See [Lazy Loading](../guide/lazy-loading.md).

!!! warning "On a list, the only safe value is 0"
    The gate that stops the query is the same one that lets it through. At
    `MaxLevels = 0` a `TTLazy<T>` reference is written as its foreign key id
    **without a query**, so the client already has the identifier for free. At
    `MaxLevels = 1` the gate opens and every reference is resolved: **one query
    per relation per row**.

    A list of 50 rows with 4 relations costs 2 queries at `Create(0, False)`
    and 202 at `Create(1, False)`. It is the N+1 problem, reached by changing a
    zero into a one, and it grows with the page size rather than with the
    depth you asked for.

    Serialize a list with `Create(0, False)`. Depth belongs to the endpoint
    that returns **one** entity, where the number of queries is bounded by the
    shape of that entity and not by how many rows came back.

!!! note "Detail collections are dropped, not degraded"
    The fallback above applies to `TTLazy<T>` references, which always carry an
    id. A detail collection has no single id to write, so when it falls past
    `MaxLevels` the key is **omitted from the object entirely**. An empty array
    would claim the collection has no rows, which is not what the serializer
    knows; an absent key means "not included at this depth".

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

`ADetails` and `AMaxLevels` are two separate gates and both must open: `ADetails` decides whether detail collections are eligible at all, `AMaxLevels` decides how deep they may go. `Create(0, True)` therefore emits no details, because level `0` allows nothing below the current entity.

This is useful for API responses where you want to return a flat list without loading and serializing the entire object graph:

```pascal
// List endpoint: flat, no details
LConfig := TTJSonSerializerConfig.Create(0, False);
FResponse.Content := LContext.ListToJSon<TCompany>(LCompanies, LConfig);

// Detail endpoint: full tree with children
LConfig := TTJSonSerializerConfig.Create(-1, True);
FResponse.Content := LContext.EntityToJSon<TCompany>(LCompany, LConfig);
```
