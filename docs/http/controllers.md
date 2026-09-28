---
title: Controllers & Routing
---

# Controllers & Routing

Controllers handle HTTP requests and produce responses. They are plain Delphi classes decorated with routing attributes.

## Defining Controllers

```pascal
type
  [TUri('/api/persons')]
  TPersonController = class(TTHttpController<TAPIContext>)
  public
    [TGet]
    procedure GetAll;

    [TGet('/?')]
    procedure GetById(const AID: TTPrimaryKey);

    [TPost]
    procedure Insert;

    [TPut]
    procedure Update;

    [TDelete('/?/?')]
    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);
  end;
```

## Route Attributes

| Attribute | HTTP Method |
|---|---|
| `TGet` | GET |
| `TPost` | POST |
| `TPut` | PUT |
| `TDelete` | DELETE |

## URL Parameters

URL parameters use the `?` placeholder. Parameters are mapped to method arguments by position:

| Route Pattern | Example URL | Parameters |
|---|---|---|
| `[TGet]` | `GET /api/persons` | None |
| `[TGet('/?')]` | `GET /api/persons/123` | `AID = 123` |
| `[TDelete('/?/?')]` | `DELETE /api/persons/123/1` | `AID = 123, AVersionID = 1` |

A placeholder stands for the last segments of the route, never for one in the middle. `[TGet('/?/detail')]` is refused when the controller is registered: a placeholder matches any value, so a fixed segment written after one turns the route into a pattern that overlaps addresses it was never meant to serve.

The router resolves a request by trying the exact address first, then the parametrized routes, then the catch-all, and at every step it looks for a route that answers the request method. The exact address wins when it answers the method and steps aside when it does not, and among the parametrized routes the search keeps going until one carries the method. So `[TGet('/2024/?')]` on one controller and `[TDelete('/?/?')]` on another can share a base URI and both stay reachable, and a literal `[TGet('/2024')]` does not turn `DELETE /reports/2024` into a `405` while `[TDelete('/?')]` is there to serve it. A `405` means no route that matches the address answers the method, and its `Allow` header lists what the address does answer.

!!! warning "Two patterns of the same shape are resolved in an order you do not control"
    What the router cannot decide for you is which of two routes that both match *and* both answer the method should win. `[TGet('/2024/?')]` and `[TGet('/?/?')]` under the same base URI both match `GET /reports/2024/7`, and which one runs is not defined. The framework does not refuse the pair, because a literal segment beside a placeholder is a legitimate way to write a special case. Keep the routes that answer the same method distinguishable by their shape, or fold the special case into the general method and branch on the value.

## Registering Controllers

```pascal
// Uses the [TUri] attribute on the controller class
FServer.RegisterController<TPersonController>();

// Overrides the [TUri] attribute with a custom base URI
FServer.RegisterController<TPersonController>('/custom');
```

## Authorization Areas

Use the `[TArea]` attribute to restrict endpoint access based on authorization areas:

```pascal
[TGet]
[TArea('read')]
procedure GetAll;

[TPost]
[TArea('write')]
procedure Insert;
```

Your authentication class fills `Request.User.Areas`; the listener is what compares them against `[TArea]` and answers `403`. See [Authentication](authentication.md) for details.

An `[TArea]` declared on a method your controller overrides is inherited by the override. Overloads are independent: two methods with the same name but different parameters do not share their areas.

`Start` refuses to run in two cases, because in both the attribute would be a lie:

- `[TArea]` anywhere and no authentication class registered - there is no user, so nothing restricts anything, and the route would be served to everyone.
- `[TArea]` on a route that also carries `[TAuthorizationType(TTHttpAuthorizationType.None)]` - authentication does not run there, so the user carries no area and the route answers `403` to everyone, forever.

## No-Auth Endpoints

To create endpoints that do not require authentication, use `[TAuthorizationType]`. It is read **on the method as well as on the class**, and the method wins:

