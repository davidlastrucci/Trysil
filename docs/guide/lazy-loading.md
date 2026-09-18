# Lazy Loading

Trysil supports deferred loading of related entities through `TTLazy<T>` and `TTLazyList<T>`, both defined in `Trysil.Lazy.pas`. Related data is loaded from the database only when first accessed, avoiding unnecessary queries for relations that may never be used.

## TTLazy\<T\> (Single Entity)

Use `TTLazy<T>` for a many-to-one relationship where a field references a single related entity.

### Entity Definition

```pascal
[TTable('Employees')]
[TSequence('EmployeesID')]
TEmployee = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TColumn('CompanyID')]
  FCompany: TTLazy<TCompany>;

  [TVersionColumn]
  [TColumn('VersionID')]
  FVersionID: TTVersion;

  function GetCompany: TCompany;
  procedure SetCompany(const AValue: TCompany);
public
  property ID: TTPrimaryKey read FID;
  property Company: TCompany read GetCompany write SetCompany;
end;
```

### Getter and Setter

```pascal
function TEmployee.GetCompany: TCompany;
begin
  Result := FCompany.Entity;
end;

procedure TEmployee.SetCompany(const AValue: TCompany);
begin
  FCompany.Entity := AValue;
end;
```

### Behavior

- The related entity is loaded on the first access to `.Entity`. Subsequent accesses return the cached instance.
- Setting `.Entity` to a different object updates the internal foreign key ID and frees the previous entity (unless the identity map holds entities of its type).
- **Assignment does not transfer ownership.** Without the identity map, `.Entity := AValue` stores a *clone* of the assigned entity: the lazy field owns its copy and the caller keeps owning the instance it passed in, so neither is freed twice. With the identity map active and a type with a primary key and no `[TJoin]`, the lazy field keeps the instance itself, whatever it is, because the map would hold an entity of that type (a type with joins or without a key is cloned as above): assign only an entity the context read or created, which the map does own. A clone from `CloneEntity` or `OldEntity`, a row of a raw select or an object you built yourself is kept as it is and freed by nobody, and if you free it the lazy field is left on freed memory. An entity someone else frees does the same with nothing you do: a clone a `TTSession<T>` holds in `Entities`, or the `OldEntity` property of an event, leaves the lazy field on freed memory as soon as the session or the event is destroyed. It is a declared limit of this release. [Who frees what](context.md#who-frees-what) has every case.
- **A value read through the lazy field goes with the entity it replaces.** Without the identity map, or for a type the map does not hold, `LNext := E.Manager.Entity.Manager.Entity; E.Manager.Entity := LNext` stores a clone of `LNext` and then frees the old manager, and `LNext` with it: it belonged to the old manager's lazy member, not to you. After the assignment read `E.Manager.Entity` again, not `LNext`.
- When the `ID` property on the lazy field changes, the cached entity is cleared and will be reloaded on next access. When the identity map does not hold its type it is also **freed**, so a pointer to it read before is dangling.
- **Soft-deleted parents resolve.** The lazy load uses `Get<T>(ID, True)`, so a parent that has been soft-deleted still resolves through its foreign key — a child referencing a logically deleted master is not left with a dangling `nil` reference.

### IsLoaded

`IsLoaded` reports whether the reference is **already in memory**, without triggering the load:

```pascal
if LEmployee.Company.IsLoaded then
  ShowName(LEmployee.Company.Entity.Name);
```

It is the only way to inspect the state of a lazy field without causing the very query you are trying to avoid — reading `.Entity` to find out whether it is loaded loads it. Use it when deciding whether touching a relation is worth it (a grid that must not trigger N+1 queries), and in tests, where it is the assertion for "no query was issued".

`TTLazyList<T>` does not expose `IsLoaded`.

## TTLazyList\<T\> (Collection)

Use `TTLazyList<T>` for a one-to-many relationship where a parent entity has multiple children.

### Entity Definition

```pascal
[TTable('Departments')]
[TSequence('DepartmentsID')]
TDepartment = class
strict private
  [TPrimaryKey]
  [TColumn('ID')]
  FID: TTPrimaryKey;

  [TColumn('DepartmentID')]
  FEmployees: TTLazyList<TEmployee>;

  function GetEmployees: TTList<TEmployee>;
public
  property ID: TTPrimaryKey read FID;
  property Employees: TTList<TEmployee> read GetEmployees;
end;
```

### Getter

```pascal
function TDepartment.GetEmployees: TTList<TEmployee>;
begin
  Result := FEmployees.List;
end;
```

### Behavior

- The list is loaded on first access. A SELECT query is executed with a filter matching the foreign key column to the parent's ID.
- `AddEntity` creates a new entity via the context and adds it to the list:

```pascal
LNewEmployee := FEmployees.AddEntity;
LNewEmployee.Firstname := 'Alice';
```

- When the parent's ID changes, the cached list is invalidated and will be reloaded on next access.

### Invalidation and Sessions

The cached list carries an `IsValid` flag. When it is cleared -- for example when the parent's ID changes -- the next access re-runs the SELECT and refills the same list instance in place.

This integrates with the Unit of Work: the collection is a `TTList<T>`, so you pass it straight to `CreateSession<T>`. When the session's `ApplyChanges` completes, it invalidates the underlying lazy list automatically, so the in-memory collection reflects the persisted state on the next read:

```pascal
var LSession := LContext.CreateSession<TEmployee>(LDepartment.Employees);
try
  LSession.Entities[0].Lastname := 'Updated';
  LSession.Update(LSession.Entities[0]);
  LSession.ApplyChanges;        // LDepartment.Employees is invalidated here
finally
  LSession.Free;
end;
```

## Important Notes

- **Context lifetime** -- Both `TTLazy<T>` and `TTLazyList<T>` hold a reference to the owning `TTContext`. The context must remain alive for as long as lazy fields may be accessed. Accessing a lazy field after the context is freed will cause an access violation.

- **Identity map interaction** -- An entity assigned through `.Entity` follows the rule under [Behavior](#behavior). When `UseIdentityMap` is `True` and the type has a primary key and no `[TJoin]`, lazy-loaded entities are not freed by the lazy wrapper (the identity map owns them); any other type the wrapper frees as without the map. When `UseIdentityMap` is `False`, the lazy wrapper owns and frees loaded entities on destruction or when the ID changes.

- **Used with TRelation** -- Lazy loading is typically combined with the `TRelation` attribute on the parent entity class to declare the referential integrity constraint:

```pascal
[TTable('Departments')]
[TRelation('Employees', 'DepartmentID', False)]
TDepartment = class
```

- **N+1 query pattern** -- Be aware that accessing lazy fields in a loop generates one query per entity. For bulk operations, consider loading related data upfront with a filtered `Select<T>` call.
