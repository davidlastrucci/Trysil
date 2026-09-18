# Upgrading from 1.0.0

This page is the checklist. It says what to change and where; it does not say
why, because the reasoning is in [the changelog](https://github.com/davidlastrucci/Trysil/blob/master/CHANGELOG.md),
and every entry there is written to be read. Coming from 1.0.0 means reading
**every** section above `## Change Tracking & Soft Delete`, not only `## 2.0.0`:
the development windows in between carry breaks of their own, and the sections
from there down were already in 1.0.0.

The shape of it: **twenty-two changes stop your build**, and **eighty-four get past
the compiler**. The first twenty-two cost you an afternoon and no thought. The
eighty-four are the reason this page exists.

They are counted against 1.0.0 **or** the public `master` between 1.0.0 and
this release, because that is what most of those upgrading run: fourteen of them
do not exist against the tag `v1.0.0`, and they are marked *on the public
master, not in 1.0.0*. What a client of the HTTP server sees change is not
counted; the ones a client is likely to meet are here all the same, marked.

## 1. Build, and fix what the compiler names

| What changed | What to do |
| --- | --- |
| `TTTableMap.DetailColums` is now `DetailColumns` | rename |
| `TTProvider.Get<T>` lost its one-argument overload | pass `AIncludeDeleted` |
| `SelectCount` returns `Int64` | widen the variable you assign it to; an `Integer` truncates above two billion rows, and raises `ERangeError` under `{$R+}` |
| `TTMetadataCache` is keyed by connection as well as by type | pass the connection name |
| `TTColumnsMetadata.Add` takes the SQL reference, and takes it once | only a driver that answers `GetMetadata` itself: see step 4 |
| `TTClonedEntities<T>.Create` takes the resolver as well as the provider | nothing, unless you constructed it, which nothing outside the session can use |
| a driver configures the connection through `DoConfigureConnection` (on the public master, not in 1.0.0) | rename your override and drop the `inherited` |
| a connection keeps a list of transaction observers | `AddTransactionObserver` / `RemoveTransactionObserver` instead of the property |
| `TTHttpListener<C>.Create` no longer takes an anonymous-route list | declare the anonymous routes on the controller |
| `TTHttpCorsController.Headers` and `.Methods` are `TTHttpCorsValues` | use the record instead of a string |
| `TTHttpLogRequest.Create` and `TTHttpLogResponse.Create` take one more argument | only if you build log records yourself |
| the one-argument `TTHttpLogNameValues.Create` is gone | pass the redaction flag |
| `TTHttpLanguage.SetThreadLanguage` and `RemoveThreadLanguage` no longer take a thread id | drop the argument |
| `TTJSonSerializers.Get` and `TTJSonDeserializers.Get` are gone | use `GetInstance`, which hands back the shared instance the framework owns: **do not free it**, where you freed what `Get(ti).Create` built |
| `Trysil.Http.Consts.SColumnNotFound` is gone | use the one in `Trysil.Consts`, which is the one every place raises now - in 1.0.0 and on the public master the HTTP filter raised the Http copy |
| `TTIdentityMap.RemoveEntity<T>` and `TTEntityIdentityMap.Remove` are gone | nothing: the map is emptied by the context that owns it |
| the resourcestring `SForbiddenArea` is now `SForbiddenAreaLog` | only if you translated the framework messages: rename it in your language unit |
| `TTJSonLazyList.CreateList` is now `PrepareList`, and `TTJSon` no longer carries `FRttiContext` | only if you subclassed `TTJSon` |
| the `IncludeDeleted` overload of `TryGet<T>` takes the flag before the output parameter (on the public master, not in 1.0.0) | `TryGet<T>(AID, AIncludeDeleted, out AEntity)`; the two-argument overload is unchanged |
| `TTObjectLazyList<T>` is gone (on the public master, not in 1.0.0) | use `TTObjectList<T>`, which carries `IsValid` now |
| `TTNewEntityCache.Create` takes no provider, and `Add`, `Contains` and `Remove` are no longer generic | nothing, unless you built a cache of your own: neither `TTContext` nor `TTProvider` handed one out |
| `IsValidInteger` widened to `Int64` and `TValidationValueType` is gone | widen to `Int64` what receives the value, and drop `TValidationValueType`; the entry on the numeric validators has the detail |

Add to those the ones from the sections below `## 2.0.0`, which you also cross
coming from 1.0.0:

- `ETException.NestedException` and the `TExceptionHelper` class helper, both
  gone;
- `TTHttpJWTEncoding`, whose two signatures changed, and `TTHttpJWTHeader`,
  removed;
- the **one-argument** `TTTransaction.Create(LConnection)`. That is the call
  that breaks. There has never been an argument-less `TTTransaction.Create`;
  the argument-less shape is `TTContext.CreateTransaction()`, which is
  deprecated but still compiles;
- the **JWT payload split**, which is the most expensive of these if you use
  Bearer authentication. An application payload inherited from
  `TTHttpJWTAbstractPayload` and overrode `GetSecret`. That class no longer
  has `GetSecret` or `Secret`, and no longer lives in `Trysil.Http.JWT`:
  inherit from `TTHttpJWTHS256Payload` (HMAC secret through `GetSecret`) or
  from `TTHttpJWTRS256Payload`, and add the unit that declares it to your
  `uses`.

## 2. Search your code for these

Nothing here stops the build.

Five entries on this page are not among the eighty-four - one is a break of a development window below `## 2.0.0`, three are what a client of the server sees, and one is a change that is not a break on Delphi 11 and 13, where the RTL was read - and they are here because you have to act on them all the same. They are marked where they stand, all five in this section.

**A member whose name starts with `F` or `f` not followed by an ASCII capital.**
`FatturaID`, `FirstName`, `F1Codice`, `fattura`. Its JSON key changes, in both directions. A client
built on the old spelling reads empty and writes nothing. A lazy member whose
name starts with two `F` - `FFornitore` - changes on the way in: its id was read
as `ornitoreID` and is read as `fornitoreID`, the key it has always been
written under.

**`NUMBER(1)` on Oracle** (on the public master, not in 1.0.0)**.** It is read as a boolean now, by precision and not by
name. A status code or a counter that narrow has to be widened to `NUMBER(2)`.

**`TTHttpResponse.ContentEncoding`.** It writes the charset, not the
`Content-Encoding` header.

**An e-mail validator relied on for the length of the top-level domain.** Long
ones are accepted now.

**A reference kept to an entity reached through a lazy member.** It is freed
with the entity that carries it.

**An entity you free or use after handing it to `TTSession<T>.Insert`.** The
session frees it now, and so does `Save`, new in this release, when the entity
is not one of the session's clones - unless the identity map holds its type, which on a JSON or
HTTP context it never does. Drop your own free once the call has returned, and
do not read the entity or hand it on after the session is destroyed: an entity
written to the response after `LSession.Free`, or added to another list, is
freed memory. See [who frees what](context.md#who-frees-what).

**The short constructors of `TTHttpLogParameters`** (on the public master, not in 1.0.0)**.** They mean
the server's own defaults now, not *no cap*.

**An entity you assigned to a lazy member without an identity map** (a break of
a development window, not one of the eighty-four)**.** The lazy member stores a
clone, where 1.0.0 kept your instance and freed it with the context. The
instance you handed over and stopped freeing is lost now: free what you
assign.

**`.Where(name).IsNull` or `.IsNotNull` on a column the entity does not map.**
They were the only two operators of the builder that did not check the name.
They raise `SColumnNotFound` now, where they used to emit the name as given.
The same holds in the expression API for `TTProperty.IsNull`, `IsNotNull` and
an empty `InValues`. On a `[TJoin]` entity the name checked is the output alias
`Alias_Column`, for the columns of the `FROM` table too: the one-argument
`TTProperty.Create('ShippedAt')` raises even on a mapped column, and so does
`TTProperty.Create('Customers', 'DeletedAt')` on a column the entity does not
map. Name a mapped column with `TTProperty.Create(Alias, Column)`, or write
that `WHERE` with `TTFilter.Create`.

**A detail collection whose child entity maps a `[TJoin]`** (on the public
master, not in 1.0.0)**.** It loaded with the column name unqualified, which
worked when the name belonged to one of the joined tables only. It raises
`SDetailColumnOnJoinEntity` on its first read now: map the detail on an entity
without `[TJoin]`, or read the rows with `Select<T>` and a filter.

**`OrderByAsc` or `OrderByDesc` on anything but a mapped column.** Both put
the string into the `ORDER BY` as it was: `UPPER(Name)`, `Name NULLS LAST`, a
name the entity does not map, `c.Name` qualified by hand. Every item of the
list is checked now, and one that is not a mapped column raises
`SColumnNotFound`; a trailing `ASC` or `DESC` is still accepted. Order by a
mapped column - on a `[TJoin]` entity by its output alias `Alias_Column` - or
put the expression in a `RawSelect`. On the public master the `TTProperty`
overloads passed their reference through unchecked as well: a property naming a
column the metadata do not carry raises now too.

**An `Update<T>` on a row read with `IncludeDeleted`.** Every `UPDATE` carries
`DeletedAt IS NULL` now, so it no longer reaches a soft-deleted row and raises
`ETConcurrentUpdateException` - through `Update<T>`, `UpdateAll<T>`,
`ApplyAll<T>`, `Save<T>` and `TTSession<T>.ApplyChanges` alike. In 1.0.0 that was the way to bring a row back:
use `Undelete<T>`.

**An entity changed and then restored with `Undelete<T>`** (on the public
master, not in 1.0.0)**.** `Undelete<T>` writes only the columns it restores -
the version, `DeletedAt`, `DeletedBy` and the update audit pair - where it used
to write the whole row. A correction made to the entity before restoring it is
no longer saved: call `Update<T>` after `Undelete<T>`.

**A total read with `CreateDataset` and written by `DatasetToJSon`, from a decimal
column.**
`ftCurrency` and `ftBCD` were read through a `Double`, so anything past fifteen
significant digits was rounded away in silence, and `ftFMTBcd`, which a wide
`DECIMAL` total comes back as, raised. All three carry their exact digits now. It is still a JSON number, not a string, so nothing on the
wire changes type - but a client, a report or a stored expectation built on
the rounded value will see a different number, and the different number is
the right one.

**A column whose name carries a symbol, on PostgreSQL, SQLite, MariaDB or SQL
Server.** A name the driver cannot bind as a parameter is refused when the
metadata of the entity are built, which is the first read, not only the first
write. In 1.0.0 such a column was readable on PostgreSQL and SQLite
(`N°Fattura`, `Importo€`) and on SQL Server (`Cod@Art`), and so it was on
MariaDB, which came later; a read-only entity on it worked. It raises now:
rename the column.

**A `DATE` or a `TIME` column written by `DatasetToJSon`.** It went out as a
timestamp converted to UTC, so a date read on a server east of Greenwich
arrived as the evening of the day before. It goes out as `2026-03-05` and
`10:30:00` now, as the entity path writes them. A client that parsed the
timestamp, or shifted it back by its own offset, has to read the plain value.
`DATETIME` and `TIMESTAMP` columns are unchanged, and so is a `DATE` on Oracle,
or on Firebird and InterBase in dialect 1: there it carries a time, FireDAC
hands it over as a timestamp, and it keeps the UTC form - do not switch a
client of those engines to the plain date. A negative `TIME` on MariaDB goes
out without its sign.

**Code that calls `EntityFromJSon`, `EntityFromJSonObject`, `ListFromJSon` or
`ListFromJSonArray` and catches `EJSONException`, `EConvertError` or
`EDateTimeException`.** A value the RTL cannot convert, and JSON that does not
parse, raise `ETJSonException` now, which through the listener is a 400. Catch
`ETJSonException` instead. A number outside the range of an `Int16` member
raises too, where it used to be stored cut - that one is what a client of the
server meets, and it is not among the counted breaks, but a host calling the
deserializer itself meets it here.

**A JSON serializer or deserializer you registered yourself.** It used to be
built once per value converted; it is one instance per type now, shared by
every request thread and destroyed at unit finalization. If it keeps state
between calls, that state is now shared and unlocked. Make it stateless.

**A report built with `DatasetToJSon` whose strings end up in a page as HTML.**
The strings are no longer HTML-encoded: `Rossi &amp; Figli` goes out as
`Rossi & Figli`. The encoding protected the page that shows them by accident;
it has to encode the value itself now.

**A name written in an attribute with the quotes of the engine, or naming
something other than an identifier.** Identifiers are quoted on all seven
engines, so `[TTable('"Clienti"')]` becomes `"""clienti"""` and a table-valued
function in `[TTable(...)]` is quoted as a name: both reach nothing. Write the
bare name, and reach a function with `RawSelect<T>`.

**An `Update<T>` that was meant to write an audit column.** The four creation
and delete tracking columns are out of the `SET` list: `[TCreatedAt]`,
`[TCreatedBy]`, `[TDeletedAt]` and `[TDeletedBy]` are written once, by the
framework. An import or a migration tool that corrected `CreatedAt` writes
nothing now, and a soft delete done by setting `DeletedAt` by hand and calling
`Update<T>` does nothing at all, without saying so: go through `Delete<T>` for
the delete, and through raw SQL for the audit.

**A body that carries an audit column.** No deserializing entry point reads the
six tracking columns any more - `EntityFromJSon`, `EntityFromJSonObject`,
`ListFromJSon`, `ListFromJSonArray` and nested detail objects all skip them. An
entity round-tripped through JSON keeps the values it had, and a
`{"deletedAt": "..."}` in a body no longer reaches the entity.

**A `[TDeletedBy]` with no `[TDeletedAt]`, or two tracking attributes on one
column.** Both are refused when the mapping is built, with
`SDeletedByWithoutDeletedAt` and `SDuplicateChangeTrackingColumn`. One column
marked `[TCreatedAt]` and `[TUpdatedAt]` together - a single *last change*
timestamp - has to become two columns, or one attribute.

**Four mappings that used to be accepted.** A column marked both
`[TPrimaryKey]` and `[TVersionColumn]`; a key or version column that also
carries a tracking attribute; a member carrying both `[TColumn]` and
`[TDetailColumn]`. Each is refused where it is declared, with its own message.

**`Save<T>` or `SaveAll<T>` on a `TTHttpContext`.** They are refused, however
the object is reached, including through a `TTContext` reference. A `PUT` that
carried the key in the body and went through `Save` has to say what it does:
`Insert<T>` or `Update<T>`, as the REST example has always done. A
`TTJSonContext` is unaffected.

**An `Insert<T>` of an entity whose primary key is zero.** It is refused now,
where the row went in with `ID = 0`. It is the JSON path that meets this: a
body with no key needs `SetSequenceID<T>` in the controller.

**A `Refresh<T>` of a row that may be gone, and an `OldEntity<T>` in an
event.** `Refresh<T>` raises when the row is no longer there, where it left the
entity exactly as it was; `OldEntity<T>` returns `nil` for the same case, where
it handed back a copy of the in-memory state as the state of the database; and
an `OldEntity` first read in an `After` event is refused, because it is
memoized on first access and after the write there is nothing old to read. Read
it in the `Before` event and keep what you need.

**A connection you close to release a file.** Pooling is on by default now, so
the connection goes back to the pool and the file - SQLite, Firebird embedded -
stays open. Set `Enabled := False` on the pool configuration where you need the
old behaviour.

**A join column alias longer than 30 bytes** (on the public master, not in
1.0.0)**.** `Alias_Column` is bounded now, for Oracle up to 12.1. A name you
wrote in an `OrderByAsc` or read from `GetMetadata` may be shorter than it was.

**A client that reads `MetadataToJSon<T>`.** The array is `properties`, not
`columns`, and the name is `entity` with the class name, not `tableName` with
the name of the table. Both are one-word changes on the client side. A
member marked `[TJSonIgnore]` is no longer described there either, where it
appeared in the metadata and in no response, and every entry now carries
`readable` and `writable`: a client that builds a form from the metadata can
read them instead of guessing.
`MaxLevels` also bounds detail collections now, where the depth budget was
reloaded on entering each one: a payload that came back deeper comes back cut.

**`GetOrAdd` with a tenant name built from something else.** A name that cannot
be one is refused with `ETTenantNameNotValid`, where any string was taken and
turned into a connection definition.

**A route with a placeholder before a fixed segment.** `[TGet('/?/detail')]` is
refused at registration, with `SNotValidParametrizedUri`.

**A server with `[TArea]` routes, or with routes that require
authentication.** `Start` refuses when a route requires authentication and no
authentication class is registered, unless you set the new `AllowAnonymous`,
which waives that one check. It does not waive the checks on `[TArea]`: a
route carrying an area with no authentication class refuses to start
`AllowAnonymous` or not, and so does an area on a route marked
`[TAuthorizationType(None)]`, where authentication never runs and the area
could never be checked. A listener built by hand with no authentication class
answers `403` on a `[TArea]` route where it used to serve it. Register the
authentication class.

**A log reader that expects request and response bodies.** They are not
captured by default any more: pass the parameter record that asks for them.

**An exception raised inside a `[TValidator]`.** It leaves the validator now,
where it became a validation error carrying `E.Message`. Raise
`ETValidationException` yourself for a failure the caller should see as one.

**A `.Offset(50)` with no `Limit`.** It raises now, where it was ignored and
every row came back.

**A SQL Server connection string.** `Encrypt=No` is no longer sent for you.
Driver 18 against a self-signed certificate does not connect until the string
says `Encrypt=No` or `TrustServerCertificate=Yes`.

**A second `Delete<T>` of a row already deleted.** It raises now, where it
passed and stamped the delete audit a second time. Only a row read with
`IncludeDeleted` can get there; use `Undelete<T>` and `Delete<T>` in turn if
you meant to refresh the audit.

**A sequence value larger than a `TTPrimaryKey`.** It raises now, where the
64-bit value came back cut to 32 bits and collided with a row that already
existed.

**A JSON array with an element that is not an object.** `ListFromJSon`,
`ListFromJSonArray` and a detail array inside an entity refuse it now, where
`[{...}, null]` came back as a list of one and nobody was told.

**A `RegisterController`, `RegisterAuthentication`, `RegisterLogWriter`,
`AllowAnonymous`, `OnCanLog` or `OnRedactContent` after `Start`.** All of them
raise now, as `Port` and `BaseUri` already did. A controller registered on a
running server was never served.

**A `RegisterConfig` for a connection already registered** (on the public
master, not in 1.0.0)**.** It raises now: pooling is baked into the FireDAC
connection definition by `RegisterConnection`, so parameters supplied after it
were stored and never read. Register the pool parameters before the
connection.

**A `RegisterLogWriter` whose writer opens something in its constructor.** The
writer is built at registration now, not at the first line logged. If its
constructor opens a file or a connection, a server that used to start and log
nothing now fails to start - which is the point, but it is a new failure.

**Code that catches `EFDDBEngineException` around the first read of an
entity.** Every driver error raised while the metadata are probed arrives as
`ETException` now. A host that read `Errors[0].ErrorCode` to tell "table
missing" from the rest, and ran a migration, catches nothing: read
`InnerException`, or probe the schema yourself.

**An `Int64` member and a client that quotes its numbers** (not one of the
eighty-four)**.** A quoted whole number is accepted on every Delphi version
now. On 11 and 13 the RTL converted it already, so there it is not a break at
all; it is here because on 10.3, 10.4 and 12, which were not checked, the answer
may have been different, and because a body your application used to refuse can
now go in.

**A `[TJSonIgnore]` on a detail collection.** It is obeyed now, where the
collection was serialized anyway: that key leaves every response. Remove the
attribute if the client needs the collection.

**A `Save<T>` after a commit that failed.** The entities are back among the new
ones, so it inserts where it used to update and raise. If the database
committed while the client thought it had not, that insert is a duplicate row:
read the entry before relying on it.

**A `.Entity := nil` on a relation you have not read.** It clears the foreign
key now, where it did nothing and the next `Update<T>` wrote the old key back.
Both 1.0.0 and the public master did nothing there, so an assignment that was
a no-op now writes `NULL`.

**A `NUMERIC` column on PostgreSQL read through `CreateDataset`.** It arrives
as a `TCurrencyField`, not a `TBCDField`: an `as TBCDField` raises
`EInvalidCast`, a `case Field.DataType` takes another branch, and
`MetadataToJSon<T>` publishes `ftCurrency`. Past about 9 * 10^11 that field
also loses the last decimals, and the changelog says where.

**A translation unit of your own.** Two message texts changed against 1.0.0:
`SForbidden`, where a typo was corrected, and **`SRecordChanged`**, which is the
message of `ETConcurrentUpdateException` - the one your users read when
optimistic locking stops a save. The text of `SColumnNotFilterable` changed
too (on the public master, not in 1.0.0). A table keyed on the English text
loses those entries and falls back to English without a sound; one keyed on the
constant, the way `Demos/Languages/README.md` teaches, keeps them. It still
needs the rename in step 1, and a line for every new constant you want
translated - this release adds dozens. Start with
`SRequiredRelationValidation`, and with `SEntityNotFound`, which
`Delete<T>(AID, AVersionID)` on a `TTHttpContext` raises for a row that is not
there, where your table translated `SRecordChanged`.

**A JWT payload whose secret can come back empty, or an RS256 key that is not
RSA** (the second on the public master, not in 1.0.0)**.** Signing with an empty
HMAC secret raises now, and a key that is not RSA is refused when it is built.
Both used to work: the first produced signatures anyone could reproduce, the
second verified ECDSA while the token said `RS256`. A `GetSecretFor` that
returns an empty string for an unknown `kid` now fails closed, which is what it
was meant to do.

**An overload of a controller method with no `[TArea]`, next to one that has
it.** Areas were collected from every method of the same name, so the overload
without the attribute was restricted by its sibling's. They are collected from
the methods with the same parameter list now - an `override` still inherits
its ancestor's - and that overload answers every authenticated caller: put
`[TArea]` on each overload that must stay restricted.

**A header set by a controller method that then raises.** An error response
keeps only the headers set before the controller method runs - CORS,
`WWW-Authenticate` on a `401` from the authentication class, anything set in the
controller's constructor - and removes the ones the method added, then sets the
JSON content type. A `Retry-After`, a `Location` or a `WWW-Authenticate` set by
the method before raising no longer reaches the client, whatever the exception:
set the status code and the body on the response and return, instead of
raising. A header that was already there and that the method overwrites keeps
the method's value.

**A tenant config whose constructor or `GetParameters` is not thread-safe.**
In 1.0.0 both ran under the write lock of `TTMultiTenant<T>`, once per tenant,
and on the public master `GetParameters` still did. They run before the lock is
taken now, so two requests for a new tenant can run them at once, and twice for
the same tenant: make them thread-safe, and have `GetParameters` return the same
parameters every time, or the second registration is refused.

**A `Delete<T>(AID, AVersionID)` on a `TTHttpContext`, and a controller that
catches the concurrency exception around it.** A row that is not there answers
`404` now, through `ETHttpNotFound`, where it raised
`ETConcurrentUpdateException` - which before this release left the listener as a
`500`, since only `ETHttpException` had a branch of its own. A real version conflict answers `409`, which is
also new: before this release it came out as a `500` like the rest.

**A detail collection sent as something other than an array.** Any value that
is not an array is refused now, naming the field - `{"rows": {}}`, a string, a
number. From Delphi 12 it used to deserialize an entity **with no rows at all**,
in silence. An empty array still means what it says, and empties the collection
**in memory**: nothing is deleted from the database until you write those rows.

**A detail collection left out of the body, or sent as `null`, when you
deserialize over an entity you already read** - through
`TTJSonDeserializer.EntityFromJSon`, or the overloads of `EntityFromJSon<T>` and
`EntityFromJSonObject<T>` that take an entity, new in this release**.** It is
left as it was now, where it was emptied in memory: code that reads the
collection afterwards sees the rows it had, not an empty list. On a fresh entity
the collection still comes out with no rows, unless a detail row carries key 0,
and reading it now runs one query where it ran none.

**A `[TRequired]` on a lazy relation, and a master you archive.** A lazy member
loads with `Get<T>(ID, True)`, so it returns a soft-deleted master on purpose -
an order has to be able to show the name of a customer that was archived - and
`[TRequired]` accepts what it is handed. In 1.0.0 it refused it, which had a
consequence worth knowing: archiving a master froze every record that pointed
at it, because no `Update<T>` on those passed validation again. Now they go on
being saved, and a new record may be pointed at an archived master too. If your
domain wants that refused, write it in a `[TValidator]`: there you have the
entity and the context, and you can tell a key just assigned from one that has
been there for years.

**A reference to a relation kept across a deserialization over an entity you
already read** - through `TTJSonDeserializer.EntityFromJSon`, or the overloads
of `EntityFromJSon<T>` and `EntityFromJSonObject<T>` that take an entity, new in
this release**.** The deserializer writes the foreign key through the property
now, so the entity the lazy member had loaded is released through the context
and the relation reloads on the next read. Before, the key changed and the
instance stayed: the relation answered with the old master under a new id, and
a key pointing at a row that is not there slipped past `[TRequired]`. On a
context without an identity map - a JSON or HTTP context never has one - that
old instance is freed, so do not keep a pointer to it across the call.

**A client that reads the status code of a failed write** (seen by a client,
not one of the eighty-four)**.** An `ETConcurrentUpdateException` answers
`409` and an `ETValidationException` answers `422`, where both used to reach the
listener's generic branch and come out as `500`. A client that retried on `500`,
or that showed "server error" and stopped, now gets a code it has no branch
for - and the body comes from `MakeOrmResponse`, so it changes too.

**A client that filters or orders on a column no response returns** (seen by a
client, not one of the eighty-four)**.** It was answered `200` in 1.0.0 and is
refused with a `400` now, the same answer as for a column that does not exist.

**A value longer than the column it is written to.** It raises now, where
`TTStringParameter` cut it to the size of the column and wrote the cut value
back into your entity, with no exception and no log line. It holds for a filter
value as much as for a write: an equality on a value longer than the column
used to match on a prefix. Declare the length with `[TMaxLength]` and validate
before writing.

**An `OrderByDesc` that names more than one column.** Each column carries its
own `DESC` now: `OrderByDesc('Code, Quantity')` used to leave `Code` ascending,
with nothing to say so.

**A `.Limit(10)` with no `Offset`.** It pages from the first row now, where the
whole paging was dropped and every row came back.

**A `TDate` or a `TTime` member of an entity.** Both were serialized as a
`TDateTime` and converted to UTC, so a pure date on a server east of Greenwich
went out as the evening of the day before. They go out as `2026-03-05` and
`10:30:00` now, and a client that parsed a timestamp has to read the plain
value.

**Two columns whose names differ only by a space and an underscore.**
`Ragione Sociale` and `Ragione_Sociale` name the same parameter: the mapping is
refused now, where one column wrote over the other.

**A client that sends a date without a time zone in a filter** (seen by a
client, not one of the eighty-four)**.** It is read as the local time of the
server, where the public master read it as UTC - 1.0.0 put the text into the
statement and the database read it as written. A client that shifted its value to make up
for that has to stop.

## 3. Fix how, and in which order, you free things

Six rules, none of which the compiler checks - the other three lifetime breaks are in the list above, because they are things to search for rather than an order to respect:

- every entity through `FreeEntity<T>`, and every list of entities built by
  `CreateEntityList<T>`. A rollback puts back what Trysil wrote to the
  entities, so it holds them until the transaction ends: a bare `Free` of an
  entity written inside that transaction makes the rollback write into freed
  memory. An event that writes another entity is inside a transaction whether
  you opened one or not. Write and free an entity through the context that
  read or created it, never through another one on the same connection.
  Search every `.Free` on an entity and every
  `TTObjectList<T>.Create(True)` that holds entities, and check each against
  [who frees what](context.md#who-frees-what): a clone and an object you
  built yourself go through `FreeClone<T>`, and the result of a
  `RawSelect<T>` stays yours;
- a `TTSession<T>` before the context that created it;
- a list of yours handed to `CreateSession<T>` after that session; for the
  list of a lazy member, which you never free, keep the entity that carries it
  alive until after the session: `ApplyChanges` reads the list;
- a list built by `CreateEntityList<T>` before that context too (on the public
  master, not in 1.0.0) - it tells the context about every entity it frees,
  with the identity map on or off;
- and **delete the loop that freed those entities by hand**, if you wrote one
  (on the public master, not in 1.0.0). That list owns what the identity map
  will not hold - a `[TJoin]` entity, a row from a `RawSelect<T>`, anything
  without a primary key - where with the map on it owned nothing and freed
  nothing. A loop written to plug that leak now frees them a second time;
- the context before the connection.

`try..finally` around the block that uses each of them is the shape that is
always right.

## 4. If you wrote a driver

Four of the eighty-four silent changes are yours alone, and none of them stops
your build - the one on `CreateUndeleteCommand` is on the public master, not in
1.0.0. Read the entries on `TTGenericConnection`, on `TTParam`, on
`CreateUndeleteCommand` and on `TTMetadataProvider.GetConnectionName` before
you deploy rather than after: an unimplemented abstract is a hint where the
driver is constructed and an `EAbstractError` in production.

If your connection descends from `TTGenericConnection`, which is what the
[driver page](../database-drivers/index.md) describes, you inherit the metadata
path and none of the `TTColumnsMetadata` change reaches you.

## 5. Then read the changelog

The entries marked **Breaking** are not the whole story, which is the point of
the two lists above. Several changes are observable without being
source-incompatible, and they are described where they belong rather than
gathered here.
