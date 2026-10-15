---
title: OpenAPI Module
---

# OpenAPI Module

The OpenAPI module (`Trysil.OpenAPI/`, package `Trysil.OpenAPI`) describes a `TTHttpServer<C>` as an **OpenAPI 3.1** document and serves it as JSON on `GET <BaseUri>/openapi.json`. Paths, verbs, path parameters, security and the schema of every entity are read from what the server already knows; a handful of attributes add what it cannot know - summaries, tags, request bodies and responses.

The package depends on `Trysil`, `Trysil.JSon` and `Trysil.Http`. It serves the document only: there is no Swagger UI page in the package. Any OpenAPI tool can read the document - [editor.swagger.io](https://editor.swagger.io) is the quickest way to look at it.

## Activation

Call `TTOpenApi<C>.Register` after the **last** `RegisterController` and **before** `Start`:

```pascal
uses
  Trysil.Http,
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI;

LServer.RegisterAuthentication<TMyAuthentication>();
LServer.RegisterController<TCustomerController>();
LServer.RegisterController<TOrderController>();

TTOpenApi<TMyContext>.Register(
  LServer, TTOpenApiInfo.Create('Orders API', '1.0', 'Customers and orders'));

LServer.Start;
```

| Method | Document |
|---|---|
| `Register(AServer, AInfo)` | Protected like any other route: it requires the authentication the server registered. On a server with no authentication use `RegisterAnonymous`: a protected document there makes `Start` raise, unless `AllowAnonymous` is `True`. |
| `RegisterAnonymous(AServer, AInfo)` | Public: the controller that serves it is marked `[TAuthorizationType(None)]`. |

`TTOpenApiInfo` (`Trysil.OpenAPI.Types`) is a record with two constructors, `Create(ATitle, AVersion)` and `Create(ATitle, AVersion, ADescription)`, and read-only `Title`, `Version` and `Description`: they become the `info` object of the document.

The document is generated **once**, inside `Register`, from the routes registered so far: a controller registered afterwards is not in it. The route that serves the document is not described in it.

`Register` and `RegisterAnonymous` raise `ETOpenApiException` (`Trysil.OpenAPI.Exceptions`) when:

- the server is already started;
- the document is already registered on this server;
- the document of the same context type `C` is already registered on another server (see [Limits](#limits));
- the title or the version is empty;
- a route describes the entity of its controller and the controller has no `EntityClass` (see [The entity of a controller](#the-entity-of-a-controller));
- a `[TRequestBody]` has the `Page` shape.

## What is described without attributes

| Part of the document | Where it comes from |
|---|---|
| Server | The `BaseUri`, as it was set, in `servers`: `{"url": "/api"}`. Without a `BaseUri` there is no `servers`. |
| Paths and verbs | The registered routes, lower-case and relative to the server: `/customer/{id}`, not `/api/customer/{id}`. |
| Tags | `[TTag]` when the controller has one; otherwise the first segment of the path, lower-case - every route under `/customer` is tagged `customer`. A path whose first segment is a placeholder, or that is the `BaseUri` alone, has no tag. |
| Path parameters | Each `?` becomes `{name}`, from the name of the method parameter without its `A` prefix: `AID` is `{id}`, `AVersionID` is `{versionID}`. Always required. |
| Path parameter type | `integer` (`int32`). With Sqids on - `TTJSonSqids.Instance.UseSqids`, read when the document is generated - `{type: string, minLength: 8}`, never a pattern, so the alphabet is not published; a `[TNotSqid]` parameter stays an integer. |
| Security | With an authentication registered, one scheme in `components.securitySchemes`, `<name>: {type: http, scheme: <name>}`, where the name is the scheme the authentication reads, lower-case (`bearer`, `basic`, `digest`), and a protected route requires it. A route marked `[TAuthorizationType(None)]` always says `security: []`. Without an authentication there is no scheme, and the protected routes carry no `security`. |
| Error responses | See [Implicit error responses](#implicit-error-responses). |
| Schemas of the entities | See [Entity schemas](#entity-schemas). |

## Attributes

The attributes live in `Trysil.OpenAPI.Attributes`, the enumerations in `Trysil.OpenAPI.Types`.

| Attribute | Where | Effect |
|---|---|---|
| `[TTag('Name')]` | Controller class, inherited | Tag of every operation of the controller, in place of the first segment of the path. |
| `[TDescription('Text')]` | Controller class, inherited | Description of the tag. |
| `[TSummary('Text')]` | Method | Summary of the operation. |
| `[TDescription('Text')]` | Method | Description of the operation. |
| `[TParameter('name', TTOpenApiParameterSource.Query, 'Text')]` | Method, repeatable | A query or header parameter (`Query` or `Header`). Always an optional string. |
| `[TRequestBody(...)]` | Method | The request body. |
| `[TResponse(...)]` | Method, repeatable | A response. |

`[TRequestBody]` and `[TResponse]` separate **what** travels from **how**. The shape, `TTOpenApiShape`, is one of:

| Shape | JSON |
|---|---|
| `Single` | One object. |
| `List` | An array of objects. |
| `Page` | `{"count": integer, "data": [ ... ]}`, both required. Not allowed on a request body. |

The type is either the entity of the controller or a class named explicitly:

```pascal
[TRequestBody(TTOpenApiShape.Single, 'The entity to insert')]
[TRequestBody(TTOpenApiFilter, TTOpenApiShape.Single, 'Filter')]

[TResponse(200, 'Deleted')]                                      // no schema
[TResponse(200, TTOpenApiShape.Page, 'Count and rows')]           // entity of the controller
[TResponse(200, TOrderSummary, TTOpenApiShape.List, 'Summary')]   // explicit class
```

Three classes of `Trysil.OpenAPI.Types` describe the JSON that Trysil itself reads or writes, for use in the explicit form:

| Class | Schema |
|---|---|
| `TTOpenApiFilter` | The body `TTHttpFilter<T>` reads: `where` (`columnName`, `condition`, `value`), `orderBy` (`columnName`, `direction`), `start`, `limit`. |
| `TTOpenApiMetadata` | What `MetadataToJSon<T>` writes. |
| `TTOpenApiError` | The body of an error response: `status`, `message`, `taskId`. |

### Write it once, on the generic base

The routes of an application usually live on a generic base controller, and the concrete controllers only close the generic. That is where the responses belong: written once, they describe every entity.

```pascal
TReadOnlyController<T: class> = class(TController)
public
  class function EntityClass: TClass; override;

  [TGet('/?')]
  [TSummary('Read by ID')]
  [TResponse(200, TTOpenApiShape.Single, 'The entity')]
  procedure Get(const AID: TTPrimaryKey); virtual;

  [TPost('/select')]
  [TSummary('Read with a filter')]
  [TRequestBody(TTOpenApiFilter, TTOpenApiShape.Single, 'Filter')]
  [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
  procedure Select; virtual;
end;

// [TTag] and [TDescription] are inherited: on the generic base they would
// give every controller the same tag, so they go on the concrete one.
[TUri('/customer')]
[TTag('Customers')]
[TDescription('The customer registry')]
TCustomerController = class(TReadOnlyController<TCustomer>);
```

### Overriding

A method that overrides a routed method can declare attributes of its own. For each kind of attribute the most derived method that declares at least one wins, and the others of that kind are ignored; the kinds it does not declare are inherited. `[TResponse]` is replaced as a block: an override that declares one response declares them all.

## The entity of a controller

A shape without a class means *the entity of the controller*, and the generator asks the controller for it through `TTHttpController<C>.EntityClass`, a virtual class function that returns `nil` by default. Override it once, in the generic base:

```pascal
uses
  System.TypInfo;

class function TReadOnlyController<T>.EntityClass: TClass;
begin
  result := GetTypeData(TypeInfo(T))^.ClassType;
end;
```

A route that uses a shape without a class on a controller whose `EntityClass` is `nil` makes `Register` raise, naming the controller and the method.

## Implicit error responses

Every operation gets the error responses Trysil can send on its own, all with the `TTOpenApiError` schema:

| Code | When |
|---|---|
| 500 | Always. |
| 401 | The route is protected and the server has an authentication. |
| 403 | The route carries `[TArea]`. |
| 404 | The path has a placeholder. |
| 400, 413, 422 | The operation has a request body. |

409 is never implicit: declare it where it can happen, typically on the update and the delete of a versioned entity. A `[TResponse]` with the same code as an implicit one replaces it.

## Entity schemas

Each entity is a schema in `components.schemas`, and the schema is the JSON the [serializer](../json/serialization.md) writes:

- property names are the JSON names;
- a member with `[TJSonIgnore]` is left out, one with `[TJSonIgnoreSerialize]` is `writeOnly`, one with `[TJSonIgnoreDeserialize]` is `readOnly`;
- the change tracking columns are `readOnly`; the version column is an integer;
- the primary key follows Sqids, like the path parameters;
- a `TTLazy<T>` member is two properties: `<name>ID`, the key, and `<name>`, a `readOnly` reference to the related schema; a detail collection is an array of references;
- a `TTNullable<T>` member has the type `[<type>, "null"]`.

| Delphi type | Schema |
|---|---|
| `String` | `string` |
| `Int16`, `Int32` | `integer`, `int32` |
| `Int64` | `integer`, `int64` |
| `Double`, `Extended` | `number`, `double` |
| `Currency` | `number` |
| `Boolean` | `boolean` |
| `TDateTime`, `TDate`, `TTime` | `string`, `date-time` / `date` / `time` |
| `TGuid` | `string`, `uuid` |
| `TBytes` | `string`, `contentEncoding: base64` |

The [validation attributes](../guide/validation.md) become constraints:

| Attribute | Constraint |
|---|---|
| `[TRequired]` | The property is in `required`. |
| `[TDisplayName]` | `title` |
| `[TMinLength]`, `[TMaxLength]` | `minLength`, `maxLength` |
| `[TMinValue]`, `[TMaxValue]` | `minimum`, `maximum` |
| `[TRange]` | `minimum` and `maximum`, inclusive |
| `[TGreater]`, `[TLess]` | `exclusiveMinimum`, `exclusiveMaximum` |
| `[TRegex]` | `pattern` |
| `[TEMail]` | `format: email` and its `pattern` |

A schema takes the name of its class. When two different classes have the same name - `TCustomer` in two units - every one of them takes its qualified name instead (`Orders.Model.TCustomer`), so neither is described with the fields of the other.

## Limits

- **One document per context type.** The document belongs to `TTOpenApiController<C>`, not to a server: in one process a second server with the same context type cannot register it, even after the first server has been destroyed. `Register` raises rather than replacing the document of the first server.
- **Placeholder names on a shared path.** OpenAPI does not allow two templates that differ only in the names of their parameters, so when two routes share a path every route takes the names of the first one registered. Within one controller the order of the methods is the order RTTI returns, which is not under your control.
- **Routes without attributes** get their path, parameters, security and implicit errors, and nothing else: no request body and no successful response.
- **Automatic tags are lower-case and have no description.** They are the first segment of the path as the router stores it; `[TTag]` and the class `[TDescription]` give a tag a name and a description of your choice.
- **Registration order.** Controllers registered after `Register` are not described.
- **Fields the application adds** to a predefined body - a `searchText` next to the filter, say - are not in `TTOpenApiFilter`: describe that body with a class of your own.

## Module Units

| Unit | Description |
|---|---|
| `Trysil.OpenAPI` | `TTOpenApi<C>`: `Register` and `RegisterAnonymous` |
| `Trysil.OpenAPI.Types` | `TTOpenApiInfo`, `TTOpenApiShape`, `TTOpenApiParameterSource`, `TTOpenApiFilter`, `TTOpenApiMetadata`, `TTOpenApiError` |
| `Trysil.OpenAPI.Attributes` | The attributes |
| `Trysil.OpenAPI.Exceptions` | `ETOpenApiException` |
| `Trysil.OpenAPI.Consts` | Messages and constants |
| `Trysil.OpenAPI.Controller` | The controllers that serve the document |
| `Trysil.OpenAPI.Generator`, `Trysil.OpenAPI.Schema` | The generator |
