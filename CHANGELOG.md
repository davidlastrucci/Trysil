# Changelog

Notable changes to Trysil, in reverse chronological order.

## Change Tracking & Soft Delete

- **Change tracking attributes**: `[TCreatedAt]`, `[TCreatedBy]`, `[TUpdatedAt]`, `[TUpdatedBy]`, `[TDeletedAt]`, `[TDeletedBy]` — automatic timestamps and user tracking on insert, update, and delete
- **Soft delete**: entities with `[TDeletedAt]` use UPDATE instead of DELETE; all SELECT queries automatically exclude soft-deleted records (`DeletedAt IS NULL`)
- **`IncludeDeleted`**: option on `TTFilter` and `TTFilterBuilder<T>` to include soft-deleted records in queries
- **`OnGetCurrentUser`**: callback property on `TTContext` to provide the current user name for `*By` fields
- **`TTChangeTrackingMap`**: mapping infrastructure for change tracking columns
- **`TTSoftDeleteSyntax`**: SQL syntax class for soft delete UPDATE statements

## Recent

- **Docs**: MkDocs Material documentation site, cookbook, demo READMEs
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
