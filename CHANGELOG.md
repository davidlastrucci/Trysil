# Changelog

Notable changes to Trysil, in reverse chronological order.

## Hardening - Error Contract, Filter Ceilings & Lifetime Fixes

**Breaking.** Two kinds, both called out inline below.

*Compilation* - `NestedException: Exception` is gone from `ETException`, replaced by three read-only string properties; the `TExceptionHelper` class helper on `Exception` is removed; and `TTHttpListener<C>.Create` takes a fourth argument. Code that inspects the exception chain, calls `E.ToJSon`, or builds a listener by hand needs the one-line change described below.

*Behaviour* - the 500 response body, the `includeDeleted` filter key, the default `limit`, and the `TaskID` format.

### Exceptions

- **`ETException` no longer takes ownership of the exception in flight.** It used to call `AcquireExceptionObject` in the base constructor, which detaches the current exception from its raise frame, and then free it in its own destructor. Any `ETException` built inside an `except` block - `ETHttpBadRequest` included, since every `ETHttp*` descends from `ETException` - stole the outer exception and freed it, leaving a later `raise;` working on a zeroed frame and a dead object. The constructor now records the **class name and message as strings**, read through `ExceptObject`, which is non-destructive
- **`NestedException: Exception` is replaced** by `HasNestedException: Boolean`, `NestedExceptionClassName: String` and `NestedExceptionMessage: String`. The chain is diagnostic text, not a live object graph
- **`ETHttpConflict` (409)** and `TTHttpStatusCodeTypes.Conflict`: a convenience subclass for a version conflict or an integrity violation, so the status code has a name. The framework never raises it: mapping `ETConcurrentUpdateException` and `ETDataIntegrityException` to HTTP stays with the application, deliberately

### HTTP error contract

- **Every 5xx goes through the same path**, including an `ETHttpException` whose status code is 500 or above. Routing it by class instead of by status would have left `raise ETHttpInternalServerError.Create(E.Message)` - a natural thing for a host to write - reporting the message to the client and reopening the hole this change closes. `TTHttpErrorResponse.ToJSon` gained an overload that keeps the caller's status code, so a 503 stays a 503
- **Breaking: the 500 body no longer carries the exception.** `TExceptionHelper`, the class helper that serialized `Self.Message` verbatim and recursed over the exception chain, is **removed**. Anything that is not an `ETHttpException` now returns `TTHttpErrorResponse.ToJSon(ATaskID)` - `{"status":500,"message":"Internal server error.","taskId":"..."}` and nothing else. That path was reachable without a token in a multi-tenant app that resolves the tenant in the controller constructor, and it leaked database engine, host, database and account names straight to the caller
- **`TTHttpLogAbstractWriter.WriteError(ALogError: TTHttpLogError)`**: the detail that no longer reaches the client now reaches the log. The record carries task id, host, uri, exception class and message, and the recorded nested class and message. Virtual and not abstract, like `WriteDiscarded`, so existing writers still compile, and the default forwards to `WriteAction`. The exception is rendered to strings **synchronously on the request thread** - the object does not survive the handler, so only the strings are queued. It is not gated by `OnCanLog`
- **Breaking: `TTHttpTaskID` is now a 32 character opaque identifier** derived from a GUID. It was a millisecond timestamp plus the thread id, which two requests served by the same thread in the same millisecond could share - and correlation by task id is only worth anything if the id is unique. `ToString` no longer appends the thread id; the `ThreadID` property stays on the record for in-process use

### Server-side filter

- **`[TNotFilterable]`** (`Trysil.Attributes`): marks a column as not reachable from the JSON filter. `where` and `orderBy` on it answer `400` with `SColumnNotFilterable`, which until now was declared and never used. The flag travels with the entity mapping, so it is resolved once per entity and costs nothing per request, and it applies to the filter built from the payload rather than to what the entity can express through `TTFilterBuilder`

```delphi
[TColumn('Password')]
[TNotFilterable]
FPassword: String;
```

