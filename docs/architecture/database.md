# Database (SQLite)

> Physical schema. Conceptual model and rationale: [data_architecture.md](data_architecture.md). Decisions: ADR-002, ADR-011, ADR-012, ADR-013, ADR-017 to ADR-022, ADR-026.
>
> **Status per table:**
>
> | Table | Schema version | Phase | State |
> |---|---|---|---|
> | `app_preferences` | v1 | 1 | Implemented |
> | `activity_types`, `activity_fields`, `activity_logs`, `log_values` | v2 | 2 | Implemented |
> | Repeating Groups: `activity_fields.parent_field_id`, `log_group_items`, `log_values.group_item_id` | v3 | 3 | Implemented (ADR-027) |
> | `plans` + `activity_logs.plan_id` | v4 | 4 | Implemented (ADR-018) |
> | `focus_sessions` | v5 | 5 | Implemented (ADR-031) |
> | `measurements`, `insight_charts` | v6 | 6 | Implemented (ADR-034) |
> | `plan_series` + `plans.series_id` | v7 | Rework step 3 | Implemented (ADR-036) |
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

### 3.3 `activity_fields` (v2; `parent_field_id` added in v3)
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
  parent_field_id  INTEGER REFERENCES activity_fields (internal_id) ON DELETE RESTRICT, -- v3, §3.10
  CHECK (measurable = 0 OR field_type IN ('number', 'rating', 'duration', 'boolean'))
) STRICT;

CREATE INDEX idx_activity_fields_type_position ON activity_fields (activity_type_id, position);
```
- `dimension` is relational because it is semantic: it decides how `normalized_value` is computed. It is locked once values exist. The default display unit is configuration (`config_json`).
- `parent_field_id` (v3) points a Repeating Group's sub-fields at their group (ADR-027, §3.10). `position` is per parent scope.
- `config_json` keys: text `multiline`, `suggest` (offer previous values); group `itemLabel`; number `decimals`, `min`, `max`, `defaultUnit`, `summary` (`average` / `latest`; absent = total) and `better` (`lower` / `neither`; absent = higher) (ADR-043).
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
- `plan_id` (v4) links a record to the plan it fulfils (ADR-018). It was added with `ALTER TABLE ... ADD COLUMN` (nullable, no default), so no rebuild. It's set on create and never changed by the app.

### 3.5 `log_values` (v2; rebuilt in v3)
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
  group_item_id    INTEGER REFERENCES log_group_items (internal_id) ON DELETE CASCADE, -- v3, §3.10
  CHECK ((text_value IS NOT NULL) + (number_value IS NOT NULL) + (boolean_value IS NOT NULL)
       + (date_value IS NOT NULL) + (time_value IS NOT NULL) + (duration_ms IS NOT NULL)
       + (json_value IS NOT NULL) = 1),
  CHECK ((number_value IS NULL) = (normalized_value IS NULL)),
  CHECK (unit_code IS NULL OR number_value IS NOT NULL)
) STRICT;

CREATE INDEX idx_log_values_field_normalized ON log_values (field_id, normalized_value);
CREATE INDEX idx_log_values_log ON log_values (log_id, field_id);
CREATE UNIQUE INDEX ux_log_values_top_level ON log_values (log_id, field_id) WHERE group_item_id IS NULL;
CREATE UNIQUE INDEX ux_log_values_item ON log_values (group_item_id, field_id) WHERE group_item_id IS NOT NULL;
```
The v2 table-level `UNIQUE (log_id, field_id)` was replaced in v3 by the two partial unique indexes (one value per field per scope). `idx_log_values_log` serves the "all values of these logs" read.

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
| repeating_group | No row of its own. Items are `log_group_items` rows, and their sub-field values are ordinary typed rows with `group_item_id` (ADR-027, §3.10) |

Empty values have no row. On edit, values are diffed by field within each scope (top level, or one item), and items are diffed by `public_id`. Unchanged rows keep their `internal_id` and `created_at`. Removed items are deleted with their child items and values (cascade).

