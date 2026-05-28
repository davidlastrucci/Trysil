---
title: REST API
---

# REST API

A complete walkthrough of the **APIRest** demo application. This is a VCL system tray application that hosts a REST API server with JWT authentication, generic CRUD controllers, and structured HTTP logging.

## Project Structure

```
Demos/APIRest/
  API.dpr                              - Main project
  API.json                             - JSON configuration file
  API.MainForm.pas                     - System tray form
  API/
    API.Config.pas                     - JSON configuration loader
    API.Context.pas                    - Per-request context
    API.Http.pas                       - Server setup
    Model/
      API.Model.Company.pas            - Company entity
      API.Model.Employee.pas           - Employee entity (lazy Company)
    Controllers/
      API.Controller.pas               - Generic CRUD controllers
    Authentication/
      API.Authentication.pas           - Bearer auth handler
      API.Authentication.Controller.pas - Login endpoint
      API.Authentication.JWT.pas       - JWT payload definition
    Log/
      API.Log.Writer.pas               - HTTP log writer
      API.Log.Model.pas                - Log entities
  SQL/
    Employess.SqlServer.sql            - SQL Server schema script
    Employess.SQLite.sql               - SQLite schema script
    Employess.FirebirdSQL.sql          - Firebird schema script
    Log.SqlServer.sql                  - Log tables schema script
```

## Entity Models

### Company

A simple entity with a relation constraint that prevents deleting a company that still has employees.

```pascal
[TTable('Companies')]
[TSequence('CompaniesID')]
[TRelation('Employees', 'CompanyID', False)]
TAPICompany = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TRequired]
  [TMaxLength(100)]
  [TColumn('Name')]
  FName: String;

  [TMaxLength(100)]
  [TColumn('Address')]
  FAddress: String;

  [TMaxLength(100)]
  [TColumn('City')]
  FCity: String;

  [TMaxLength(100)]
  [TColumn('Country')]
  FCountry: String;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;
public
  property ID: TTPrimaryKey read FID;
  property Name: String read FName write FName;
  property Address: String read FAddress write FAddress;
  property City: String read FCity write FCity;
  property Country: String read FCountry write FCountry;
  property VersionID: TTVersion read FVersionID;
end;
```

`[TRelation('Employees', 'CompanyID', False)]` tells Trysil: "the `Employees` table references this entity via its `CompanyID` column, and cascade delete is **not** allowed." If you attempt to delete a company that has employees, Trysil raises an exception before executing the SQL.

### Employee

The Employee entity uses `TTLazy<TAPICompany>` for its Company field -- the related Company entity is loaded from the database only when the `Company` property is first accessed.

```pascal
[TTable('Employees')]
[TSequence('EmployeesID')]
TAPIEmployee = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TRequired]
  [TMaxLength(100)]
  [TColumn('Firstname')]
  FFirstname: String;

  [TRequired]
  [TMaxLength(100)]
  [TColumn('Lastname')]
  FLastname: String;

  [TMaxLength(255)]
  [TEmail]
  [TColumn('Email')]
  FEmail: String;

  [TRequired]
  [TDisplayName('Company')]
  [TColumn('CompanyID')]
  FCompany: TTLazy<TAPICompany>;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;

  function GetCompany: TAPICompany;
  procedure SetCompany(const AValue: TAPICompany);
public
  property ID: TTPrimaryKey read FID;
  property Firstname: String read FFirstname write FFirstname;
  property Lastname: String read FLastname write FLastname;
  property Email: String read FEmail write FEmail;
  property Company: TAPICompany read GetCompany write SetCompany;
  property VersionID: TTVersion read FVersionID;
end;
```

The getter and setter delegate to `FCompany.Entity`:

```pascal
function TAPIEmployee.GetCompany: TAPICompany;
begin
  result := FCompany.Entity;
end;

procedure TAPIEmployee.SetCompany(const AValue: TAPICompany);
begin
  FCompany.Entity := AValue;
end;
```

The `[TDisplayName('Company')]` attribute provides a human-readable name for the field, used by metadata endpoints and validation error messages.

## Configuration

The application reads its configuration from a JSON file alongside the executable (`API.json`):

```json
{
  "server": {
    "baseUri": "",
    "port": 4450
  },
  "cors": {
    "allowHeaders": "Content-Type, Authorization",
    "allowOrigin": "*"
  },
  "database": {
    "connectionName": "",
    "server": "",
    "username": "",
    "password": "",
    "databaseName": ""
  }
}
```

`TAPIConfig` is a lazy singleton that loads this file on first access:

```pascal
TAPIConfig = class
public
  property Server: TAPIServerConfig read FServer;
  property Cors: TAPICorsConfig read FCors;
  property Database: TAPIDatabaseConfig read FDatabase;

  class property Instance: TAPIConfig read GetInstance;
end;
```

## Per-Request Context

Each HTTP request gets its own `TAPIContext`, which creates a database connection (from the pool), a `TTHttpContext` for ORM + JSON operations, and a JWT payload container.

