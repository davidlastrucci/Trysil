# Changelog

Notable changes to Trysil, in reverse chronological order.

## Database Drivers — InterBase, MariaDB, Oracle

- **InterBase driver** (`Trysil.Data.FireDAC.InterBase`): generator-based sequences (`GEN_ID`), `FIRST/SKIP` pagination — built on `TFDPhysIBDriverLink`
- **MariaDB driver** (`Trysil.Data.FireDAC.MariaDB`): native sequences (`NEXTVAL`) on MariaDB 10.3+, `LIMIT/OFFSET` pagination — built on the FireDAC MySQL driver (`TFDPhysMySQLDriverLink`). MariaDB was chosen over MySQL because Trysil assigns primary keys from a sequence *before* `INSERT`, which MySQL cannot provide
- **Oracle driver** (`Trysil.Data.FireDAC.Oracle`): sequences (`seq.NEXTVAL FROM DUAL`), `OFFSET/FETCH` pagination, EZConnect descriptor `//host:port/service` — built on `TFDPhysOracleDriverLink`
- **Packaging**: `.dpk` / `.dproj` for all five Delphi versions (260–370), wired into each `Trysil.groupproj` and the shared `MainBuild.bat`
- **Tests**: full per-database fixture suites (disabled by default in `Trysil.Tests.json`)

## Undelete & Lazy Loading

- **`Undelete<T>` / `UndeleteAll<T>`** (`TTContext`): reverse a soft delete — clears the `[TDeletedAt]` / `[TDeletedBy]` columns and issues an `UPDATE`. Raises `ETException` (`SUndeleteNotSupported`) when the entity has no `[TDeletedAt]` column
- **`IncludeDeleted` overloads on `Get<T>` / `TryGet<T>`**: `Get<T>(AID, AIncludeDeleted)` and `TryGet<T>(AID, out AEntity, AIncludeDeleted)` load an entity by primary key even when it is soft-deleted (existing single-argument overloads default to `False`)
- **`TTLazy<T>` resolves soft-deleted entities**: lazy single-entity references now load through `Get<T>(ID, True)`, so a soft-deleted parent still resolves through its foreign key
- **`ITLazyList<T>` interface** (`Trysil.Generics.Collections`): exposes `Invalidate` and `GetList`; `TTLazyList<T>` implements it and `Invalidate` clears the cached list so it reloads on next access
- **`TTSession<T>` from a lazy list**: new `CreateSession<T>(ITLazyList<T>)` overload — after `ApplyChanges` the lazy list is invalidated, keeping the in-memory collection in sync with the persisted state
- **`TNoRefCountObject`** (`Trysil.Classes`): no-reference-count base adopted by `TTAbstractLazy<T>` so it can implement an interface without lifetime side effects on Delphi 10.3/10.4 (`CompilerVersion < 35`)

## JOIN Queries & Raw Select

- **`[TJoin]` attribute**: declarative JOIN support with three overloads — simple (`TJoin(Kind, Table, SourceCol, TargetCol)`), with alias for self-joins (`TJoin(Kind, Table, Alias, SourceCol, TargetCol)`), and chained (`TJoin(Kind, Table, Alias, SourceTableOrAlias, SourceCol, TargetCol)`)
- **`[TColumn]` 2-parameter overload**: `TColumn('Alias', 'ColumnName')` maps a field to a joined table column
- **`TJoinKind`**: scoped enum — `Inner`, `Left`, `Right`
- **Read-only enforcement**: join entities raise `ETException` on `Insert`, `Update`, or `Delete`
- **Identity map skip**: join entities bypass the identity map (same PK can appear in multiple rows)
- **Soft delete support**: `DeletedAt IS NULL` is qualified with the FROM table name when JOINs are present
- **Full backward compatibility**: all changes are behind `HasJoins` checks — existing entities are unaffected
- **`TTContext.RawSelect<T>`**: execute arbitrary SQL and map results to DTO classes via `[TColumn]` attributes — no `[TTable]`, `[TPrimaryKey]`, or `[TSequence]` required
- **`TTRawReader`**: lightweight reader that wraps a `TDataSet` for raw SQL result mapping

## Change Tracking & Soft Delete

