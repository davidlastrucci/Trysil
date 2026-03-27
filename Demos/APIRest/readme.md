# API REST Demo

A complete REST API server demonstrating Trysil's HTTP module with JWT authentication, CRUD controllers, CORS, and structured logging.

## Features

- Attribute-based REST routing (`[TGet]`, `[TPost]`, `[TPut]`, `[TDelete]`)
- JWT Bearer authentication with area-based authorization
- Generic CRUD controllers (read-only and read-write)
- Per-request context with connection pooling
- CORS support
- Full request/response logging to database
- System tray application with Start/Stop controls
- SQL scripts for SQL Server, Firebird, and SQLite

## Prerequisites

- Delphi Enterprise edition (for SQL Server) or Community edition (for SQLite/Firebird)
- Trysil packages built, including `Trysil.Http` and `Trysil.JSon` (see [Setup](../../Docs/Setup.md))

## Setup

1. Run the appropriate SQL script from the `SQL/` folder on your database:
   - `Employess.SqlServer.sql` -- SQL Server
   - `Employess.FirebirdSQL.sql` -- Firebird
   - `Employess.SQLite.sql` -- SQLite
   - `Log.SqlServer.sql` -- logging tables (SQL Server only)

2. Create an `API.json` file in the executable output directory:

   ```json
   {
     "server": {
       "baseUri": "http://localhost",
       "port": 4450
     },
     "cors": {
       "allowHeaders": "*",
       "allowOrigin": "*"
     },
     "database": {
       "connectionName": "Main",
       "server": "YourServer",
       "username": "",
       "password": "",
       "databaseName": "YourDatabase"
     }
   }
   ```

3. Open `API.dproj` in Delphi, build and run.

## Endpoints

### Authentication

```
POST /logon
Content-Type: application/json

{"username": "Guest", "password": "Test"}
```

Response: `{"token": "eyJ..."}` (expires in 30 minutes)

Use the token in subsequent requests:

```
Authorization: Bearer eyJ...
```

### Company Controller

```
FServer.RegisterController<TAPIReadWriteController<TAPICompany>>('/company');
```

| HTTP Method | URI | Trysil | Database | LazyEntity | LazyList |
|---|---|---|---|---|---|
| GET | /company/{id} | Get\<TAPICompany\> | SELECT | Yes | Yes |
| GET | /company | SelectAll\<TAPICompany\> | SELECT | Yes | No |
| POST | /company | Insert\<TAPICompany\> | INSERT | | |
| PUT | /company | Update\<TAPICompany\> | UPDATE | | |
| DELETE | /company/{id}/{versionId} | Delete\<TAPICompany\> | DELETE | | |
| POST | /company/select | Select\<TAPICompany\> | SELECT | Yes | No |
| GET | /company/find/{id} | Get\<TAPICompany\> | SELECT | No | No |
| GET | /company/createnew | CreateEntity\<TAPICompany\> | | | |
| GET | /company/metadata | MetadataToJSon\<TAPICompany\> | | | |

### Employee Controller

Same endpoints as Company, registered at `/employee` with `TAPIEmployee`.

## Project Structure

| Path | Description |
|---|---|
| `API.dpr` | Main project file |
| `API.MainForm.pas` | System tray form with server controls |
| `API/API.Config.pas` | JSON configuration loader |
| `API/API.Context.pas` | Per-request context (connection + auth) |
| `API/API.Http.pas` | HTTP server setup and controller registration |
| `API/Model/` | Entity definitions (Company, Employee) |
| `API/Authentication/` | JWT payload, handler, and login controller |
| `API/Controllers/` | Generic CRUD controllers |
| `API/Log/` | Request/response logging |
| `SQL/` | Database scripts for all supported engines |
