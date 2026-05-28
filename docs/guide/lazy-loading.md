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
- Setting `.Entity` to a different object updates the internal foreign key ID and frees the previous entity (unless the identity map is active).
- When the `ID` property on the lazy field changes, the cached entity is cleared and will be reloaded on next access.

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

- The list is loaded on the first access to `.List`. A SELECT query is executed with a filter matching the foreign key column to the parent's ID.
- `AddEntity` creates a new entity via the context and adds it to the list:

```pascal
LNewEmployee := FEmployees.AddEntity;
LNewEmployee.Firstname := 'Alice';
```

- When the parent's ID changes, the cached list is freed and will be reloaded on next access.

## Important Notes

- **Context lifetime** -- Both `TTLazy<T>` and `TTLazyList<T>` hold a reference to the owning `TTContext`. The context must remain alive for as long as lazy fields may be accessed. Accessing a lazy field after the context is freed will cause an access violation.

- **Identity map interaction** -- When `UseIdentityMap` is `True`, lazy-loaded entities are not freed by the lazy wrapper (the identity map owns them). When `UseIdentityMap` is `False`, the lazy wrapper owns and frees loaded entities on destruction or when the ID changes.

- **Used with TRelation** -- Lazy loading is typically combined with the `TRelation` attribute on the parent entity class to declare the referential integrity constraint:

```pascal
[TTable('Departments')]
[TRelation('Employees', 'DepartmentID', False)]
TDepartment = class
```

- **N+1 query pattern** -- Be aware that accessing lazy fields in a loop generates one query per entity. For bulk operations, consider loading related data upfront with a filtered `Select<T>` call.
