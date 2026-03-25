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

The authentication handler determines which areas the current user has access to. See [Authentication](authentication.md) for details.

## No-Auth Endpoints

To create endpoints that do not require authentication, use `[TAuthorizationType]` on the controller class:

```pascal
[TUri('/logon')]
[TAuthorizationType(TTHttpAuthorizationType.None)]
TLogonController = class(TTHttpController<TAPIContext>)
public
  [TPost]
  procedure Logon;
end;
```

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
  LPersons := TTList<TPerson>.Create;
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
    LPerson.Free;
  end;
end;
```

## Generic CRUD Controllers

A powerful pattern is building reusable generic controllers that handle standard CRUD operations for any entity type:

```pascal
type
  TAPIController = class(TTHttpController<TAPIContext>)
  end;

  TAPIReadOnlyController<T: class> = class(TAPIController)
  public
    [TGet('/?')]
    [TArea('read')]
    procedure Get(const AID: TTPrimaryKey);

    [TGet]
    [TArea('read')]
    procedure SelectAll;

    [TPost('/select')]
    [TArea('read')]
    procedure Select;

    [TGet('/metadata')]
    [TArea('read')]
    procedure Metadata;
  end;

  TAPIReadWriteController<T: class> = class(TAPIReadOnlyController<T>)
  public
    [TPost]
    [TArea('write')]
    procedure Insert;

    [TPut]
    [TArea('write')]
    procedure Update;

    [TDelete('/?/?')]
    [TArea('write')]
    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);
  end;
```

Register once per entity type:

```pascal
FServer.RegisterController<TAPIReadWriteController<TCompany>>('/company');
FServer.RegisterController<TAPIReadWriteController<TEmployee>>('/employee');
FServer.RegisterController<TAPIReadOnlyController<TCountry>>('/country');
```

This gives you a full REST API for each entity with minimal code. The generic controller methods use the type parameter `T` with `TTJSonContext` methods to serialize and deserialize the correct entity type.
