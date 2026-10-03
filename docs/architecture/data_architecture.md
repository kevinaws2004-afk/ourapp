# Data Architecture

> The conceptual/domain data model: entities, identity, ownership, field types, value semantics, units, structured values, time and analytics.
> Physical SQLite schema, indexes and triggers: [database.md](database.md). Decisions: ADR-006, ADR-013, ADR-017 to ADR-026.

---

## 1. Entity overview

```text
ActivityType 1───* ActivityField
     │ 1                 │ 1
     │                   │
     * ActivityLog 1───* LogValue (typed storage; top-level: one per field)
     │   │      └───* LogGroupItem 1───* LogValue (Repeating Group items, Phase 3, ADR-027)
     │   │ 0..1
     │   └──── plan ──▶ Plan (0..1)              (Phase 4, ADR-018)
     │
     └─0..1── FocusSession ──▶ ActivityLog (set on finish; Phase 5)

Plan *───0..1 ActivityType           (Task = Plan without ActivityType, ADR-018)

Measurement                           (independent; Phase 6)
AppPreference                         (key/value, ADR-012)

Code registries (not tables): FieldType catalog · Unit registry (ADR-020) · Icon registry (ADR-024) · Activity palette
```

## 2. Identity, ownership & aggregates

**Identity (ADR-017).**
- Every entity has a UUIDv7 `public_id`: its **only** identity in the domain, in routes, exports, JSON payloads and future sync.
- The database's `internal_id` integers exist only inside the data layer, for joins.
- Domain ID types are thin value wrappers (`ActivityTypeId`, `ActivityFieldId`, `ActivityLogId`) around the public ID string.

An **aggregate** is saved, deleted (soft) and, in future, synced as a whole.

| Aggregate root | Owns | Notes |
|---|---|---|
| ActivityType | its ActivityFields | Type + fields saved in one transaction. Fields have their own public IDs and soft-delete flags because values reference them. |
| ActivityLog | its LogValues and LogGroupItems | Log + items + values saved in one transaction. Top-level values are identified by log + field, item values by item + field. Items have stable `public_id`s (ADR-027). No soft delete for children (ADR-022). |
| Plan *(Phase 4)* | — | References ActivityType (optional). |
| FocusSession *(Phase 5)* | — | References ActivityType, optionally Plan, and the resulting ActivityLog. |
| Measurement *(Phase 6)* | — | |

Cross-aggregate references must tolerate the target being soft-deleted (archived types still render historical logs).

## 3. Entities

Column-level detail is in [database.md](database.md).

### 3.1 ActivityType (§3.1, ADR-026)
`id, name, iconId, colorKey, description?, supportsTimer, supportsPlanning, sortOrder, fields, createdAt, updatedAt, deletedAt?`

- "Supports repeating groups" (§3.1) is **derived** (any Repeating Group field), not stored.
- `iconId` is an icon-registry key (ADR-024) and `colorKey` an activity-palette key. Neither is ever a glyph, code point or hex value.

### 3.2 ActivityField (§10, ADR-026)
`id, activityTypeId, name, fieldType, dimension?, position, required, measurable, config (typed), createdAt, updatedAt, deletedAt?`

Lifecycle rules (FR-AT-09; historical data safety, enforced by domain **and** DB triggers):
- **Allowed any time:** rename, reorder, toggle required/measurable, change presentation config (decimals, multiline, default display unit within the same dimension).
- **Locked once any value exists:** `fieldType` and `dimension`. UX: "add a new field and remove the old one".
- **Never:** moving a field to another activity type.
- **Delete:** soft delete. Values remain and are shown in historical logs as a muted "removed field". Not offered in new logs.
- **Select options:** removing an option that may be in use marks it `archived` in config (stable option IDs); archived options render for history but can't be chosen for new values.
- Active field names must be unique within a type (case-insensitive). This is a domain rule.

### 3.3 ActivityLog (§3.3, ADR-021)
`id, activityTypeId, startedAt, endedAt?, durationMs?, tzOffsetMinutes, localDate, notes?, values, createdAt, updatedAt, deletedAt?` (+ `planId?` from Phase 4)

