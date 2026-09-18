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
| `OldEntity` | `T` | The entity state before changes (loaded lazily from the database on first access) |
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

These methods are invoked by the resolver via RTTI. They must be declared on the entity class itself (not on a parent class), must take no parameters, and must be **`public`**.

!!! warning "A private event method is never called"
    Delphi emits RTTI for `public` and `published` methods only. An event
    attribute on a `private`, `strict private` or `protected` method is
    therefore never seen by the resolver: nothing is registered, nothing
    raises, and the method is simply never called. The mistake is silent, so
    put event methods in the `public` section.

## Event Execution Order

When the resolver processes a write operation, the full sequence is:

1. **Validation** (attribute-based validation, on `Insert`, `Update` and `Undelete`: `Delete` does not validate; `Undelete` fires the update events)
2. **Event class** `DoBefore` (if a `TInsertEvent` / `TUpdateEvent` / `TDeleteEvent` is registered)
3. **Event method** `[TBeforeInsertEvent]` / `[TBeforeUpdateEvent]` / `[TBeforeDeleteEvent]` on the entity
4. **SQL command execution** (INSERT / UPDATE / DELETE)
5. **Event class** `DoAfter`
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
