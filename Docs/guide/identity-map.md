# Identity Map

`TTIdentityMap` ensures that only one object instance exists per entity type and primary key within a `TTContext`. It is defined in `Trysil.IdentityMap.pas`.

## Overview

When the identity map is enabled, loading the same entity twice by primary key returns the same object reference rather than creating a duplicate:

```pascal
LPerson1 := LContext.Get<TPerson>(42);
LPerson2 := LContext.Get<TPerson>(42);
// LPerson1 = LPerson2 (same object reference)
```

Without the identity map, each call creates a separate object:

```pascal
LPerson1 := LContext.Get<TPerson>(42);
LPerson2 := LContext.Get<TPerson>(42);
// LPerson1 <> LPerson2 (different objects with the same data)
```

## Enabling the Identity Map

```pascal
// Enabled (default when using single-parameter constructor)
LContext := TTContext.Create(LConnection);

// Explicitly enabled
LContext := TTContext.Create(LConnection, True);

// Disabled
LContext := TTContext.Create(LConnection, False);
```

The default constructor enables the identity map. Pass `False` to disable it.

## Scope

The identity map is **scoped to a single TTContext instance**. It is not a global singleton.

- Each `TTContext` owns its own identity map.
- Two contexts never share cached entities, even if they use the same connection.
- There is no cross-request or cross-tenant collision risk.
- Safe for multi-threaded use when each thread creates its own context.

## When to Use

**Enable** the identity map when:

- Loading complex object graphs with lazy-loaded relations, to avoid duplicate instances of the same entity.
- Working within a single request or unit of work where consistent object identity matters.

**Disable** the identity map when:

- Performing simple, stateless CRUD operations where each query should return fresh data.
- Working with large datasets where caching all loaded entities would consume too much memory.

## Object Ownership

When the identity map is enabled, it owns the cached entity objects (via `TObjectDictionary` with `doOwnsValues`). This means:

- Entities loaded through the context are freed when the context is destroyed.
- You must not free entities manually that were loaded through a context with an active identity map.
- `TTLazy<T>` and `TTLazyList<T>` respect the identity map: they do not free loaded entities when the map is active.

When the identity map is disabled, the caller is responsible for freeing entities returned by `Get<T>` and other read operations, typically through the `TTList<T>` or `TTObjectList<T>` that owns them.

## Checking the State

```pascal
if LContext.UseIdentityMap then
  WriteLn('Identity map is active');
```
