# Generate entity model

**Trysil > Generate entity model** writes a Delphi unit for each entity of the model and adds it to the active project.

## The dialog

![Generate entity model](images/generate-model.png)

| Field | Meaning |
|---|---|
| Model directory | Folder of the units, relative to the project folder. Default `Model` |
| Unit filenames | Pattern of the unit names. Default `{ProjectName}.Model.{EntityName}` |
| Entities | The entities to generate, all ticked by default. Right click for **Select all entities** / **Unselect all entities** |
| Generate filter properties companion | Adds a `T<Entity>Properties` record to each unit |
| Generate & register API REST controllers | Only for projects created by the [API REST wizard](api-rest.md) |

The unit name pattern accepts two placeholders, ignoring case: `{ProjectName}`, the name of the `.dproj` without extension, and `{EntityName}`. For the project `OrdersAPI` and the entity `Order` the default gives `OrdersAPI.Model.Order`. Nested folders are allowed in **Model directory**, for example `Source/Model`, and are created when missing.

The defaults come from [Settings](settings.md). What you choose here is remembered for the project in `__trysil\__settings\settings.json`.

If a unit with the same name is already in the project, the Expert lists the units that would be overwritten and asks before continuing.

## What is generated

Each unit contains the entity class with its Trysil attributes, and the getters and setters of the lazy properties. The units are opened in the editor and added to the project: save them as you would any new unit.

For an `Order` entity with an order date, a customer and a note:

```delphi
unit OrdersAPI.Model.Order;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Filter.Expression,
  Trysil.Validation.Attributes,
  Trysil.Lazy,

  OrdersAPI.Model.Customer;

type

{ TOrder }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TColumn('OrderDate')]
    FOrderDate: TDateTime;

    [TRequired]
    [TColumn('CustomerID')]
    FCustomer: TTLazy<TCustomer>;

    [TMaxLength(200)]
    [TColumn('Notes')]
    FNotes: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;

    function GetCustomer: TCustomer;
    procedure SetCustomer(const AValue: TCustomer);
  public
    property ID: TTPrimaryKey read FID;
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    property Customer: TCustomer read GetCustomer write SetCustomer;
    property Notes: String read FNotes write FNotes;
    property VersionID: TTVersion read FVersionID;
  end;
```

`ID` and `VersionID` are read-only: Trysil assigns them. The units of the referenced entities are added to the `uses` clause.

`{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}` turns a misspelled attribute into a compile error instead of an attribute silently ignored.

## Regenerating the model

When the database changes, regenerate the units of the entities that changed: the Expert rewrites each unit whole, after asking. Whatever was written by hand in a model unit is lost with it:

- event methods on the entity (`[TBeforeInsertEvent]` and the other five) and `[TValidator]` methods;
- validation attributes added to the fields after generation;
- calculated properties and helper methods;
- an event class tied to the entity with `[TInsertEvent]`, `[TUpdateEvent]` or `[TDeleteEvent]`, which has to live in the unit of the entity.

Keep the model units as the Expert writes them, and put the code you write in units of your own. Business rules go in a `TTEntityEvents<T>` registered with `TTEventRegistration.RegisterEvents<T, E>` from the unit that holds them: the entity knows nothing of it, so regenerating the entity leaves it untouched. See [Registering events without attributes](../../guide/events.md#registering-events-without-attributes).

## Filter properties companion

With **Generate filter properties companion** ticked, each unit also declares a record with one `TTProperty` per data column, the primary key included and the version column excluded:

```delphi
{ TOrderProperties }

  TOrderProperties = record
  public
    ID: TTProperty;
    OrderDate: TTProperty;
    Notes: TTProperty;

    class function Create: TOrderProperties; static;
  end;
```

It gives compile-time checked column names to the [expression API](../../guide/filtering.md):

```delphi
var
  LOrder: TOrderProperties;
  LFilter: TTFilter;
begin
  LOrder := TOrderProperties.Create;
  LFilter := Context.CreateFilterBuilder<TOrder>()
    .Where(
      (LOrder.OrderDate >= StartOfTheMonth(Today)) and
      LOrder.Notes.IsNotNull)
    .OrderByDesc(LOrder.OrderDate)
    .Build;
```

Entity and entity list columns have no entry in the record.

## API REST controllers

In a project created by the [API REST wizard](api-rest.md) the option **Generate & register API REST controllers** is enabled; in any other project it is greyed out. When ticked, for each selected entity the Expert also:

1. writes a controller unit `<Project>.Controller.<Entity>` in the `Controllers` folder of the project:

    ```delphi
    [TUri('/order')]
    TOrderController = class(TReadWriteController<TOrder>)
    end;
    ```

    The URI is the entity name in lower case;

2. opens `<Project>.Http` and registers the controllers: it adds the units to its `uses` clause and a `Server.RegisterController<TOrderController>();` line to `RegisterEntityControllers`. Units and registrations already there are not added again, so the model can be regenerated with the option ticked.