- **Change tracking attributes**: `[TCreatedAt]`, `[TCreatedBy]`, `[TUpdatedAt]`, `[TUpdatedBy]`, `[TDeletedAt]`, `[TDeletedBy]` — automatic timestamps and user tracking on insert, update, and delete
- **Soft delete**: entities with `[TDeletedAt]` use UPDATE instead of DELETE; all SELECT queries automatically exclude soft-deleted records (`DeletedAt IS NULL`)
- **`IncludeDeleted`**: option on `TTFilter` and `TTFilterBuilder<T>` to include soft-deleted records in queries
- **`OnGetCurrentUser`**: callback property on `TTContext` to provide the current user name for `*By` fields
- **`TTChangeTrackingMap`**: mapping infrastructure for change tracking columns
- **`TTSoftDeleteSyntax`**: SQL syntax class for soft delete UPDATE statements

## Recent

- **docs**: MkDocs Material documentation site, cookbook, demo READMEs
- **SmartLauncher**: added to Built With Trysil
- **Sync & Cache**: internal improvements

## FilterBuilder & ApplyAll

- `TTFilterBuilder<T>`: fluent query builder with `Where`, `AndWhere`, `OrWhere`, operators (`Equal`, `NotEqual`, `Greater`, `Like`, `IsNull`, `IsNotNull`, `NotLike`), `OrderByAsc`, `OrderByDesc`, `Limit`, `Offset`
- `ApplyAll<T>`: batch insert + update + delete in a single transaction
- Refactoring for toxicity-free naming

## Save & SaveAll

- `TTContext.Save<T>`: automatically determines insert or update
- `TTContext.SaveAll<T>`: same for lists
- Transaction support for Save operations

## Delphi 13 Florence

- Full support for Delphi 13 Florence (version 370)
- Updated all packages and build scripts

## Languages

- `TTLanguage` localization system for framework error messages
- Italian (`Trysil.Languages.IT`) and French (`Trysil.Languages.FR`) translations

## HTTP Multi-Tenant

- `TTMultiTenant<T>` for per-request tenant context
- Default HTTP controller support
- `Dataset.ToJSon()` for arbitrary dataset serialization
- `TTContext.CreateDataset` for raw SQL queries

## Read/Write Connection Splitting

- Dual connection support: read connection (`TTProvider`) and write connection (`TTResolver`)
- `SelectCount` with `TTWhereClause`

## Blob Support

- `TBytes` field mapping for binary data (images, documents)
- Blob demo application

## JSON Enhancements

- `[TJSonIgnore]` attribute to exclude fields from serialization
- Enum type support
- `TTJSonSqids` for encoded IDs

## Event Methods

- `[TBeforeInsert]`, `[TAfterInsert]`, `[TBeforeUpdate]`, `[TAfterUpdate]`, `[TBeforeDelete]`, `[TAfterDelete]` attributes for entity lifecycle hooks
- Custom validator methods via `[TValidator]`

## Logging

- `TTLoggerItemID` with ConnectionID and ThreadID for multi-threaded correlation

## HTTP Module

- Attribute-based routing (`[TGet]`, `[TPost]`, `[TPut]`, `[TDelete]`)
- JWT Bearer authentication
- CORS support
- Area-based authorization
- Structured HTTP request/response logging

## Packages

- Split `Trysil` package into `Trysil` + per-database driver packages
- Support for Delphi 10.3, 10.4, 11, 12, 13

## Core

- `TTContext`: SelectAll, Select, Get, TryGet, Refresh, OldEntity, Insert, Update, Delete, CreateEntity, CloneEntity, CreateTransaction, CreateSession, CreateFilterBuilder, Validate, GetMetadata
- `TTSession<T>`: Unit of Work with full entity cloning
- `TTIdentityMap`: per-context entity cache
- `TTNullable<T>`: generic nullable wrapper
- `TTLazy<T>` / `TTLazyList<T>`: deferred loading
- Validation attributes: `[TRequired]`, `[TMaxLength]`, `[TMinLength]`, `[TMaxValue]`, `[TMinValue]`, `[TRange]`, `[TRegex]`, `[TEmail]`
- 4 database drivers: SQLite, PostgreSQL, SQL Server, Firebird (all via FireDAC)
- Connection pooling via FireDAC
- `TTMapper.Instance` singleton for cached entity-to-table mapping
