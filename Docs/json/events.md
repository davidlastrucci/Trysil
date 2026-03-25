---
title: JSON Events
---

# JSON Events

JSON events allow you to hook into the serialization and deserialization process to customize the JSON output or transform incoming data.

## Custom Serialization/Deserialization Hooks

Create an event class by extending `TTJSonEvent<T>` and overriding the desired methods:

```pascal
type
  TPersonJSonEvent = class(TTJSonEvent<TPerson>)
  public
    procedure DoAfterSerialized(const AJSon: TJSonObject); override;
    procedure DoAfterDeserialized(const AJSon: TJSonValue); override;
  end;

procedure TPersonJSonEvent.DoAfterSerialized(const AJSon: TJSonObject);
begin
  // Add a computed field after serialization
  AJSon.AddPair('FullName',
    Entity.Firstname + ' ' + Entity.Lastname);
end;

procedure TPersonJSonEvent.DoAfterDeserialized(const AJSon: TJSonValue);
begin
  // Transform data after deserialization
  Entity.Firstname := Entity.Firstname.Trim;
  Entity.Lastname := Entity.Lastname.Trim;
end;
```

## Registering Events

Register your event class with the global event factory. This is typically done once at application startup:

```pascal
TTJSonEventFactory.Instance.RegisterEvent<TPerson, TPersonJSonEvent>();
```

Once registered, the event is automatically invoked whenever `TPerson` entities are serialized or deserialized through `TTJSonContext`.

## Use Cases

### Add Computed Fields During Serialization

```pascal
procedure TOrderJSonEvent.DoAfterSerialized(const AJSon: TJSonObject);
begin
  AJSon.AddPair('TotalFormatted',
    Format('EUR %.2f', [Entity.Total]));
end;
```

### Transform Data During Deserialization

```pascal
procedure TPersonJSonEvent.DoAfterDeserialized(const AJSon: TJSonValue);
begin
  // Normalize email to lowercase
  Entity.Email := Entity.Email.ToLower;
end;
```

### Remove or Modify JSON Properties

```pascal
procedure TPersonJSonEvent.DoAfterSerialized(const AJSon: TJSonObject);
begin
  // Remove sensitive data from output
  AJSon.RemovePair('InternalNotes');

  // Add hypermedia links
  AJSon.AddPair('_link',
    Format('/api/persons/%d', [Entity.ID]));
end;
```

## Event Lifecycle

1. **Serialization:** Entity is serialized to `TJSonObject` using standard attribute mapping, then `DoAfterSerialized` is called with the resulting JSON object.
2. **Deserialization:** JSON is deserialized to an entity instance using standard attribute mapping, then `DoAfterDeserialized` is called with the source JSON value.

The `Entity` property (inherited from `TTJSonEvent<T>`) gives you access to the entity being processed.
