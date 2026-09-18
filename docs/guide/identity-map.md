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

- Entities the map caches are freed when the context is destroyed.
- Do not free an entity the map holds yourself: `FreeEntity<T>` leaves it alone, and a type with a `[TJoin]` or without a primary key is not in the map at all. [Who frees what](context.md#who-frees-what) has every case.
- `TTLazy<T>` and `TTLazyList<T>` respect the identity map: they do not free loaded entities when the map is active and the type has a primary key and no `[TJoin]`, which is what the map holds.

When the identity map is disabled, the caller is responsible for freeing entities returned by `Get<T>` and other read operations: `FreeEntity<T>` for a single entity, and for a list the one built by `CreateEntityList<T>`. Both decide on what the map will really hold, not on whether the map is switched on: it registers an entity only when the entity has a primary key and carries no `[TJoin]`, and `RawSelect<T>` never reaches it at all. So a join entity belongs to the list that carries it, and is released by `FreeEntity<T>`, with the map enabled as much as without it.

`RawSelect<T>` is the one case those two questions come apart, because the answer depends on the call and not on the type. A list is built before anyone knows who will fill it, and a target that carries a `[TPrimaryKey]` and no `[TJoin]` looks exactly like an entity `Select<T>` would register - so `CreateEntityList<T>` hands back a list that does not own, while `RawSelect<T>` puts in it entities the map never sees. **Collect a `RawSelect<T>` into a `TTObjectList<T>.Create(True)` of your own**, never into `CreateEntityList<T>`: the result of a raw select is always the caller's. `TTList<T>` on its own owns nothing - the owning list is `TTObjectList<T>`.

That recipe leaves one thing out, and it matters as soon as the raw-select target carries a lazy member or a `[TDetailColumn]`: an owning `TTObjectList<T>` frees the entity but does **not** go through the context's disposal, so the lazy wrappers the provider registered for it stay alive, keyed on an address nobody holds any more - and the next entity allocated at that address inherits them. For a plain DTO, which is what a raw select usually maps, there is nothing to leave behind and the owning list is right. When there is, keep them in a plain `TTList<T>`, which owns nothing, and free each one with `TTContext.FreeClone<T>`: it frees unconditionally **and** goes through the disposal path.

The same question decides what `TTLazy<T>.SetEntity` does with what you hand
it, and it has the same edge: when the map would hold an entity of that shape,
the lazy member keeps your instance as it is instead of cloning it - and if
that instance did not come out of the map, because you cloned it or built it
yourself, nothing frees it, and if you free it the lazy member is left on
freed memory. A clone the session holds in `Entities`, or the `OldEntity` of
an event, leaves it there as soon as the session or the event is destroyed.
Hand a lazy member an entity the context loaded, or let it load its own.

!!! warning "Free the list before the context that made it"
    `CreateEntityList<T>` installs a hook on the list that points back at the
    context, so that an entity leaving the list is released through the same
    disposal path as any other. The list borrows the context and is not told
    when it dies: freeing the context first and the list afterwards calls into
    freed memory. It is the one borrowed reference here that does not outlive
    its lender, and nothing in the type system says so.

## Checking the State

```pascal
if LContext.UseIdentityMap then
  WriteLn('Identity map is active');
```