- **`MetadataToJSon<T>` reports `"filterable": false`** for a column carrying `[TNotFilterable]`. The pair is emitted only when the column is excluded, so existing payloads do not change and absence keeps meaning filterable. Without it a client that builds its filter UI from the metadata would keep offering a column that answers `400`
- **`TTHttpFilterParameters`**: ceilings for the JSON filter, carrying `MaxLimit`, `MaxWhereConditions`, `MaxOrderByColumns` and `IncludeDeleted`. `TTHttpFilter<T>.Create` with two arguments applies `Defaults` - 1000 / 32 / 8 / False; the three-argument overload takes them from the host application. A negative ceiling means unlimited, and **a zero ceiling means the default**, so a record left at its zero state - `Default(TTHttpFilterParameters)`, or a field of a class, which the RTL zeroes - behaves as the defaults instead of removing the pagination clause altogether. A local variable is not that: the record has no managed fields, so nothing zeroes it on the stack, and a garbage `IncludeDeleted` reads as `True`. Assign `Default(TTHttpFilterParameters)` or a constructor, and do not rely on the declaration. This governs the filter built from the payload: an endpoint that builds its own `TTFilter` is unaffected
- **Breaking: an omitted `limit` no longer means the whole table.** `TTFilterPaging.IsEmpty` is true for `limit <= 0`, so the pagination clause was simply not emitted. `limit` is now clamped: absent, zero or negative means `MaxLimit`, above the ceiling is capped to it, and a negative `start` is normalized to `0`
- **Breaking: `includeDeleted` is no longer read from the payload.** Bypassing the soft-delete filter was a visibility switch in the client's hands. It is now `TTHttpFilterParameters.IncludeDeleted`, decided server-side
- **A non-object item inside `orderBy` is a 400**, as it already was inside `where`. It used to leave the array slot at the zero record, whose `ToString` produced `' '` - not empty, so it passed the `OrderBy.IsEmpty` guard and produced `... ORDER BY  `, a syntax error surfacing as a driver message on the 500 path
- **Column names are canonicalized**: the name that reaches the SQL text comes from the metadata, not from the client string that matched it case-insensitively
- **More `where` conditions or `orderBy` columns than the maximum is a 400**, not a slow query

### Logging

- **The discarded-entry counters are bounded.** The host is sanitized and truncated to 64 characters before it becomes a dictionary key or reaches the report, distinct hosts are capped at 64 with the remainder accumulating under `<other>`, and an absent host no longer produces an empty key. The counters are now flushed **on a timer as well as when the queue empties** - under sustained load the queue never empties, so they were never flushed and the dictionary grew with every new `Host` header

### Multi-tenant

- **`TTMultiTenant.Remove` detaches without destroying.** `FOwner` is an owning list, so `Remove` freed the tenant immediately while other threads could still hold a reference handed out by `TryGet` or `GetOrAdd`. The instance now lives until the registry is destroyed, and `GetAll` iterates the dictionary so it stops listing removed tenants
- **Registering the same connection twice is a no-op, registering a different one under the same name still raises.** `Remove` never deregistered the connection, so a `GetOrAdd` on the same name afterwards hit a duplicate key and burned the name - and with the cooldown in place that transient failure stuck to it for the whole window. `RegisterConnection` now compares against a signature of the parameters Trysil itself passed, rather than reading them back from FireDAC: an identical registration - the parameter lines sorted and matched on exact text, parameter names included - is left exactly as it is, a conflicting one raises. Reading them back would have called a shorter list identical to a longer one - which is what happens when pooling is turned off for a name, since the `POOL_*` lines simply stop being emitted - and would have compared values case-insensitively, so a changed password or a `Database` differing only in case would have passed as unchanged. Replacing the definition instead would have been worse than the disease - `DeleteConnectionDef` does not touch the physical layer, so the old `TFDPhysConnectionHost`, its pool and **its cleanup thread** would survive for the life of the process, and for a while the host's `POOL_MaximumItems` would be doubled. Not deleting anything also means the name never stops resolving, which a delete-then-add sequence cannot promise to a request thread running in between. The signature is taken from `DriverID` plus the caller's parameters and **before** the `POOL_*` lines are appended: those are derived from `TTFireDACConnectionPool.Instance.Config`, which an application can change at any point, so folding them in would have made an identical re-registration start raising the moment anyone touched the global pool configuration - the burned name again, by another route. The whole comparison happens under the pool's write lock, as does the deregistration. A conflict raises `ETException` with `SConnectionAlreadyRegistered`: it used to be an `EListError` from the connection dictionary, or FireDAC's own duplicate-definition error, so an `except` that discriminates by class needs updating
- **`UnregisterConnection` is a hard teardown**, not the inverse of a cache miss. It calls `CloseConnectionDef` before `DeleteConnectionDef`, so it closes every open connection on the definition and destroys the physical connection host and its pool instead of leaving them alive for the life of the process. That is what makes it the way to *replace* a definition, since registration refuses to overwrite one - but it also means a `TTConnection` another thread resolved an instant earlier keeps its object and loses the FireDAC connection underneath it, raising on the next statement. Quiesce the name before calling it
- **Failed tenant creation is rate limited.** A failed `GetOrAdd` records the name with a cooldown - `FailureCooldown`, 5000 ms by default, `0` disables it - and repeats inside the window fail without touching the disk. Failures are still not memoized permanently, so onboarding a tenant by dropping a folder keeps working. The table is capped at 128 names; when it is full the entry closest to expiry is evicted, rather than the new name going unrecorded, which would have removed the protection precisely under the load that creates it
- **Breaking: `GetOrAdd` now always raises `ETTenantUnavailable` when it cannot build the tenant**, carrying `TenantName` and `OriginalClassName` and keeping the original message. It used to propagate whatever the host's `TTTenantConfig` raised, and with the cooldown in place the class would have depended on how recently someone else had tried the same name - a host discriminating by type would have taken different branches for the same cause. Wrapping every failure makes it deterministic. The original exception cannot simply be re-raised: Delphi constructors are not virtual, so rebuilding one from a class reference calls `Exception.Create` and would produce, for instance, an `ETHttpNotFound` with a status code of zero.

    One consequence to plan for: `ETTenantUnavailable` descends from `ETException`, not from `ETHttpException`, so on the HTTP path an unresolvable tenant now answers **500 with the fixed body**, where before the exception the host's `TTTenantConfig` raised decided the status. If you turned an unknown host into a 404 that way, catch `ETTenantUnavailable` where you resolve the tenant and re-raise the `ETHttp*` you want

