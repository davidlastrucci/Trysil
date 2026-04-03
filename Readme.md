<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Dark.png">
    <img width="300" height="107" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Light.png" alt="Trysil - Delphi ORM" title="Trysil - Delphi ORM">
  </picture>
</p>

<p align="center">
  <strong>A lightweight, attribute-driven ORM for Delphi</strong><br>
  Map database tables to classes. Query, insert, update, delete — all through clean Object Pascal.
</p>

<p align="center">
  <a href="https://github.com/davidlastrucci/Trysil/blob/master/Licence.md"><img src="https://img.shields.io/badge/license-BSD--3--Clause-blue.svg" alt="License"></a>
  <a href="https://github.com/davidlastrucci/Trysil/stargazers"><img src="https://img.shields.io/github/stars/davidlastrucci/Trysil?style=social" alt="GitHub Stars"></a>
  <img src="https://img.shields.io/badge/Delphi-10.3%20%E2%80%94%2013-red" alt="Delphi 10.3 to 13">
  <a href="https://getitnow.embarcadero.com/trysil-delphi-orm/"><img src="https://img.shields.io/badge/GetIt-available-orange.svg" alt="GetIt"></a></p>

---

## Features

- **Attribute-based mapping** — decorate classes with `[TTable]`, `[TColumn]`, `[TPrimaryKey]` and you're done
- **4 database drivers** — SQLite, PostgreSQL, SQL Server, Firebird — all through FireDAC
- **Fluent query builder** — type-safe filtering with `TTFilterBuilder<T>`
- **Lazy loading** — `TTLazy<T>` and `TTLazyList<T>` for related entities
- **Change tracking & soft delete** — `[TCreatedAt]`, `[TUpdatedAt]`, `[TDeletedAt]` with automatic timestamps and user tracking
- **Optimistic locking** — built-in via `[TVersionColumn]`
- **Identity map** — per-context, multi-tenant safe
- **Unit of Work** — `TTSession<T>` tracks and applies changes automatically
- **JSON serialization** — full round-trip with `TTJSonContext`
- **REST HTTP module** — attribute-based routing, CORS, JWT, multi-tenant support
- **Nullable types** — `TTNullable<T>` generic wrapper
- **Connection pooling** — delegated to FireDAC
- **Structured logging** — SQL tracing with thread-safe correlation IDs

## Quick Start

### 1. Define an entity

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

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
  end;
```

### 2. Use it

```pascal
var
  LContext: TTContext;
  LPersons: TTList<TPerson>;
  LPerson: TPerson;
