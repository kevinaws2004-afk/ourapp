# Database (SQLite)

> Physical schema. Conceptual model and rationale: [data_architecture.md](data_architecture.md). Decisions: ADR-002, ADR-011, ADR-012, ADR-013, ADR-017 to ADR-022, ADR-026.
>
> **Status per table:**
>
> | Table | Schema version | Phase | State |
> |---|---|---|---|
> | `app_preferences` | v1 | 1 | Implemented |
> | `activity_types`, `activity_fields`, `activity_logs`, `log_values` | v2 | 2 | Implemented |
> | Repeating Groups: `activity_fields.parent_field_id`, `log_group_items`, `log_values.group_item_id` | v3 (planned) | 3 | Designed (ADR-027) |
> | `plans` + `activity_logs.plan_id` | v4 (planned) | 4 | Designed (ADR-018) |
> | `focus_sessions` | planned | 5 | Designed |
> | `measurements` | planned | 6 | Designed |
>
> Implemented DDL lives in `lib/core/database/tables/activity_engine.drift` (activity engine) and `tables/app_preferences_table.dart`. If this document and those files ever disagree, the code is the truth and this document must be fixed in the same change.

---

## 1. Principles

1. SQLite is the single source of truth in V1 (ADR-002), accessed through drift (ADR-011).
2. **Generic schema.** No per-activity tables, and no dynamic columns for user fields (ADR-006, ADR-026).
3. **Two-level identity** (ADR-017): `internal_id INTEGER PRIMARY KEY` for joins and FKs; `public_id TEXT UNIQUE` (UUIDv7) for identity. `internal_id` never leaves the data layer.
4. **Typed first, JSON only for genuine structure** (ADR-019).
5. **Integrity in the database where it's cheap**: STRICT tables, FKs, CHECKs, partial unique indexes and triggers. The domain validates as well.
6. **Every index has a query justification** (§6), because indexes cost writes and storage.
7. All multi-row writes are transactions. All SQL lives in the data layer.

## 2. Conventions

| Concern | Convention |
|---|---|
| Table names | plural `snake_case`; Dart uses `camelCase` via drift |
| Table kind | Activity-engine tables are `STRICT` (SQLite enforces column types) |
| Primary key | `internal_id INTEGER PRIMARY KEY` (rowid alias, no `AUTOINCREMENT`; internal ids are local-only) |
| Public identity | `public_id TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36)`, UUIDv7 from `Uuid7IdGenerator`; immutable (trigger) |
| Foreign keys | `INTEGER` → `internal_id`; `ON DELETE RESTRICT`, except aggregate children (`log_values` → `ON DELETE CASCADE`) |
| Instants | `INTEGER` UTC epoch **milliseconds** (`*_at`) (ADR-013) |
| Calendar day | `local_date TEXT` `YYYY-MM-DD`, computed at write time from the instant and the device offset (ADR-013 refinement) |
| Durations | `duration_ms INTEGER` (ADR-021) |
| Booleans | `INTEGER CHECK (x IN (0,1))` |
| Enums | `TEXT` + `CHECK (x IN (...))` |
| JSON | `TEXT CHECK (json_valid(x))`, with `"v"` and stable IDs (ADR-019) |
| Timestamps | `created_at` set once; `updated_at` on every mutation, including soft delete/restore, from the injected `Clock` |
| Soft delete | `deleted_at INTEGER NULL` (ADR-022); hot indexes are partial `WHERE deleted_at IS NULL` |
| Exceptions | `app_preferences`: text `key` PK, `updated_at` only (ADR-012). `log_values`: no `public_id`, no `deleted_at` (aggregate child, ADR-017/022) |

Connection setup:
- `foreign_keys = ON` in `AppDatabase.migration.beforeOpen`, so it also applies in tests.
- `journal_mode = WAL` and `synchronous = NORMAL` in `openAppDatabaseConnection()`.
- The bundled SQLite is 3.53 (via `sqlite3` 3.x), which supports STRICT tables, partial indexes and JSON functions.

## 3. Schema