### ORM

- **`[TWhereClause]` parameters are bound again.** `TTAbstractSelectSyntax.AddWhereClause` added them to the syntax object's own copy of the `TTFilter` record while the binding ran on the caller's copy. `TTAbstractSelectSyntax` now exposes `Filter`, and `TTGenericConnection.SelectCount` and `TTGenericReader.GetDataset` read `SQL` into a local first and then bind `LSyntax.Filter`
- **`Guid` and `Currency` columns are honoured on the filter path.** `TTColumnMetadata` carries `IsGuid` and `IsCurrency`, populated by `TTGenericConnection.GetMetadata`, and `TTFilterParameter` carries them to `SetParameter`. A `Currency` column mapped onto `ftBCD` was converted and bound as `Double`. `FindColumnMap` matches on `LookupName` rather than `Name`, so this and `[TNotFilterable]` resolve on entities with `[TJoin]` too, where the metadata columns carry the join alias
- **`TTLazy.SetEntity`**: `FEntity` is cleared right after the `Free`, so a failing clone no longer leaves a dangling reference for the destructor to free twice, and `SetEntity(nil)` clears the relation instead of reaching `CloneEntity(nil)` and an access violation
- **`TTFireDACConnectionPool.Instance`**: the singleton is still created lazily, but under a lock instead of a plain test-and-assign. The test-and-assign was not atomic, and two instances would mean two open `TFDManager`s with connection definitions registered on only one of them. Creation stays lazy on purpose: `AfterConstruction` calls `FDManager.Open`, which cannot run during unit initialization
- **`TTParameter.Create` with two arguments** passed the uninitialized `FConnectionID` instead of `AConnectionID`
- **`SetContentStream`** freed `AResponseInfo.ContentStream`, which is still nil on the only reachable error path, losing the stream it had just built

### Logging: what the cap actually covered

