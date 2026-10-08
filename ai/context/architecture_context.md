# Architecture Context (AI quick-load)

> Compressed context. Canonical: [docs/architecture/](../../docs/architecture/architecture.md) and [architecture_decisions.md](../../docs/decisions/architecture_decisions.md).

**Stack:** Flutter + Dart 3 · SQLite (local, source of truth) · Riverpod · go_router · native animations · fl_chart charts behind `AppChart` (ADR-033) · drift for SQLite (ADR-011) · gen-l10n (ADR-015). Hand-written Riverpod providers, no riverpod_generator/freezed (ADR-014). **No backend.**

**Status:**
- Phases 1–6 are implemented (incl. focus timer, insights and body measurements): scaffold, preferences, design tokens/theme, adaptive shell, go_router, gen-l10n, the **generic activity engine** (activity types, fields, logs, typed values, builder, built-in activities, generic form renderer), relational Repeating Groups, and **plans + Today** (plan → record, planned vs actual).
- Navigation (ADR-028, ADR-044): **Today | Plan | Challenges | Insights | Me** (no floating Record button). Everything on a day is an item you open to log into, saved as you type (ADR-035). Plan is date-based: Week | Month plus a day screen sharing Today's `DayItems` (ADR-039), with repeating plans generated as ordinary plans for the dates viewed (schema v7, ADR-036). Insights builds per-activity charts from fields by type and number config (ADR-037, ADR-043); challenges (ADR-044, schema v9) are one table, with progress and streaks computed from logs; chart reads are limited to the period, with the all-time best as its own query. Activities (setup) live under Me → Activities.
- All five tabs are implemented (Insights in Phase 6, Challenges in ADR-044).
- See [application_architecture.md](../../docs/architecture/application_architecture.md) for the implemented-vs-planned map.

**Structure:**
```text
lib/main.dart
lib/app/        router, shell, theme wiring, bootstrap
lib/core/       database (all drift tables), design tokens, clock, ids, logging (errors/platform: later)
lib/l10n/       ARB strings + committed gen-l10n output
lib/shared/     reusable design-system components
lib/features/<feature>/{data,domain,presentation}   (only folders that are needed)
```
Features: `activity_types`, `activity_logs`, `plans`, `focus`, `today`, `insights`, `measurements`, `history`, `onboarding`, `settings`.

**Layers:** Presentation → Domain ← Data. Domain is pure Dart (no Flutter, no DB imports). Cross-feature imports go through **domain only**. `core/` and `shared/` never import features.

**Data flow:** SQLite watch query → repository stream (domain entities) → StreamProvider → widget. Writes: widget → notifier → use case/repository (validates, transacts) → SQLite → streams update UI.

**Generic engine:** Activity Type → Field definitions → **generic form renderer** (field-type registry, exhaustive switch) → Activity Log + log_values → analytics on (time, value, unit). Never branch on activity identity.

**Tables:**
- Schema v1: `app_preferences` (text key, `updated_at` only, ADR-012).
- **Schema v2 (implemented):** `activity_types`, `activity_fields`, `activity_logs`, `log_values`. These are STRICT tables with CHECKs, partial indexes and integrity triggers.
- **Schema v3 (implemented, Phase 3, ADR-027):** Repeating Groups: `activity_fields.parent_field_id`, `log_group_items`, `log_values.group_item_id` (rebuilt with partial unique indexes per scope).
- **Schema v4 (implemented, Phase 4, ADR-018):** `plans` (task = no activity; `planned_duration_ms` exclusive with `planned_end_at`) and `activity_logs.plan_id`. **Schema v8 (ADR-040):** any plan can store `completed` (Mark done, finished timer); otherwise a linked record makes an activity plan in progress on its day and done after it (`Plan.effectiveStatus(today:)`, `WatchDayOverview`).
- **Schema v5 (Phase 5, ADR-031):** `focus_sessions` (timestamp-derived elapsed time, one active session, finish = record + session in one `UnitOfWork`).
- **Schema v6 (Phase 6, ADR-034):** `measurements` (fixed types, canonical units) and `insight_charts` (saved chart configs, versioned JSON; OQ-14 confirmation pending).
- Insights: one generic engine over (local_date, value) points from activity time/count, any number field (nested, text filter), volume, measurements, planned vs actual.
- Identity: INTEGER `internal_id` (joins, data layer only) + UUIDv7 `public_id` (ADR-017).
- Values: typed columns (`text_value`, `number_value` + `unit_code` + `normalized_value`, `boolean_value`, `date_value`, `time_value`, `duration_ms`, `json_value`) (ADR-019/020).
- Calendar lookups: `local_date` (ADR-013).
- Soft delete (ADR-022).
Details: [database.md](../../docs/architecture/database.md).

**Structured values:** Multi Select is JSON with `"v"` and stable option IDs. **Repeating Groups are relational** (ADR-027, schema v3, implemented): sub-fields are `activity_fields` rows with `parent_field_id`, items are `log_group_items` rows, and item values are typed `log_values` rows with `group_item_id`. Domain: `RepeatingGroupValue` → `GroupItem(id, values)`; `ActivityType.activeFields` is top-level only, `subFieldsOf(groupId)` gives sub-fields; nesting ≤ 2. See [data_architecture.md §5](../../docs/architecture/data_architecture.md#5-structured-values).

**Focus timer:** elapsed derived from persisted timestamps; survives process death; finish = one transaction (session + log + values + plan status).

**Future sync:** not built. V1 keeps IDs/timestamps/soft-delete so it can be added. See [future_sync.md](../../docs/architecture/future_sync.md).

**Live queries:** `reactiveQuery(db.tableUpdates(...), load)`, which is safe across Riverpod 3's pausing of hidden providers. Errors: sealed `AppException`, translated by `guardStorage` (ADR-025). Use cases: Verb + object with `call()` (ADR-023).

**Pending decisions:** ADR-P15, P17, P18, and owner confirmation of OQ-14 (saved charts). P09/P11/P21 were resolved by ADR-031/033/032. Treat recommendations as working assumptions; flag when your task depends on one that isn't approved.