### 3.1 `app_preferences` (v1, implemented)
```sql
CREATE TABLE app_preferences (
  key        TEXT PRIMARY KEY NOT NULL,   -- 'theme_mode', 'onboarding_completed'
  value_json TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
```
An accepted exception (ADR-012): a fixed key set updated in place; "reset" writes the default value, and rows are never deleted.

### 3.2 `activity_types` (v2, implemented)
```sql
CREATE TABLE activity_types (
  internal_id       INTEGER PRIMARY KEY,
  public_id         TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  name              TEXT NOT NULL CHECK (length(trim(name)) > 0),
  icon_id           TEXT NOT NULL CHECK (length(icon_id) > 0),     -- icon registry key (ADR-024)
  color_key         TEXT NOT NULL CHECK (length(color_key) > 0),   -- design-system palette key
  description       TEXT,
  supports_timer    INTEGER NOT NULL DEFAULT 0 CHECK (supports_timer IN (0, 1)),
  supports_planning INTEGER NOT NULL DEFAULT 1 CHECK (supports_planning IN (0, 1)),
  sort_order        INTEGER NOT NULL DEFAULT 0,
  created_at        INTEGER NOT NULL,
  updated_at        INTEGER NOT NULL,
  deleted_at        INTEGER
) STRICT;
```
- `icon_id` and `color_key` are abstract keys, validated by the domain against the registries. There's no SQL CHECK list, so adding icons or colors needs no migration.
- No secondary index: the table holds dozens of rows, so `ORDER BY sort_order` sorts in memory for free (§6).

### 3.3 `activity_fields` (v2, implemented)
```sql
CREATE TABLE activity_fields (
  internal_id      INTEGER PRIMARY KEY,
  public_id        TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  activity_type_id INTEGER NOT NULL REFERENCES activity_types (internal_id) ON DELETE RESTRICT,
  name             TEXT NOT NULL CHECK (length(trim(name)) > 0),
  field_type       TEXT NOT NULL CHECK (field_type IN (
                     'text', 'number', 'boolean', 'single_select', 'multi_select',
                     'date', 'time', 'duration', 'rating', 'repeating_group')),
  dimension        TEXT CHECK (dimension IS NULL OR field_type = 'number'),
  position         INTEGER NOT NULL CHECK (position >= 0),
  required         INTEGER NOT NULL DEFAULT 0 CHECK (required IN (0, 1)),
  measurable       INTEGER NOT NULL DEFAULT 0 CHECK (measurable IN (0, 1)),
  config_json      TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(config_json)),
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  deleted_at       INTEGER,
  CHECK (measurable = 0 OR field_type IN ('number', 'rating', 'duration', 'boolean'))
) STRICT;

CREATE INDEX idx_activity_fields_type_position ON activity_fields (activity_type_id, position);
```
- `dimension` is relational because it is semantic: it decides how `normalized_value` is computed. It is locked once values exist. The default display unit is configuration (`config_json`).
- `repeating_group` is already allowed by the CHECK. Phase 3 adds `parent_field_id` for its sub-fields (ADR-027, §3.10).
- `position` is dense among active fields and rewritten in the same transaction on reorder. It's not UNIQUE, because a reorder would collide mid-transaction and deleted fields keep stale positions.

### 3.4 `activity_logs` (v2, implemented)
```sql
CREATE TABLE activity_logs (
  internal_id       INTEGER PRIMARY KEY,
  public_id         TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  activity_type_id  INTEGER NOT NULL REFERENCES activity_types (internal_id) ON DELETE RESTRICT,
  started_at        INTEGER NOT NULL,
  ended_at          INTEGER,
  duration_ms       INTEGER CHECK (duration_ms IS NULL OR duration_ms >= 0),
  tz_offset_minutes INTEGER NOT NULL CHECK (tz_offset_minutes BETWEEN -1080 AND 1080),
  local_date        TEXT NOT NULL CHECK (local_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  notes             TEXT,
  created_at        INTEGER NOT NULL,
  updated_at        INTEGER NOT NULL,
  deleted_at        INTEGER,
  CHECK (ended_at IS NULL OR ended_at >= started_at),
  CHECK (duration_ms IS NULL OR ended_at IS NULL OR duration_ms <= ended_at - started_at)
) STRICT;

CREATE INDEX idx_activity_logs_day
  ON activity_logs (local_date, started_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_activity_logs_type_day
  ON activity_logs (activity_type_id, local_date, started_at) WHERE deleted_at IS NULL;
```
- Actual elapsed duration is `duration_ms` (ADR-021). A manual entry has `started_at` + `duration_ms`; a timed activity (Phase 5) also has `ended_at`.
- `local_date` is the local calendar day of `started_at` at recording time (ADR-013 refinement). A midnight-crossing activity belongs to its start day.
- Phase 4 (schema v4) adds `plan_id INTEGER REFERENCES plans (internal_id)` with `ALTER TABLE ... ADD COLUMN`. SQLite allows this because the default is NULL, so no table rebuild is needed.