- **`MaxContentLength` did not keep the body out of the log.** With `Content-Type: application/x-www-form-urlencoded` Indy reads the whole body into `FormParams`, glues it to the query string and decodes it into `Params`, so the parameters *are* the body while only `Content` was gated. `Params` is now omitted whenever `Content` is, and `ParamsOmitted` declares it the way `ContentOmitted` does
- **Breaking: the log caps have finite defaults.** `RegisterLogWriter<W>()` and `RegisterLogWriter<W>(AThreadPoolSize)` used to leave content, parameters and headers unlimited, so the two forms an application reaches for first were the two that capped nothing. They now apply 64 KB of content and 128 items. Pass a `TTHttpLogParameters` explicitly, with a negative value, to go back to unlimited
- **Sensitive headers are redacted, not omitted.** `Authorization`, `Proxy-Authorization`, `Cookie`, `Set-Cookie` and `X-Api-Key` reach the writer with their name intact and `<redacted>` in place of the value. With `TTHttpAuthenticationBasic` the previous behaviour put the credentials in the log in clear text after base64, on every request. `OnCanLog` was not a remedy: it is per request and all-or-nothing, so keeping the token out meant giving up the endpoint's log entirely
- **`MaxItemCount`**: a fourth `TTHttpLogParameters` field, because a cap in bytes does not bound a count - tens of thousands of short distinct parameter names fit in a body of about a megabyte. Above the cap `Params` and `Headers` are not captured, while `ParamsCount` and `HeadersCount` are always written. Negative means unlimited, and the existing constructors keep the previous behaviour
- **The demo's log writer is aligned with the contract.** `TLogRequest` gains `ParamsCount`, `ParamsOmitted`, `HeadersCount` and `HeadersOmitted`, `TLogResponse` gains `Uri`, and a `log.Errors` table with a `WriteError` override joins the other three. Without the override the default forwards the whole error payload into a `TTHttpLogAction`, and the demo's `[Action]` column is `nvarchar(255)`: the row was silently truncated away by the database and the exception swallowed by the log thread, so a 5xx left no trace exactly where the documentation promised one. `Demos/APIRest/SQL/Log.SqlServer.sql` gains the columns and the table. It is the code hosts copy, so a `Params` column left empty with nothing in the row to say why is a defect in the example, not only in the example's documentation
- **Breaking: `TTHttpListener<C>.Create` takes the log**, so the listener can hand `WriteError` the detail it no longer sends to the client. The constructor signature changed rather than gaining an overload: the listener is built by `TTHttpServer<C>` and there is no reason for a host to construct one, but the type is in the package, so this is noted rather than assumed harmless
- **`TTMultiTenant<T>.GetAll` no longer returns registration order.** It iterates the dictionary now, which is what makes it stop listing removed tenants; the order is unspecified and differs between runs. Sort the result if you display it
- **`TTHttpLogResponse.Uri`**: the request record carried the uri and the response record did not, so a writer could not decide anything by route on the way out - redaction had to scan every payload for sensitive keys instead of matching the endpoint. `LogResponse` already receives both records, so the value was there all along

### Authorization

- **Breaking: `[TAuthorizationType]` is now read on the method as well as on the class**, the method taking precedence. Areas were already read on both. The asymmetry cut both ways, and both directions change on upgrade:

    - a method added to a controller declared `[TAuthorizationType(None)]` - which is what an authentication controller is, so that it can expose the login - silently became an anonymous endpoint, inheriting the file's convention along with its authorization level. That case is now closed;
    - conversely, `[TAuthorizationType(None)]` written **on a method** of an authenticated controller used to be ignored, leaving the endpoint protected. It is now applied, and that endpoint becomes anonymous.

    Nothing reports the second case: it compiles, runs, and answers without a token. Before upgrading, grep for the attribute on methods and confirm each occurrence still says what you mean

### HTTP headers

- **Header lookup is case insensitive.** `TTHttpHeaders` now builds its dictionary with an ordinal case-insensitive comparer, so `Headers.Value['Authorization']` matches whatever case the client sent. It also affects enumeration: two headers differing only in case now collapse into one entry, so `Headers.Count` and the log's `HeadersCount` can be one lower than before. The comparer is resolved once in a class constructor rather than per request, because the RTL's own `TIStringComparer.Ordinal` is a lazily created singleton with an unsynchronized test-and-assign. HTTP header names are case insensitive by specification and **HTTP/2 mandates lower case**: the previous exact-match lookup would have failed to authenticate the first conforming client or proxy, closed - a 401, not a bypass - and with "the right credentials do not work" as the only symptom. `TTHttpParameters` deliberately keeps exact-match semantics, as query parameter names are case sensitive

### Build

- **Every package is set to explicit rebuild** (`{$IMPLICITBUILD OFF}`, 50 `.dpk` files across the five Delphi versions). Building a project group that includes Trysil no longer rebuilds the packages implicitly, which is both faster and predictable; the trade-off is that after changing Trysil's own sources you have to build the packages yourself before the change reaches a dependent project

### Tests

