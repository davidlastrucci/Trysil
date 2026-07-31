# Changelog

Notable changes to Trysil, in reverse chronological order.

## JWT - Signing Algorithms & Key Rotation

- **Payload split into algorithm units**: `TTHttpJWTAbstractPayload` (`Trysil.Http.JWT.Payload.pas`) now declares only the signing contract (`Algorithm`, `Sign`, `Verify`, `ToJSon`, `FromJSon`); the actual cryptography lives in `TTHttpJWTHS256Payload` (`Trysil.Http.JWT.Payload.HS256.pas`) and `TTHttpJWTRS256Payload` (`Trysil.Http.JWT.Payload.RS256.pas`)
- **BREAKING CHANGE**: application payloads must now inherit from `TTHttpJWTHS256Payload` (previous behavior: HMAC-SHA256 with the secret returned by `GetSecret`) or from `TTHttpJWTRS256Payload`, no longer from `TTHttpJWTAbstractPayload`
- **RS256 (RSA-SHA256)**: asymmetric signing built on OpenSSL `libcrypto`, so the issuer holds the private key and every resource server only needs the public one
- **Key objects, parsed once** (`Trysil.Http.JWT.RSAKey.pas`): `TTHttpJWTRSAPrivateKey` (`Sign` + `Verify`) and `TTHttpJWTRSAPublicKey` (`Verify` only) parse their PEM in the constructor and own the OpenSSL `EVP_PKEY` for their whole lifetime. The application creates them once at startup and the payload borrows them through `GetSigningKey` / `GetVerificationKey`, so **no request ever parses a PEM**. A verify-only server is expressed by the type: give it a public key and `Sign` does not exist
- **Verification key resolved per token**: `GetVerificationKey(AKeyID)` is called at verify time with the `kid` of the incoming token, so it can pick the matching key or the current tenant's. An unresolved key fails closed (`Verify` returns `False`, no exception), while signing without a private key raises `ETHttpJWTException`
- **`SigningKeyID` derives from the key**: the RS256 payload emits the `kid` of the key it signs with, so a key ID is declared in one place
- **`libcrypto` resolved dynamically at first use**: the key unit compiles on every platform and only fails (with `ETHttpJWTException`) when a key is actually loaded without OpenSSL present. Candidate library names cover Windows (`libcrypto-4/3/1_1[-x64].dll`), Linux, macOS (including the Homebrew paths) and Android; resolution is guarded by a critical section and the library is intentionally left loaded. HS256 has no external dependency
- **Keys are warmed up on construction**: loading a key runs one signature operation while still single-threaded, so OpenSSL's lazily populated internals are in place before several threads share the key. One key instance can then sign and verify concurrently
- **Tests**: first RS256 test fixture (`Trysil.Tests.Http.JWT.RS256.pas`): round-trip, wrong public key, missing signing key, unresolved verification key, `kid` in the header, and eight threads sharing one key pair
- **`kid` header for key rotation**: `TTHttpJWTAbstractPayload.SigningKeyID` (override `GetSigningKeyID` to emit a `kid` when a token is generated). On the way in, the `kid` is an **argument, not payload state**: `LoadFromToken` extracts it from the header and passes it to `Verify`, which hands it to `GetSecretFor` (HS256) or `GetVerificationKey` (RS256). `GetSecretFor` defaults to `GetSecret`, so applications that do not rotate keys are unaffected
- **Header is parsed, not compared byte-for-byte**: `LoadFromToken` reads the header JSON and matches `alg` case-insensitively against the payload's own algorithm; a token signed with a different algorithm is rejected, and additional header members such as `kid` no longer invalidate the token
- **`TTHttpJWTEncoding` works on bytes**: `Encode(TBytes): String` / `Decode(String): TBytes` produce and consume base64url without padding directly, replacing the previous double base64 string round-trip. The `TTHttpJWTHeader` class is gone: the header is built by `TTHttpJWT<P>`
- **Constant-time HS256 signature comparison**: `TTHttpJWTHS256Payload` compares signatures without early exit, removing the timing side channel of a plain string equality test

## HTTP - Client IP Behind a Proxy