```pascal
[TUri('/logon')]
[TAuthorizationType(TTHttpAuthorizationType.None)]
TLogonController = class(TTHttpController<TAPIContext>)
public
  [TPost]
  procedure Logon;

  [TPost('/reset')]
  [TAuthorizationType(TTHttpAuthorizationType.Authentication)]
  procedure ResetPassword;
end;
```

Without the attribute on `ResetPassword` that endpoint would be anonymous, because it inherits the class declaration. A controller opened at class level is almost always an authentication controller, so it is exactly the file where a new method must state its own answer.

!!! warning "Check your annotated methods before upgrading"
    Until this version the attribute was read **only** on the class: written on a method it was silently ignored. It now applies, in both directions. A `[TAuthorizationType(TTHttpAuthorizationType.None)]` written on a method of an authenticated controller used to do nothing and left the endpoint protected; it now opens it. Nothing reports the change, so grep for the attribute on methods and confirm each one says what you mean today.

## Request and Response

Inside controller methods, you have access to:

| Property | Type | Description |
|---|---|---|
| `FRequest` | `TTHttpRequest` | The incoming HTTP request |
| `FResponse` | `TTHttpResponse` | The outgoing HTTP response |
| `FContext` | `C` (your context type) | The per-request context |

```pascal
procedure TPersonController.GetAll;
var
  LPersons: TTList<TPerson>;
  LConfig: TTJSonSerializerConfig;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);
  LPersons := FContext.Context.CreateEntityList<TPerson>();
  try
    FContext.Context.SelectAll<TPerson>(LPersons);
    FResponse.Content := FContext.Context.ListToJSon<TPerson>(LPersons, LConfig);
  finally
    LPersons.Free;
  end;
end;

procedure TPersonController.GetById(const AID: TTPrimaryKey);
var
  LPerson: TPerson;
  LConfig: TTJSonSerializerConfig;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);
  LPerson := FContext.Context.Get<TPerson>(AID);
  try
    FResponse.Content := FContext.Context.EntityToJSon<TPerson>(LPerson, LConfig);
  finally
    FContext.Context.FreeEntity<TPerson>(LPerson);
  end;
end;
```

### Caller IP Address

`TTHttpRequest` exposes two IP properties:

| Property | Value |
|---|---|
| `RemoteIP` | the peer of the TCP connection, always the raw socket address |
| `ClientIP` | the originating caller, resolving `X-Forwarded-For` when the request arrives through a local reverse proxy |

`ClientIP` returns `RemoteIP` unchanged for direct connections. Only when the connection comes from loopback (`127.*`, `::1`, including `::ffff:`-mapped forms), which means a reverse proxy on the same host, does it read `X-Forwarded-For` and take the **last** entry: the one written by that proxy. Earlier entries in the chain come from the client and are ignored, so the header cannot be forged from outside. Ports and bracketed IPv6 literals are stripped.

```pascal
procedure TAuditController.Post;
begin
  FContext.Audit(FRequest.ClientIP, FRequest.User.Username);
end;
```

Use `ClientIP` for audit trails and rate limiting, `RemoteIP` when you need to know which host actually opened the connection.

## Generic CRUD Controllers

`Trysil.Http.Entity` carries the logic of the standard CRUD operations, for any entity type, in two classes: `TTHttpEntityReader<T>` reads and `TTHttpEntityWriter<T>` writes. They are not controllers. They take the `TTHttpContext` in the constructor, borrowing it without owning it, receive the request body as a `TJSonValue` and return the response as a JSON string, so they know nothing of routes, areas or authentication: those stay in your controllers, which delegate to them.

### TTHttpEntityReader\<T\>

| Method | Returns | Default configuration |
|---|---|---|
| `Get(AID)` | the entity | `WithDetails` |
| `Find(AID)` | the entity | `EntityOnly` |
| `SelectAll` | `{"count": n, "data": [...]}` | `WithRelations` |
| `Select(AJSonFilter)` | `{"count": n, "data": [...]}`, filtered by the body | `WithRelations` |
| `Metadata` | the entity metadata | - |

Each method but `Metadata` has an overload that takes a `TTJSonSerializerConfig` instead of the default one. `Get` and `Find` raise `ETHttpNotFound` for an id that is not there. `count` is the number of rows the filter matches, `data` only the page.