- Twenty-three new cases, suite at 360 green: the nested exception is captured as strings and a `raise;` after a swallowed `ETException` still finds the original alive; the 500 body carries no chain; `ETHttpConflict` is 409; the task id is unique across a thousand calls on one thread and carries no clock; the filter uses canonical column names in both `where` and `orderBy`, rejects a non-object `orderBy` item and refuses too many conditions or columns; the limit ceiling clamps and a negative ceiling stays unlimited; the log queue carries error entries and never keys a discard on an empty host; the item cap is unlimited unless asked for and rejects counts above it; header lookup ignores case while parameter lookup does not

## Transactions - Explicit Mode & RunInTransaction

- **`TTContext.RunInTransaction(AProc)`**: runs a procedure inside a transaction. It commits on clean exit, rolls back and re-raises on an exception, and **joins the active transaction** when one is already open, so a domain method that wraps itself in it is atomic both when called on its own and when called from inside a larger unit of work
- **`TTTransactionMode`** (`Trysil.Transaction.pas`, scoped enum): `CommitOnDestroy` or `RollbackOnDestroy`, passed to `CreateTransaction`, decides what destruction means when neither `Commit` nor `Rollback` was called. `RollbackOnDestroy` makes the ordinary `try..finally LTransaction.Free` correct, because any path that does not reach `Commit` rolls back
- **`TTTransaction.Commit` is now public**, and clears the local flag so that destruction never repeats work already done. A failed `Commit` attempts a rollback and re-raises, instead of leaving the transaction open on the connection
- **`CreateTransaction()` with no arguments is deprecated** and maps to `CommitOnDestroy`. Existing behaviour is unchanged, so nothing breaks: `try..finally LTransaction.Free` still commits on the way out of an exception, which is exactly why the deprecation is there
- **A nested `RollbackOnDestroy` raises**: Trysil does not use savepoints, so an inner transaction cannot roll back independently of the outer one. Declaring that intention now fails immediately instead of silently doing nothing
- **Destruction is silent by design**: whatever happens in `BeforeDestruction` is swallowed, because an exception escaping a destructor would replace the error that caused the unwind and would stop the instance from being freed
- **`TTTransaction.Run(AConnection, AProc)`**: the shared implementation, at the connection layer. `TTContext.RunInTransaction`, `TTContext.InternalApplyAll`, `TTSession<T>.ApplyChanges` and `TTGenericCommand.ExecuteCommand` all route through it, so `TTTransaction` is now constructed in exactly two places
- **`ExecuteCommand` no longer builds a transaction object per command** when the connection is already in one
- **Tests**: six new cases in `Trysil.Tests.Abstract.Transaction.pas` - `RollbackOnDestroy` with and without an explicit `Commit`, a nested `RollbackOnDestroy` raising, and `RunInTransaction` committing, rolling back and joining an outer transaction

## Currency - First-Class Decimal Type

- **`Currency` entity fields**: `Currency` and `TTNullable<Currency>` are now mapped end to end without going through `Double`. `TTColumnMap.IsCurrency` drives the choice, exactly like `IsGuid` / `IsInteger` / `IsInt64`, so a `Currency` member is read through `TTCurrencyColumn` (`TField.AsCurrency`) and written through `TTCurrencyParameter` (`TTParam.AsCurrency`), and its four decimals stay exact
- **`TTParam.AsCurrency`**: new writer on the parameter contract, implemented by `TTFDParam`, the only implementation, so no driver had to change
- **Filter values**: a `Currency` value bound to a filter parameter is now written as `Currency` instead of being converted to `Double`
- **JSON**: `TTJSonCurrencySerializer` / `TTJSonCurrencyDeserializer` emit and parse the exact decimal representation with invariant formatting, replacing the previous aliasing on the `Double` serializer
- **`TTDataset<T>`**: a `Currency` column is published as an `ftCurrency` field definition, and the record buffer is converted for both plain and nullable members. Previously a `TTNullable<Currency>` member was filled with the raw bit pattern of a `TTNullable<Double>`
- **Trysil Expert**: new `Currency` column type, generating `DECIMAL(19,4)` (`NUMBER(19,4)` on Oracle, the same type). Firebird and InterBase get `DECIMAL(18,4)`, since they reject a precision above 18
- **Tests**: `TTestAllTypes` gains a `Currency` and a `TTNullable<Currency>` column on all seven engines, with a round-trip test that accumulates 0.07 ten times and expects exactly 0.70

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
