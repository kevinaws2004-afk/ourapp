# CLAUDE.md

Primary instructions for Claude Code in this repository. Read fully before doing any work.

## 1. What this project is

**Personal Activity & Life Tracking App** (working title): a customizable, **local-first** Flutter app that lets users **plan** their day, **log** what they actually did, capture the data that matters for each activity, and **understand** their progress over time.

Core loop: **Plan → Do → Log → Measure → Understand.** Gym, Reading, Work, Meetings and Body Weight are all configurations of **one generic activity engine**, not separate features.

**Current phase:** see [`ai/tasks/current_task.md`](ai/tasks/current_task.md). Only work on the phase the owner has approved there.

**Navigation & terminology (ADR-028, ADR-035):** Today | Plan | Insights | Me. No floating Record button. Everything on a day is an **item**: you add it (quick add, or **Start now** for what you're doing), then open it to log into it; it saves as you type. Plan is date-based: Week | Month, and a tapped day opens like Today (ADR-039). Reusable activities are configured under Me → Activities but never required before logging. Activity Log is the internal/domain name; the UI talks about items being done.

**Naming rule (ADR-010):** the product name is **undecided**.
- `daylog` / `com.ourapp.daylog` are internal technical identifiers only (Dart package, app/bundle ID). Never present "Daylog" as the product name in UI, copy, docs prose or marketing.
- "Daylight" is only the provisional design direction (ADR-016).
- The temporary visible name is **OurApp**. It's defined in exactly three places ([development_guide.md §2.1](docs/development/development_guide.md#21-product-naming-temporary)); keep it that way.

## 2. Sources of truth (in priority order)

1. [`personal_activity_tracker_spec_updated.md`](personal_activity_tracker_spec_updated.md): product spec (cited as §N).
2. [`claude_setup.md`](claude_setup.md): engineering process and documentation requirements.
3. [`docs/`](docs/): engineering documentation derived from 1–2.
4. [`ai/`](ai/): condensed context and enforceable rules for agents.

If code and docs disagree, the docs win unless the owner says otherwise; fix the drift. If the docs are ambiguous, **ask or document the ambiguity. Never invent requirements.**

## 3. Technology stack

Flutter · Dart 3 (null-safe) · SQLite (local, V1 source of truth) · Riverpod · go_router · native Flutter animations · gesture/drag-and-drop built-ins · fl_chart behind the shared `AppChart` (ADR-033) · drift for SQLite (ADR-011) · gen-l10n localization (ADR-015) · Phosphor icons via the bundled official font + generated registry (ADR-024) · DM Mono for numeric tokens (ADR-032). Riverpod 3 providers are hand-written; no riverpod_generator, no freezed (ADR-014). **No backend.** Android first, iOS-compatible.

## 4. Where things live

| Path | Contents |
|---|---|
| `lib/main.dart` | Entry point: calls `bootstrap()` |
| `lib/app/` | Bootstrap, root `App`, router (`router.dart`), adaptive shell, startup failure screen, provider logger, `dev/` (debug-only token showcase) |
| `lib/core/` | `database/` (drift DB, all table definitions incl. `tables/activity_engine.drift`, `guardStorage`, `isActive`, `reactiveQuery`), `design/` (tokens, theme, Phosphor icons and registries, window size classes), `errors/` (AppException), `time/` (Clock, LocalDate), `ids/` (UUIDv7), `units/` (unit registry), `logging/` (AppLogger) |
| `lib/shared/widgets/` | Reusable design-system components |
| `lib/features/<feature>/{data,domain,presentation}/` | Feature code (only the layers that are needed). Implemented: `settings` (preferences, Me), `activity_types` (types, fields, builder, templates, Me → Activities), `activity_logs` (logs, typed values, generic form renderer), `plans` (plans and tasks, day overview, the item screen where you log (ADR-035), date-based Plan tab), `today` (Today screen), `focus` (focus timer, ADR-031), `measurements` (Me → Body measurements), `insights` (generic analytics engine + charts, ADR-034) |
| `lib/l10n/` | ARB strings (`app_en.arb`) + committed gen-l10n output |
| `assets/fonts/` | Bundled fonts with licenses: Fraunces, DM Sans and DM Mono (OFL), Phosphor icons (MIT) |
| `tool/` | `generate_phosphor_glyphs.py` (icon constants and registry) |
| `drift_schemas/` | Exported schema snapshots per version (for migration tests) |
| `test/`, `integration_test/` | Unit/widget/repository tests mirroring `lib/`; on-device launch test |
| `docs/product/` | Product spec condensation, numbered requirements + open questions, user flows |
| `docs/architecture/` | Architecture overview, app structure, data model, SQLite schema, state management, future sync |
| `docs/development/` | Dev guide & phases, coding standards, testing, error handling, performance |
| `docs/ui/` | Design system (tokens), UI guidelines (patterns, states, copy), responsive rules |
| `docs/decisions/` | Accepted and pending ADRs |
| `ai/context/` | Quick-load summaries (product, architecture, design) |
| `ai/rules/` | Enforceable rules (coding, architecture, UI, database, testing) |
| `ai/tasks/current_task.md` | Current phase, what's allowed, blocking decisions |

## 5. Required reading

- **Every session:** this file, `ai/tasks/current_task.md`, and the `ai/context/*` file(s) relevant to the task.
- **Before architectural, cross-feature, or schema changes:** `docs/architecture/architecture.md` + the specific doc (`application_architecture.md`, `data_architecture.md`, `database.md`, `state_management.md`) + `docs/decisions/architecture_decisions.md`.
- **Before UI work:** `docs/ui/design_system.md`, `docs/ui/ui_guidelines.md`, `docs/ui/responsive_design.md`.
- **Before implementing a feature:** its requirement IDs in `docs/product/requirements.md` and flow in `docs/product/user_flows.md`.

## 6. Architectural principles (binding)

1. Feature-first structure; Presentation → Domain ← Data; domain is pure Dart.
2. No business logic in widgets. No database code in UI. Repositories (domain interfaces, data implementations) sit between logic and SQLite.
3. SQLite is the source of truth; local-first, offline-first; Riverpod holds no authoritative state.
4. **Generic activity engine:** no per-activity tables/screens; never branch on activity identity; new activity types are data; Set Table/Repeating Group are generic field types.
5. One generic form renderer driven by field definitions.
6. Sync-ready data, but **no sync code**:
   - two-level identity: INTEGER `internal_id` for joins (data layer only), UUIDv7 `public_id` for identity (ADR-017)
   - UTC ms instants + `local_date` (ADR-013)
   - soft delete (ADR-022)
7. Platform-independent logic; Android first, nothing that blocks iOS.
8. Simple over clever; no premature abstraction.
9. Design system is shared infrastructure; no hardcoded visual values.

Full rules: [`ai/rules/architecture_rules.md`](ai/rules/architecture_rules.md).

## 7. Coding standards

Spec vocabulary only (ActivityType, ActivityLog, Plan, Measurement…). Immutable entities, sealed classes + exhaustive switches, no `dynamic` outside JSON boundaries, injected `Clock` (never `DateTime.now()`), small widgets and files, no global mutable state, typed `AppException`s, `AppLogger` (no `print`). Full rules: [`ai/rules/coding_rules.md`](ai/rules/coding_rules.md), rationale: [`docs/development/coding_standards.md`](docs/development/coding_standards.md).

## 8. Testing expectations

Unit tests for domain rules; repository tests against real in-memory SQLite (no DB mocks); widget tests for meaningful behavior (form renderer, field editors, states); integration test for the §43 success scenario. Deterministic clock/IDs. Every bug fix and migration gets a test. Rules: [`ai/rules/testing_rules.md`](ai/rules/testing_rules.md).

## 9. Database rules

- **Schema:** generic STRICT tables only; schema v2 = activity engine; v3 = relational Repeating Groups (ADR-027); v4 = plans + `activity_logs.plan_id` (ADR-018); v5 = focus sessions (ADR-031); v6 = measurements + saved insight charts (ADR-034); v7 = repeating plans (`plan_series`, `plans.series_id`, ADR-036); v8 = any plan can be stored as completed (`plans` rebuilt without the tasks-only check, ADR-040). Triggers lock field semantics once values exist (ADR-026) and enforce group structure.
- **Identity:** INTEGER FKs/joins, UUIDv7 `public_id`s (ADR-017).
- **Values:** typed value columns, with JSON only for multi-select (ADR-019). Repeating Groups are rows: `log_group_items` + scoped `log_values` (ADR-027).
- **Units:** user unit + write-time `normalized_value` (ADR-020); durations as `duration_ms` (ADR-021).
- **Soft delete:** via the shared `isActive` predicate (ADR-022).
- **Repositories:** wrapped in `guardStorage` (ADR-025); live queries via `reactiveQuery` + `tableUpdates`.
- **Writes and migrations:** transactions for multi-row writes; forward-only migrations with tests; update `docs/architecture/database.md` with every schema change. Rules: [`ai/rules/database_rules.md`](ai/rules/database_rules.md).

## 10. UI/UX rules

The product must feel calm, premium, personal and distinctive, never a generic CRUD or black dashboard app. Use tokens and shared components; implement loading/empty/error/success states; apply the Plan vs Reality grammar; responsive by window size class; accessibility (48dp, contrast, 200% text, semantics, reduced motion); purposeful motion; run the visual quality checklist before calling UI done. Colors: only white shades, mist `#DDF0EF` and the six palette colors sky, lilac, teal, rose, slate, coral; text/borders are slate shades (ADR-029, ADR-038; brand = teal). Flowfy is a principles reference only; never copy it. Rules: [`ai/rules/ui_rules.md`](ai/rules/ui_rules.md).

## 11. Dependency rules

Prefer Flutter/Dart built-ins. A new package needs a clear need, maintenance, permissive license, Android + iOS support, no telemetry/network behavior. Architecture-shaping packages (DB, state, routing, codegen, charts, animation frameworks) need an ADR. No analytics/crash-reporting/ads SDKs. Fonts/icons bundled. Details: [`docs/development/coding_standards.md#dependencies`](docs/development/coding_standards.md#dependencies).

## 12. Git & quality expectations

`dart format` clean, `flutter analyze` zero issues, all tests green before reporting work done. Small focused changes; branches `feature/…`, `fix/…`, `docs/…`; Conventional-Commit-style messages. Commit/push only when asked. Docs and ADRs updated in the same change as the behavior they describe. Report test failures and skipped steps honestly.

## 13. Documentation must stay synchronized with the code

Documentation is part of the project, not a one-time artifact. **Code and docs must never intentionally diverge.**

- **Before** a significant change: check which docs describe the area and whether the change contradicts them (especially accepted ADRs). If it does, raise it first.
- **After** the change, **in the same task**, update the affected docs: architecture, product/requirements/flows, database/data model, UI/design system, development conventions, ADRs, `CLAUDE.md`, `ai/context/*`, `ai/rules/*`, `ai/tasks/current_task.md`.
- Never leave a doc describing architecture or behavior the code no longer follows. Correct or remove outdated statements; label proposals as proposals.
- Don't change docs just to change them. Keep them accurate and concise, with one main document per topic.

Which change updates which document: [`docs/development/development_guide.md` §4.1](docs/development/development_guide.md#41-documentation-maintenance-binding).

## 14. How to approach implementation

1. Check `ai/tasks/current_task.md`; confirm the work is in the current phase and approved.
2. Identify requirement IDs and flows; check open questions/pending ADRs that affect the task. If a blocking decision is unresolved, follow the documented recommendation **and say so**, or ask.
3. Read the relevant architecture/UI docs. Understand existing code before changing it.
4. Implement in a vertical slice: domain (+ tests) → data (+ migration & tests) → providers → presentation (tokens, shared components, all states, responsive) → route.
5. Verify: format, analyze, tests; visual checklist for UI.
6. Update docs/ADRs and `ai/tasks/current_task.md` per §13.
7. Summarize what changed, what was verified, which docs were updated, and any open issues.

## 15. What Claude must NOT do

- Start implementation, run `flutter create`, or add packages before the owner approves the phase.
- Add a backend, API calls, authentication, cloud sync, AI features, social features, subscriptions, telemetry, or any §42-excluded feature.
- Create per-activity tables, screens, or `if (activity == gym)` logic.
- Put business logic in widgets or SQL in UI/domain.
- Hardcode colors, sizes, fonts, durations; use default Material styling where a product component exists.
- Invent product requirements or silently resolve open questions/pending ADRs.
- Make large architectural changes without reading the architecture docs and recording an ADR.
- Hard-delete user data, edit shipped migrations, or recreate the DB on failure.
- Copy another product's (e.g. Flowfy's) branding, palette, fonts, illustrations, layouts or wording.
- Claim work is done when tests fail or checks were skipped.
- Finish a change that leaves documentation out of sync with the code, or edit docs without a real reason.
