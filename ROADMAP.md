# Roadmap

## ~~v1.0 — Stabilization~~ (Completed)

- ~~Semantic versioning and first GitHub release~~
- ~~Public roadmap~~
- ~~Good first issues for community contributions~~

## ~~v1.1 — Raw SQL~~ (Completed)

- **`[TJoin]` attributes**: declarative JOIN support (3 overloads: simple, self-join with alias, chained) — no raw SQL needed for most multi-table queries
- **`TTContext.RawSelect<T>`**: for queries that attributes can't express (subquery, UNION, GROUP BY, aggregations) — maps raw SQL results to DTO classes via `[TColumn]`
- Both approaches: read-only, skip identity map, fully backward compatible

## v1.2 — Commit Changes Event

- `TTContext.OnCommitChanges` — event fired after a transaction commit with a summary of all changes
- Each change carries: entity class, action (insert/update/delete), entity ID, old values, new values
- Enables event-driven replication, audit trails, and cache invalidation on external systems

## v1.3 — Batch Operations

- Native batch insert for data coming from external sources (file imports, system synchronization)
- Performance improvement for bulk operations

## v1.4 — Schema Awareness

- Schema diff: compare entity definitions against existing database schema
- Generate DDL scripts (CREATE/ALTER)

## Backlog

- Async support
- Query cache with invalidation
- Projections / DTO mapping
- HTTP enhancements (rate limiting, OpenAPI)
- InterBase, MySQL/MariaDB drivers