```pascal
TAPIContext = class
strict private
  FConnection: TTConnection;
  FContext: TTHttpContext;
  FPayload: TAPIJWTPayload;
public
  constructor Create;
  destructor Destroy; override;
  property Context: TTHttpContext read FContext;
  property Payload: TAPIJWTPayload read FPayload;
end;

constructor TAPIContext.Create;
begin
  inherited Create;
  TTFireDACConnectionPool.Instance.Config.Enabled := True;
  FConnection := TTSqlServerConnection.Create(
    TAPIConfig.Instance.Database.ConnectionName);
  FContext := TTHttpContext.Create(FConnection);
  FPayload := TAPIJWTPayload.Create;
end;
```

!!! note
    `TTHttpContext` extends `TTJSonContext` (which extends `TTContext`), so it provides the full ORM API plus JSON serialization/deserialization in a single object.

## Generic CRUD Controllers

The demo defines reusable generic controllers that work with any entity type. This eliminates boilerplate -- you register the same controller class for each entity, and the generic type parameter determines which table it operates on.

### Base Controller

All controllers extend a common base that extracts `TTHttpContext` from the per-request `TAPIContext`:

```pascal
TAPIController = class(TTHttpController<TAPIContext>)
strict protected
  property Context: TTHttpContext read GetContext;
end;
```

### Read-Only Controller

Provides GET (by ID), GET (all), POST (filtered select), and GET (metadata) endpoints:

```pascal
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

  [TGet('/find/?')]
  [TArea('read')]
  procedure Find(const AID: TTPrimaryKey);

  [TGet('/metadata')]
  [TArea('read')]
  procedure Metadata;
end;
```

- `[TGet('/?')]` -- the `?` is a route parameter placeholder that maps to the method's `AID` parameter.
- `[TArea('read')]` -- the user's JWT must include the `read` area to access these endpoints.

The `SelectAll` implementation shows how simple it is:

```pascal
procedure TAPIReadOnlyController<T>.SelectAll;
begin
  InternalSelect(TTFilter.Empty());
end;
```

The `Select` endpoint accepts a filter payload in the request body, parsed by `TTHttpFilter<T>`:

```pascal
procedure TAPIReadOnlyController<T>.Select;
var
  LHttpFilter: TTHttpFilter<T>;
begin
  LHttpFilter := TTHttpFilter<T>.Create(Context, FRequest.JSonContent);
  InternalSelect(LHttpFilter.Filter);
end;
```

### Read-Write Controller

Extends the read-only controller with Insert, Update, Delete, and CreateNew:

```pascal
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

  [TGet('/createnew')]
  [TArea('write')]
  procedure CreateNew;
end;
```

The `Delete` endpoint takes both the ID and the version ID as route parameters (`/?/?`). The version ID is required for optimistic locking -- if the version does not match the current database value, the delete fails.

The `Insert` implementation deserializes the entity from the request JSON, assigns a sequence ID if needed, and persists it:

```pascal
procedure TAPIReadWriteController<T>.Insert;
var
  LEntity: T;
begin
  LEntity := Context.EntityFromJSonObject<T>(FRequest.JSonContent);
  try
    if Context.GetID<T>(LEntity) <= 0 then
      Context.SetSequenceID<T>(LEntity);
    Context.Insert<T>(LEntity);
    FResponse.Content := Context.EntityToJSon<T>(LEntity, ConfigGet);
  finally
    LEntity.Free;
  end;
end;
```

## Server Setup

`TAPIHttp` wires everything together: connection registration, CORS, authentication, logging, and controller registration.

```pascal
constructor TAPIHttp.Create;
begin
  inherited Create;
  FServer := TTHttpServer<TAPIContext>.Create;
end;

procedure TAPIHttp.AfterConstruction;
begin
  inherited AfterConstruction;
  FServer.BaseUri := TAPIConfig.Instance.Server.BaseUri;
  FServer.Port := TAPIConfig.Instance.Server.Port;

  FServer.CorsConfig.AllowHeaders := TAPIConfig.Instance.Cors.AllowHeaders;
  FServer.CorsConfig.AllowOrigin := TAPIConfig.Instance.Cors.AllowOrigin;

  TTSqlServerConnection.RegisterConnection(
    TAPIConfig.Instance.Database.ConnectionName,
    TAPIConfig.Instance.Database.Server,
    TAPIConfig.Instance.Database.Username,
    TAPIConfig.Instance.Database.Password,
    TAPIConfig.Instance.Database.DatabaseName);

  FServer.RegisterLogWriter<TAPILogWriter>();
  FServer.RegisterAuthentication<TAPIAuthentication>();

  // Register controllers for each entity type
  FServer.RegisterController<TAPILogonController>();
  FServer.RegisterController<TAPIReadWriteController<TAPICompany>>('/company');
  FServer.RegisterController<TAPIReadWriteController<TAPIEmployee>>('/employee');
end;
```