- **Actual** elapsed duration is the log's `durationMs` (ADR-021). Manual entry: `startedAt` + `durationMs`. Timed (Phase 5): `startedAt`, `endedAt`, `durationMs` (active time; pauses excluded).
- Notes are a **built-in** log property. Templates add neither a Notes field nor a Duration field for the activity's own time (OQ-10).
- `localDate` is computed at write time from `startedAt` and the device offset (§7).
- `values`: `Map<ActivityFieldId, FieldValue>`. Absent = no value.

### 3.4 LogValue
Exactly one typed representation per row, chosen by the field type (§4, [database.md §3.5](database.md#35-log_values-v2-implemented)).

### 3.5 Plan and Task (Phase 4, ADR-018)
`id, planDate, activityTypeId?, title, notes?, plannedStartAt?, plannedEndAt?, sortOrder, status, createdAt, updatedAt, deletedAt?`

- **Task** = a Plan with `activityTypeId == null`; the title is its identity.
- **Effective status** (domain, derived; reality wins):
  ```text
  activity plan:  linked non-deleted log exists ──▶ completed
                  active focus session (Phase 5)  ──▶ in_progress
                  otherwise                       ──▶ stored status (planned | skipped | cancelled)
  task:           stored status (planned | completed | skipped | cancelled)
  ```
  Stored `completed` is allowed for tasks only (CHECK). No `completed_at` column is needed: task completion time is the row's `updated_at` at completion, and activity-plan completion time is the linked log's start.
- **Planned duration** = `plannedEndAt − plannedStartAt` when both exist. Untimed planned durations are an open sub-item (ADR-018).

### 3.6 Measurement (Phase 6)
`id, measurementType, value, unitCode, normalizedValue, recordedAt, tzOffsetMinutes, localDate, notes?, …`. Fixed V1 types (OQ-09). Units via the registry (ADR-020).

### 3.7 FocusSession (Phase 5)
`id, activityTypeId, planId?, activityLogId?, state, startedAt, pausedAt?, pausedDurationMs, endedAt?, durationMs?`. Lifecycle: create → pause/resume → finish in one transaction (set times + create the log with `durationMs` + link it). Discard soft-deletes the session and creates no log. One active session at a time (DB unique partial index).

## 4. Field type catalog

Resolved by OQ-01 (owner, 2026-10-04).

The catalog is **closed and code-defined** (domain sealed hierarchy). The DB stores the key. **Domain-specific types are compositions, never new types:** Weight/Distance/Calories = Number + dimension; Reps/Steps/Pages/Count = Number (decimals 0); Percentage = Number (0–100); Sets/Exercises/Checklist = Repeating Group.

| Key | Value semantics | Storage ([database.md §3.5](database.md#35-log_values-v2-implemented)) | Validation | Measurable | Config (`config_json`) | Phase |
|---|---|---|---|---|---|---|
| `text` | String, trimmed; empty = no value | `text_value` | ≤ 10,000 chars | no | `{"multiline": false}` | 2 |
| `number` | Decimal as entered; optional unit within the field's `dimension` | `number_value` + `normalized_value` (+ `unit_code` if dimensioned) | finite; `min ≤ v ≤ max`; ≤ `decimals` places; unit belongs to dimension | yes | `{"decimals":0..3, "min"?, "max"?, "defaultUnit"?}` | 2 |
| `boolean` | true/false | `boolean_value` | — | yes (count true) | `{}` | 2 |
| `single_select` | One option ID | `text_value` | option exists and is not archived (new values) | no | `{"options":[{"id","label","archived"?}]}` | 2 |
| `multi_select` | Ordered set of option IDs (≥ 1) | `json_value` `{"v":1,"optionIds":[…]}` | each option exists and isn't archived; no duplicates | no | same as single select | 2 |
| `date` | Local calendar date | `date_value` `YYYY-MM-DD` | valid date | no | `{}` | 2 |
| `time` | Local time of day, minute precision | `time_value` minutes 0–1439 | range | no | `{}` | 2 |
| `duration` | Elapsed time | `duration_ms` | ≥ 0 | yes | `{}` | 2 |
| `rating` | Integer 1..max | `number_value` = `normalized_value` | `1 ≤ v ≤ max` | yes | `{"max": 3..10}` (default 5) | 2 |
| `repeating_group` | Ordered list of items, each holding values for the group's sub-fields | no value row; `log_group_items` + typed child `log_values` (ADR-027) | sub-field rules per item; nesting ≤ 2 | via sub-fields | `{"itemLabel": "Exercise"}`; sub-fields are `activity_fields` rows with `parent_field_id` | **3** |

Every field type implements, in domain:
- `parseConfig(json)` / `configToJson()`
- `validate(field, value) → ValidationResult` (pure)
- storage mapping: `FieldValue` ↔ typed columns (data layer codec)
- `summarize(field, value) → String` for timeline/history lines

Presentation adds an editor per type in the exhaustive `FieldEditorRegistry` ([application_architecture.md §4](application_architecture.md#4-generic-form-renderer)).

**Timer** is not a field type: `supportsTimer` on the type plus the log's built-in duration (ADR-021).

## 5. Structured values

All JSON payloads (Multi Select values and config JSON) follow ADR-019:
- An explicit `"v"` version in value JSON. Config JSON evolves through tolerant decoders (unknown keys ignored, missing keys default).
- Identity is **always** a stable ID: option IDs and item IDs are UUIDv7 strings, and field references use field `public_id`s. Display names never act as identity.
- **Migration strategy:** decoders accept every historical `"v"`. A new format bumps `"v"` and ships an upgrade function in the domain codec. Rewriting stored rows in bulk is optional (a data migration) and never required for reading.

### 5.1 Multi Select (Phase 2)
```json
{ "v": 1, "optionIds": ["01890a5d-…", "01890a5e-…"] }
```
Order is the user's selection order. Trade-off: per-option counting reads JSON (`json_each`). That's acceptable because multi-select aggregation isn't a V1 hot path.

### 5.2 Select options in config
```json
{ "options": [ { "id": "01890a5d-…", "label": "Spanish" }, { "id": "…", "label": "French", "archived": true } ] }
```

### 5.3 Repeating Group (Phase 3, ADR-027)
Stored **relationally**, not as JSON:
- **Definition:**
  - the group is an `activity_fields` row of type `repeating_group` (config: `itemLabel`)
  - its **sub-fields** are ordinary `activity_fields` rows with `parent_field_id` pointing at it, so they're typed, unit-aware and semantics-locked like any field
- **Values:**
  - each item is a `log_group_items` row (stable UUIDv7 `public_id`, `position`, optional `parent_item_id` for a nested group)
  - each sub-field value is an ordinary typed `log_values` row with `group_item_id`
- **Nesting:** at most two levels. Gym = Exercises { Exercise: Text, Sets { Weight: Number (mass), Reps: Number } }. Checklists = Items { Item: Text, Done: Boolean }.
- **Domain shape (Phase 3):** a `RepeatingGroupValue` holds ordered items, each with an ID and `Map<ActivityFieldId, FieldValue>`; nested groups appear as sub-values. The repository maps it to and from rows in one transaction.
- **Why:** nested numbers (set weights, reps) stay queryable and indexable for Insights without parsing JSON on hot paths (ADR-019). Schema: [database.md §3.10](database.md#310-repeating-groups-designed-phase-3-adr-027).

## 6. Units (ADR-020)

A **code-defined Unit Registry** (`lib/core/units/`, pure Dart, shared by activity fields and measurements):

| Dimension | Canonical unit | V1 units (code → symbol) |
|---|---|---|
| mass | kg | `kg`, `g`, `lb`, `oz` |
| distance | m | `m`, `km`, `mi`, `ft`, `yd` |
| volume | ml | `ml`, `l`, `fl_oz_us`, `cup_us` |
| temperature | °C | `celsius`, `fahrenheit` (affine) |
| energy | kcal | `kcal`, `kj` |
| duration | ms | `ms`, `s`, `min`, `h`. Formatting/conversion only; not a Number dimension (durations use the Duration type) |

- `canonical = value × factor + offset`. The conversion runs **once at write time** into `normalized_value`.
- Unit codes are permanent and are never renamed or removed. New units are added in code with no schema change.
- Display: values show in the unit they were entered in. Charts convert `normalized_value` into the field's display unit.

## 7. Time model

Decision: ADR-013.

- **Instants** are UTC epoch milliseconds.
- Logs (and measurements) store `tzOffsetMinutes` and **`localDate`**, the local calendar day of the instant, computed **at write time** by `LocalDateCalculator` from the `Clock`'s offset for that instant. Day queries are therefore indexed equality/range lookups.
- **Local dates** (`planDate`, Date field values) are `YYYY-MM-DD`: calendar concepts, not instants.
- **Day assignment:** an activity belongs to the local day of its start. A midnight-crossing activity shows on the start day.
- **Durations** are `durationMs` integers. They're formatted only in presentation.
- **Week start:** device locale default (assumption to confirm in Phase 6).
- All "now" and offsets come from the injectable `Clock` (`nowUtc()`, `offsetAt(instant)`).

## 8. Analytics data model (Phase 6)

The engine understands **Time + Measurement + Unit** (§24) only.

```text
MetricSource ──extract──▶ List<DataPoint(localDate, timestamp, value, unit)>
     │
Aggregation(bucket: day|week|month|session, fn: sum|avg|max|min|count, range)
     │
Series ──▶ Chart / Total / Count / Average / Comparison
```

**MetricSource** variants (sealed):
- `LogDurationSource(type)`: `activity_logs.duration_ms` per log (ADR-021).
- `LogCountSource(type)`: 1 per log.
- `FieldSource(type, field)`: `log_values.normalized_value` (number, rating), `duration_ms` (duration), or `boolean_value` (count true).
- `NestedFieldSource(type, subField, filter?)`: values of a Repeating Group sub-field, joined through `log_group_items` (e.g. Weight of sets whose parent exercise's name is "Chest Press"). These are relational joins (ADR-027).
- `MeasurementSource(type)`: `measurements.normalized_value`.
- `TaskCompletionSource()`: tasks with stored `completed`.

Queries drive from `idx_activity_logs_type_day` (type + date range), then look up values by `(log_id, field_id)`, with no JSON on these paths ([database.md §6](database.md#6-indexes-and-query-plans)). Chart configuration `{source, aggregation, range, chartType}` is a value object and isn't persisted in V1 (OQ-14).

## 9. Starter templates (Phase 2)

Templates are **plain data** (`features/activity_types/presentation/activity_templates.dart`; they live in presentation only because their names are localized, and become the user's own editable content once installed). Installing one copies it into normal rows with fresh UUIDv7 IDs; afterwards a template-derived type is indistinguishable from a user-built one. No code may check "is this the X template". Phase 2 templates use only Phase 2 field types:

| Template | Fields (built-in: start, duration, notes) | Timer |
|---|---|---|
| Reading | Book (text), Pages (number, decimals 0), Rating (rating /5) | yes |
| Focused Work | Project (text) | yes |
| Walking | Distance (number, distance, km), Steps (number), Calories (number, energy, kcal), Location (text) | yes |
| Language Learning | Language (single select), Words learned (number), Lesson (text), Difficulty (rating /5) | yes |

Gym, Meeting (action-item checklist) and Cooking (ingredients checklist) need Repeating Group and arrive in Phase 3.

## 10. Data lifecycle

| Action | Behavior |
|---|---|
| Delete log | Soft delete; Undo restores (`RestoreActivityLog`). |
| Delete (archive) activity type | Soft delete the type only. Hidden from lists; historical logs keep rendering with its name/icon/color. Undo restores. |
| Remove field | Soft delete; values retained. |
| Edit log | Values diffed by field: changed rows updated, cleared rows hard-deleted, new rows inserted. |
| Purge | Not done in V1. |
| Export *(later)* | Uses public IDs only and includes deletion flags. |
