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
     │   │      └───* LogGroupItem 1───* LogValue (Repeating Group items, ADR-027)
     │   │ 0..1
     │   └──── plan ──▶ Plan (0..1)              (ADR-018)
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
| Plan | — | References ActivityType (optional). |
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
- Active activity type names must be unique (trimmed, case-insensitive; archived types don't count). Enforced in `CreateActivityType` / `UpdateActivityType` (`duplicateActivityName`), not in the schema (ADR-039).

### 3.3 ActivityLog (§3.3, ADR-021)
`id, activityTypeId, startedAt, endedAt?, durationMs?, tzOffsetMinutes, localDate, notes?, values, createdAt, updatedAt, deletedAt?` + `planId?` (the plan it fulfils; set on create, kept on edit)

- **Actual** elapsed duration is the log's `durationMs` (ADR-021). Manual entry: `startedAt` + `durationMs`. Timed (Phase 5): `startedAt`, `endedAt`, `durationMs` (active time; pauses excluded).
- Notes are a **built-in** log property. Templates add neither a Notes field nor a Duration field for the activity's own time (OQ-10).
- `localDate` is computed at write time from `startedAt` and the device offset (§7).
- `values`: `Map<ActivityFieldId, FieldValue>`. Absent = no value.

### 3.4 LogValue
Exactly one typed representation per row, chosen by the field type (§4, [database.md §3.5](database.md#35-log_values-v2-rebuilt-in-v3)).

### 3.5 Plan and Task (implemented in Phase 4, ADR-018)
`id, planDate, activityTypeId?, title, notes?, plannedStartAt?, plannedEndAt?, plannedDurationMs?, sortOrder, status, createdAt, updatedAt, deletedAt?`

- **Task** = a Plan with `activityTypeId == null`; the title is its identity.
- **Effective status** (domain, derived; reality wins):
  ```text
  activity plan:  linked non-deleted log exists ──▶ completed
                  active focus session (Phase 5)  ──▶ in_progress
                  otherwise                       ──▶ stored status (planned | skipped | cancelled)
  task:           stored status (planned | completed | skipped | cancelled)
  ```
  Stored `completed` is allowed for tasks only (CHECK). No `completed_at` column is needed: task completion time is the row's `updated_at` at completion, and activity-plan completion time is the linked log's start.
- **Planned duration** = `plannedEndAt − plannedStartAt` when both exist, otherwise `plannedDurationMs` (owner-confirmed; never both). Domain: `Plan.plannedLengthMs`.
- **Title:** an activity plan created without a title takes the activity's name. A task needs a title.
- **Plannable:** a newly chosen activity must exist, be active and have `supportsPlanning`. An existing plan keeps its activity even if archived since. A plan with records can't change its activity.
- **Order:** timed plans by start time, then untimed plans by `sortOrder` (`orderPlans`).
- **Day overview** (`WatchDayOverview`): a date's plans, each with the records fulfilling it (from any day) and its effective status, plus the date's records and the subset not fulfilling one of its plans. `entries` merges them into one list of items (ADR-035): plans and unplanned records in time order (a plan's time is its planned start, else its first record), then untimed plans in manual order. Records of a deleted plan count as unplanned.
- **Use cases:** `CreatePlan`, `UpdatePlan`, `SetPlanStatus` (complete/reopen tasks; skip; cancel; activity plans can't be stored completed), `MovePlan` (wall-clock shift, reopen, append), `ReorderPlans`, `DeletePlan`/`RestorePlan`. Items (ADR-035): `EnsureItemActivity` (the first thing logged into an item without an activity links it to the active activity with its name, or creates one with no fields), `MarkItemDone` (a task is completed; an activity item gets a log at its planned time and length), `DeleteItem`/`RestoreItem` (the plan and its log together). `LogActivity` accepts a `planId` and rejects a plan of another activity (`planRecordMismatch`).
- **Repeating plans (ADR-036):** a `PlanSeries` (title, activity, local start minute, length, `RepeatRule`: weekdays, every N weeks from the start week, optional last date) generates ordinary plans as occurrences for the dates being viewed (`EnsureSeriesOccurrences`, idempotent; a deleted occurrence stays deleted). `RepeatPlan` (start a series from a plan; from an occurrence it ends the old series the day before and removes its later open occurrences), `StopRepeating`, `PlanNext` (same title, activity and length on another date). `MovePlan` moves an occurrence as a one-off copy.
- **Item → log (ADR-035):** an item has at most one live log (`ActivityLogRepository.getLogForPlan`: the plan's earliest active log; older data with several shows the others as separate items). It's created by the first change, with start = planned start (else now for today's plan, or that date at the current local time; `recordStartFor`), and saved as the user types: `LogActivity` / `UpdateActivityLog` with `partial: true`, where missing required values are allowed and all other checks apply. Quick add links a typed activity name (`matchByName`) or installs the matching starter template. One session with many sets is one record.

### 3.6 Measurement (implemented in Phase 6, ADR-034)
`id, type, value, unitCode, normalizedValue, recordedAt, tzOffsetMinutes, localDate, notes?, createdAt, updatedAt`.
- Fixed V1 types (OQ-09 recommendation): weight (mass, kg), height/chest/waist/arms/legs (distance, cm), body fat (percentage).
- Units via the registry, with the canonical value computed at write (ADR-020).
- Validation: finite and positive; body fat at most 100 %; the unit must belong to the type's dimension.
- Use cases: `RecordMeasurement`, `UpdateMeasurement`, `DeleteMeasurement`/`RestoreMeasurement`.

### 3.7 FocusSession (implemented in Phase 5, ADR-031)
`id, activityTypeId, planId?, logId?, state, startedAt, pausedAt?, pausedDurationMs, endedAt?, durationMs?`.
- `elapsedMs(now)` is derived from timestamps.
- Use cases:
  - `StartFocusSession`: a timer activity, an optional plan of that activity, one active session.
  - `PauseFocusSession` / `ResumeFocusSession`.
  - `DiscardFocusSession`: soft delete, no record.
  - `FinishFocusSession(id)` (ADR-035): in one `UnitOfWork`, the timed span goes into the item's log: a new log (start, `endedAt` = the pause or now, duration) if the plan has none, otherwise an update that keeps its values and notes (a second timed session keeps the first start and adds its time); then `markFinished`.
- Plans show `EffectivePlanStatus.inProgress` while their session is active, even if something is already logged.

## 4. Field type catalog

Resolved by OQ-01 (owner, 2026-10-04).

The catalog is **closed and code-defined** (domain sealed hierarchy). The DB stores the key. **Domain-specific types are compositions, never new types:** Weight/Distance/Calories = Number + dimension; Reps/Steps/Pages/Count = Number (decimals 0); Percentage = Number (0–100); Sets/Exercises/Checklist = Repeating Group.

| Key | Value semantics | Storage ([database.md §3.5](database.md#35-log_values-v2-rebuilt-in-v3)) | Validation | Measurable | Config (`config_json`) | Phase |
|---|---|---|---|---|---|---|
| `text` | String, trimmed; empty = no value | `text_value` | ≤ 10,000 chars | no | `{"multiline"?: true, "suggest"?: true}` (`suggest` = offer previously recorded values) | 2 (`suggest`: 3) |
| `number` | Decimal as entered; optional unit within the field's `dimension` | `number_value` + `normalized_value` (+ `unit_code` if dimensioned) | finite; `min ≤ v ≤ max`; ≤ `decimals` places; unit belongs to dimension | yes | `{"decimals":0..3, "min"?, "max"?, "defaultUnit"?}` | 2 |
| `boolean` | true/false | `boolean_value` | — | yes (count true) | `{}` | 2 |
| `single_select` | One option ID | `text_value` | option exists and is not archived (new values) | no | `{"options":[{"id","label","archived"?}]}` | 2 |
| `multi_select` | Ordered set of option IDs (≥ 1) | `json_value` `{"v":1,"optionIds":[…]}` | each option exists and isn't archived; no duplicates | no | same as single select | 2 |
| `date` | Local calendar date | `date_value` `YYYY-MM-DD` | valid date | no | `{}` | 2 |
| `time` | Local time of day, minute precision | `time_value` minutes 0–1439 | range | no | `{}` | 2 |
| `duration` | Elapsed time | `duration_ms` | ≥ 0 | yes | `{}` | 2 |
| `rating` | Integer 1..max | `number_value` = `normalized_value` | `1 ≤ v ≤ max` | yes | `{"max": 3..10}` (default 5) | 2 |
| `repeating_group` | Ordered list of items, each holding values for the group's sub-fields | no value row; `log_group_items` + typed child `log_values` (ADR-027) | sub-field rules per item (issue target `<itemId>/<fieldId>`); unique item IDs; nesting ≤ 2; ≥ 1 sub-field; item label required | via sub-fields | `{"itemLabel": "Exercise"}`; sub-fields are `activity_fields` rows with `parent_field_id` | **3** |

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

### 5.3 Repeating Group (implemented in Phase 3, ADR-027)
Stored **relationally**, not as JSON:
- **Definition:**
  - the group is an `activity_fields` row of type `repeating_group` (config: `itemLabel`)
  - its **sub-fields** are ordinary `activity_fields` rows with `parent_field_id` pointing at it, so they're typed, unit-aware and semantics-locked like any field
- **Values:**
  - each item is a `log_group_items` row (stable UUIDv7 `public_id`, `position`, optional `parent_item_id` for a nested group)
  - each sub-field value is an ordinary typed `log_values` row with `group_item_id`
- **Nesting:** at most two levels. Gym = Exercises { Exercise: Text, Sets { Weight: Number (mass), Reps: Number } }. Checklists = Items { Item: Text, Done: Boolean }.
- **Domain shape:** a `RepeatingGroupValue` holds ordered `GroupItem`s, each with a `GroupItemId` (UUIDv7, generated when the item is added in the form) and `Map<ActivityFieldId, FieldValue>`; a nested group is a sub-value. `FieldDefinition.subFields` carries sub-fields in definitions; `ActivityType.subFieldsOf(groupId)` reads them; `activeFields` is top-level only. The repository maps values to and from rows in one transaction.
- **Normalization:** `LogActivity`/`UpdateActivityLog` drop items with no values and groups with no items before validation, so an untouched "Add set" row is never stored.
- **Why:** nested numbers (set weights, reps) stay queryable and indexable for Insights without parsing JSON on hot paths (ADR-019). Schema: [database.md §3.10](database.md#310-repeating-groups-v3-implemented-adr-027).

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

## 8. Analytics data model (implemented in Phase 6, ADR-034)

The engine understands **Time + Measurement + Unit** (§24) only. Domain: `features/insights/domain/insight.dart` (pure).

```text
InsightSource ──points──▶ List<DataPoint(localDate, value)>   (canonical units, oldest first)
     │
buildSeries(bucket: day|week|month, aggregation: sum|average|max|min|count|latest, range)
     │
InsightSeries (buckets + total, count, average, best, latest) ──▶ AppChart / headline / change / personal best
```

**InsightSource** variants (sealed):
- `ActivityDurationSource(type)`: `activity_logs.duration_ms` per record (ADR-021).
- `ActivityCountSource(type)`: 1 per record.
- `FieldValueSource(type, field, filter?)`: `log_values.normalized_value` of a Number or Rating field at any depth.
  - The optional `TextFilter(field, value)` keeps values whose own item, parent item or record has that text (case-insensitive). Example: Weight of sets whose exercise is "Chest Press" (OQ-15: free text, case-folded).
  - Duration fields aren't chartable here yet (they store `duration_ms`).
- `VolumeSource(type, group, amount, count, filter?)`: amount × count per group item, e.g. kg × reps per set (FR-AN-08).
- `MeasurementSource(type)`: `measurements.normalized_value`.
- `PlannedVsActualSource(type?)`: planned length (`planned_end_at − planned_start_at` or `planned_duration_ms`) and recorded `duration_ms` of linked records, both by `plan_date` (FR-AN-09).

**Results** (`WatchInsight`): the period (`from`, `to`), the series for the range, the period value against the previous period of the same length, and the **personal best** (all-time highest point) for field and volume sources; for a volume also the **best day** (highest per-day total, `bestDayTotal`). `InsightRange.bucket` gives automatic charts a bucket that fits the range. Default aggregations: time/count/volume = total, body = latest, field = best.

**Logging from memory** (ADR-041, `activity_logs/domain/log_memory.dart`): `LastLogOfType` (newest log of a type with values, except the item's own) and `LastRowNamed` / `findLastRow` (newest list row with a given name, any depth) read once through `ActivityLogRepository.recentLogsForType`; `copyValues` / `copyRow` give copied rows fresh `GroupItemId`s. `DuplicatePlan` copies a plan on its day through `CreatePlan`.

**Saved charts** (`InsightChartConfig`: title, source, aggregation, bucket, line/bar) are persisted in `insight_charts` as versioned JSON (`InsightChartCodec`, `"v": 1`). This departs from the OQ-14 recommendation and awaits owner confirmation.

**Display:** canonical values convert to the field's (or measurement type's) default unit; durations show as time (`InsightDisplay`).

Queries are relational, with no JSON on these paths ([database.md §6](database.md#6-indexes-and-query-plans)). No task-completion source yet.

## 9. Starter templates

Templates are **plain data** (`features/activity_types/presentation/activity_templates.dart` for the starters below, `everyday_templates.dart` for the gallery; they live in presentation only because their names are localized, and become the user's own editable content once installed). Installing one copies it into normal rows with fresh UUIDv7 IDs; afterwards a template-derived type is indistinguishable from a user-built one. No code may check "is this the X template". Templates:

| Template | Fields (built-in: start, duration, notes) | Timer |
|---|---|---|
| Reading | Book (text), Pages (number, decimals 0), Rating (rating /5) | yes |
| Focused Work | Project (text) | yes |
| Walking | Distance (number, distance, km), Steps (number), Calories (number, energy, kcal), Location (text) | yes |
| Language Learning | Language (single select), Words learned (number), Lesson (text), Difficulty (rating /5) | yes |

| Gym (Phase 3) | Workout (single choice: Push, Pull, Legs, Upper body, Lower body, Full body, Cardio; A12), Exercises (group, item "Exercise") { Exercise (text, required, suggest), Sets (group, item "Set") { Weight (number, mass, kg, 2 decimals), Reps (number) } } | yes |
| Meeting (Phase 3) | People (text), Topics (multi-line text), Decisions (multi-line text), Action items (group, item "Action item") { Item (text, required), Done (boolean) } | yes |
| Cooking (Phase 3) | Recipe (text, suggest), Servings (number), Calories (number, energy, kcal), Rating (rating /5), Ingredients (group, item "Ingredient") { Ingredient (text, required, suggest), Have it (boolean) } | yes |

Meeting "People" is Text, not Multi Select: the spec allows either (§22), and a fixed option list for people would need maintenance.

**Gallery (ADR-042):** `templateCategories(l10n)` groups the starters above with the everyday templates into 14 life areas (Sleep & self-care, Health, Food & drink, Home & chores, Money, Family & care, Work, Learning, Exercise & sport, Mind & wellbeing, Faith & spirituality, Hobbies & fun, Friends & community, Travel & errands; 147 templates). The areas follow the time-use surveys of the US (ATUS), UK (ONS) and India (TUS) plus commonly tracked habits; the list covers common activities across cultures and is not meant to be complete. `activityTemplates(l10n)` is the flat list (quick add suggestions). Each is built from small helpers over the generic field types (`_text`, `_number`, `_rating`, `_yesNo`, `_choice`, `_multiChoice`, `_duration`, `_time`, `_date`, `_list`); all strings are in the ARB. `activity_templates_test.dart` checks every template passes `ActivityTypeValidator`, names are unique, and each starter appears once.

**Anything else is the user's own activity**, built in the builder from the same field types and stored exactly like an installed template; `custom_activity_test.dart` covers the owner's examples ("Build my company", "Car maintenance", "Study").

## 10. Data lifecycle

| Action | Behavior |
|---|---|
| Delete log | Soft delete; Undo restores (`RestoreActivityLog`). |
| Delete (archive) activity type | Soft delete the type only. Hidden from lists; historical logs keep rendering with its name/icon/color. Undo restores. |
| Remove field | Soft delete; values retained. |
| Edit log | Values diffed by field: changed rows updated, cleared rows hard-deleted, new rows inserted. |
| Purge | Not done in V1. |
| Export *(later)* | Uses public IDs only and includes deletion flags. |
