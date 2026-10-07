# Events

Trysil provides lifecycle events that fire during Insert, Update and Delete operations (`Undelete` fires the update events). Events are defined across several units: `Trysil.Events.Abstract.pas`, `Trysil.Events.pas`, `Trysil.Events.Attributes.pas`, and `Trysil.Events.Factory.pas`.

## Lifecycle Events

| Event | When |
|---|---|
| BeforeInsert | Before inserting a new record |
| AfterInsert | After inserting a new record |
| BeforeUpdate | Before updating an existing record |
| AfterUpdate | After updating an existing record |
| BeforeDelete | Before deleting a record |
| AfterDelete | After deleting a record |

## Event Classes

Define custom event logic by extending `TTEvent<T>`:

```pascal
type
  TPersonInsertEvent = class(TTEvent<TPerson>)
  public
    procedure DoBefore; override;
    procedure DoAfter; override;
  end;

procedure TPersonInsertEvent.DoBefore;
begin
  // Runs before the INSERT command is executed
  if Entity.Firstname = '' then
    raise ETException.Create('Firstname is required');
end;

procedure TPersonInsertEvent.DoAfter;
begin
  // Runs after the INSERT command has executed
  // Entity.ID is now assigned
end;
```

### Available Properties

Inside an event class, the following properties are available via `TTEvent<T>`:

| Property | Type | Description |
|---|---|---|
| `Entity` | `T` | The entity being processed |
| `OldEntity` | `T` | The entity state before changes (loaded lazily from the database on first access; `nil` in the events of an insert, where there is no row yet) |
| `Context` | `TTContext` | The current context, allowing additional queries or operations |

