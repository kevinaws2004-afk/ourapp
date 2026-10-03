# Architecture Context (AI quick-load)

> Compressed context. Canonical: [docs/architecture/](../../docs/architecture/architecture.md) and [architecture_decisions.md](../../docs/decisions/architecture_decisions.md).

**Stack:** Flutter + Dart 3 · SQLite (local, source of truth) · Riverpod · go_router · native animations · CustomPaint charts (pending ADR-P11) · drift for SQLite (ADR-011) · gen-l10n (ADR-015). Hand-written Riverpod providers, no riverpod_generator/freezed (ADR-014). **No backend.**

**Status:**
- Phases 1–2 are implemented: scaffold, preferences, design tokens/theme, adaptive shell, go_router, gen-l10n, and the **generic activity engine**: activity types, fields, logs, typed values, builder, templates, generic form renderer.
- Navigation (ADR-028): **Today | Plan | Insights | Me**, plus a global Quick Record action. Plan is date-based (calendar/week strip plus a Recorded section). Activities (setup) live under Me → Activities.
- Placeholder tabs: Today, Insights.
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
- Designed for later phases: Repeating Group tables (v3, Phase 3, ADR-027), `plans` (v4, Phase 4), `focus_sessions`, `measurements`.
- Identity: INTEGER `internal_id` (joins, data layer only) + UUIDv7 `public_id` (ADR-017).
- Values: typed columns (`text_value`, `number_value` + `unit_code` + `normalized_value`, `boolean_value`, `date_value`, `time_value`, `duration_ms`, `json_value`) (ADR-019/020).
- Calendar lookups: `local_date` (ADR-013).
- Soft delete (ADR-022).
Details: [database.md](../../docs/architecture/database.md).

**Structured values:** Multi Select is JSON with `"v"` and stable option IDs. **Repeating Groups are relational** (ADR-027, Phase 3 schema v3): sub-fields are `activity_fields` rows with `parent_field_id`, items are `log_group_items` rows, and item values are typed `log_values` rows with `group_item_id`. See [data_architecture.md §5](../../docs/architecture/data_architecture.md#5-structured-values).

**Focus timer:** elapsed derived from persisted timestamps; survives process death; finish = one transaction (session + log + values + plan status).

**Future sync:** not built. V1 keeps IDs/timestamps/soft-delete so it can be added. See [future_sync.md](../../docs/architecture/future_sync.md).

**Live queries:** `reactiveQuery(db.tableUpdates(...), load)`, which is safe across Riverpod 3's pausing of hidden providers. Errors: sealed `AppException`, translated by `guardStorage` (ADR-025). Use cases: Verb + object with `call()` (ADR-023).

**Pending decisions:** ADR-P09, P11, P15, P17, P18, P21, plus the ADR-018 `planned_duration_ms` sub-item. Treat recommendations as working assumptions; flag when your task depends on one that isn't approved.
