# Database Rules (AI)

> Rationale: [database.md](../../docs/architecture/database.md), [data_architecture.md](../../docs/architecture/data_architecture.md). Decisions: ADR-011–013, ADR-017–022, ADR-026.

1. Never create per-activity tables (`gym_logs`, `reading_logs`, …) or dynamic columns for user fields. Use `activity_types` / `activity_fields` / `activity_logs` / `log_values`.
2. Table definitions live in `core/database/tables/` (`activity_engine.drift` for the engine: STRICT tables, CHECKs, partial indexes, triggers). Queries live in repositories in `features/*/data/`. No SQL anywhere else.
3. **Two-level identity (ADR-017):** `internal_id INTEGER PRIMARY KEY` for all FKs and joins; `public_id TEXT UNIQUE` (UUIDv7 from `IdGenerator`, generated in the domain/use case) for identity. `internal_id` never leaves the data layer. Domain, routes, JSON and exports use `public_id` only. `log_values` (aggregate child) has no `public_id`.
4. Instants: UTC epoch-ms INTEGER. Calendar lookups use an explicit `local_date` TEXT (`YYYY-MM-DD`) computed at write time from the `Clock` offset, plus `tz_offset_minutes` (ADR-013).
5. User-owned entities have `created_at`, `updated_at` (every mutation) and `deleted_at`. Exceptions: `log_values` and `log_group_items` (no `deleted_at`; aggregate children of their log) and `app_preferences` (text key, `updated_at` only, ADR-012).
6. Default queries exclude deleted rows using the shared `isActive(table.deletedAt)` predicate (it also lets SQLite use the partial indexes). Never hard-delete user data in V1.
7. **Typed values (ADR-019):** exactly one of `text_value`, `number_value` (+ `unit_code`, `normalized_value`), `boolean_value`, `date_value`, `time_value`, `duration_ms`, `json_value`, chosen by field type. JSON only for Multi Select. Empty values have no row. Repeating Groups are **relational** (ADR-027): sub-fields with `parent_field_id`, `log_group_items` rows, item values with `group_item_id` (schema v3, implemented). A group has no value row. Edits diff items by `public_id` (keep identity) and values per scope. Never store them as JSON.
8. JSON payloads carry `"v"`, use stable IDs (never display names), and decoders accept all past versions.
9. **Units (ADR-020):** store the user's `unit_code` and the as-entered number, and compute `normalized_value` (canonical unit) **at write time**. Unit codes are permanent.
10. Durations are `duration_ms` INTEGER. The activity's actual elapsed time is `activity_logs.duration_ms`; planned duration lives only on plans: the time range or `planned_duration_ms`, never both (ADR-018/021). Any plan can store `completed` (schema v8, ADR-040); without it, a record with `plan_id` makes an activity plan in progress on its day and done after it (`Plan.effectiveStatus`).
11. Multi-row writes are transactions (type + fields, log + values, using a built-in activity).
12. Wrap every public repository method in `guardStorage` so raw drift/SQLite errors become `AppException`s (ADR-025).
13. Live queries use `reactiveQuery(db.tableUpdates(TableUpdateQuery.onAllTables([...])), load)`. Never watch a constant trigger query (drift won't re-emit unchanged results). Load lists plus children in two queries (no N+1).
14. Field type and dimension are immutable once values exist, and fields can't change owner. This is enforced by the domain **and** DB triggers; don't bypass or drop them. Removed fields/options are soft-deleted/archived, never erased.
15. Every index needs a query justification ([database.md §6](../../docs/architecture/database.md#6-indexes-and-query-plans)). Verify new hot paths with `EXPLAIN QUERY PLAN` in tests.
16. Every schema change: bump `schemaVersion`, `build_runner`, `drift_dev make-migrations`, add the `fromXToY` step, add migration tests, and update database.md, all in the same change. Never edit a shipped migration; a failed migration never deletes the database.
17. Don't add sync columns or outbox tables in V1.