`Select` and `SelectAll` build the filter with `TTHttpFilter<T>`, bounded by the `TTHttpFilterParameters` given to the constructor, or by `TTHttpFilterParameters.Defaults` with the one-argument constructor: `SelectAll` is the same query with no body, so it stops at `MaxLimit` too.

| Event | Called |
|---|---|
| `OnAddEntityFilter` | with the filter built from the body, before `SelectCount` and `Select` |
| `OnBeforeSerializeEntity` | on each entity, before it is serialized |

`OnAddEntityFilter` is where the server narrows what the client asked for, a row-level restriction for instance. `TTFilter.AddWhere` joins the condition to the one from the body with `AND`, and keeps an `OR` of the body inside its parentheses:

```pascal
LReader.OnAddEntityFilter :=
  procedure(var AFilter: TTFilter)
  begin
    AFilter.AddWhere('UserID = :userID');
    AFilter.AddParameter('userID', ftInteger, LUserID);
  end;
```

The conditions from the body use the parameters `p0`, `p1`, ...: give yours other names.

### TTHttpEntityWriter\<T\>

| Method | Does | Default configuration |
|---|---|---|
| `Insert(AJSonEntity)` | deserializes, takes the id from the sequence if the body has none, inserts, returns the entity | `WithDetails` |
| `Update(AJSonEntity)` | deserializes, updates, reloads the row, returns it | `WithDetails` |
| `Delete(AID, AVersionID)` | loads the row, puts back the version the client sent, deletes | - |
| `CreateNew` | returns a new entity, with its id, without inserting it | `EntityOnly` |

`Insert`, `Update` and `CreateNew` have an overload that takes a `TTJSonSerializerConfig`. `Update` reloads the row before answering because the body does not carry the change tracking columns. `Delete` raises `ETHttpNotFound` for an id that is not there and `ETConcurrentUpdateException`, a 409, for a version the row no longer has.

| Event | Called |
|---|---|
| `OnBeforeInsert`, `OnAfterInsert` | around the insert |
| `OnBeforeUpdate`, `OnAfterUpdate` | around the update |
| `OnBeforeDelete`, `OnAfterDelete` | around the delete |
| `OnApplyDetails` | after the insert or the update, before `OnAfterInsert` or `OnAfterUpdate` |

Every write runs in `RunInTransaction` with its events: an exception in any of them, `OnApplyDetails` included, rolls the row back.

### The controllers

The controllers are yours: two generic base classes, one for reading and one, derived from it, for writing, declare the routes and delegate. Everything the application wants to share - areas, events, configurations - lives in them once:

```pascal
type
  TAPIReadOnlyController<T: class> = class(TTHttpController<TAPIContext>)
  strict private
    FReader: TTHttpEntityReader<T>;
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TGet('/?')]
    [TArea('read')]
    procedure Get(const AID: TTPrimaryKey);

    [TPost('/select')]
    [TArea('read')]
    procedure Select;
  end;

  TAPIReadWriteController<T: class> = class(TAPIReadOnlyController<T>)
  strict private
    FWriter: TTHttpEntityWriter<T>;
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TPost]
    [TArea('write')]
    procedure Insert;

    [TDelete('/?/?')]
    [TArea('write')]
    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);
  end;

constructor TAPIReadOnlyController<T>.Create(
  const AContext: TAPIContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FReader := TTHttpEntityReader<T>.Create(FContext.Context);
end;

procedure TAPIReadOnlyController<T>.Select;
begin
  FResponse.Content := FReader.Select(FRequest.JSonContent);
end;
```

Register once per entity type:

```pascal
FServer.RegisterController<TAPIReadWriteController<TCompany>>('/company');
FServer.RegisterController<TAPIReadWriteController<TEmployee>>('/employee');
FServer.RegisterController<TAPIReadOnlyController<TCountry>>('/country');
```

A read-only controller does not create the writer, so it cannot write: that is visible from its dependencies, not only from the routes it declares. The [REST API example](../examples/rest-api.md) has the complete controllers.