### 3.6 Triggers (v2, extended in v3–v6)

Historical-integrity rules that SQL can enforce cheaply (ADR-026):

| Trigger | Rule |
|---|---|
| `trg_log_values_insert_check`, `trg_log_values_update_check` | The value's field belongs to the log's activity type. The populated column matches the field's type (a `repeating_group` never has a value row). `unit_code` is present exactly when a number field has a dimension. v3: the value is in its field's scope (`log_value_scope_mismatch`). |
| `trg_activity_fields_semantics_locked` | `field_type`/`dimension` can't change once any value, item or sub-field exists for the field |
| `trg_activity_fields_parent_check` (v3) | A sub-field's parent is a `repeating_group` of the same type; a group nested in a group can't contain another group (`activity_field_parent_invalid`) |
| `trg_activity_fields_parent_immutable` (v3) | A field can't move to another group |
| `trg_log_group_items_insert_check` (v3) | An item's field is a group of the log's type, and its parent item belongs to the parent group in the same log (`group_item_field_invalid`, `group_item_parent_invalid`) |
| `trg_log_group_items_structure_immutable` (v3) | An item's `public_id`, log, field and parent never change (only `position`) |
| `trg_activity_logs_plan_check_insert/_update` (v4) | A record's plan has the record's activity type; never a task (`log_plan_mismatch`) |
| `trg_plans_type_locked` (v4) | A plan with records keeps its activity type (`plan_type_locked`, translated to `ValidationException`) |
| `trg_plans_public_id_immutable` (v4) | `public_id` never changes |
| `trg_focus_sessions_plan_check` (v5) | A session's plan is for its activity (`focus_plan_mismatch`) |
| `trg_focus_sessions_public_id_immutable` (v5), `trg_measurements_public_id_immutable` (v6) | `public_id` never changes |
| `trg_activity_fields_owner_immutable` | A field can't move to another activity type |
| `trg_activity_logs_type_immutable` | A log's activity type can't change |
| `trg_*_public_id_immutable` (types, fields, logs) | `public_id` never changes |

Each raises `RAISE(ABORT, '<code>')`. `activity_field_semantics_locked` is user-reachable, so the repository translates it to `ValidationException` (ADR-025). The other codes are prevented by domain validation first; if one fires it surfaces as a `StorageException` (a bug). Cost: one or two primary-key lookups per value write, which is negligible at user-paced write rates.

