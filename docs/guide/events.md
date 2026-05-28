# Events

Trysil provides lifecycle events that fire during Insert, Update, and Delete operations. Events are defined across several units: `Trysil.Events.Abstract.pas`, `Trysil.Events.pas`, `Trysil.Events.Attributes.pas`, and `Trysil.Events.Factory.pas`.

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

`OldEntity` is loaded on demand by calling `TTContext.OldEntity<T>` internally. It is most useful in update events to compare old and new values.

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

  [TBeforeInsert]
  procedure BeforeInsert;

  [TAfterInsert]
  procedure AfterInsert;

  [TBeforeUpdate]
  procedure BeforeUpdate;

  [TAfterUpdate]
  procedure AfterUpdate;

  [TBeforeDelete]
  procedure BeforeDelete;

  [TAfterDelete]
  procedure AfterDelete;
end;
```

### Available Method Attributes

| Attribute | When |
|---|---|
| `TBeforeInsert` | Before INSERT |
| `TAfterInsert` | After INSERT |
| `TBeforeUpdate` | Before UPDATE |
| `TAfterUpdate` | After UPDATE |
| `TBeforeDelete` | Before DELETE |
| `TAfterDelete` | After DELETE |

These methods are invoked by the resolver via RTTI. They must be declared on the entity class itself (not on a parent class) and must take no parameters.

## Event Execution Order

When the resolver processes a write operation, the full sequence is:

1. **Validation** (attribute-based validation runs first)
2. **Event method** `[TBeforeInsert]` / `[TBeforeUpdate]` / `[TBeforeDelete]` on the entity
3. **Event class** `DoBefore` (if a `TInsertEvent` / `TUpdateEvent` / `TDeleteEvent` is registered)
4. **SQL command execution** (INSERT / UPDATE / DELETE)
5. **Event class** `DoAfter`
6. **Event method** `[TAfterInsert]` / `[TAfterUpdate]` / `[TAfterDelete]` on the entity

## Raising Exceptions in Events

Raising an exception in a `DoBefore` method or a `[TBeforeInsert]` method prevents the SQL command from executing. If a transaction is active, the exception propagates and can trigger a rollback:

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
  LAudit.TableName := 'Persons';
  LAudit.EntityID := Entity.ID;
  LAudit.Action := 'UPDATE';
  LAudit.Timestamp := Now;
  Context.Insert<TAuditLog>(LAudit);
end;
```