begin
  LContext := TTContext.Create(LConnection);
  try
    // Read all
    LPersons := TTList<TPerson>.Create;
    try
      LContext.SelectAll<TPerson>(LPersons);
      for LPerson in LPersons do
        Writeln(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
    finally
      LPersons.Free;
    end;

    // Insert
    LPerson := LContext.CreateEntity<TPerson>();
    try
      LPerson.Firstname := 'David';
      LPerson.Lastname := 'Lastrucci';
      LContext.Insert<TPerson>(LPerson);
    finally
      LPerson.Free;
    end;
  finally
    LContext.Free;
  end;
end;
```

### 3. Watch it in action

<p align="center">
  <a href="https://www.youtube.com/watch?v=4qKkhO76DKA">
    <img src="https://img.youtube.com/vi/4qKkhO76DKA/maxresdefault.jpg" alt="Trysil - Delphi ORM from scratch">
  </a><br>
  <sub>▶ Watch: <strong>Trysil — Delphi ORM from scratch</strong></sub>
</p>

### 4. Filter with the fluent builder

```pascal
var
  LFilter: TTFilter;
begin
  LFilter := LContext.CreateFilterBuilder<TPerson>()
    .Where('Lastname').Equal('Lastrucci')
    .OrderByAsc('Firstname')
    .Limit(10)
    .Build;

  LContext.Select<TPerson>(LPersons, LFilter);
end;
```

## Database Support

| Database | Driver unit | Notes |
|---|---|---|
| SQLite | `Trysil.Data.FireDAC.SQLite` | Great for development and testing |
| PostgreSQL | `Trysil.Data.FireDAC.PostgreSQL` | Full support |
| SQL Server | `Trysil.Data.FireDAC.SqlServer` | Requires Enterprise edition |
| Firebird | `Trysil.Data.FireDAC.FirebirdSQL` | Full support |

## Delphi Compatibility

| Version | Codename |
|---|---|
| Delphi 10.3 | Rio |
| Delphi 10.4 | Sydney |
| Delphi 11 | Alexandria |
| Delphi 12 | Athens |
| **Delphi 13** | **Florence** (active development) |

All packages support Community Edition, except `Trysil.SqlServer` which requires Enterprise.

## Installation

### Via GetIt (recommended)

Install directly from the Delphi IDE: **Tools > GetIt Package Manager**, search for **Trysil**.

Or visit: [getitnow.embarcadero.com/trysil-delphi-orm](https://getitnow.embarcadero.com/trysil-delphi-orm/)

### Via Boss

```
boss install davidlastrucci/Trysil
```

### Manual

1. Clone the repository
   ```
   git clone https://github.com/davidlastrucci/Trysil.git
   ```
2. Open `Packages/<ver>/Trysil.groupproj` in the Delphi IDE and **Build All**, or run from the command line:
   ```
   Packages\Build370.bat
   ```
3. Add the output path to your project's Search Path:
   ```
   $(Trysil)\$(Platform)\$(Config)
   ```
   where `$(Trysil)` points to `Lib/<ver>`.

See the full [Setup guide](https://github.com/davidlastrucci/Trysil/blob/master/Docs/Setup.md) for details.

## Documentation

| Resource | Link |
|---|---|
| Online Help | [davidlastrucci.github.io/trysil](https://davidlastrucci.github.io/trysil) |
| Getting Started | [Docs/GettingStarted.md](https://github.com/davidlastrucci/Trysil/blob/master/Docs/GettingStarted.md) |
| Simple Sample | [Docs/Sample.md](https://github.com/davidlastrucci/Trysil/blob/master/Docs/Sample.md) |
| Run Simple Demo | [Docs/RunSimpleDemo.md](https://github.com/davidlastrucci/Trysil/blob/master/Docs/RunSimpleDemo.md) |
| Manual (English) | [PDF](https://www.lastrucci.net/trysil/trysil-en.pdf) |
| Manual (Italiano) | [PDF](https://www.lastrucci.net/trysil/trysil-it.pdf) |

## Architecture Overview

```
TTContext  ─────────────────────────────  Main API
  ├── TTProvider                          SELECT / Read operations
  ├── TTResolver                          INSERT / UPDATE / DELETE
  │     ├── Validation (attributes)
  │     └── Events (Before/After hooks)
  ├── TTIdentityMap                       Per-context entity cache
  ├── TTSession<T>                        Unit of Work
  ├── TTTransaction                       Explicit transaction management
  └── TTFilterBuilder<T>                  Fluent query builder

TTConnection (abstract)
  └── TTGenericConnection
        ├── SQLite
        ├── PostgreSQL
        ├── SQL Server
        └── Firebird

Modules
  ├── Trysil          → ORM core
  ├── Trysil.JSon     → JSON serialization via TTJSonContext
  └── Trysil.Http     → REST hosting, routing, CORS, JWT, multi-tenant
```

## The Name

During World War II, **ORM** was a British operation to establish a reception base centred on **Trysil** in eastern Norway ([source](http://codenames.info/operation/orm/)). That's why this ORM is called Trysil.

## Built With Trysil

Projects and applications using Trysil in production. [See the full list](https://github.com/davidlastrucci/Trysil/blob/master/Docs/BuiltWithTrysil.md) — and add yours!

## Support the Project

If Trysil is useful to you, please consider:

- **Star** this repository — it's free and helps others discover the project
- **Share** your project in the [Show and tell](https://github.com/davidlastrucci/Trysil/issues/9) issue
- **Donate** via [![PayPal](https://img.shields.io/badge/PayPal-donate-blue.svg)](https://www.paypal.com/paypalme/DavidLastrucci)
- **Reach out** at [david.lastrucci@gmail.com](mailto:david.lastrucci@gmail.com) — feedback is always welcome

## License

BSD-3-Clause — see [Licence.md](https://github.com/davidlastrucci/Trysil/blob/master/Licence.md) for details.

---

<p align="center">
  Made with &#10084;&#65039; by <a href="https://www.lastrucci.net/">David Lastrucci</a>
</p>