### 3.7 `plans` (v4, implemented, ADR-018)
```sql
CREATE TABLE plans (
  internal_id         INTEGER NOT NULL PRIMARY KEY,
  public_id           TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  plan_date           TEXT NOT NULL CHECK (plan_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  activity_type_id    INTEGER REFERENCES activity_types (internal_id) ON DELETE RESTRICT,  -- NULL = Task
  title               TEXT NOT NULL CHECK (length(trim(title)) > 0),
  notes               TEXT,
  planned_start_at    INTEGER,
  planned_end_at      INTEGER,
  planned_duration_ms INTEGER,
  sort_order          INTEGER NOT NULL DEFAULT 0,
  status              TEXT NOT NULL DEFAULT 'planned'
                      CHECK (status IN ('planned', 'completed', 'skipped', 'cancelled')),
  created_at          INTEGER NOT NULL,
  updated_at          INTEGER NOT NULL,
  deleted_at          INTEGER,
  CHECK (planned_end_at IS NULL OR planned_start_at IS NOT NULL),
  CHECK (planned_end_at IS NULL OR planned_end_at >= planned_start_at),
  CHECK (planned_duration_ms IS NULL OR (planned_duration_ms > 0 AND planned_end_at IS NULL)),
  CHECK (status <> 'completed' OR activity_type_id IS NULL)   -- dropped in v8 (ADR-040)
) STRICT;
CREATE INDEX idx_plans_day ON plans (plan_date, sort_order) WHERE deleted_at IS NULL;
CREATE INDEX idx_plans_type_day ON plans (activity_type_id, plan_date)
  WHERE deleted_at IS NULL AND activity_type_id IS NOT NULL;

ALTER TABLE activity_logs ADD COLUMN plan_id INTEGER REFERENCES plans (internal_id) ON DELETE RESTRICT;
CREATE INDEX idx_activity_logs_plan ON activity_logs (plan_id) WHERE plan_id IS NOT NULL;
```
- `planned_duration_ms` (owner-confirmed 2026-10-04, ADR-018) is the planned length of an untimed or start-only plan ("Read for 45 minutes"). It can't coexist with `planned_end_at`, so there is one source of planned duration. An end time requires a start time.
- `sort_order` is the manual order among a date's untimed plans; timed plans display by `planned_start_at` (domain `orderPlans`). New and moved plans append (`MAX + 1`); reorder rewrites `0..n-1` in one transaction.
- **v8 (ADR-040):** the tasks-only `completed` CHECK is gone (table rebuilt with drift's `TableMigration`, internal IDs and all rows kept; `trg_activity_logs_plan_check_*` and `trg_focus_sessions_plan_check`, whose bodies read `plans`, are dropped before and recreated after; the table's own indexes and triggers are recreated by the rebuild). Any plan can store `completed`: Mark done, or a finished timer. Without it, a non-deleted record with `plan_id` makes an activity plan *in progress* on its day and *done* once the day has passed (domain `Plan.effectiveStatus`). Deleting that record reopens a plan that wasn't marked done.
- "Move to tomorrow" changes `plan_date` and shifts planned times by whole days at the same local wall-clock time. An occurrence of a repeating plan moves as a one-off copy instead, and the occurrence is soft-deleted on its date (ADR-036).