Adding a new entity to the API requires just one line: register a new `TAPIReadWriteController<TYourEntity>` with its base path.

## JWT Authentication

### Login Endpoint

The logon controller is marked with `[TAuthorizationType(TTHttpAuthorizationType.None)]` so it can be accessed without a token:

```pascal
[TUri('/logon')]
[TAuthorizationType(TTHttpAuthorizationType.None)]
TAPILogonController = class(TAPIController)
public
  [TPost]
  procedure Logon;
end;

procedure TAPILogonController.Logon;
begin
  FUsername := FRequest.JSonContent.GetValue<String>('username', '');
  FPassword := FRequest.JSonContent.GetValue<String>('password', '');
  CheckCredentials;
  ResponseToken;
end;
```

`CheckCredentials` validates the username/password and populates the user's areas (permissions). `ResponseToken` generates a JWT containing the username, areas, and a 30-minute expiry, then returns it as JSON:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Bearer Authentication Handler

Protected endpoints require a `Bearer` token in the `Authorization` header. `TAPIAuthentication` extends `TTHttpAuthenticationBearer` and validates the JWT payload:

```pascal
TAPIAuthentication = class(TTHttpAuthenticationBearer<
  TAPIContext, TAPIJWTPayload>)
strict protected
  function CreatePayload: TAPIJWTPayload; override;
  function IsValid(const APayload: TAPIJWTPayload): Boolean; override;
end;

function TAPIAuthentication.IsValid(const APayload: TAPIJWTPayload): Boolean;
begin
  result := APayload.IsValid;
  if result then
  begin
    Context.Payload.Assign(APayload);
    FRequest.User.Username := APayload.Username;
    for LArea in APayload.Areas do
      FRequest.User.Areas.Add(LArea);
  end;
end;
```

The `[TArea('read')]` and `[TArea('write')]` attributes on controller methods are checked against the areas in the JWT payload. A user with only the `read` area cannot call `Insert`, `Update`, or `Delete`.

## Structured HTTP Logging

The demo logs every HTTP request, response, and action to database tables via `TAPILogWriter`:

```pascal
TAPILogWriter = class(TTHttpLogAbstractWriter)
public
  procedure WriteAction(const AAction: TTHttpLogAction); override;
  procedure WriteRequest(const ARequest: TTHttpLogRequest); override;
  procedure WriteResponse(const AResponse: TTHttpLogResponse); override;
end;

procedure TAPILogWriter.WriteRequest(const ARequest: TTHttpLogRequest);
var
  LLogRequest: TLogRequest;
begin
  LLogRequest := FContext.Context.CreateEntity<TLogRequest>();
  try
    LLogRequest.SetValues(ARequest);
    FContext.Context.Insert<TLogRequest>(LLogRequest);
  finally
    LLogRequest.Free;
  end;
end;
```

The log entities (`TLogAction`, `TLogRequest`, `TLogResponse`) are standard Trysil entities mapped to tables in the `log` schema. The SQL scripts in `SQL/Log.SqlServer.sql` create these tables.

## System Tray Application

The main form runs as a system tray application. It creates the HTTP server on startup and provides Start/Stop/Terminate actions via the tray icon's popup menu:

```pascal
constructor TAPIMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttp := TAPIHttp.Create;
end;

procedure TAPIMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FHttp.Start;
end;
```

The `.dpr` file hides the main form:

```pascal
Application.MainFormOnTaskbar := False;
Application.ShowMainForm := False;
```

## API Endpoints

Once running, the server exposes the following endpoints:

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/logon` | Authenticate and receive a JWT |
| `GET` | `/company` | List all companies |
| `GET` | `/company/{id}` | Get company by ID |
| `GET` | `/company/find/{id}` | Find company by ID (shallow) |
| `POST` | `/company/select` | Filtered query |
| `GET` | `/company/metadata` | Entity metadata |
| `POST` | `/company` | Insert company |
| `PUT` | `/company` | Update company |
| `DELETE` | `/company/{id}/{versionId}` | Delete company |
| `GET` | `/company/createnew` | Get empty entity template |

The same endpoints are available for `/employee`.

## Running the Demo

1. Create the SQL Server database using the scripts in `Demos/APIRest/SQL/`.
    - Run `Employess.SqlServer.sql` to create the `Companies` and `Employees` tables.
    - Run `Log.SqlServer.sql` to create the log tables.
2. Edit `API.json` with your connection details (server, username, password, database name).
3. Build and run the project -- the application sits in the system tray and starts the server automatically.
4. Use the included Postman collection (`Trysil APIRest.postman_collection.json`) to test the endpoints.

!!! tip
    To add a new entity to the API, define the entity class with Trysil attributes, then register a controller in `TAPIHttp.RegisterControllers`:
    ```pascal
    FServer.RegisterController<TAPIReadWriteController<TMyEntity>>('/myentity');
    ```
    That single line gives you the full set of CRUD endpoints.