### 3.5 `log_values` (v2, implemented)
```sql
CREATE TABLE log_values (
  internal_id      INTEGER PRIMARY KEY,
  log_id           INTEGER NOT NULL REFERENCES activity_logs (internal_id) ON DELETE CASCADE,
  field_id         INTEGER NOT NULL REFERENCES activity_fields (internal_id) ON DELETE RESTRICT,
  text_value       TEXT,
  number_value     REAL,
  unit_code        TEXT,
  normalized_value REAL,
  boolean_value    INTEGER CHECK (boolean_value IS NULL OR boolean_value IN (0, 1)),
  date_value       TEXT CHECK (date_value IS NULL OR date_value GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  time_value       INTEGER CHECK (time_value IS NULL OR time_value BETWEEN 0 AND 1439),
  duration_ms      INTEGER CHECK (duration_ms IS NULL OR duration_ms >= 0),
  json_value       TEXT CHECK (json_value IS NULL OR json_valid(json_value)),
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  UNIQUE (log_id, field_id),
  CHECK ((text_value IS NOT NULL) + (number_value IS NOT NULL) + (boolean_value IS NOT NULL)
       + (date_value IS NOT NULL) + (time_value IS NOT NULL) + (duration_ms IS NOT NULL)
       + (json_value IS NOT NULL) = 1),
  CHECK ((number_value IS NULL) = (normalized_value IS NULL)),
  CHECK (unit_code IS NULL OR number_value IS NOT NULL)
) STRICT;

CREATE INDEX idx_log_values_field_normalized ON log_values (field_id, normalized_value);
```
Storage per field type ([data_architecture.md §4](data_architecture.md#4-field-type-catalog)):

| Field type | Column(s) |
|---|---|
| text | `text_value` |
| number | `number_value` (as entered), `unit_code` (only if the field has a dimension), `normalized_value` (canonical; equals `number_value` when unitless) |
| boolean | `boolean_value` |
| single_select | `text_value` = option ID |
| multi_select | `json_value` `{"v":1,"optionIds":[…]}` |
| date | `date_value` |
| time | `time_value` (minutes since local midnight) |
| duration | `duration_ms` |
| rating | `number_value` + `normalized_value` (integer 1..max) |
| repeating_group | No row of its own. Items are `log_group_items` rows, and their sub-field values are ordinary typed rows with `group_item_id` (Phase 3, ADR-027, §3.10) |

Empty values have no row. Values are replaced with the log on edit, diffed by field, so unchanged rows keep their `internal_id` and `created_at`.

### 3.6 Triggers (v2, implemented)

Historical-integrity rules that SQL can enforce cheaply (ADR-026):

| Trigger | Rule |
|---|---|
| `trg_log_values_insert_check`, `trg_log_values_update_check` | The value's field belongs to the log's activity type. The populated column matches the field's type. `unit_code` is present exactly when a number field has a dimension. |
| `trg_activity_fields_semantics_locked` | `field_type`/`dimension` can't change once any value exists for the field |
| `trg_activity_fields_owner_immutable` | A field can't move to another activity type |
| `trg_activity_logs_type_immutable` | A log's activity type can't change |
| `trg_*_public_id_immutable` (types, fields, logs) | `public_id` never changes |

Each raises `RAISE(ABORT, '<code>')`. The repository translates the code to `ValidationException` (ADR-025). Cost: one or two primary-key lookups per value write, which is negligible at user-paced write rates.

### 3.7 `plans` (designed, Phase 4 / schema v4, ADR-018)
```sql
CREATE TABLE plans (
  internal_id      INTEGER PRIMARY KEY,
  public_id        TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  plan_date        TEXT NOT NULL CHECK (plan_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  activity_type_id INTEGER REFERENCES activity_types (internal_id) ON DELETE RESTRICT,  -- NULL = Task
  title            TEXT NOT NULL CHECK (length(trim(title)) > 0),
  notes            TEXT,
  planned_start_at INTEGER,
  planned_end_at   INTEGER,
  sort_order       INTEGER NOT NULL DEFAULT 0,
  status           TEXT NOT NULL DEFAULT 'planned'
                   CHECK (status IN ('planned', 'completed', 'skipped', 'cancelled')),
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  deleted_at       INTEGER,
  CHECK (planned_end_at IS NULL OR planned_start_at IS NULL OR planned_end_at >= planned_start_at),
  CHECK (status <> 'completed' OR activity_type_id IS NULL)   -- activity-plan completion is derived
) STRICT;
CREATE INDEX idx_plans_day ON plans (plan_date, sort_order) WHERE deleted_at IS NULL;
CREATE INDEX idx_plans_type_day ON plans (activity_type_id, plan_date)
  WHERE deleted_at IS NULL AND activity_type_id IS NOT NULL;

ALTER TABLE activity_logs ADD COLUMN plan_id INTEGER REFERENCES plans (internal_id) ON DELETE RESTRICT;
CREATE INDEX idx_activity_logs_plan ON activity_logs (plan_id) WHERE plan_id IS NOT NULL;
```
Pending confirmation: `planned_duration_ms INTEGER CHECK (planned_duration_ms IS NULL OR (planned_duration_ms > 0 AND planned_end_at IS NULL))` (ADR-018 sub-item).

### 3.8 `focus_sessions` (designed, Phase 5)
```sql
CREATE TABLE focus_sessions (
  internal_id        INTEGER PRIMARY KEY,
  public_id          TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  activity_type_id   INTEGER NOT NULL REFERENCES activity_types (internal_id) ON DELETE RESTRICT,
  plan_id            INTEGER REFERENCES plans (internal_id) ON DELETE RESTRICT,
  activity_log_id    INTEGER REFERENCES activity_logs (internal_id) ON DELETE RESTRICT,
  state              TEXT NOT NULL CHECK (state IN ('running', 'paused', 'finished', 'discarded')),
  started_at         INTEGER NOT NULL,
  paused_at          INTEGER,
  paused_duration_ms INTEGER NOT NULL DEFAULT 0 CHECK (paused_duration_ms >= 0),
  ended_at           INTEGER,
  duration_ms        INTEGER CHECK (duration_ms IS NULL OR duration_ms >= 0),
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER,
  CHECK ((state = 'paused') = (paused_at IS NOT NULL)),
  CHECK ((state = 'finished') = (activity_log_id IS NOT NULL AND ended_at IS NOT NULL AND duration_ms IS NOT NULL))
) STRICT;
-- At most one active session (OQ-11), enforced by the database:
CREATE UNIQUE INDEX ux_focus_sessions_one_active
  ON focus_sessions (state IN ('running', 'paused')) WHERE state IN ('running', 'paused') AND deleted_at IS NULL;
```

### 3.9 `measurements` (designed, Phase 6)
```sql
CREATE TABLE measurements (
  internal_id       INTEGER PRIMARY KEY,
  public_id         TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  measurement_type  TEXT NOT NULL,          -- fixed V1 keys (OQ-09), validated in the domain
  value             REAL NOT NULL,          -- as entered
  unit_code         TEXT NOT NULL,          -- unit registry code (ADR-020)
  normalized_value  REAL NOT NULL,          -- canonical unit of the dimension, computed at write
  recorded_at       INTEGER NOT NULL,
  tz_offset_minutes INTEGER NOT NULL,
  local_date        TEXT NOT NULL,
  notes             TEXT,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
) STRICT;
CREATE INDEX idx_measurements_type_day
  ON measurements (measurement_type, local_date, recorded_at) WHERE deleted_at IS NULL;
```

### 3.10 Repeating Groups (designed, Phase 3, ADR-027)

Schema v3 changes:
```sql
-- Sub-fields of a Repeating Group are ordinary field rows.
ALTER TABLE activity_fields ADD COLUMN parent_field_id INTEGER
  REFERENCES activity_fields (internal_id) ON DELETE RESTRICT;
CREATE INDEX idx_activity_fields_parent ON activity_fields (parent_field_id) WHERE parent_field_id IS NOT NULL;

-- One row per item (an exercise, a set, a checklist item).
CREATE TABLE log_group_items (
  internal_id    INTEGER NOT NULL PRIMARY KEY,
  public_id      TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  log_id         INTEGER NOT NULL REFERENCES activity_logs (internal_id) ON DELETE CASCADE,
  field_id       INTEGER NOT NULL REFERENCES activity_fields (internal_id) ON DELETE RESTRICT, -- the group field
  parent_item_id INTEGER REFERENCES log_group_items (internal_id) ON DELETE CASCADE,         -- nested group
  position       INTEGER NOT NULL CHECK (position >= 0),
  created_at     INTEGER NOT NULL,
  updated_at     INTEGER NOT NULL
) STRICT;
CREATE INDEX idx_log_group_items_log ON log_group_items (log_id, parent_item_id, position);

-- log_values is rebuilt (12-step) to add group_item_id and replace the table-level
-- UNIQUE (log_id, field_id) with two partial unique indexes:
--   group_item_id INTEGER REFERENCES log_group_items (internal_id) ON DELETE CASCADE
CREATE UNIQUE INDEX ux_log_values_top_level ON log_values (log_id, field_id) WHERE group_item_id IS NULL;
CREATE UNIQUE INDEX ux_log_values_item ON log_values (group_item_id, field_id) WHERE group_item_id IS NOT NULL;
```
Rules, enforced by triggers and the domain:
- A sub-field's parent must be a `repeating_group` field of the same activity type, and nesting is at most two levels.
- An item's field must be a `repeating_group` belonging to the log's type. A nested item's field must be a sub-field of its parent item's field.
- A value with `group_item_id` must be for a sub-field of that item's field. A value without one must be for a top-level field.
- Items have stable `public_id`s, so edits and reorders keep identity. Items and their values are aggregate children of the log: no soft delete, and they cascade with the log.
- Analytics example: the max weight per day for "Chest Press" joins set values (Weight field) → their set item → parent exercise item → exercise-name value, then the log by `local_date`. These are all integer joins on indexed columns; Phase 3 verifies them with `EXPLAIN QUERY PLAN` and may add a `(field_id, text_value)` index if the name filter needs one.

## 4. Relationships

| From | To | Cardinality | On target soft-delete |
|---|---|---|---|
| activity_fields.activity_type_id | activity_types | many → 1 | fields hidden with the type |
| activity_logs.activity_type_id | activity_types | many → 1 | logs stay visible (archived type) |
| log_values.log_id | activity_logs | many → 1 (CASCADE on purge) | values follow the log |
| log_values.field_id | activity_fields | many → 1 | values kept; shown as a removed field |
| plans.activity_type_id *(Phase 4)* | activity_types | many → 0..1 | plan stays |
| activity_logs.plan_id *(Phase 4)* | plans | many → 0..1 | link retained |

## 5. Transactions (atomic)

| Operation | Rows |
|---|---|
| Create/update activity type | `activity_types` + insert/update/soft-delete `activity_fields` + position rewrite |
| Log activity / update log | `activity_logs` + upsert/delete `log_values` |
| Delete/restore log or type | the row's `deleted_at` + `updated_at` |
| Install template | type + fields |

## 6. Indexes and query plans

Every index exists for a named hot path (owner performance requirement). The repository tests check the important query plans with `EXPLAIN QUERY PLAN`.

| Index | Serves | Query shape |
|---|---|---|
| `activity_types.public_id` (UNIQUE, implicit) | Resolve a route/domain ID | `WHERE public_id = ?` |
| — (none on `activity_types` otherwise) | Active types list | Tiny table; a full scan + in-memory sort is cheaper than index maintenance |
| `idx_activity_fields_type_position` | Ordered fields of a type (form renderer, builder; includes removed fields for history) | `WHERE activity_type_id = ? ORDER BY position` |
| `idx_activity_logs_day` (partial) | **Today / logs for a date**, in time order | `WHERE local_date = ? AND deleted_at IS NULL ORDER BY started_at` |
| `idx_activity_logs_type_day` (partial) | **Activity history** (newest first, keyset), **analytics ranges per type** | `WHERE activity_type_id = ? AND deleted_at IS NULL [AND local_date BETWEEN ? AND ?] ORDER BY local_date DESC, started_at DESC` |
| `log_values UNIQUE (log_id, field_id)` | **Values for a log** (prefix `log_id`), and the per-log lookup in analytics joins | `WHERE log_id IN (…)` |
| `idx_log_values_field_normalized` | **Historical values for a field** (min/max/PR), and the "field has values?" check behind the semantics-lock trigger | `WHERE field_id = ? [ORDER BY normalized_value]`, `EXISTS (… WHERE field_id = ?)` |
| *(Phase 3)* `idx_log_group_items_log`, `ux_log_values_item`, `idx_activity_fields_parent` | A log's items in order; an item's values; sub-fields of a group | see §3.10 |
| *(Phase 4)* `idx_plans_day`, `idx_plans_type_day`, `idx_activity_logs_plan` | Plans for a date (ordered); plans by type and date; derived plan completion | see §3.7 |
| *(Phase 6)* `idx_measurements_type_day` | Measurements over date ranges | `WHERE measurement_type = ? AND local_date BETWEEN ? AND ?` |

Rules:
- Queries on partial indexes must repeat the index predicate (`deleted_at IS NULL`). The shared active-row helper always adds it.
- Repositories load a page of logs, then **all their values in one `log_id IN (…)` query**. There are no N+1 query patterns.
- Analytics over a field and date range drive from `idx_activity_logs_type_day`, then look up each log's value through `UNIQUE (log_id, field_id)`.
- There are no JSON predicates on hot paths.

## 7. Migrations

1. **Versioning:** SQLite `user_version` through drift's `schemaVersion`. v1 = `app_preferences`; **v2 = activity engine** (§3.2–3.6); v3 = Repeating Groups (Phase 3, §3.10); v4 = plans (Phase 4, §3.7).
2. **Forward-only, append-only.** A shipped migration is never edited.
3. Each step is transactional and leaves the DB valid. SQLite table rebuilds (the 12-step pattern) are used only when `ALTER TABLE` can't express a change.
4. **drift workflow (implemented):**
   1. Edit the schema (`tables/*.drift`, `tables/*.dart`).
   2. Bump `schemaVersion`.
   3. `dart run build_runner build -d`.
   4. `dart run drift_dev make-migrations`. This exports `drift_schemas/app_database/drift_schema_vN.json` and regenerates the step helpers (`lib/core/database/app_database.steps.dart`) and migration tests (`test/drift/app_database/`).
   5. Add the `fromXToY` step in `AppDatabase.migration`.
   6. Commit everything.
5. **Tests:** generated tests verify each step against the exported schema snapshots. Hand-written tests verify that data survives (e.g. v1 preferences survive v1→v2).
6. Unknown or newer on-disk versions throw `MigrationException`, which shows the startup failure screen. The database is never deleted or recreated.
7. JSON payload evolution (`"v"`) is handled by tolerant domain decoders; bulk rewrites are optional.
8. User changes to activity types and fields are **data**, never migrations.

## 8. Integrity checklist

Enforced in the DB (CHECK/FK/trigger) **and** the domain:
- one value column per row, matching the field type
- the value's field belongs to the log's type
- field semantics locked after first value
- `ended_at ≥ started_at`, and `duration_ms ≤ ended_at − started_at`
- immutable `public_id`
- unit present exactly for dimensioned numbers

Domain only:
- unit belongs to the field's dimension
- select option exists and isn't archived for new values
- required fields present
- number/rating ranges
- `icon_id`/`color_key` exist in the registries
- duplicate active field names within a type are rejected

## 9. Size & performance expectations

~10–50k logs and 100k–500k value rows over several years (§8). Every hot path is an indexed integer join or a range scan. Budgets: [performance.md](../development/performance.md).