### 3.7a `plan_series` (v7, implemented, ADR-036)
```sql
CREATE TABLE plan_series (
  internal_id      INTEGER NOT NULL PRIMARY KEY,
  public_id        TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  activity_type_id INTEGER REFERENCES activity_types (internal_id) ON DELETE RESTRICT,
  title            TEXT NOT NULL CHECK (length(trim(title)) > 0),
  notes            TEXT,
  start_minute     INTEGER CHECK (start_minute IS NULL OR start_minute BETWEEN 0 AND 1439),
  duration_ms      INTEGER CHECK (duration_ms IS NULL OR duration_ms > 0),
  weekdays         INTEGER NOT NULL CHECK (weekdays BETWEEN 1 AND 127),  -- bit 0 = Monday
  interval_weeks   INTEGER NOT NULL DEFAULT 1 CHECK (interval_weeks BETWEEN 1 AND 52),
  start_date       TEXT NOT NULL CHECK (start_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  end_date         TEXT CHECK (end_date IS NULL OR end_date >= start_date),
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  deleted_at       INTEGER
) STRICT;

ALTER TABLE plans ADD COLUMN series_id INTEGER REFERENCES plan_series (internal_id) ON DELETE RESTRICT;
CREATE UNIQUE INDEX ux_plans_series_date ON plans (series_id, plan_date) WHERE series_id IS NOT NULL;
-- + trg_plan_series_public_id_immutable
```
- A series holds what each occurrence looks like (title, activity, local start minute, length) and when it happens (weekdays, every N weeks from the start week, optional last date).
- **Occurrences are ordinary `plans` rows**, generated idempotently for the dates being viewed (`EnsureSeriesOccurrences`, `INSERT OR IGNORE`), so each can be opened and logged into, skipped or deleted on its own.
- `ux_plans_series_date` deliberately includes deleted rows: an occurrence the user deleted (or moved away) is never generated again.
- Changing a repeat from an occurrence ends the old series the day before (or deletes it if it hadn't started) and soft-deletes its later occurrences that are still open (planned, nothing logged); "Stop repeating after this" does the same after the occurrence.

### 3.8 `focus_sessions` (v5, implemented, ADR-031)
```sql
CREATE TABLE focus_sessions (
  internal_id        INTEGER NOT NULL PRIMARY KEY,
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
  CHECK ((state = 'finished') = (activity_log_id IS NOT NULL AND ended_at IS NOT NULL AND duration_ms IS NOT NULL)),
  CHECK (ended_at IS NULL OR ended_at >= started_at)
) STRICT;
-- At most one active session (OQ-11); also serves "the active session".
CREATE UNIQUE INDEX ux_focus_sessions_one_active
  ON focus_sessions (state IN ('running', 'paused')) WHERE state IN ('running', 'paused') AND deleted_at IS NULL;
CREATE INDEX idx_focus_sessions_plan ON focus_sessions (plan_id) WHERE plan_id IS NOT NULL;
```
- Elapsed time is derived: `(ended_at or paused_at or now) − started_at − paused_duration_ms`. Nothing ticks in storage.
- Finishing writes the record and sets `finished` + `activity_log_id` + `ended_at` + `duration_ms` in one transaction. Discarding sets `discarded` and `deleted_at`.
- Trigger `trg_focus_sessions_plan_check`: a session's plan must be for its activity (`focus_plan_mismatch`).

### 3.9 `measurements` (v6, implemented, ADR-034)
```sql
CREATE TABLE measurements (
  internal_id       INTEGER NOT NULL PRIMARY KEY,
  public_id         TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  measurement_type  TEXT NOT NULL CHECK (length(measurement_type) > 0),  -- fixed V1 keys (OQ-09), validated in the domain
  value             REAL NOT NULL,          -- as entered
  unit_code         TEXT NOT NULL,          -- unit registry code (ADR-020)
  normalized_value  REAL NOT NULL,          -- canonical unit of the type's dimension, computed at write
  recorded_at       INTEGER NOT NULL,
  tz_offset_minutes INTEGER NOT NULL CHECK (tz_offset_minutes BETWEEN -1080 AND 1080),
  local_date        TEXT NOT NULL CHECK (local_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
  notes             TEXT,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
) STRICT;
CREATE INDEX idx_measurements_type_day
  ON measurements (measurement_type, local_date, recorded_at) WHERE deleted_at IS NULL;
```
- Types: weight (kg), height, chest, waist, arms, legs (cm), body_fat (percent). A type key from a newer app version is skipped on read.

### 3.11 `insight_charts` (v6, implemented, ADR-034)
```sql
CREATE TABLE insight_charts (
  internal_id INTEGER NOT NULL PRIMARY KEY,
  public_id   TEXT NOT NULL UNIQUE CHECK (length(public_id) = 36),
  position    INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
  config_json TEXT NOT NULL CHECK (json_valid(config_json)),  -- {"v":1, title, source, aggregation, bucket, kind}; a volume source may carry "formula" (ADR-043)
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
) STRICT;
```
- The user's saved charts. The config references activities and fields by public ID; an unreadable config (newer `"v"`) is skipped. A handful of rows, so there's no index beyond the public ID.
- Chart data is never stored: it is computed from records, plans and measurements (§6).

### 3.10 Repeating Groups (v3, implemented, ADR-027)

Schema v3 changes (migration `from2To3` in `AppDatabase`):
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
- Analytics example: the max weight per day for "Chest Press" joins set values (Weight field) → their set item → parent exercise item → exercise-name value, then the log by `local_date`. These are all integer joins on indexed columns. Phase 3 tests the plans for a log's items and a group's sub-fields. No `(field_id, text_value)` index was added: autocomplete (`textSuggestions`) uses the `field_id` prefix of `idx_log_values_field_normalized`. The analytics join is measured in Phase 6.

## 4. Relationships

| From | To | Cardinality | On target soft-delete |
|---|---|---|---|
| activity_fields.activity_type_id | activity_types | many → 1 | fields hidden with the type |
| activity_logs.activity_type_id | activity_types | many → 1 | logs stay visible (archived type) |
| log_values.log_id | activity_logs | many → 1 (CASCADE on purge) | values follow the log |
| log_values.field_id | activity_fields | many → 1 | values kept; shown as a removed field |
| log_values.group_item_id | log_group_items | many → 0..1 (CASCADE) | values follow the item |
| log_group_items.log_id | activity_logs | many → 1 (CASCADE on purge) | items follow the log |
| log_group_items.parent_item_id | log_group_items | many → 0..1 (CASCADE) | nested items follow their parent |
| activity_fields.parent_field_id | activity_fields | many → 0..1 | sub-fields soft-deleted with their group |
| plans.activity_type_id | activity_types | many → 0..1 | plan stays (archived activity) |
| activity_logs.plan_id | plans | many → 0..1 | link retained; a record of a deleted plan shows as unplanned |
| focus_sessions.activity_type_id / plan_id / activity_log_id | activity_types / plans / activity_logs | many → 1 / 0..1 / 0..1 | session history kept |

## 5. Transactions (atomic)

| Operation | Rows |
|---|---|
| Create/update activity type | `activity_types` + insert/update/soft-delete `activity_fields` (sub-fields after their parent) + position rewrite |
| Log activity / update log | `activity_logs` + insert/reposition/delete `log_group_items` + upsert/delete `log_values` |
| Delete/restore log or type | the row's `deleted_at` + `updated_at` |
| Use a built-in activity | type + fields |
| Reorder plans | `sort_order` of the date's untimed plans |
| Finish a focus session | the record (+ items + values) and the session's finished state (`UnitOfWork`, ADR-031) |

## 6. Indexes and query plans

Every index exists for a named hot path (owner performance requirement). The repository tests check the important query plans with `EXPLAIN QUERY PLAN`.

| Index | Serves | Query shape |
|---|---|---|
| `activity_types.public_id` (UNIQUE, implicit) | Resolve a route/domain ID | `WHERE public_id = ?` |
| — (none on `activity_types` otherwise) | Active types list | Tiny table; a full scan + in-memory sort is cheaper than index maintenance |
| `idx_activity_fields_type_position` | Ordered fields of a type (form renderer, builder; includes removed fields for history) | `WHERE activity_type_id = ? ORDER BY position` |
| `idx_activity_logs_day` (partial) | **Today / logs for a date**, in time order | `WHERE local_date = ? AND deleted_at IS NULL ORDER BY started_at` |
| `idx_activity_logs_type_day` (partial) | **Activity history** (newest first, keyset), **analytics ranges per type** | `WHERE activity_type_id = ? AND deleted_at IS NULL [AND local_date BETWEEN ? AND ?] ORDER BY local_date DESC, started_at DESC` |
| `idx_log_values_log` | **Values for a log**, and the per-log lookup in analytics joins | `WHERE log_id IN (…)` |
| `ux_log_values_top_level`, `ux_log_values_item` (partial UNIQUE) | One value per field per scope; an item's values | `WHERE group_item_id = ?` |
| `idx_log_values_field_normalized` | **Historical values for a field** (min/max/PR), and the "field has values?" check behind the semantics-lock trigger | `WHERE field_id = ? [ORDER BY normalized_value]`, `EXISTS (… WHERE field_id = ?)` |
| `idx_log_group_items_log` | A page of logs' items in order (one query, no N+1) | `WHERE log_id IN (…) ORDER BY position` |
| `idx_activity_fields_parent` (partial) | Sub-fields of a group; the semantics-lock "has sub-fields?" check | `WHERE parent_field_id = ?` |
| `idx_plans_day` (partial) | **A date's plans** in manual order (Today, Plan tab), with no temp sort | `WHERE plan_date = ? AND deleted_at IS NULL ORDER BY sort_order` |
| `idx_activity_logs_plan` (partial) | **Records fulfilling a date's plans** (derived completion, planned vs actual); "plan has records?" | `JOIN plans p ON p.internal_id = l.plan_id WHERE p.plan_date = ?` |
| `idx_plans_type_day` (partial) | Plans of a type over dates (planned-vs-actual analytics) | `WHERE activity_type_id = ? AND plan_date BETWEEN ? AND ?` |
| `ux_focus_sessions_one_active` (partial UNIQUE) | One active session; "the active session" | `WHERE state IN ('running','paused') AND deleted_at IS NULL` |
| `idx_focus_sessions_plan` (partial) | A plan's sessions | `WHERE plan_id = ?` |
| `idx_measurements_type_day` (partial) | A measurement type's history and series | `WHERE measurement_type = ? AND deleted_at IS NULL ORDER BY local_date, recorded_at` |
| *(Insights, existing indexes)* | Time/count series use `idx_activity_logs_type_day`; field series use `idx_log_values_field_normalized` + the log by primary key; volume joins items to their two values (`ux_log_values_item`); activity totals use `idx_activity_logs_day` | see `DbInsightRepository` |

Rules:
- Queries on partial indexes must repeat the index predicate (`deleted_at IS NULL`). The shared active-row helper always adds it.
- Repositories load a page of logs, then **all their items in one query and all their values in one query** (`log_id IN (…)`). There are no N+1 query patterns.
- Analytics over a field and date range drive from `idx_activity_logs_type_day`, then look up each log's value through `idx_log_values_log`.
- There are no JSON predicates on hot paths.

## 7. Migrations

1. **Versioning:** SQLite `user_version` through drift's `schemaVersion`. v1 = `app_preferences`; **v2 = activity engine** (§3.2–3.6); **v3 = Repeating Groups** (§3.10; adds a column and a table, then rebuilds `log_values` with drift's `TableMigration`); **v4 = plans** (§3.7; adds `plans` and `activity_logs.plan_id`, no rebuild); **v5 = focus sessions** (§3.8); **v6 = measurements + insight charts** (§3.9, §3.11); **v7 = repeating plans** (§3.7a; a new table, a nullable column on `plans` and a unique index, no rebuild); **v8 = completable activity plans** (§3.7; `plans` rebuilt to drop one CHECK, ADR-040).
2. **Forward-only, append-only.** A shipped migration is never edited.
3. Each step is transactional and leaves the DB valid. SQLite table rebuilds (the 12-step pattern) are used only when `ALTER TABLE` can't express a change.
4. **drift workflow (implemented):**
   1. Edit the schema (`tables/*.drift`, `tables/*.dart`).
   2. Bump `schemaVersion`.
   3. `dart run build_runner build -d`.
   4. `dart run drift_dev make-migrations`. This exports `drift_schemas/app_database/drift_schema_vN.json` and regenerates the step helpers (`lib/core/database/app_database.steps.dart`) and migration tests (`test/drift/app_database/`).
   5. Add the `fromXToY` step in `AppDatabase.migration`.
   6. Commit everything.
5. **Tests:** generated tests verify each step against the exported schema snapshots. Hand-written tests verify that data survives (v1 preferences survive v1→v2; v2 values survive v2→v3 with `group_item_id` NULL; logs survive v3→v4 with `plan_id` NULL; v4→v5 and v5→v6 are verified against the snapshots; plans survive v6→v7 with `series_id` NULL).
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
- Repeating Group structure: sub-field parent and nesting depth, item field/parent, value scope (v3)
- plans: stored `completed` only for tasks; one source of planned duration; a record fulfils only a plan of its own activity; a fulfilled plan keeps its activity (v4)

Domain only:
- unit belongs to the field's dimension
- select option exists and isn't archived for new values
- required fields present (per scope: top level and each group item)
- groups have at least one sub-field and an item label; empty items are dropped before saving
- number/rating ranges
- `icon_id`/`color_key` exist in the registries
- duplicate active field names within a type are rejected

## 9. Size & performance expectations

~10–50k logs and 100k–500k value rows over several years (§8). Every hot path is an indexed integer join or a range scan. Budgets: [performance.md](../development/performance.md).
