# Orders Model

An entity model example for a typical order management domain. This is not a runnable demo -- it provides a reference for modeling complex relationships with Trysil.

## Entities

| Entity | Table | Description |
|---|---|---|
| `TCustomer` | Customers | Company name, address, email |
| `TBrand` | Brands | Product brand |
| `TProduct` | Products | Description, price, lazy-loaded brand |
| `TOrder` | Orders | Date, lazy-loaded customer, detail list |
| `TOrderDetail` | OrderDetails | Product, quantity, price, status tracking |

## Relationships

```
TCustomer ──< TOrder ──< TOrderDetail >── TProduct >── TBrand
```

- `TOrder.Customer` -- `TTLazy<TCustomer>` (loaded on demand)
- `TOrder.Detail` -- `TTLazyList<TOrderDetail>` (loaded on demand)
- `TProduct.Brand` -- `TTLazy<TBrand>` (loaded on demand)
- `TOrderDetail.Product` -- `TTLazy<TProduct>` (loaded on demand)

## View Models

Three view entities filter order details by fulfillment status:

| View Entity | Description |
|---|---|
| `TProductsToBeProduced` | Items not yet produced |
| `TProductsToBeDelivered` | Items produced but not delivered |
| `TProductsToBeCashed` | Items delivered but not invoiced |

## Key Patterns Demonstrated

- **Lazy loading** with `TTLazy<T>` and `TTLazyList<T>`
- **`[TRelation]`** attribute for parent-child relationships
- **`[TDetailColumn]`** for detail list mapping
- **Nullable fields** with `TTNullable<TDateTime>` for optional dates
- **Validation** with `[TRequired]`, `[TMaxLength]`, `[TGreater]`
- **View entities** using `[TWhereClause]` for status-based filtering
