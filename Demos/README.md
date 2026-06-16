# Demos

| Demo | Type | Database | Description |
|---|---|---|---|
| [Simple](Simple/) | VCL app | SQL Server | CRUD with validation, search, ListView binding |
| [Simple.SQLite](Simple.SQLite/) | VCL app | SQLite | Same as Simple, zero config, auto-creates DB |
| [Expressions](Expressions/) | Console app | SQLite | Algebraic filter expressions vs fluent builder, with generated SQL |
| [APIRest](APIRest/) | REST server | SQL Server / Firebird / SQLite | JWT auth, generic CRUD controllers, CORS, logging |
| [Blob](Blob/) | VCL app | SQL Server | Store and retrieve images as BLOB fields |
| [Orders](Orders/) | Model only | -- | Reference entity model with lazy loading, relations, views |
| [Languages](Languages/) | Units | -- | Italian and French translations for Trysil messages |

## Where to Start

**Simple.SQLite** is the easiest demo: no external database needed, the SQLite file is created automatically. It still requires the prerequisites below.

## Prerequisites

The demos link against the **pre-built** Trysil packages via the `$(Trysil)` search path. Before opening any demo:

1. Build the Trysil packages for the platform/config you want to run (see the [Setup guide](../docs/Setup.md)).
2. Define the `$(Trysil)` environment variable pointing to `Lib\<version>` (Tools > Options > Environment Variables).
3. Make sure the demo's active **Platform/Config matches** a Trysil platform/config you actually built - a mismatch causes `unit not found` (F1026/F2613) errors.

Open `Trysil.Demos.groupproj` to build or run all demos together.
