# Expressions

Console demo that explains the **algebraic expression API** for filtering
(`Trysil.Filter.Expression.pas`) side by side with the fluent
`TTFilterBuilder<T>`.

| | |
|---|---|
| **Type** | Console app |
| **Database** | SQLite (auto-created, zero config) |
| **Focus** | `TTProperty` / `TTExpression`, grouped WHERE, `T<Entity>Properties` |

## What it shows

The program seeds a small `People` table and runs a series of filters. For
each one it prints the **generated WHERE clause** (`TTFilter.Where`) and the
matching rows, so you can see exactly what SQL each expression produces.

1. **Simple parametric comparison** - `Age >= 18`.
2. **The grouping problem** - `(City = 'Roma' or City = 'Milano') and Age >= 30`.
   The flat fluent chain produces `City = :p0 OR City = :p1 AND Age >= :p2`,
   which SQL reads as `Roma OR (Milano AND Age>=30)` - the wrong result. The
   expression form adds explicit parentheses and gets it right.
3. **`Between` / `InValues` / `Like` / `IsNull`**.
4. **`not (...)`** and nested expressions.
5. **`OrderByDesc(TTProperty)`** - type-safe ordering.

Every expression uses the `TPersonProperties` companion record (the same shape
the Trysil Expert generates), so column names are checked at compile time
instead of being passed as strings.

## Key point

The expression API always compares a column to a **value** (a bound
parameter). Column-to-column comparisons (`Importo <> AltroValore`) are not
expressible here - for those build a raw `TTFilter.Create('...')`.

## Run

Open `Demo.dproj` in Delphi, build, and run. The database
`Expressions.db` is recreated on every launch, so the output is always
deterministic. No external database or configuration is required.
