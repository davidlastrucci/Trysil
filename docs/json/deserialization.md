---
title: JSON Deserialization
---

# JSON Deserialization

Deserialize JSON strings and objects into Trysil entity instances and lists.

!!! warning "The body sets more than you may expect"
    Deserialization reads into the entity every mapped column it finds in the
    JSON, including the **primary key**, the **`[TVersionColumn]`**, every
    foreign key behind a `TTLazy<T>` and every `[TDetailColumn]` collection.
    It is deliberate: `Update<T>` composes its `WHERE` from the key and the
    version the entity holds, and on a fresh entity the body is the only place
    they can come from.

    So a body can set the version and any foreign key, a tenant column
    included. Trysil does not decide which of them a body may set: mark the
    fields it must never set with `[TJSonIgnoreDeserialize]`, or deserialize
    into a fresh instance and copy across only the fields you accept.

    Change tracking columns are the exception: no entry point reads them from
    JSON. Which fields to mark, and which two to leave alone, is
    [below](#restricting-what-the-body-may-write).

## JSON String to Entity

```pascal
var LPerson := LContext.EntityFromJSon<TPerson>(LJsonString);
try
  // LPerson is a new entity populated from JSON
  LContext.Insert<TPerson>(LPerson);
finally
  LContext.FreeEntity<TPerson>(LPerson);
end;
```

The returned entity is a newly created instance, and the caller owns it: a JSON context refuses the identity map, so nothing else will free it. `FreeEntity<T>` is the way to free what a context read or created, whether or not a map is in play; a clone from `CloneEntity` or `OldEntity` is freed with `FreeClone<T>`, and an entity handed to a session's `Insert` is the session's. See [who frees what](../guide/context.md#who-frees-what).

## TJSonValue to Entity

When you already have a parsed JSON value (e.g., from an HTTP request body):

```pascal
var LPerson := LContext.EntityFromJSonObject<TPerson>(LJsonValue);
try
  // Work with the entity
finally
  LContext.FreeEntity<TPerson>(LPerson);
end;
```

## Onto an Already Loaded Entity

Both entry points have an overload that fills an entity you already own instead
of creating a fresh one. This is the shape to use for an update endpoint:

```pascal
var LEntity := LContext.Get<TPerson>(AID);
try
  LContext.EntityFromJSonObject<TPerson>(LJsonValue, LEntity);
  LContext.Update<TPerson>(LEntity);
finally
  LContext.FreeEntity<TPerson>(LEntity);
end;
```

Why it matters: with a fresh entity every column absent from the body is blank,
and `Update<T>` writes the whole row, so an absent column is written back
blank. Filling a loaded entity keeps the stored values for what the body does
not mention.

Three things to know:

- The identity map is forbidden in a `TTJSonContext`, so `Get<T>` returns an
  entity nobody owns: the `try..finally` is not optional.
- The semantics are replace-all, not merge. A `String` column absent from the
  body keeps its loaded value, but a `TTNullable` column absent from the body
  is set to NULL.
- The `id` in the body still wins over the entity you loaded. Compare it with
  the one resolved from the route if that matters to you.

!!! warning "Detail collections already loaded are destroyed"
    If the entity carries a `TTLazyList<T>` detail and you deserialize onto it
    a body that carries the collection, the list is cleared before being
    refilled from the body, and in a
    `TTJSonContext` the list owns its items: every detail entity read from the
    database is **freed**. Any pointer you took from `LEntity.Details.List`
    before the call is dangling once the list has been cleared, even if the
    call then raises.
    The same holds for a `TTLazy<T>` whose master you had already read: if the
    body carries a different id, the entity in the cache is handed to
    `FreeEntity<T>` and the relation reloads on the next read. It happens
    column by column, so it happens even when a later column raises.
    Take the references you need after deserializing, not before.

!!! note "Change tracking never comes from JSON"
    `[TCreatedAt]`, `[TCreatedBy]`, `[TUpdatedAt]`, `[TUpdatedBy]`,
    `[TDeletedAt]` and `[TDeletedBy]` are skipped by every deserialization
    entry point, on both overloads. A value for them in a request body is
    ignored. See [Change Tracking](../guide/entities.md#change-tracking).

## Restricting What the Body May Write

`[TJSonIgnoreDeserialize]` is read on every mapped member, a `TTLazy<T>`
foreign key and a `[TDetailColumn]` collection included, so the entity is
where a field the client must never write gets closed:

```pascal
[TTable('Orders')]
[TRelation('OrderDetails', 'OrderID', True)]
TOrder = class
strict private
  [TColumn('ID')]
  [TPrimaryKey]
  FID: TTPrimaryKey;

  [TColumn('TenantID')]
  [TJSonIgnoreDeserialize]
  FTenant: TTLazy<TTenant>;

  [TDetailColumn('ID', 'OrderID')]
  [TJSonIgnoreDeserialize]
  FDetail: TTLazyList<TOrderDetail>;

  [TColumn('VersionID')]
  [TVersionColumn]
  FVersionID: TTVersion;
end;
```

The tenant is still serialized, and never read from the body. Without the
attribute a body carrying `{"tenantId": 2}` sets the foreign key to 2 in the
entity, and `Update<T>` writes it like any other column: neither the
`[TWhereClause]` nor the filter that scopes the reads applies to a write, and
the deserializer cannot know which of your columns decides who may see the
row.

On a detail collection the attribute keeps the rows in the body out of the
entity: without it, a body that carries the collection replaces it in memory.

!!! warning "Do not mark the primary key or the version column"
    **The key says which row `Update<T>` writes.** On a fresh entity the `id`
    in the body is the only key it carries. Ignore it and the key stays 0:
    `Update<T>` affects no row, unless a row carries key 0, and raises
    `ETConcurrentUpdateException`.

    **The version is what optimistic locking compares.** On the overload that
    fills a loaded entity, ignoring it leaves the version `Get<T>` has just
    read, so the `WHERE` of `Update<T>` always matches and a stale version is
    never detected. On a fresh entity the version stays 0: `Update<T>`
    overwrites a row never updated since its insert, and raises
    `ETConcurrentUpdateException` on any other.

    With both read from the body, a body can carry a stale version, which
    `Update<T>` refuses with `ETConcurrentUpdateException`, or the key of a row
    the caller may not touch, which the deserializer does not check.

## JSON String to List

```pascal
var LPersons := LContext.CreateEntityList<TPerson>();
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
var LPersons := LContext.CreateEntityList<TPerson>();
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
    FContext.Context.FreeEntity<TPerson>(LPerson);
  end;
end;
```

## A Deserializer of Your Own

A member of a type Trysil does not know needs a deserializer, registered once at startup next to the other `Register*` calls - and, to go out, a serializer registered on `TTJSonSerializers` the same way. A type Trysil already handles cannot be registered a second time.

```pascal
type
  TVatCode = type String;

  TVatCodeDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

function TVatCodeDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
var
  LValue: String;
begin
  LValue := AJSon.Value;
  if LValue.Length <> 11 then
    raise ETJSonException.Create('A VAT code has eleven digits.');
  result := TTValue.From<TVatCode>(TVatCode(LValue));
end;

// at startup
TTJSonDeserializers.Instance.Register<TVatCode>(TVatCodeDeserializer);
```

The instance is **one per type, shared by every request thread**: keep no state in it between calls.

What `FromJSon` raises decides whose fault the failure is:

- **The value is wrong**: raise `ETJSonException`, which the listener answers `400` with your message. A conversion of the RTL that fails - `EJSONException`, `EConvertError`, `EDateTimeException`, `EArgumentException`, `ERangeError`, `EIntOverflow`, `EMathError`, `EVariantError` - is turned into an `ETJSonException` naming the field, and answers `400` too.
- **Something is wrong on the server** - a lookup table that is not loaded, a setting that is missing: raise `ETJSonServerException`, which answers `500` and goes to the error log.

!!! warning "A defect in your code can answer 400"
    The eight classes above become a `400` whatever raised them, a bug in
    your deserializer included: an index out of range, or a `StrToInt` on a
    setting, tells the client that its value is not valid. The client cannot
    tell the difference, but the log can: the line of that `400` carries the
    class of the exception behind it - the class, not its message, which
    quotes the value the client sent. The message is still on the exception
    of the `400`, in `InnerException`, in `NestedExceptionMessage` and in
    `ToString`: a host that logs any of them writes the value of the client. The message of the `400` itself is
    written as it is: for JSON that does not parse, handed over as a string,
    it is the parser's message, which names the path of the keys the client
    sent. When a failure is
    yours, raise `ETJSonServerException` yourself.
