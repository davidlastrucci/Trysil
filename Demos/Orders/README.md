# Orders — Trysil sample application

A full master/detail desktop application built with **Trysil**, showing in a single project most of the features the ORM offers. It is the demo used on stage at Delphi Day 2026 (Piacenza, June 10th) and the closest thing to a real-world starter you can get with Trysil today.

## What this demo shows

| Area | Where to look |
|---|---|
| Entity mapping with attributes (`[TTable]`, `[TColumn]`, `[TPrimaryKey]`, `[TSequence]`, `[TVersionColumn]`, `[TRelation]`) | `Model/Orders.Model.*.pas` |
| Validation attributes (`[TRequired]`, `[TMaxLength]`, `[TMinValue]`, `[TEMail]`) | `Model/Orders.Model.Customer.pas`, `Model/Orders.Model.OrderDetail.pas` |
| `TTNullable<TDateTime>` for nullable columns | `Model/Orders.Model.OrderDetail.pas` (`Produced`/`Delivered`/`Cashed`) |
| Change tracking + soft delete (`[TCreatedAt]`/`[TCreatedBy]`/`[TUpdatedAt]`/`[TUpdatedBy]`/`[TDeletedAt]`/`[TDeletedBy]`) | `Model/Orders.Model.Customer.pas` |
| Lazy loading single + collection (`TTLazy<T>`, `TTLazyList<T>`) | `Model/Orders.Model.Order.pas` (`Customer`, `Detail`) |
| Computed property at the model level (no DB column) | `Model/Orders.Model.OrderDetail.pas` (`Amount = Quantity * Price`) |
| Read-only entities mapped on SQL views (with inheritance for shared mapping) | `Model/Orders.Model.ProductsTodo.pas` |
| `TTContext` CRUD: `CreateEntity`/`Save`/`Refresh`/`Delete`/`Select`/`SelectAll`/`FreeEntity` | views & dialogs |
| `TTFilterBuilder<T>` (fluent filter with `Where`/`Like`/`Equal`/`IncludeDeleted`) | `UI/Views/Orders.View.Customer.pas` (city filter + show-deleted) |
| `TTSession<T>` master/detail in a single transaction (`Insert`/`Update`/`Delete`/`Save`/`ApplyChanges`) | `UI/Dialogs/Orders.Dialog.Order.pas` + `Orders.Dialog.OrderDetail.pas` |
| Identity map (default) | implicit, no extra code needed |
| Optimistic locking via `[TVersionColumn]` | all entities |
| Multi-database swap (SQLite ↔ SQL Server) via a single JSON field | `_Config/Orders.Config.json` + `Classes/Orders.Config.pas` |

## Domain model

```
Brand ──< Product ──< OrderDetail >── Order >── Customer
```

- **Brand**: simple lookup (Description, VersionID).
- **Product**: belongs to a Brand, has a list price.
- **Customer**: full address, audit columns (CreatedAt/By, UpdatedAt/By), soft delete (DeletedAt/By).
- **Order**: header — date, customer (lazy), cashed flag, detail collection (lazy).
- **OrderDetail**: order line — product (lazy), quantity, price; nullable `Produced`/`Delivered`/`Cashed` dates feed three reporting views (`ProductsToBeProduced`, `ProductsToBeDelivered`, `ProductsToBeCashed`).

## Project layout

```
Demos/Orders/
├── _Config/
│   └── Orders.Config.json        # template, copy next to the exe and edit
├── __trysil/                     # Trysil Expert designer metadata (model + settings)
├── Classes/                      # cross-cutting infrastructure
│   ├── Orders.Config.pas         # JSON config reader
│   ├── Orders.FrameManager.pas   # frame registry + switching
│   └── Orders.ManagedFrame.pas   # base frame with Context property
├── Images/                       # toolbar icons + window icon
├── Model/                        # entities (one file per class)
│   ├── Orders.Model.Brand.pas
│   ├── Orders.Model.Customer.pas
│   ├── Orders.Model.Order.pas
│   ├── Orders.Model.OrderDetail.pas
│   ├── Orders.Model.Product.pas
│   └── Orders.Model.ProductsTodo.pas
├── SQL/
│   ├── SQLite/
│   │   ├── Orders.sql            # CREATE TABLE/VIEW/INDEX
│   │   └── Populate.sql          # sample data (12 customers, 15 orders, 45 details)
│   └── SQL Server/
│       ├── Orders.sql
│       └── Populate.sql
├── UI/
│   ├── Dialogs/                  # modal edit dialogs (Brand/Customer/Product/Order/OrderDetail)
│   ├── Views/                    # main frames (Brand/Customer/Product/Order)
│   └── Orders.MainForm.pas       # main window
├── Orders.dpr
├── Orders.dproj                  # Delphi 13 Florence project
└── README.md
```

## Build

Open `Orders.dproj` in Delphi 13 Florence (or newer) and build. The project Search Path expects the standard Trysil environment variable:

```
$(Trysil)\$(Platform)\$(Config)
```

pointing at the Trysil compiled output for the version you are using (see the main repository `Packages/` for build batches).

## Configure the database

The application looks for a config file named `<ExeName>.Config.json` next to the executable (so `Win64\Debug\Orders.Config.json` after a debug build).

Copy `_Config\Orders.Config.json` next to the built executable and fill in the values you need:

```json
{
  "active": "SQLite",
  "configurations": {
    "SQLite": {
      "driver": "SQLite",
      "databasename": "C:\\path\\to\\Orders.db"
    },
    "MSSQL": {
      "driver": "MSSQL",
      "server": "(local)\\YOURINSTANCE",
      "username": "",
      "password": "",
      "databasename": "Orders"
    }
  }
}
```

Switch between the two databases by editing the `active` field (`"SQLite"` or `"MSSQL"`). The status bar at the bottom of the main window shows the active driver and database version, so you have visual feedback.

> SQL Server: trusted connection is used when `username` is empty.

## Create the schema and seed the data

Run, in order, the scripts under `SQL/<engine>/`:

1. `Orders.sql` — tables, sequences (SQL Server), reporting views, indexes (`IDX_*` prefix).
2. `Populate.sql` — sample data (8 brands, 20 products, 12 customers, 15 orders, 45 details).

For SQLite you can just point `databasename` at an empty file and run the two scripts with the tool of your choice (`sqlite3` CLI, DB Browser for SQLite, …).

## Where to start reading

If you are new to Trysil, the suggested reading order through the source is:

1. `Model/Orders.Model.Brand.pas` — minimal entity, see how attributes look.
2. `Model/Orders.Model.Customer.pas` — same shape plus validation, change tracking and soft delete.
3. `Model/Orders.Model.Order.pas` — relations (`TTLazy<TCustomer>`, `TTLazyList<TOrderDetail>`).
4. `UI/Views/Orders.View.Brand.pas` — simplest CRUD list using `TTContext`.
5. `UI/Views/Orders.View.Customer.pas` — same plus a `TTFilterBuilder` city filter and a "Show deleted" checkbox.
6. `UI/Dialogs/Orders.Dialog.Order.pas` + `UI/Dialogs/Orders.Dialog.OrderDetail.pas` — master/detail edit with `TTSession`: the OK button runs `Context.Save<TOrder>(FOrder)` and `FSession.ApplyChanges` in a single `TTTransaction`, so the whole master/detail change is atomic.

## License

Same as the parent Trysil project. See the root `LICENSE` file.
