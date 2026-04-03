# Filtering

Trysil provides two ways to filter queries: the `TTFilter` record for manual construction and `TTFilterBuilder<T>` for a fluent, type-safe API. Both are defined in `Trysil.Filter.pas`.

## TTFilter Record

### Simple WHERE Clause

```pascal
LFilter := TTFilter.Create('Lastname = :Lastname');
LFilter.AddParameter('Lastname', ftWideString, 'Smith');
LContext.Select<TPerson>(LPersons, LFilter);
```

### With Max Records and Ordering

```pascal
LFilter := TTFilter.Create('Active = 1', 20, 'Lastname ASC');
LContext.Select<TPerson>(LPersons, LFilter);
```

This limits the result to 20 records ordered by `Lastname`.

### With Pagination

```pascal
LFilter := TTFilter.Create('Active = 1', 0, 20, 'Lastname ASC');
LContext.Select<TPerson>(LPersons, LFilter);
```

Parameters: WHERE clause, start offset, limit, ORDER BY.

### Adding Parameters

```pascal
LFilter := TTFilter.Create('Age >= :MinAge AND Age <= :MaxAge');
LFilter.AddParameter('MinAge', ftInteger, 18);
LFilter.AddParameter('MaxAge', ftInteger, 65);
```

Always use named parameters (`:ParamName`) instead of concatenating values into the WHERE string. This prevents SQL injection and ensures correct type handling.

## TTFilter.Empty

Use `TTFilter.Empty` when no filter is needed. This is equivalent to selecting all records:

```pascal
LContext.Select<TPerson>(LPersons, TTFilter.Empty);
```

`SelectAll<T>` internally uses `TTFilter.Empty`.

## TTFilterBuilder\<T\> (Fluent API)

The preferred way to build filters. The builder resolves column metadata from the entity type at construction time, ensuring column names and data types are valid.

Obtain a builder via `TTContext.CreateFilterBuilder<T>`:

```pascal
var LBuilder := LContext.CreateFilterBuilder<TPerson>();
try
  var LFilter := LBuilder
    .Where('Lastname').Equal('Smith')
    .AndWhere('Firstname').Like('J%')
    .OrderByAsc('Lastname')
    .Limit(20)
    .Offset(0)
    .Build;

  LContext.Select<TPerson>(LPersons, LFilter);
finally
  LBuilder.Free;
end;
```

!!! warning
    The builder is an object that must be freed after use. Call `Free` once you have obtained the `TTFilter` via `Build`.

## Available Operators

| Method | SQL Operator | Example |
|---|---|---|
| `Equal(value)` | `=` | `.Where('Status').Equal(1)` |
| `NotEqual(value)` | `<>` | `.Where('Status').NotEqual(0)` |
| `Greater(value)` | `>` | `.Where('Age').Greater(18)` |
| `GreaterOrEqual(value)` | `>=` | `.Where('Age').GreaterOrEqual(18)` |
| `Less(value)` | `<` | `.Where('Age').Less(65)` |
| `LessOrEqual(value)` | `<=` | `.Where('Age').LessOrEqual(65)` |
| `Like(pattern)` | `LIKE` | `.Where('Name').Like('J%')` |
| `NotLike(pattern)` | `NOT LIKE` | `.Where('Name').NotLike('Test%')` |
| `IsNull` | `IS NULL` | `.Where('Email').IsNull` |
| `IsNotNull` | `IS NOT NULL` | `.Where('Email').IsNotNull` |

## Combining Conditions

```pascal
LBuilder
  .Where('Lastname').Equal('Smith')         // first condition
  .AndWhere('Active').Equal(True)           // AND
  .OrWhere('Role').Equal('Admin')           // OR
```

- `Where` starts the first condition.
- `AndWhere` adds a condition with AND.
- `OrWhere` adds a condition with OR.

Conditions are combined in declaration order. The builder does not support explicit grouping with parentheses.

## Sorting and Pagination

```pascal
LBuilder
  .OrderByAsc('Lastname')       // ORDER BY Lastname ASC
  .Limit(50)                    // LIMIT 50
  .Offset(100)                  // OFFSET 100
```

```pascal
LBuilder
  .OrderByDesc('CreatedAt')     // ORDER BY CreatedAt DESC
```

Only one `OrderBy` call is active at a time. Calling `OrderByAsc` or `OrderByDesc` replaces any previous ordering.

## Including Soft-Deleted Records

When an entity has a `[TDeletedAt]` column, all queries automatically exclude soft-deleted records by adding `DeletedAt IS NULL` to the WHERE clause. To include them:

### Via TTFilterBuilder

```pascal
var LFilter := LContext.CreateFilterBuilder<TArticle>()
  .Where('Title').Like('Draft%')
  .IncludeDeleted
  .Build;

LContext.Select<TArticle>(LArticles, LFilter);
```

### Via TTFilter

```pascal
LFilter := TTFilter.Create('Title LIKE :Title');
LFilter.AddParameter('Title', ftWideString, 'Draft%');
LFilter.IncludeDeleted := True;
LContext.Select<TArticle>(LArticles, LFilter);
```

See [Entity Mapping — Soft Delete](entities.md#soft-delete) for how to set up change tracking attributes.

## SelectCount

Count records matching a filter without loading entities:

```pascal
var LBuilder := LContext.CreateFilterBuilder<TPerson>();
try
  var LFilter := LBuilder
    .Where('Active').Equal(True)
    .Build;

  LCount := LContext.SelectCount<TPerson>(LFilter);
finally
  LBuilder.Free;
end;
```

## Static Filters via Attributes

For filters that never change at runtime, use `TWhereClause` and `TWhereClauseParameter` attributes directly on the entity class:

```pascal
[TTable('Users')]
[TWhereClause('Active = :Active')]
[TWhereClauseParameter('Active', True)]
TActiveUser = class
```

Every query on `TActiveUser` will automatically include `WHERE Active = True`. These parameters are compile-time constants and cannot carry runtime values.

See [Entity Mapping](entities.md#where-clause-static-filters) for details.
