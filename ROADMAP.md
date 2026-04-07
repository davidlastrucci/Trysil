# Roadmap

## v1.0 — Stabilization (current)

- Semantic versioning and first GitHub release
- Public roadmap
- Good first issues for community contributions

## v1.1 — Raw SQL

- `TTContext.RawSelect<T>('SELECT ...')` — map result sets to read-only DTOs (Data Transfer Objects) via RTTI
- Enables complex JOINs across multiple tables without falling back to direct FireDAC access
- DTOs are plain classes with `[TColumn]` attributes — no identity map, no change tracking, no persistence

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