- **`TTHttpRequest.ClientIP`**: returns `RemoteIP` for direct connections. When the connection comes from loopback (`127.*`, `::1`, `0:0:0:0:0:0:0:1`, including `::ffff:`-mapped forms), it takes the **last** `X-Forwarded-For` entry, which is the one written by the trusted local reverse proxy, strips any port, and unwraps bracketed IPv6 literals. Client-supplied entries earlier in the chain are ignored, so the header cannot be spoofed from outside
- **`TTHttpLogRequest.ClientIP`**: exposed next to `RemoteIP` and emitted in the request log JSON, so logs behind a proxy show the real caller

## Fixes

- **`TTContext.ApplyAll<T>` inside an open transaction**: it no longer opens a second transaction when the write connection already has one. It joins the caller's transaction, and rollback/commit stay with whoever started it
- **`TTLazy<T>` double free**: assigning an entity to a lazy relation with the identity map disabled now stores a **clone** of that entity. Previously the caller and the lazy field owned the same instance and both freed it
- **A failing log writer no longer breaks the server**: `TTHttpServer<C>.Log` swallows exceptions raised by a log writer, so logging cannot abort the operation being logged
- **`Host` in `TTHttpLogResponse`**: the response log record is now built from the request and carries `Host` alongside the user
- **Sqids round-trip on a lazy relation foreign key**: JSON deserialization decodes the raw string value of the FK instead of its quoted JSON representation
- **MariaDB driver ID**: the FireDAC driver link registered by `TTMariaDBDriver` is now named `MariaDB` instead of `Trysil_MariaDB` (the other drivers keep the `Trysil_<engine>` form derived from their base driver ID). Only relevant to code that referenced the driver ID directly
- **Trysil Expert - API REST generation**: after generating the project the Expert opens `<ProjectName>.dproj` instead of a non-existent `<ProjectName>Group.groupproj`

## HTTP Filter - Include Deleted

- **`includeDeleted` in the select payload**: `TTHttpFilter<T>` now reads the `includeDeleted` boolean from the select request JSON and propagates it to `TTFilter.IncludeDeleted`, so the REST `select` and `exporttoexcel` endpoints can return soft-deleted rows on demand (defaults to `False`, so existing clients are unaffected)

## Algebraic Filter Expressions

- **Expression filter API** (`Trysil.Filter.Expression.pas`): `TTProperty` and `TTExpression` records add operator-overloaded WHERE building to `TTFilterBuilder<T>`. Combine comparisons with `and` / `or` / `not` to produce correctly **parenthesized** groups — e.g. `((City = 'Roma') or (City = 'Milano')) and (Age >= 18)` — which the flat fluent chain cannot express
- **`TTProperty` operators & methods**: `=`, `<>`, `>`, `>=`, `<`, `<=`, plus `Like`, `NotLike`, `IsNull`, `IsNotNull`, `Between`, `InValues`
- **Builder overloads**: `Where` / `AndWhere` / `OrWhere` accept a `TTExpression`; `OrderByAsc` / `OrderByDesc` accept a `TTProperty`. Both forms share one parameter counter, so they mix freely in a single builder
- **Join entity filtering**: the two-argument `TTProperty.Create(Alias, Column)` qualifies the WHERE reference as `Alias.Column` and validates against the joined column's output alias `Alias_Column` — the first filter form that resolves join aliases
- **Trysil Expert — companion record generation**: the "Generate entity model" dialog can emit a `T<Entity>Properties` companion record next to each entity (one `TTProperty` per column, primary key included, version column excluded), so column names are checked by the compiler at the call site. Controlled by a checkbox (on by default)
- **Trysil Expert — Smallint type**: smallint columns now generate a `Smallint` field instead of `Integer`

## Trysil Expert — AI Assistant Skills

- **"Install AI assistant skills" command** (`TTInstallSkillsForm`): new Trysil Expert menu entry that writes LLM instruction files — the `trysil-orm`, `trysil-json`, and `trysil-http` skills — into the active project, teaching AI coding assistants the Trysil API
- **Multi-assistant support**: select one or more of Claude Code, Cursor, GitHub Copilot, Windsurf, or a generic (`llms.txt`) layout — each is written to that tool's own convention inside the project folder
- **`TTSkillsInstaller`**: downloads the skills archive from the [`trysil-ai-skills`](https://github.com/davidlastrucci/trysil-ai-skills) repository and copies the selected tool folders into the project, prompting for confirmation before overwriting existing files

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
