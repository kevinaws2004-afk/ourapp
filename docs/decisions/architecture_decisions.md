# Architecture Decision Records

> **Accepted** decisions (ADR-0xx) were made in the source documents (`claude_setup.md`, the spec). **Pending** decisions (ADR-Pxx) are recommendations that need owner approval. When one is approved, move it to Accepted with the next number and date it; never delete history.
> Format: Decision · Context · Reason · Consequences.

---

## Accepted

### ADR-001: Flutter instead of separate Kotlin/Swift applications
- **Status:** Accepted (source: setup §4, spec §6)
- **Decision:** Build one app in Flutter/Dart.
- **Context:** Android first, iOS later; one small team; a highly custom visual identity.
- **Reason:** A single codebase for both platforms; custom rendering suits a distinctive design system; strong animation/gesture support; the domain logic is shared in Dart.
- **Consequences:** Platform-specific features (app blocking, notifications, widgets) need plugins or platform channels behind interfaces. The app must avoid Android-only assumptions to keep iOS cheap.

### ADR-002: SQLite as the V1 source of truth
- **Status:** Accepted (spec §8, §27; setup §5.8)
- **Decision:** All data lives in a local SQLite database on the device.
- **Context:** Thousands of logs, sets, sessions, measurements; offline; zero infrastructure cost.
- **Reason:** Structured storage, queries, indexes, transactions, offline, proven performance, no server.
- **Consequences:** Schema migrations must be managed carefully (see [database.md §7](../architecture/database.md#7-migrations)). Backups are the user's responsibility until export/sync exists.

### ADR-003: Local-first, offline-first architecture
- **Status:** Accepted (spec §6, §39)
- **Decision:** Every feature works fully offline; the device is the authority.
- **Context:** Privacy positioning ("your data stays on your device"), no backend in V1.
- **Reason:** Simplicity, privacy, speed, ₹0 infrastructure.
- **Consequences:** No server-side features. Data model must stay sync-ready (stable IDs, timestamps, soft delete) without implementing sync.

### ADR-004: Riverpod for state management
- **Status:** Accepted (setup §4, spec §6)
- **Decision:** Use Riverpod for dependency injection and state.
- **Context:** Need testable DI, reactive DB streams, scoped screen state.
- **Reason:** Compile-safe providers, easy test overrides, good async (`AsyncValue`) and stream support, no `BuildContext` dependency for logic.
- **Consequences:** Conventions in [state_management.md](../architecture/state_management.md). No code generation for providers (ADR-014).

### ADR-005: Feature-first project structure
- **Status:** Accepted (setup §5.1, §6)
- **Decision:** `lib/features/<feature>/{data,domain,presentation}` plus `app/`, `core/`, `shared/`.
- **Context:** Many features sharing one generic engine; long-term maintainability.
- **Reason:** Locality of change; clear ownership; layers inside features keep separation of concerns.
- **Consequences:** Cross-feature dependency rules are needed ([application_architecture.md §2](../architecture/application_architecture.md#2-dependency-rules)). Empty layer folders are not created.

### ADR-006: Generic, configuration-driven activity engine
- **Status:** Accepted (spec §5, §46; setup §5.14–16)
- **Decision:** Activity Types, Fields, Logs and Values are generic. No per-activity tables or screens. The UI renders forms from field definitions.
- **Context:** Users define their own activities (Language Learning, Cooking…) with no developer involvement.
- **Reason:** Extensibility without migrations or code; one engine to test.
- **Consequences:** Structured needs (sets, exercise lists) are solved by generic field types (Set Table, Repeating Group). Analytics must work on generic (time, value, unit) data. Some queries are more complex than with bespoke tables (see ADR-P05).

### ADR-007: Repository abstraction between domain and persistence
- **Status:** Accepted (setup §5.7)
- **Decision:** Domain defines repository interfaces; data layer implements them over SQLite.
- **Context:** Testability, separation of concerns, future sync.
- **Reason:** UI/domain independent of DB library; sync-aware implementations can be introduced later.
- **Consequences:** Mappers between rows and entities; repositories never leak DB types.

### ADR-008: No backend in V1
- **Status:** Accepted (spec §7, §42)
- **Decision:** No API server, cloud database, Firebase/Supabase/AWS, authentication.
- **Context:** V1 focus on the core loop; ₹0 cost; privacy.
- **Reason:** Avoid complexity and cost until the core product is proven.
- **Consequences:** No accounts, sync, remote config, crash reporting or analytics services. Future plan in [future_sync.md](../architecture/future_sync.md).

### ADR-009: Android-first, iOS-compatible
- **Status:** Accepted (setup §5.4, spec §33.7)
- **Decision:** Ship and test on Android first; keep the code iOS-compatible.
- **Context:** Initial target market/device.
- **Reason:** Focus testing effort while preserving future reach.
- **Consequences:** Plugins must support iOS or sit behind interfaces; the iOS project folder is kept and compiled; no Android-only APIs in domain/data.

### ADR-010: Internal technical identifiers and product naming rule
- **Status:** Accepted 2026-10-03 (owner gate, B1)
- **Decision:**
  - Internal codename / Dart package: `daylog`.
  - Android application ID and iOS bundle ID: `com.ourapp.daylog`.
  - Temporary development display name: **OurApp**.
- **Context:** `flutter create` needs identifiers, and the Play application ID becomes permanent once published. The product name is undecided.
- **Reason:** A neutral codename unblocks scaffolding without committing to a product name.
- **Consequences:**
  - `daylog` is **only** a technical identifier. It must never appear as the product name in UI, copy, onboarding, docs prose, the README description or marketing.
  - "Daylight" is only the provisional design direction (ADR-016), also never the product name.
  - The visible name lives in exactly three places, so it can be changed before release (see [development_guide.md §2.1](../development/development_guide.md#21-product-naming-temporary)).

### ADR-011: drift as the SQLite access library
- **Status:** Accepted 2026-10-03 (owner gate, B2; resolves ADR-P01)
- **Decision:** Use drift (with `drift_flutter` for opening the database and `drift_dev` + `build_runner` for code generation). Generated `*.g.dart` files are committed to git.
- **Context:** The data layer needs reactive queries (Today timeline), typed SQL, migrations with tests, background-isolate execution and in-memory test databases.
- **Reason:** drift provides all of these. With sqflite, stream notification, mapping and migration testing would be hand-built.
- **Consequences:**
  - A `build_runner` step is required after schema changes.
  - Committing generated files keeps the repo buildable without running the generator.
  - Drift's database class must list every table, so **table definitions live in `lib/core/database/tables/`** (one cohesive schema, no `core → features` import). Feature `data/` layers hold repositories (and DAOs when useful) that use the core database.
  - This refines [application_architecture.md §1](../architecture/application_architecture.md#1-project-layout).

### ADR-012: Phase 1 schema limited to `app_preferences`; `app_preferences` is a documented exception (Option A)
- **Status:** Accepted 2026-10-03 (owner gate, B3; resolves ADR-P14)
- **Decision:**
  1. Schema version 1 creates only `app_preferences`. The activity tables are added by Phase 2's first migration.
  2. Preferences are stored in SQLite, not `shared_preferences`.
  3. `app_preferences` is an **intentional exception** to the timestamp rule: text `key` primary key, `value_json`, `updated_at` only. "Reset" writes the default value; rows are never deleted.
- **Context:** Phase 1 needs only the theme mode and the onboarding flag. Several activity-schema decisions are still pending.
- **Reason:** Avoids locking unsettled schema decisions into the first migration. Preferences are a small fixed key set updated in place; per-key last-writer-wins on `updated_at` suffices for future sync.
- **Consequences:**
  - ADR-P02, P04, P05, P06, P07, P08 and P20 had to be decided before Phase 2 created the activity tables. They were, as ADR-017 to ADR-026.
  - `app_preferences` is also an exception to the two-level identity model (ADR-017): its text `key` is the stable identifier, and there is no `internal_id`/`public_id`.

### ADR-013: Time storage
- **Status:** Accepted 2026-10-03 (owner gate, B4; resolves ADR-P03)
- **Decision:**
  - Instants are stored as UTC epoch milliseconds (`INTEGER`).
  - Calendar dates are stored as `YYYY-MM-DD` text.
  - Logs and measurements also store `tz_offset_minutes`.
  - An activity belongs to the local day of its start.
  - All "now" comes from the injectable `Clock`.
- **Context:** The daily timeline and analytics must stay correct across time zones and DST.
- **Reason:** Integers index and compare efficiently, with no parsing ambiguity. The stored offset keeps day assignment stable when travelling.
- **Consequences:**
  - Day boundaries are computed in Dart. See [data_architecture.md §7](../architecture/data_architecture.md#7-time-model).
  - **Refinement (2026-10-04, with ADR-026's performance rules):** rows that are looked up by calendar day also store an explicit `local_date` (`YYYY-MM-DD`, the local day of the start/recorded instant, computed at write time). Day queries are then simple indexed equality/range lookups, with no per-query offset arithmetic.

### ADR-014: Hand-written Riverpod providers; no riverpod_generator, no freezed
- **Status:** Accepted 2026-10-03 (owner gate, B5; resolves the code-generation part of ADR-P10)
- **Decision:**
  - Use Riverpod (`flutter_riverpod`) with hand-written providers.
  - No `riverpod_generator` and no `freezed`.
  - Entities use Dart 3 sealed classes and records, with hand-written `copyWith`/equality where needed.
  - drift is the only code generator.
- **Context:** Provider patterns set in Phase 1 are copied by every later feature.
- **Reason:** Explicit, readable providers; one generator toolchain; faster builds.
- **Consequences:** Slightly more boilerplate per provider and entity. Moving to generators later is mechanical. Use-case naming is decided by ADR-023.

### ADR-015: Flutter localization (gen-l10n) from Phase 1, English only
- **Status:** Accepted 2026-10-03 (owner gate, B6; resolves ADR-P19)
- **Decision:**
  - Use the SDK's `flutter_localizations` + `gen-l10n` with ARB files in `lib/l10n/`.
  - English is the only locale in V1.
  - Generated localization files are committed (consistent with ADR-011).
- **Context:** Phase 1 introduces the first user-visible strings.
- **Reason:** Centralized copy from day one. Retrofitting strings later is expensive.
- **Consequences:** User-visible strings are never inlined in widgets. The visible product name comes from the `appTitle` ARB entry.

### ADR-016: "Daylight" visual identity as provisional v0
- **Status:** Accepted as **provisional** 2026-10-03 (owner gate, B7; resolves ADR-P12)
- **Decision:** Implement the tokens in [design_system.md](../ui/design_system.md): palette, Fraunces (display) + DM Sans (UI) bundled as OFL font assets, Day Arc motif, Plan-vs-Reality grammar.
- **Context:** Phase 1 builds the token system and the light/dark themes.
- **Reason:** The structure must exist before screens. Values are centralized, so they're cheap to change.
- **Consequences:**
  - The token *structure* is binding.
  - The *values* stay provisional until the owner reviews the dev token showcase on a device. Changes after that review update design_system.md and the token files together.
  - "Daylight" is a design-direction name, never the product name (ADR-010).
  - Brand, accent and status colors were replaced by activity-palette colors in ADR-029. Neutrals remain provisional.

### ADR-017: Two-level identity, INTEGER internal key + UUIDv7 public ID
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P02)
- **Decision:** Every user-owned entity table has:
  - `internal_id INTEGER PRIMARY KEY`, the SQLite rowid alias. It is used for **all foreign keys and joins**.
  - `public_id TEXT NOT NULL UNIQUE`, a UUIDv7 generated in the application layer (`Uuid7IdGenerator`, `core/ids/`). It is the stable, opaque domain identity used for routing, the domain layer, import/export, JSON references and future sync.
- **Context:** Hot paths (Today, history, values per log, field history) are joins. Integer keys are smaller and faster to compare and index than 36-character text keys. Cross-device identity still needs globally unique IDs.
- **Reason:** Integer joins for local performance; UUIDv7 for identity that never collides and never changes.
- **Consequences:**
  - `internal_id` **never leaves the data layer**. Domain entities, routes, exports and JSON payloads carry only `public_id`. Repositories translate between the two.
  - `public_id` is immutable, enforced by triggers. No `AUTOINCREMENT`: internal ids are local-only, so rowid reuse after a hard delete is harmless.
  - Child rows that are never referenced on their own (`log_values`) have only `internal_id`. Their identity is (log `public_id`, field `public_id`).
  - Exception: `app_preferences` (ADR-012).
  - Future sync maps `public_id` ↔ `internal_id` per device ([future_sync.md](../architecture/future_sync.md)).

### ADR-018: Normalized plans; a Task is a Plan without an Activity Type; logs reference plans
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P04). **Implemented 2026-10-04 (Phase 4, schema v4):** `plans` and `activity_logs.plan_id`.
- **Decision:**
  - One `plans` table: `internal_id`, `public_id`, `plan_date`, nullable `activity_type_id`, `title`, `notes`, `planned_start_at`, `planned_end_at`, `sort_order`, `status`, `created_at`, `updated_at`, `deleted_at`.
  - A **Task** is a plan with `activity_type_id IS NULL`; its title is its identity.
  - `activity_logs.plan_id` (nullable FK) records Plan → actual Activity Log explicitly.
- **Context:** Planned vs actual (§20, §43) must be explicit, not inferred. Separate plan and task systems would duplicate persistence and UI.
- **Reason:** One planning model; intention and reality stay in separate tables, linked by a foreign key.
- **Consequences:**
  - **No conflicting duplicate state.** Completion of an *activity* plan is **derived** from its linked, non-deleted logs. Stored `status` holds only what can't be derived:
    - `planned` (default)
    - `skipped`
    - `cancelled`
    - `completed`, **for tasks only**, which have no log. Enforced by `CHECK (status <> 'completed' OR activity_type_id IS NULL)`.
    - *Amended by ADR-040 (schema v8): any plan can store `completed` (Mark done, finished timer); a log makes an activity item in progress on its day and done once the day has passed.*
  - `in_progress` is derived (from an active focus session, Phase 5).
  - The domain computes the effective status; reality (a linked log) wins over a stored `skipped`.
  - Indexes: `(plan_date, sort_order)` and `(activity_type_id, plan_date)`, both partial on `deleted_at IS NULL`. Plus `activity_logs(plan_id)` partial on `plan_id IS NOT NULL` for derived completion.
  - **Planned duration sub-item: resolved 2026-10-04 (owner chose "Add it").** `planned_duration_ms INTEGER NULL` with `CHECK (planned_duration_ms IS NULL OR (planned_duration_ms > 0 AND planned_end_at IS NULL))`, so there is never a second source of planned duration. An end time also requires a start time (CHECK).
  - Integrity triggers (v4): a record may only fulfil a plan of its own activity type (never a task), and a plan with records keeps its activity type.

### ADR-019: Hybrid typed + JSON value storage
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P05)
- **Decision:**
  - `log_values` has dedicated typed columns: `text_value`, `number_value` (+ `unit_code`, `normalized_value`), `boolean_value`, `date_value`, `time_value`, `duration_ms`.
  - Exactly one is populated per row, chosen by the field type and enforced by CHECK plus a trigger.
  - `json_value` is used **only** for genuinely structured values: Multi Select (a list of option IDs) and Repeating Group.
- **Context:** Filtering, sorting, aggregation and analytics must not need JSON parsing on hot paths.
- **Reason:** Typed relational data for queryability and performance; JSON only where the shape is truly nested or list-valued.
- **Consequences:**
  - Every JSON payload has `"v"`, references fields/options/items by **stable IDs** (UUIDv7 `public_id`s, or UUIDv7 item IDs), and never uses display names for identity.
  - Decoders accept every past `"v"`. Format changes add a new `"v"` with a documented upgrade path ([data_architecture.md §5](../architecture/data_architecture.md#5-structured-values)).
  - Hot indexes: `UNIQUE (log_id, field_id)` (values of a log) and `(field_id, normalized_value)` (field history, field existence checks).
  - **Repeating Group storage:** resolved by **ADR-027**, which uses relational rows. `json_value` is therefore used only by Multi Select.

### ADR-020: Unit registry and write-time normalization
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P06)
- **Decision:**
  - A **code-defined Unit Registry** (domain) defines dimensions (mass, distance, duration, volume, temperature, energy) and units. Each unit has a stable code, dimension, affine conversion to the dimension's canonical unit (`canonical = value × factor + offset`), symbol and display decimals.
  - A Number field may declare a `dimension` (column on `activity_fields`) and a default display unit (config).
  - Values store the user's `unit_code`, the as-entered `number_value`, and `normalized_value` in the canonical unit, computed **at write time**.
- **Context:** Historical values must be comparable without converting thousands of rows per read.
- **Reason:** A deterministic, testable conversion on write; analytics read one column.
- **Consequences:**
  - Unit codes are permanent (never renamed or removed). Adding a unit is a code change only, with no schema change.
  - `normalized_value` equals `number_value` for unitless numbers and ratings, so analytics always read `normalized_value`.
  - Durations use the Duration field type (`duration_ms`). The registry's duration dimension serves conversion and formatting only, and is not offered as a Number dimension. That way there's one way to store a duration.
  - Measurements (Phase 6) use the same `unit_code` + `normalized_value` pattern.

### ADR-021: Durations are integer milliseconds; planned and actual are distinct
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P07). Supersedes the earlier P07 recommendation (seconds, plus a "timer target field").
- **Decision:**
  - Elapsed durations are `duration_ms INTEGER`.
  - **Actual** elapsed duration of an activity is `activity_logs.duration_ms`. A timed activity also stores `started_at`/`ended_at`; a manual entry stores `started_at` + `duration_ms`.
  - Duration-type fields (`log_values.duration_ms`) are for *additional* user-defined durations, never the activity's own elapsed time.
  - **Planned** duration lives only on plans (ADR-018).
  - Formatting ("1h 42m") is presentation only.
  - Running timers derive elapsed time from persisted timestamps and the `Clock` (Phase 5).
- **Context:** The spec has both a log duration and "Duration" fields (OQ-10). Planned and actual must never share a field.
- **Reason:** One source of truth per concept.
- **Consequences:**
  - CHECK `duration_ms <= ended_at − started_at` when both are present (active time ≤ wall-clock time).
  - Templates do not add a Duration field for the activity's own time; the log editor shows duration as a built-in row, like notes.

### ADR-022: Soft delete for user-owned entities, enforced in the data layer
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P08)
- **Decision:**
  - User-owned entities (activity types, fields, logs; later plans, measurements, focus sessions) have `deleted_at`.
  - Repositories exclude deleted rows by default through one shared query helper; callers can't forget the filter.
  - Hot-path indexes are **partial** (`WHERE deleted_at IS NULL`), so tombstones don't cost reads.
- **Context:** Undo, restore, future sync tombstones and historical integrity.
- **Reason:** Safe deletion without losing referenced history.
- **Consequences:**
  - Child rows of an aggregate (`log_values`) are not tombstoned. They are replaced with the log on edit (hard-deleted when cleared) and cascade only on a physical purge (not done in V1).
  - Historical reads (e.g. rendering a log whose field was removed) explicitly include deleted fields.
  - Restore clears `deleted_at` and bumps `updated_at`.

### ADR-023: Use-case naming, Verb + domain object/capability
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P10)
- **Decision:**
  - Use cases are named for user/business intent: `CreateActivityType`, `UpdateActivityType`, `DeleteActivityType`, `LogActivity`, `UpdateActivityLog`, `WatchToday`, and so on.
  - No `Manager`/`Handler`/`Processor`/`Service` names without a specific architectural reason.
- **Context:** Names should state capability.
- **Reason:** Readable, searchable application layer.
- **Consequences:**
  - Each use case is a small class with a single `call(...)` method (callable class). The owner's decision covered class names; `call` is the convention applied, recorded here.
  - **All write operations** go through use cases (they enforce domain rules). Composite reads (e.g. `WatchToday`) are use cases. Simple single-repository reads may be watched directly through repository providers.

### ADR-024: Phosphor icons via bundled official font + abstract icon registry
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P13)
- **Decision:**
  - Phosphor is the single icon family.
  - Integration: the **official Phosphor font files** (`Phosphor.ttf` regular, `Phosphor-Fill.ttf` fill) from Phosphor's own MIT-licensed `@phosphor-icons/web` 2.1.2 package, bundled as assets.
  - A code **icon registry** maps stable `icon_id`s (e.g. `barbell`) to `const IconData`.
  - SQLite stores only `icon_id`.
- **Context:** Verified 2026-10-04:
  - The official Flutter wrapper `phosphor_flutter` 2.1.0 (last release May 2024) **fails to compile on Flutter 3.47**: it subclasses `IconData`, which is now a `final` class. The analyzer passes, but the release compiler rejects it.
  - The other Phosphor wrappers on pub.dev are unofficial and very new.
- **Reason:** Official, MIT-licensed glyphs; no fragile wrapper dependency; the database stays independent of any icon library.
- **Consequences:**
  - Unknown/legacy `icon_id`s fall back to a neutral glyph.
  - Adding an icon = registry entry (codepoint from Phosphor's `selection.json`/`style.css`).
  - Release builds tree-shake both fonts to the glyphs used. Verified 2026-10-04: `Phosphor.ttf` went from 488 KB to 24.7 KB and `Phosphor-Fill.ttf` from 449 KB to 2.3 KB.
  - Glyph constants, activity icon IDs and the registry are generated by `tool/generate_phosphor_glyphs.py`.
  - The registry is the only place glyphs are referenced; replacing the library later changes only the registry.

### ADR-025: Single application error model
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P16)
- **Decision:**
  - Raw DB/platform error → repository translation → sealed `AppException` → use case → Riverpod `AsyncValue` → user-facing message.
  - Categories:
    - `ValidationException` (carries field issues)
    - `NotFoundException`
    - `StorageException`
    - `MigrationException`
    - `UnsupportedException`
  - Each has a stable category, a safe message key mapped to localized copy in presentation, and optional debug context (never shown to users).
- **Context:** Database exceptions must not leak into UI; messages must be human-readable.
- **Reason:** One predictable error path.
- **Consequences:**
  - Domain validation returns a `ValidationResult` for live form feedback; use cases throw `ValidationException` when given invalid input.
  - Trigger/constraint violations are translated to `ValidationException` (rule broken) or `StorageException`.
  - Other categories are added only when justified.

### ADR-026: Relational activity type/field schema with locked field semantics
- **Status:** Accepted 2026-10-04 (owner decision; resolves ADR-P20)
- **Decision:**
  - `activity_types` has explicit columns: `internal_id`, `public_id`, `name`, `icon_id`, `color_key`, `description`, `supports_timer`, `supports_planning`, `sort_order`, timestamps.
  - `activity_fields` has explicit columns: `internal_id`, `public_id`, `activity_type_id`, `name`, `field_type`, `dimension`, `position`, `required`, `measurable`, `config_json`, timestamps.
  - `config_json` holds only field-type-specific configuration: numeric constraints, select options (with stable option IDs), rating scale, text presentation, default unit.
  - No dynamic columns and no per-activity tables.
  - All activity-engine tables are SQLite `STRICT` tables.
- **Context:** Generic engine (ADR-006) with strong integrity and fast access.
- **Reason:** Queryable metadata stays relational; flexible configuration stays in JSON.
- **Consequences:** **Historical data safety is enforced by database triggers**, not only the domain:
  - A field's `field_type`/`dimension` can't change once values exist.
  - A field can't move to another activity type.
  - A log's activity type can't change.
  - A value's field must belong to its log's activity type and use the storage column of its field type.
  - `public_id`s are immutable.

  Violations surface as `ValidationException`. Every index has a documented query justification ([database.md §6](../architecture/database.md#6-indexes-and-query-plans)).

### ADR-027: Repeating Groups are stored as relational rows
- **Status:** Accepted 2026-10-04 (owner decision; resolves the ADR-019 sub-item). **Implemented 2026-10-04 (Phase 3, schema v3).**
- **Decision:** A Repeating Group's structure is relational:
  - **Sub-fields are real `activity_fields` rows** with `parent_field_id` → the group field. Each has its own `public_id`, `field_type`, `dimension` and semantics lock.
  - **Items are `log_group_items` rows:** `internal_id`, `public_id` (stable item ID), `log_id`, `field_id` (the group field), `parent_item_id` (nested groups), `position`, timestamps.
  - **Item values are ordinary typed `log_values` rows** with `group_item_id` → their item.
  - Nesting is limited to two levels (group → group), e.g. Gym: Exercises { Exercise: Text, Sets { Weight: Number (mass), Reps: Number } }.
- **Context:** Workout sets and similar nested values feed Insights (max weight, volume, progression). ADR-019 requires keeping analytics out of JSON.
- **Reason:**
  - Nested values become typed, unit-normalized and indexable like any other value.
  - Integrity is enforced by FKs and triggers.
  - Item identity is stable for edits, reordering and future sync.
- **Consequences:**
  - The Phase 3 migration (schema **v3**):
    - adds `activity_fields.parent_field_id`
    - adds the `log_group_items` table
    - rebuilds `log_values` (12-step pattern), because its table-level `UNIQUE (log_id, field_id)` becomes two partial unique indexes (top-level values vs item values) and it gains `group_item_id`
  - Triggers are extended for parent/child consistency.
  - Repeating Group fields have no `log_values` row of their own; their presence is their items.
  - Plans moved to schema v4 (implemented in Phase 4).
  - Design: [database.md §3.10](../architecture/database.md#310-repeating-groups-v3-implemented-adr-027), [data_architecture.md §5.3](../architecture/data_architecture.md#53-repeating-group-implemented-in-phase-3-adr-027).

### ADR-028: Primary navigation, date-based Plan, Activities under Me, "Record" terminology
- **Status:** Accepted 2026-10-04 (owner product decision; supersedes the spec's recommended navigation in §34 and the Track entry points in §36).
- **Decision:**
  - **Primary navigation: Today | Plan | Insights | Me.** Track is removed.
  - **Plan** is the date-based planning system. A calendar/date selector navigates to any past, present or future date and shows that date's plans alongside what was actually recorded.
  - **Today** is the specialized view of the current date: today's plan, today's reality, and their relationship.
  - **Me → Activities** is where reusable Activity Types are created and configured (builder, templates). It's for setup, not daily recording.
  - **Quick Record:** records an activity that wasn't planned. *Amended 2026-10-04 (owner): no floating Record button on every tab, and no rail action.* ~~Quick Record now opens from Today's **Record something**.~~ *Superseded by ADR-035:* there is no Quick Record sheet. Anything unplanned is added to the day with **Now** and opened to log into it; an activity's page keeps its Record button, which does the same.
  - **Terminology:**
    - "Record" is the user-facing action.
    - Activity Log is the internal/domain name.
    - Activity Type is the reusable definition.
    - Plan is an intended activity/task for a date.
    - Insights covers progress, measurements and patterns.
- **Context:** Daily use is plan → do → record. Configuring activities is occasional, so it doesn't deserve a primary tab.
- **Reason:** Navigation follows the core loop. Setup moves out of the way, and recording stays reachable everywhere.
- **Consequences:**
  - Routes: Me → `/me/activities`, `/me/activities/:typeId`. Plan stays at `/plan` and holds a selected-date state.
  - The Plan tab shows the selected date's plans paired with their records (Phase 4), plus what was recorded without a plan.
  - Code keeps the domain names (`ActivityLog`, `LogActivity`). Only user-facing copy says "Record".

### ADR-029: The app's colors come only from the activity palette
- **Status:** Accepted 2026-10-04 (owner decision; partly resolves ADR-016's provisional values).
- **Decision:**
  - Apart from neutrals (canvas/surfaces, text, borders, scrims), every color in the app is one of the activity-palette colors (design_system.md §2.4).
  - **Amendment (same day, owner):** `sand` is removed from the palette everywhere, leaving **nine** colors. Warning moves to apricot.
  - Mapping:
    - **brand = teal**
    - **accent = apricot** (rating stars, highlights)
    - **success = moss**
    - **warning = apricot** (originally sand; see the amendment)
    - **danger = rose**
  - Each role uses that color's `solid` value, and its `soft` value for containers.
- **Context:** The owner wants one cohesive color family across the product.
- **Reason:** A single recognizable palette for activities, actions and status.
- **Consequences:**
  - The indigo brand and the separate status/accent colors are removed.
  - Light-mode moss and apricot are under 4.5:1 against the canvas, so they're used **only as graphics** (icons, fills, accents) with readable text beside them. Rose (4.54:1) may carry error text, and teal carries white text at 4.59:1.
  - `palette_consistency_test.dart` keeps the tokens identical to the palette, and `color_contrast_test.dart` enforces the contrast rules above.
  - Neutrals stay provisional under ADR-016.
  - **Superseded in part by ADR-038:** the palette is now six colors (sage, apricot, moss removed); accent/warning = coral, success = teal.
  - Removing `sand` means a stored `color_key = 'sand'` renders with the `slate` fallback, and the builder asks for a new color on the next save. No migration is needed: the app is pre-release and no template used sand.

### ADR-030: Plan and Record are one user workflow
- **Status:** Accepted 2026-10-04 (owner correction after reviewing Phases 3–4). Refines ADR-018 and ADR-028. **Implemented 2026-10-04.** **Partly superseded by ADR-035 (2026-10-04):** the separate record form, "Track details", "Record again", the Start focus / Record now choice and Quick Record are gone; a plan opens as an item you log into. What still holds: the domain concepts, the day-planner quick add (names match activities and templates), planned-slot prefill, plan options behind More, and one session = one record.
- **Decision:**
  - The domain keeps three concepts: Activity Type (definition), Plan (intention) and Activity Log (reality, "Record" in the UI). The **user workflow is one flow**: plan an activity for a date → tap it → record what actually happened → the record links to the plan → the plan shows as done.
  - **Tapping a plan does the plan:**
    - An activity plan that has no record yet (open or skipped) opens **its record form**, linked to the plan (`/logs/new/:typeId?plan=`). For Gym that is the exercises and sets, duration and notes.
    - A recorded activity plan opens **its record** (the latest, if there are several).
    - A task (no activity, e.g. "Food") offers **Mark as done** or **Track details**. Its check control ticks it directly.
  - **Anything can be tracked, with fields the user chooses.** "Track details" opens the activity builder prefilled with the plan's name. The user adds whatever fields they want (Calories, With whom, Pages, sets…). Saving the activity links the plan to it and opens its record form. Later plans with that name link to it automatically.
  - **What an activity tracks can change while recording.** The record form has "Edit what to track", which opens that activity's builder; the form reloads with the new fields and keeps what was entered.
  - Starter templates (Gym, Reading, Meeting…) are only optional shortcuts; nothing is specific to them.
  - **Plan options** (edit details, Skip, Reopen, Move to tomorrow, Delete, and "Record again" for a recorded plan) sit behind a secondary **More** control on the plan, not behind the tap.
  - "Mark as done" exists **only for tasks**. An activity plan completes by being recorded (derived, ADR-018).
  - **One session = one record.** A Gym session with ten sets is one record with ten Repeating Group rows (ADR-027). Doing Gym twice is two records; "Record again" links a second record to the same plan.
  - **The app is a day planner.** Plans are time slots ("21:10–21:55 Reading", "07:30 Gym", "Bath"). Quick add takes a from–to time.
    - Typing an activity's name ("Gym") plans that activity, not a task with that title.
    - Typing a starter template's name that isn't installed yet installs the template first.
    - Anything else is a task.
  - The record form shows the plan it fulfils ("Planned · Reading · 21:10–21:55") and **prefills the plan's slot** (owner example: Reading 21:10–21:55 → 45 minutes):
    - **start:** the planned start when there is one; otherwise now (today's plan) or the plan's date at the current time
    - **duration:** the planned length, as a starting point the user corrects to what actually happened
  - Quick Record stays the path for unplanned activities.
- **Context:** In the first Phase 4 build, tapping a plan opened a planning sheet whose visible actions were Skip/Move/Delete/Mark as done. Recording was a small "Start" button, so Plan and Record felt like separate workflows.
- **Reason:** Planning exists to be lived. The planned item is the natural entry point for recording reality, while intention and reality stay separate in storage for planned-vs-actual.
- **Consequences:**
  - The plan tile has no Start button. It shows ✓ when recorded/done and a More button for options.
  - No schema or domain-rule change: `activity_logs.plan_id`, derived completion and the Repeating Group storage are unchanged.

### ADR-031: Focus sessions derive time from timestamps; the record is created on finish
- **Status:** Accepted 2026-10-04 (owner chose "Record on finish"; resolves ADR-P09). **Implemented 2026-10-04 (Phase 5, schema v5).** **Finish amended by ADR-035:** the timer runs inside its item while you log; finishing writes the timed span into the item's log (creating it if needed) instead of opening a record form. Timestamp-derived time, one active session and the single transaction are unchanged.
- **Decision:**
  - `focus_sessions` stores `state` (running, paused, finished, discarded), `started_at`, `paused_at`, `paused_duration_ms`, `ended_at`, `duration_ms`, the activity, and the optional plan and record.
  - **Elapsed time = (end, or pause, or now) − start − completed pauses.** It is computed from persisted timestamps and the `Clock`, never counted in memory, so it survives backgrounding and process death (FR-FO-06).
  - **One active session** (OQ-11), enforced by a unique partial index.
  - **Finish:** the session is paused (time frozen) and the record form opens, prefilled with the start and the focused time. Saving creates the record (with `ended_at`, `duration_ms` and the session's plan) and marks the session finished **in one transaction** (`UnitOfWork`). Backing out keeps the session paused. Discard soft-deletes the session and creates no record.
  - A plan with an active session shows **In progress** (derived). Tapping a planned timer activity offers "Start focus" or "Record now".
- **Context:** The spec links a session to a log that doesn't exist yet. A long session (§43: 1 h 42 m) must survive the app being killed.
- **Reason:** No half-finished records; reality is written once, atomically. Required fields are filled in the familiar record form.
- **Consequences:**
  - `ActivityLogDraft.endedAt` was added. Its rules: the end must not be before the start, and the duration can't exceed the elapsed time (ADR-021).
  - No ongoing notification (OQ-13 stays "not in V1"). The timer's correctness doesn't depend on one.

### ADR-032: DM Mono for numeric tokens
- **Status:** Accepted 2026-10-04 (owner chose "Bundle DM Mono"; resolves ADR-P21). **Implemented 2026-10-04.**
- **Decision:** `numericHero`, `numericLarge` and `numericMedium` use the bundled **DM Mono** (OFL, Regular + Medium; `assets/fonts/dm_mono/`). Every digit has the same width, so a running timer doesn't jitter. All other text keeps DM Sans and Fraunces.
- **Context:** Neither bundled variable font has `tnum` (Phase 1 finding).
- **Consequences:** Adds about 100 KB of font assets. The design-system numeric rows refer to DM Mono.

### ADR-033: Charts use fl_chart behind one shared component
- **Status:** Accepted 2026-10-04 (owner chose fl_chart; resolves ADR-P11, overriding its CustomPaint recommendation). **Implemented 2026-10-04.**
- **Decision:**
  - `fl_chart` (MIT, no network or telemetry, Android + iOS) is wrapped by `shared/widgets/charts/AppChart` (line and bar, one or more series, gaps for empty buckets).
  - Features never use fl_chart directly. The wrapper styles it only with design tokens (palette accent, neutral grid, theme text styles).
- **Reason:** Faster to build richer charts (tooltips, grouped bars) with a maintained package, while the wrapper keeps the identity consistent and the package replaceable.
- **Consequences:** One new dependency (`fl_chart ^1.2.0`). Chart visuals are reviewed in the visual checklist.

### ADR-034: Insights scope, measurements and saved charts
- **Status:** Accepted 2026-10-04 (owner chose "Core + gym & PRs"; resolves OQ-02 and the V1? status of FR-AN-05/06/08/09). **Implemented 2026-10-04 (Phase 6, schema v6).**
- **Decision:**
  - **One generic engine** (FR-AN-01): a chart is a series of `(local_date, value)` points from a source, bucketed (day/week/month) and aggregated (total, average, best, lowest, count, latest) over a range (week/month/3 months/year).
  - **Sources**, all read with relational SQL over typed, canonical columns:
    - an activity's recorded time
    - how often an activity was recorded
    - any Number or Rating field at any depth, with an optional text filter on the same item, its parent item or the record (e.g. Weight where Exercise = "Chest Press")
    - **volume** = product of two number sub-fields per group item (weight × reps)
    - a body measurement
    - planned vs actual time by plan date
  - **V1 includes** (owner): totals, counts, averages, line/bar charts, this period vs the previous one, **personal best** (all-time highest value of a field or volume), volume, and planned-vs-actual trends.
  - The Insights tab shows per-activity totals for the range against the previous one, and the user's **saved charts**: an `insight_charts` table with versioned JSON configs referencing stable public IDs.
  - **Saving charts departs from the OQ-14 recommendation** (ad hoc charts, no persistence in V1). It was built so FR-AN-07's configuration isn't lost each visit. **It awaits owner confirmation of OQ-14.** If the owner prefers ad hoc charts, the table stays unused and the builder becomes a transient picker.
  - **Body measurements** use a `measurements` table with the same value + unit + canonical pattern (ADR-020). The fixed V1 types follow the documented OQ-09 recommendation (weight, height, body fat, chest, waist, arms, legs; custom types deferred), and the domain validates them. The unit registry gained `cm`, `in` and a percentage dimension (`percent`).
- **Context:** The spec's §44 lists PRs and planned-vs-actual analytics as future, while §13/§20/§43 imply them. The owner chose to include them.
- **Consequences:**
  - No activity-specific chart code. Gym volume and PRs are generic metrics over Repeating Group rows.
  - Duration fields aren't chartable as field values yet: they store `duration_ms`, not `normalized_value`.

### ADR-035: An item on your day is where you log; it saves as you type
- **Status:** Accepted 2026-10-04 (owner, after using Phases 1–6 on a phone: "the flow is missing… user should not go somewhere else"). Supersedes parts of ADR-028, ADR-030 and ADR-031. **Implemented 2026-10-04.**
- **Decision:**
  - **One user-facing concept: an item on a day.** It has a title, date, optional time and planned length, a state (planned, in progress, done, skipped) and what was logged into it. Storage is unchanged: a `Plan`, at most one live `ActivityLog` for it (`activity_logs.plan_id`), and the `ActivityType` that remembers its layout.
  - **Opening an item is where you log into it** (`/item/:planId`). The same screen serves planned, in-progress and done items. Records made without a plan (older data, or from an activity's page) open the same way (`/item/log/:logId`).
  - **Saved as you type.** There is no Save button and nothing to discard. The first change creates the log (start = the planned start, or now); later changes update it. You can leave mid-session and come back to add more (e.g. another set).
  - **Required is a hint while logging.** Auto-saved logs are *partial*: `LogValidator.validate(partial: true)` skips missing required values; type, range and unit checks still apply. The `*` on the label marks what's expected.
  - *(Amended by ADR-042: new items come from an activity, yours, built in or made your own; this still applies to older items without one.)* **Anything can be logged without setup.** The first thing logged into an item with no activity (a task or a new name like "Doctor call") gives it an activity named after it (an existing one with that name, or a new one with no fields), so later items with that name share it.
  - **Add to log, right in the item.** Every item has **Add to log**: ready-made shapes in one tap (*Sets & reps* = Exercises → Sets → Weight kg × Reps; *Checklist* = Item + Done) or one thing of any field type (Text, Number with unit, Yes/No, choices, Date, Time, Duration, Rating, **List**), named and configured in the field sheet. Lists offer **Add detail** in place. What's added goes onto the item's activity (`AddItemField`, created for it first if needed), so the next item with that name has it. The pencil in the item opens the builder to rename, reorder or remove.
  - *(Amended by ADR-040: logging makes an item in progress; Mark done or finishing the timer makes it done.)* **Done** = something was logged, or **Mark done** (an activity item gets a log at its planned time and length; a task is ticked off). A running timer shows the item as **In progress** even if something is logged.
  - **The timer lives in the item.** Start timer / Pause / Finish sit at the top of the item, and you keep logging while it runs; the full-screen timer is optional. Finishing writes the timed span into the item's log in one transaction (a second session on the same item adds its time).
  - **Today and Plan show one list of items**: plans and records made without a plan, in time order (a plan's time is its planned start, or when it was logged), then untimed plans in manual order. The separate "Recorded / Also recorded" sections are gone.
  - **Adding:** the quick add on Today and Plan, with **Now** (today only) for what you're doing right now: it adds the item at the current time and opens it. An activity's page "Record" does the same for that activity. *Amended by ADR-039: "Now" became the **Start now** action; time is one sheet.*
  - **Deleting an item** deletes the plan and what was logged into it; Undo restores both.
- **Context:** On a real device the owner found plan, record and setup felt like three separate places. They want the planner to be the app: plan Gym, then at the gym open it and log sets into it, with nothing else to go through.
- **Reason:** Planning exists to be lived; the planned item is where reality gets captured, as it happens.
- **Consequences:**
  - Removed: the record form (`LogEditorScreen`), the Quick Record sheet, the Start focus / Record now sheet, "Track details" and "Record again".
  - Domain additions: `EnsureItemActivity`, `AddItemField`, `definitionOf(ActivityType)`, `MarkItemDone`, `DeleteItem` / `RestoreItem`, `partial` on `LogActivity` / `UpdateActivityLog`, `ActivityLogRepository.getLogForPlan`, `ActivityTypeRepository.getActiveTypes`, `DayOverview.entries`. `FinishFocusSession` takes only the session.
  - No schema change.
  - The rest of the rework: ADR-036 (planner, repeating plans, Plan next) and ADR-037 (automatic insights).

---

### ADR-036: Week/month planner, repeating plans as generated occurrences, Plan next
- **Status:** Accepted 2026-10-04 (owner-approved rework, step 3). **Implemented 2026-10-04 (schema v7).**
- **Decision:**
  - **Plan tab: Day | Week | Month.** *(Superseded by ADR-039: Week | Month, and a tapped day opens a day screen like Today.)* Day is the existing date view. Week stacks the seven days (locale's first day of the week) with their items; a day's heading opens it and "+" plans on it. Month is a calendar with a dot per planned item, in its activity's color; tapping a day opens it.
  - **Repeating plans** (`plan_series`): weekdays, every 1–4 weeks (stored 1–52) counted from the start week, optional last date. A plan becomes repeating from its options ("Repeat…"); it is the first occurrence.
  - **Occurrences are ordinary plans**, generated for the dates being viewed (Today, a day, a week, a month grid) by `EnsureSeriesOccurrences`, idempotently. So every occurrence can be opened and logged into, skipped, moved or deleted like any plan, and planned-vs-actual just works.
  - A unique index on `(series_id, plan_date)` that includes deleted rows means a deleted (or moved) occurrence is never generated again.
  - **Changing the repeat from an occurrence** = "this and following": the old series ends the day before (deleted if it hadn't started), its later open occurrences (planned, nothing logged) are removed, and a new series starts from this one. **Stop repeating after this** keeps the occurrence and removes later open ones. Editing an occurrence's title or time changes only that one.
  - **Moving an occurrence** moves a one-off copy (no longer repeating) and deletes the occurrence on its date; Undo deletes the copy and restores the occurrence.
  - **Plan next…** (any item): pick a date (a week later is suggested) and, for a timed plan, a time → the same title and activity on that date, with the same planned length. Not tied to any kind of activity.
- **Context:** The owner wants the planner to be the app: day, week and month planning, Gym every Mon/Wed/Fri, and the next appointment planned from where you are.
- **Reason:** Materialized occurrences keep one model for everything you log into, and need no special read paths. Generating only what's viewed keeps it cheap and unbounded series safe.
- **Consequences:** Schema v7 (`plan_series`, `plans.series_id`, `ux_plans_series_date`). New use cases `EnsureSeriesOccurrences`, `RepeatPlan`, `StopRepeating`, `PlanNext`; `MovePlan` returns the moved plan. `PlanRepository` gained range and series methods. A repeating plan shows a repeat icon. Phosphor `repeat` and `calendar-plus` were added to the UI icon set (same font version).

### ADR-037: Automatic per-activity insights, worked out from fields
- **Status:** Accepted 2026-10-04 (owner-approved rework, step 4). **Implemented 2026-10-04.** OQ-14 (keep saved charts?) still awaits the owner; until then saved charts stay, below the automatic ones.
- **Decision:**
  - Insights lists each activity done in the range with **days done**, time and how often, and the change vs the previous period. Tapping one opens its **progress page**.
  - The progress page's charts are **generated from the activity's fields**, never from what the activity is (`autoChartsFor`):
    - time spent and times done, per week
    - each top-level Number (total per week) and Rating (average)
    - inside lists: for each row name logged so far (from the list's first Text field, e.g. each exercise), the best of its Number; when a list has two Numbers (e.g. weight and reps), the best of the first and the **volume** (first × second, summed)
    - at most 4 row names per list and 16 charts
  - They use the existing engine (ADR-034) and chart card, with the selected range, change vs previous period and personal best. They aren't saved and have no edit menu.
  - *Amended 2026-10-05 (backlog A20/A23): their bucket follows the selected range (`InsightRange.bucket`: days for Week, weeks for Month and 3 months, months for Year), and charts with nothing in the period are left out.*
  - The user's own saved charts stay below, as "Your own charts" (pending OQ-14).
- **Context:** The owner: "in a week how many days which activity is done… based on that data graph of progression" without building charts.
- **Consequences:** `ActivityTotals.days` (distinct `local_date`s); `InsightChartConfig` has value equality (so generated charts are stable provider keys); route `/insights/activity/:typeId`.

### ADR-038: Six colors, white shades and mist
- **Status:** Accepted 2026-10-04 (owner decision; amends ADR-029, resolves ADR-016's provisional neutrals).
- **Decision:**
  - The whole app uses only white shades, mist `#DDF0EF` and the activity-palette colors **sky, lilac, teal, rose, slate, coral**.
  - `sage`, `apricot` and `moss` are removed from the palette. Accent and warning move to **coral**, success to **teal**.
  - Neutrals: light surfaces are white shades (`#F7FBFB` canvas, `#FFFFFF` cards) with mist as the sunken surface; text and borders are slate shades; dark mode uses deep slate surfaces and white-shade text.
- **Context:** The owner found the warm linen neutrals and the extra colors made the app feel off and asked for one tight color set.
- **Consequences:**
  - Stored `color_key` values `sage`/`moss` resolve to teal and `apricot` to coral via `ActivityColorKey.fromName`, so nothing breaks and no migration is needed; the builder writes the replacement key on the next save.
  - Success and brand share teal; completion is still told apart by icon and copy, not color alone.
  - Six activity colors for seven templates: Language and Gym both use coral.

### ADR-039: Plan tab is Week | Month; one quick add with Start now, a time sheet and suggestions; unique activity names
- **Status:** Accepted 2026-10-05 (owner approved improvement backlog items A1–A8, [improvement_backlog.md](../product/improvement_backlog.md)). Amends ADR-035 (adding) and ADR-036 (Plan views).
- **Decision:**
  - **No separate Day view.** The Plan tab is **Week | Month** (opens on Week). Tapping a day opens a **day screen** (`/plan/day`, the Plan tab's selected date) that shows exactly what Today shows for today: the shared `DayItems` (quick add, day summary, items). It steps a day at a time and has a calendar button. One "+" per screen.
  - **Quick add actions.** The "Now" toggle chip is replaced by actions that appear once something is typed: **Start now** (today only: adds the item at the current time and opens it) and **Set a time**. Enter or "+" adds it untimed or at the chosen time.
  - **One time sheet** replaces the two clock dialogs: suggested starts (the next half hours after now on today, typical times on other days, "Other time…"), then a length (No end, 15 min, 30 min, 1 h, 2 h, "Until…"); lengths past midnight are disabled. Pure rules in `PlanTimeSuggestions`.
  - **Suggestions while typing:** up to four matches (`suggestByName`): your activities first, then templates no activity has the name of yet.
  - **Recent chips:** plannable activities ordered by use in plans from four weeks back to a week ahead (`rankByUse`, `recentActivityTypesProvider`), at most eight, under a "Recent" label.
  - **Activity names are unique** among active activities (trimmed, case-insensitive): `CreateActivityType` and `UpdateActivityType` reject a taken name with `ValidationCode.duplicateActivityName` on `name`. Archived activities don't count. Quick add never installs a template whose name an activity already has.
  - **Me** shows "Your setup" (Activities, Body measurements); developer tools sit in a separate section that only debug builds show. `TabPlaceholder` was removed.
- **Context:** A hands-on evaluation found Today and Plan → Day were the same screen with two "+", "Now" was a hidden toggle, time took two dialogs defaulting to 9 AM, chips had no label, and duplicate "Gym"/"Reading" activities could be created.
- **Consequences:**
  - No schema change. Existing duplicate names stay as they are; only new creates and renames are checked (A24 handles showing them).
  - The debug demo data refuses to load when one of its activity names is taken (`DemoDataResult.namesTaken`).
  - Tests: unique names (repository), time suggestions, suggestions, usage ranking (domain), quick add, time sheet, day screen and template picker (widget). Device integration test updated, not run.

### ADR-040: Any item can be marked done; logging makes it in progress (schema v8)
- **Status:** Accepted 2026-10-05 (owner chose the "proper fix" for backlog item A10). **Implemented 2026-10-05 (schema v8).** Amends ADR-018 (completion of activity plans) and ADR-035 ("Done = something was logged").
- **Decision:**
  - `plans.status = 'completed'` is allowed for activity plans too: schema v8 drops `CHECK (status <> 'completed' OR activity_type_id IS NULL)` (table rebuild, internal IDs kept; triggers on `activity_logs` / `focus_sessions` that read `plans` are dropped and recreated).
  - Effective status (`Plan.effectiveStatus(hasRecord:, today:, inFocus:)`): a running timer → in progress; stored `completed` → done; otherwise, for an activity item with something logged → **in progress on its day (or later dates), done once its day has passed**; else the stored status. Something logged still wins over skipped/cancelled.
  - **Mark done** (`MarkItemDone`) works for any item: an activity item with nothing logged first gets a log at its planned time and length; then the plan is stored as completed. It returns the log it created, so Undo can remove it.
  - **Finishing the timer** on an item stores it as completed.
  - **Reopen** ("Mark as not done") sets any item marked done back to planned. Something logged on a past day counts as done by itself and isn't toggled.
  - `ValidationCode.onlyTasksCanBeCompleted` is removed.
- **Context:** Logging the first exercise of a workout marked the whole session done (evaluation finding A10).
- **Consequences:**
  - The item screen keeps **Mark done** at the bottom until it's done ("Logged so far. Mark it done when you've finished." once something is logged). The row check toggles done/not done for every item (A17).
  - "N done" on a day counts items marked done (or past days' logged items), not every item with a log.
  - Migration test v7→v8 keeps plans, their logs, series links and sort order, and checks the rebuilt table's triggers still guard it.

### ADR-041: Logging from memory, quick choices, rest timer and quick actions (Phase B)
- **Status:** Accepted 2026-10-05 (owner approved backlog Phase B, B1–B8). **Implemented 2026-10-05.** No schema change.
- **Decision:**
  - **Use last time (B1):** an empty item of an activity shows its most recent log with something in it ("Last time · Fri, Oct 2" + summary) and **Use last time**, which copies the values with fresh list-row IDs (`copyValues`) into the item, ready to adjust. Never automatic: nothing is copied until tapped.
  - **Row memory (B2):** a list row that has its name and nothing else shows "Last time: Chest Press 60 kg × 8 (×2)" from the newest earlier row with that name (any depth, case-insensitive; `findLastRow`, `LastRowNamed`) and **Use** to copy its details. Generic: the name is the row's first Text sub-field. Only while logging into an item (`RowMemoryScope`).
  - Lookups read once through `ActivityLogRepository.recentLogsForType` (latest 10 / 30 logs), not the live history stream.
  - **Quick choices (B3):** an item with nothing to log offers chips for "How it went" (a 1–5 rating added at once), "An amount" (a number you name) and "Sets & reps", plus "More…". The "Add to log" sheet lists these quick choices first and puts every field type under "More kinds of detail".
  - **Plainer field sheet (B4):** field types read "Words", "An amount", "Yes or no", "One choice", "Several choices", "A date", "A time of day", "Time spent", "A rating", "A list". Required, Show in insights, decimals, min/max and the text options sit under **Advanced**.
  - **Rest timer (B5):** all-number lists (e.g. sets) offer **Rest** in an item; a bar at the bottom counts down (90 s by default; −15 s / +15 s; the last length is remembered while the app runs) and buzzes lightly at the end. It's in memory only (`restTimerProvider`) and never logged.
  - **Quick finish (B6)** is the row check from A17 (ADR-040).
  - **Quick actions (B7):** long-press a day row → mark done / not done, move to tomorrow, **Duplicate** (`DuplicatePlan`: same day, title, activity, time and notes; a planned one-off), skip, delete; each with Undo.
  - **Template gallery (B8):** cards per template (badge, name, fields, or "Already in your activities"); tapping previews the real form (`previewType`, shared with the builder) with **Add {name}**. New templates: Running, Study, Meditation, Water, Sleep, Mood. Body weight stays in Me → Body measurements.
- **Context:** The evaluation found logging asked people to design forms and start from blank every time (backlog Phase B).
- **Consequences:** No schema change; templates and quick choices are plain data and nothing treats them specially. A one-time read was added to the log repository. The rest timer's haptic needs no permission.

### ADR-042: One concept, the activity: every item comes from one (yours, built in, or made your own)
- **Status:** Accepted 2026-10-07 (owner); amended the same day (owner: "consider only the word activity"). **Implemented 2026-10-07.** Amends ADR-035 ("Anything can be logged without setup"), ADR-039 (quick add) and ADR-041 (B8 gallery). No schema change.
- **Product rule (owner):**
  - **There is one concept: the activity.** It's what you put on a day and log inside (Plan → Do → Log). The word "template" is not used in the app or the docs: a ready-made one is a **built-in activity**, and it looks and behaves like the user's own.
  - **Built-in activities = convenient starting points.** They cover common everyday activities across life areas and cultures so most people find a fast start. The list is never meant to be complete, and nothing is forced into one.
  - **Your own = unlimited flexibility.** **Make your own** is a first-class choice wherever something is added to a day. The user names it and decides what to record with the generic field types; it is saved and reused.
  - **Generic fields = the user decides what matters.** Text, Number (with optional unit dimension), Yes/No, choices, Date, Time, Duration, Rating and Repeating Group express anything ("Build my company": Hours, Task, Progress, Notes, Money spent; "Car maintenance": Kilometres, Fuel, Cost, Issue, Notes). No new code, field type or built-in activity is needed for a new kind of activity.
  - **Activity Log = what actually happened**, as before.
- **Decision:**
  - **One list of activities** (`ActivityCatalog`), used by Me → Activities and **Browse activities**: search (name, category or what it logs), then **Yours** (the user's activities), then the built-in ones under their life-area headings, in the same card (badge, name, what it logs). A built-in activity whose name one of yours already has is left out, so each name appears once. Tapping one of yours opens it (Me) or chooses it (Browse); tapping a built-in one previews its form with **Use {name}**, which saves it as yours and opens or chooses it.
  - Quick add (Today, a day) and the plan sheet ("+" in Week) add only activities: typed name or chip, **Browse activities**, or **Make your own**. In quick add, what's chosen in Browse activities or Make your own is added to the day at once. Suggestions show yours, then built-in ones, each with what it logs and no label telling them apart. A new name offers "Make “{name}” your own"; enter does the same: the builder opens with the name, and on save the new activity is added to the day. Backing out adds nothing.
  - The plan sheet no longer offers "Just a task" for new plans. Existing plans without an activity still open, edit and log (`EnsureItemActivity` stays for them).
  - Navigation stays in the router: the day screens receive an `ActivityChooser` (browse, make your own) that returns the activity's ID.
  - Code uses the same word: `builtInActivities`, `activityCategories`, `starterActivities`, `AddBuiltInActivity`, `BrowseActivitiesScreen` (`/activities/browse`), ARB keys `builtIn…`.
- **Context:** The owner wants the product to eventually manage a person's whole life. That only scales if any activity a person invents is data with the fields they choose, and if people see one simple idea instead of two.
- **Consequences:**
  - Plain one-off tasks ("Buy milk") are now small activities with no fields; the domain still accepts plans without an activity (enforced in the UI only), so older data keeps working.
  - Verified by `test/features/activity_logs/data/custom_activity_test.dart`: the owner's examples are created and logged with generic fields only.
  - Not in scope (future directions, not started): expense management, budgets, goals and other life-management modules. The Money activities are ordinary activities, nothing more.
  - **Terminology:** earlier ADRs and backlog entries say "template", "gallery" or "starter template"; read those as "built-in activity" and "the list of activities".

## Pending decisions

Each needs owner approval. **Recommendation** is what the docs currently assume. Resolved entries are struck through and point to their accepted ADR.

| ID | Topic | Recommendation | Alternatives | Why it matters now |
|---|---|---|---|---|
| ~~ADR-P01~~ | SQLite access library | **Resolved → ADR-011 (drift)** | | |
| ~~ADR-P02~~ | Primary key format | **Resolved → ADR-017 (INTEGER internal key + UUIDv7 public ID)** | | |
| ~~ADR-P03~~ | Time storage | **Resolved → ADR-013** | | |
| ~~ADR-P04~~ | Plan schema | **Resolved → ADR-018** (sub-item `planned_duration_ms` confirmed 2026-10-04) | | |
| ~~ADR-P05~~ | Structured values | **Resolved → ADR-019 + ADR-027** (relational Repeating Groups) | | |
| ~~ADR-P06~~ | Units | **Resolved → ADR-020** | | |
| ~~ADR-P07~~ | Duration semantics | **Resolved → ADR-021** | | |
| ~~ADR-P08~~ | Soft delete | **Resolved → ADR-022** | | |
| ~~ADR-P09~~ | Focus session model | **Resolved → ADR-031** | | |
| ~~ADR-P10~~ | Use-case naming | **Resolved → ADR-023** | | |
| ~~ADR-P11~~ | Charts | **Resolved → ADR-033 (fl_chart behind `AppChart`)** | | |
| ~~ADR-P12~~ | Visual identity v0 | **Resolved → ADR-016 (provisional)** | | |
| ~~ADR-P13~~ | Icon family | **Resolved → ADR-024 (Phosphor, bundled official font)** | | |
| ~~ADR-P14~~ | Preferences storage | **Resolved → ADR-012 (SQLite, Option A)** | | |
| **ADR-P15** | Search | V1: bounded `LIKE` queries over notes, `value_text` and `value_json`; adopt FTS5 if slow (requires bundled SQLite with FTS5, e.g. via `sqlite3_flutter_libs`) | FTS5 from day one | Search is V1? (FR-SH-01) |
| ~~ADR-P16~~ | Error handling | **Resolved → ADR-025** | | |
| **ADR-P17** | Animation tooling | Native Flutter animation APIs (implicit/explicit animations, `AnimatedSwitcher`, page transitions); add `flutter_animate` only if it materially reduces complexity; `animations` package for container transform is acceptable | `flutter_animate` everywhere; Rive/Lottie for illustrations | Dependency discipline |
| **ADR-P18** | Draft persistence for long logs (**resolved by ADR-035, 2026-10-04:** items save as you type, so there are no drafts) | Persist in-progress log drafts (e.g. a gym session) so backgrounding/kill doesn't lose input: either a `log_drafts` table (JSON of the form) or saving the log early with `ended_at = NULL` | Memory only (risk of data loss) | §43 gym flow lasts ~1 hour |
| ~~ADR-P19~~ | Localization infrastructure | **Resolved → ADR-015** | | |
| ~~ADR-P20~~ | Activity type/field schema | **Resolved → ADR-026** | | |
| ~~ADR-P21~~ | Numeric font with tabular figures | **Resolved → ADR-032 (DM Mono for numeric tokens)** | | |

### Defaults applied at scaffold (owner did not object at the 2026-10-03 gate; revisit before release)

| Topic | Default | Where |
|---|---|---|
| Flutter / Dart | Stable channel at scaffold time, pinned in `pubspec.yaml` `environment` | [development_guide.md §2](../development/development_guide.md#2-environment) |
| Android minimum SDK | API 26 | `android/app/build.gradle.kts` |
| iOS deployment target | Flutter default | `ios/` |
| Lints | `flutter_lints` + strict analyzer modes | `analysis_options.yaml` |
| Phase 1 icons | Flutter's built-in rounded Material icons; replaced by Phosphor in Phase 2 (ADR-024) | `lib/core/design/` |
| State class suffix | `Notifier` | [coding_standards.md §2](../development/coding_standards.md#2-naming) |

### Decisions explicitly *not* made (intentionally deferred)

- Final product name and app icon (identifiers are fixed by ADR-010).
- CI provider.
- Whether to add a foreground service/ongoing notification for focus (OQ-13).
- Export file format details (OQ-03).
- Anything about future backend technology (see [future_sync.md](../architecture/future_sync.md)).