`OldEntity` is loaded on demand by calling `TTContext.OldEntity<T>` internally. It is most useful in update events to compare old and new values. The clone belongs to the event, which frees it when the event is destroyed: do not free it, and do not hand it to a lazy member or keep it past the event. See [who frees what](context.md#who-frees-what).

## Registering Event Classes

Use event attributes on the entity class declaration:

```pascal
[TTable('Persons')]
[TSequence('PersonsID')]
[TInsertEvent(TPersonInsertEvent)]
[TUpdateEvent(TPersonUpdateEvent)]
[TDeleteEvent(TPersonDeleteEvent)]
TPerson = class
```

| Attribute | Triggers |
|---|---|
| `TInsertEvent(TEventClass)` | `DoBefore` and `DoAfter` around INSERT |
| `TUpdateEvent(TEventClass)` | `DoBefore` and `DoAfter` around UPDATE |
| `TDeleteEvent(TEventClass)` | `DoBefore` and `DoAfter` around DELETE |

Each attribute receives a class reference that must descend from `TTEvent`.
An event class normally inherits the constructor of `TTEvent<T>`. One that
declares its own must take the context, the entity and the operation, in this
order: `constructor Create(const AContext: TTContext; const AEntity: TPerson;
const AOperation: TTEventOperation)`, with `TTEventOperation` declared in
`Trysil.Events.Abstract`.

## Registering Events Without Attributes

The attribute ties the event class to the entity in the entity's own
declaration. The two classes need each other, so they end up in the same unit,
behind a forward declaration. That unit is also the one the Trysil Expert
regenerates when the database changes, and the business rules would go with it.

`TTEntityEvents<T>`, in `Trysil.Events`, carries all six events of an entity in
one class, and a registration ties it to the entity from the outside. The
entity knows nothing of its events, so the rules live in a unit of their own:

```pascal
unit Persons.Events;

interface

uses
  Trysil.Exceptions,
  Trysil.Events,
  Persons.Model;

type
  TPersonEvents = class(TTEntityEvents<TPerson>)
  strict protected
    procedure BeforeInsert; override;
    procedure BeforeUpdate; override;
  end;

implementation

procedure TPersonEvents.BeforeInsert;
begin
  if Entity.Firstname = '' then
    raise ETException.Create('Firstname is required');
end;

procedure TPersonEvents.BeforeUpdate;
begin
  if Entity.Lastname <> OldEntity.Lastname then
    raise ETException.Create('Lastname cannot change');
end;

initialization
  TTEventRegistration.RegisterEvents<TPerson, TPersonEvents>;

end.
```

`BeforeInsert`, `AfterInsert`, `BeforeUpdate`, `AfterUpdate`, `BeforeDelete`
and `AfterDelete` are virtual and empty: override only the ones you need. The
framework calls the one that matches the operation, and the class has the same
`Entity`, `OldEntity` and `Context` as any other event class.

- **The registration is checked by the compiler.** `RegisterEvents<T, E>`
  requires `E` to be a `TTEntityEvents<T>`, so an event class written for
  another entity does not compile. Register through `TTEventRegistration`:
  `TTEventRegistry`, which holds the registrations, is public only because the
  framework reaches it from another unit.
- **The registration is inherited.** An entity with no registration of its own
  uses the one of its nearest ancestor, as it does with the event attributes.
- **Each entity is registered once.** Registering the same entity twice, or a
  `nil` class, raises. In an `initialization` section the exception stops the
  application before it starts.
- **Do not mix the attribute and the registration on the same branch.** An
  entity that has an event attribute and a registration on its hierarchy
  raises, but only at the first write of the operation in conflict: with
  `[TUpdateEvent]` and a registration, inserts go through the registration and
  the first update raises.
- **A registration lasts for the life of the process.** There is no way to
  remove one, which matters only to a host that unloads packages at runtime.

## Event Method Attributes

For simpler cases where a full event class is not needed, add event methods directly on the entity using method attributes:

```pascal
TPerson = class
strict private
  // fields...
public
  [TBeforeInsertEvent]
  procedure BeforeInsert;

  [TAfterInsertEvent]
  procedure AfterInsert;

  [TBeforeUpdateEvent]
  procedure BeforeUpdate;

  [TAfterUpdateEvent]
  procedure AfterUpdate;

  [TBeforeDeleteEvent]
  procedure BeforeDelete;

  [TAfterDeleteEvent]
  procedure AfterDelete;
end;
```

### Available Method Attributes

| Attribute | When |
|---|---|
| `TBeforeInsertEvent` | Before INSERT |
| `TAfterInsertEvent` | After INSERT |
| `TBeforeUpdateEvent` | Before UPDATE |
| `TAfterUpdateEvent` | After UPDATE |
| `TBeforeDeleteEvent` | Before DELETE |
| `TAfterDeleteEvent` | After DELETE |

These methods are invoked by the resolver via RTTI. They must take no parameters and must be **`public`**. They can be declared on the entity class or on one of its ancestors: an inherited event method fires as well. A virtual event method overridden in a derived class fires once, through the override, whether or not the override repeats the attribute.

!!! warning "A private event method is never called"
    Delphi emits RTTI for `public` and `published` methods only. An event
    attribute on a `private`, `strict private` or `protected` method is
    therefore never seen by the resolver: nothing is registered, nothing
    raises, and the method is simply never called. The mistake is silent, so
    put event methods in the `public` section.

## Event Execution Order

When the resolver processes a write operation, the full sequence is:

1. **Validation** (attribute-based validation, on `Insert`, `Update` and `Undelete`: `Delete` does not validate; `Undelete` fires the update events)
2. **Event class** `DoBefore` (if a `TInsertEvent` / `TUpdateEvent` / `TDeleteEvent` attribute or a registration supplies one; for a `TTEntityEvents<T>` this is `BeforeInsert` / `BeforeUpdate` / `BeforeDelete`)
3. **Event method** `[TBeforeInsertEvent]` / `[TBeforeUpdateEvent]` / `[TBeforeDeleteEvent]` on the entity
4. **SQL command execution** (INSERT / UPDATE / DELETE)
5. **Event class** `DoAfter` (for a `TTEntityEvents<T>`, `AfterInsert` / `AfterUpdate` / `AfterDelete`)
6. **Event method** `[TAfterInsertEvent]` / `[TAfterUpdateEvent]` / `[TAfterDeleteEvent]` on the entity

## Raising Exceptions in Events

Raising an exception in a `DoBefore` method or a `[TBeforeInsertEvent]` method prevents the SQL command from executing. If a transaction is active, the exception propagates and can trigger a rollback:

```pascal
procedure TOrderDeleteEvent.DoBefore;
begin
  if Entity.Status = 'Shipped' then
    raise ETException.Create('Cannot delete a shipped order');
end;
```

## Example: Audit Logging

```pascal
type
  TPersonUpdateEvent = class(TTEvent<TPerson>)
  public
    procedure DoAfter; override;
  end;

procedure TPersonUpdateEvent.DoAfter;
var
  LAudit: TAuditLog;
begin
  LAudit := Context.CreateEntity<TAuditLog>();
  try
    LAudit.TableName := 'Persons';
    LAudit.EntityID := Entity.ID;
    LAudit.Action := 'UPDATE';
    LAudit.Timestamp := Now;
    Context.Insert<TAuditLog>(LAudit);
  finally
    Context.FreeEntity<TAuditLog>(LAudit);
  end;
end;
```

The audit entry is freed with `FreeEntity<T>`, not with `Free`. The event runs
inside the transaction Trysil opened for the update, and if that transaction
rolls back it puts back what it wrote to `LAudit` too: `FreeEntity<T>` tells it
to forget the entity first, a bare `Free` leaves it writing into freed memory.
