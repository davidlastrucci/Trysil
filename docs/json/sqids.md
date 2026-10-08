---
title: Sqids
---

# Sqids

With Sqids on, the ids that leave the application are short opaque strings
instead of sequential numbers: `"k8j2ld03"` instead of `42`. A client cannot
read how many rows a table has, nor guess the id of the next one. The database
is not involved: primary keys stay integers in the tables, in the entities and
in every `TTContext` call. Only their representation outside the application
changes.

> **Unit**: `Trysil.JSon.Sqids.pas`

!!! warning "Delphi 12 Athens or later"
    `TTJSonSqids` is built on `TSqidsEncoding`, an RTL type introduced in
    Delphi 12. On 10.3, 10.4 and 11 the class compiles but does nothing:
    `UseSqids := True` is accepted, `UseSqids` reads back `False` and the ids
    go out as plain integers.

## Turning it on

`TTJSonSqids.Instance` is a singleton, shared by the JSON and HTTP modules. Set
it once at startup, before the first entity is serialized:

```pascal
TTJSonSqids.Instance.UseSqids := True;
```

It is off by default.

## What is encoded

| Where | With Sqids on |
|---|---|
| Primary key, serialization | emitted as a JSON string |
| Primary key, deserialization | read as a sqid. An absent or `null` key is left alone; a value that is not a valid sqid raises `ETJSonException` naming the field |
| `TTLazy<T>` relation | its `<name>ID` member is emitted and read as a sqid |
| HTTP route parameters | every `?` placeholder is read as a sqid, except those of a parameter marked [`[TNotSqid]`](#plain-numbers-in-a-route) |
| HTTP filter | a condition on the primary key or on a `TTLazy<T>` relation takes a sqid; a plain number is refused with `400` |

The same applies to related entities and to detail collections: every
serialized entity has its own primary key encoded.

!!! warning "Integer columns are not encoded"
    Only the primary key and the `TTLazy<T>` relations are encoded. A foreign
    key mapped as a plain `Integer` column goes out as a number, so it shows
    the id Sqids was meant to hide. Map relations as `TTLazy<T>` to keep every
    id opaque.

## Only canonical sqids are ids

A string is read as an id only if it is the very sqid `Encode` produces for
that number. `TSqidsEncoding` decodes more than it produces: `2026`, a number and
not a sqid, decodes to 24471 without an error. Trysil encodes the
number back and compares it with the string it received, so those values are
refused instead of reaching the application as another id: a route answers
`404`, the JSON raises `ETJSonException`, the filter answers `400`.

## HTTP routes

A route placeholder `?` binds an `Integer` parameter of the controller method.
With Sqids on, the segment of the URL is decoded as a sqid:

```pascal
[TGet('/?')]
procedure Get(const AID: Integer);
```

`GET /api/order/k8j2ld03` calls `Get(42)`. Every placeholder of the route is
read as a sqid, so `/orders/?/rows/?` takes two sqids. A segment that is not a
sqid does not match the placeholder, and the route answers `404`: with Sqids on,
`GET /api/order/42` reaches no method at all.

### Plain numbers in a route

A placeholder that carries a number which is not an id, a version or a year,
marks its parameter with `[TNotSqid]` (`Trysil.Http.Attributes`). The client
sends that value as the number it is, and the placeholder reads it as one:

```pascal
[TDelete('/?/?')]
procedure Delete(
  const AID: TTPrimaryKey;
  [TNotSqid] const AVersionID: TTVersion);

[TGet('/report/?/?')]
procedure Report(
  [TNotSqid] const AYear: Integer;
  [TNotSqid] const AMonth: Integer);
```

`DELETE /api/order/k8j2ld03/3` calls `Delete(42, 3)`: the version goes out in
the JSON as a number, because only ids are encoded, and comes back as one.

- **With Sqids off the attribute changes nothing**: every placeholder reads an
  integer anyway.
- **Every placeholder is a sqid unless marked.** A forgotten `[TNotSqid]` makes
  the route answer `404`, which shows at the first call; it never lets a plain
  id through.
- **Methods that share a route mark the same positions.** The router reads the
  placeholders before it knows which method answers, so a `GET` and a `DELETE`
  on the same route that disagree stop the server at registration.
- **An override inherits the reading.** The route and `[TNotSqid]` are read
  from the method that declares the route attribute: an override of `Delete`
  repeats neither.

## HTTP filters

`TTHttpFilter<T>`, and so `TTHttpEntityReader<T>.Select`, reads the value of a
condition on the primary key or on a `TTLazy<T>` relation as a sqid:

```json
{ "where": [ { "columnName": "customerID", "condition": "=", "value": "k8j2ld03" } ] }
```

A plain number on those columns is refused with `400`. Without that, a filter
like `ID > 0` would list every row by its sequential id and go round what Sqids
hides everywhere else. The other integer columns keep taking numbers.

## Encoding by hand

For an id that travels elsewhere, in a query string, a header or a message,
the singleton exposes the conversion directly:

| Method | Sqids on | Sqids off |
|---|---|---|
| `Encode(AValue): TJSonValue` | a `TJSonString` with the sqid | a `TJSonNumber` |
| `Decode(AValue): Integer` | decodes the sqid, raises `EConvertError` if it is not a canonical one | parses the integer, raises `EConvertError` if it is not one |
| `TryDecode(AValue, out AResult): Boolean` | decodes the sqid, `False` if it is not a canonical one | `Integer.TryParse` |

`Encode` returns a new `TJSonValue`: free it, or hand it to a `TJSonObject`
that owns it.

Sqids are lower-case. Every id is lower-cased on its way out and on its way
in, so a client that sends one in capitals is still read.

## The alphabet

The encoder shuffles an alphabet of 36 characters and pads every id to at
least 8 characters. The default alphabet is in the source of Trysil, so anyone
can decode the ids of an application that keeps it. Set your own:

```pascal
TTJSonSqids.Instance.Alphabet := 'q7w3e9r1t5y8u2i6o4p0asdfghjklzxcvbnm';
TTJSonSqids.Instance.UseSqids := True;
```

The alphabet must:

- be at least 5 characters long;
- not repeat a character;
- contain only ASCII characters and no capital letter: ids are lower-cased on
  the way in, so a capital in the alphabet would turn one id into another.

A wrong alphabet raises `ETJSonException` when it is assigned.

!!! warning "Configure once"
    The encoding is built on the first `Encode` or `Decode`. After that,
    assigning `Alphabet` raises `ETJSonException`: a new alphabet would turn
    every id already handed out into another number. Set it at startup, before
    the server starts.

The same holds across restarts: change the alphabet of an application in
production and the ids its clients have stored point to other rows.

!!! note "Not encryption"
    Sqids hide the sequence, they do not protect the data. Anyone who knows
    the alphabet decodes the ids, and an id that decodes is still subject to
    the authorization of the application.
