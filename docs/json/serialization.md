---
title: JSON Serialization
---

# JSON Serialization

Serialize Trysil entities and lists to JSON strings or Delphi JSON objects.

## Entity to JSON String

```pascal
var LConfig := TTJSonSerializerConfig.Create(-1, False);
var LJson := LContext.EntityToJSon<TPerson>(LPerson, LConfig);
// Returns: {"ID":1,"Firstname":"David","Lastname":"Lastrucci","VersionID":1}
```

## Entity to TJSonObject

When you need to manipulate the JSON object before converting to a string:

```pascal
var LJsonObj := LContext.EntityToJSonObject<TPerson>(LPerson, LConfig);
try
  // Work with TJSonObject directly
  LJsonObj.AddPair('ComputedField', 'value');
  LResult := LJsonObj.ToJSON;
finally
  LJsonObj.Free;
end;
```

## List to JSON String

```pascal
var LJson := LContext.ListToJSon<TPerson>(LPersons, LConfig);
// Returns: [{"ID":1,...},{"ID":2,...}]
```

## List to TJSonArray

```pascal
var LArray := LContext.ListToJSonArray<TPerson>(LPersons, LConfig);
try
  // Work with TJSonArray directly
finally
  LArray.Free;
end;
```

## Dataset to JSON

Convert any `TDataset` to a JSON string, regardless of whether it comes from Trysil:

```pascal
var LJson := LContext.DatasetToJSon(LDataset);
```

The field names come out **lower cased**, which is not the camelCase an entity
produces. The difference is deliberate: an entity takes its names from the
Delphi members, while here they arrive from the database, where the case
depends on the dialect - `CUSTOMERNAME` on Oracle, `customername` on
PostgreSQL. There is no camelCase to recover from either, so lower case is the
one form that is the same everywhere. Alias the columns in the `SELECT` if you
want to decide the names yourself.

## Metadata to JSON

Export entity column metadata (names, types, sizes) as JSON:

```pascal
var LJson := LContext.MetadataToJSon<TPerson>();
// Returns column metadata: names, types, sizes
```

This is useful for building dynamic UIs or generating documentation from entity definitions.

The payload names what it describes with `entity`, the **class name** without the `T` that Delphi puts in front of a type: `TAPIOrder` is reported as `APIOrder`. Only that one letter is dropped, and only when a capital follows it, so an acronym keeps its shape and a class called `Temp` is left alone. It used to be `tableName`, the name of the table in the database, and that was the one line in the payload that spoke of the schema: every other name in it - the columns, the primary key, the version column - is already the JSON name the client sees in ordinary responses. The table name is of no use to a client that addresses `/api/orders`, it changes when you rename a table and would break that client for a change that does not concern it, and it is the first thing worth having for anyone probing the API for a way into the database underneath. The class name is stable across a schema refactor and identifies the type, which is what a client caching metadata needs.

The array is called `properties`, not `columns`, because that is what it holds: one entry per mapped **member**, reported with the JSON name the client sees in ordinary responses. A `[TColumn('CustomerID')]` on a `TTLazy<TCustomer>` appears as `customerID`, not as the column behind it. Reading it as a list of database columns was the mistake the old name invited.

Each property reports `name`, `type`, and - when they are not zero - `size` and `precision`. For a decimal column the two mean what they mean in the database and not what their names suggest: **`size` is the decimal scale** and `precision` the total number of digits, so `decimal(19,4)` comes back as `"size": 4, "precision": 19`. A client that validates an amount needs both: `size` alone does not say how many integer digits fit. `precision` is new in 2.0.0 and, like `size`, is omitted when zero, so an existing payload only gains a key.

A column carrying [`TNotFilterable`](../api-reference/attributes.md#tnotfilterable) also reports `"filterable": false`. The pair appears **only** when the column cannot be filtered, so absence means filterable. From 2.0.0 that covers one case more: a column no response returns is not filterable either, so a member carrying `[TJSonIgnoreSerialize]` reports `filterable: false` beside its `readable: false`. The one exception is a column map built by hand with no member, which the mapper never produces: it has no JSON name and stays filterable by its column name. A client that builds a filter UI from the metadata should hide those columns, otherwise the first `where` on one comes back as a `400`.

The direction is declared the same way. `properties` holds one entry per member the entity serializes **or** deserializes, and only the exception is written: `"readable": false` on a member the body may write and no response returns - a password taken on create is the case from the manual - and `"writable": false` on one that is returned and never read from the body, which includes every change tracking column, because the deserializer refuses those. A member that goes both ways gains no key. Only `[TJSonIgnore]`, which is neither direction, is left out of the payload entirely, and the `primaryKey` and `versionColumn` pairs at the top answer the same question as the array below them: a key the body may write and no response returns is still named as the key, with `"readable": false` on its entry.

## Ignoring Fields

Use the `TJSonIgnore` attribute to exclude specific fields from serialization:

```pascal
type
  [TTable('Persons')]
  [TSequence('PersonsID')]
  TPerson = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Firstname')]
    FFirstname: String;

    [TColumn('Lastname')]
    FLastname: String;

    [TJSonIgnore]
    [TColumn('InternalField')]
    FInternalField: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property InternalField: String read FInternalField write FInternalField;
    property VersionID: TTVersion read FVersionID;
  end;
```

When serialized, `InternalField` will not appear in the JSON output.

## Serialization Config

The `TTJSonSerializerConfig` record controls serialization depth and detail inclusion. See [JSON Configuration](configuration.md) for details.

!!! warning "An `Int64` is emitted as a JSON number"
    Which is exact on the wire and lossy in JavaScript: `Number` holds whole
    values up to 2^53 - 9,007,199,254,740,992 - and silently rounds anything
    larger. A `BIGINT` primary key generated from a timestamp, or a quantity
    in thousandths, can reach that range.

    Trysil emits every number as a JSON number, `Currency` included, so no
    mapping quotes it for you. If the values in a column go beyond that
    range, map the member as `String` rather than relying on the client to
    read it back intact.

    In the other direction both forms are accepted: a client that holds a
    large whole number as a string may send it quoted, and the value reaches
    the `Int64` member without passing through a `Double`.

## Cycles

Two entities that point at each other - an employee and a manager, a category
and its parent - form a cycle. With `MaxLevels` at `-1` the depth gate is
always open, so the serializer follows the reference each way in turn.

It stops on its own: while it descends it remembers which entities it is
inside, by class and primary key, and when one of them comes round again it
emits only the reference id, exactly as `MaxLevels = 0` does. The JSON is
finite and valid, and no exception is raised.

The identity check is on the key rather than on the instance because a JSON
context refuses the identity map, so each step loads a fresh object: two
instances of the same row are the same entity as far as a cycle is concerned.
An entity with no `[TPrimaryKey]` - a DTO filled by `RawSelect` - has no
identity to compare, and is serialized as it was before.
