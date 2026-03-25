---
title: Home
---

# Trysil

![Trysil](assets/logo.png){ width="300" }

**A lightweight, attribute-driven ORM for Delphi.**

Trysil maps your Delphi classes to database tables using attributes, giving you a clean, type-safe API for all CRUD operations without writing raw SQL.

## Key Features

- **Attribute-based entity mapping** -- decorate classes with `[TTable]`, `[TColumn]`, `[TPrimaryKey]` and more
- **Full CRUD via `TTContext`** -- `SelectAll<T>`, `Get<T>`, `Insert<T>`, `Update<T>`, `Delete<T>`, `Save<T>`
- **Fluent query builder** -- `TTFilterBuilder<T>` for type-safe WHERE clauses, ordering, and paging
- **Optimistic locking** -- automatic version-column checks on every update
- **Lazy loading** -- `TTLazy<T>` and `TTLazyList<T>` for deferred related-entity loading
- **Unit of Work pattern** -- `TTSession<T>` tracks changes and applies them in a single transaction
- **Built-in validation attributes** -- `[TRequired]`, `[TMaxLength]`, `[TMinValue]`, `[TMaxValue]` and more
- **JSON serialization module** -- `TTJSonContext` for entity-to-JSON and JSON-to-entity conversion
- **HTTP REST server** -- attribute-based routing, authentication (Basic/Bearer/Digest/JWT), CORS, multi-tenant support
- **Multi-database support** -- SQLite, SQL Server, PostgreSQL, and Firebird
- **Connection pooling** -- built-in via FireDAC

## Why Trysil?

Stop writing brittle SQL strings and manual field mapping. Let the ORM handle it.

**Don't write this:**

```pascal
Query.SQL.Text :=
  'SELECT I.ID, I.Number, C.Name AS CustomerName, ' +
  'N.Name AS CountryName FROM Invoices AS I ' +
  'INNER JOIN Customers AS C ON C.ID = I.CustomerID ' +
  'INNER JOIN Countries AS N ON N.ID = C.CountryID ' +
  'WHERE I.ID = :InvoiceID';
Query.ParamByName('InvoiceID').AsInteger := 1;
Query.Open;
ShowMessage(Format('Invoice No: %d, Customer: %s, Country: %s', [
  Query.FieldByName('Number').AsInteger,
  Query.FieldByName('CustomerName').AsString,
  Query.FieldByName('CountryName').AsString]));
```

**Write this:**

```pascal
LInvoice := Context.Get<TInvoice>(1);
ShowMessage(Format('Invoice No: %d, Customer: %s, Country: %s', [
  LInvoice.InvoiceNo,
  LInvoice.Customer.Name,
  LInvoice.Customer.Country.Name]));
```

Trysil resolves relationships, handles lazy loading, manages transactions, and validates your data -- all through a single `TTContext` entry point.

## Quick Links

- [Getting Started](getting-started/installation.md) -- install, configure, and run your first project
- [Quick Start](getting-started/quick-start.md) -- a complete working example in five minutes
- [Database Setup](getting-started/database-setup.md) -- schema design rules for each supported database
- [Built with Trysil](community/built-with-trysil.md) -- projects and companies using Trysil in production

## The Name

The name comes from **"Trysil -- Operation ORM"**, a World War II operation codename.
See [codenames.info/operation/orm](http://codenames.info/operation/orm/) for the historical reference.

---

*Trysil is created and maintained by David Lastrucci -- [https://www.lastrucci.net/](https://www.lastrucci.net/)*
