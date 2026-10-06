# Development Guide

> How to work on this codebase: setup, workflow, how to implement a feature, and the planned implementation order.
> Standards: [coding_standards.md](coding_standards.md). Tests: [testing_strategy.md](testing_strategy.md).

---

## 1. Current state

See [`ai/tasks/current_task.md`](../../ai/tasks/current_task.md) for the live phase status.

- Source-of-truth inputs: `personal_activity_tracker_spec_updated.md`, `claude_setup.md` (repo root).

## 2. Environment

| Tool | Requirement |
|---|---|
| Flutter | Stable channel. Project scaffolded with **Flutter 3.47.6**; minimum pinned in `pubspec.yaml` `environment.flutter` |
| Dart | Bundled with Flutter (**Dart 3.13.5** at scaffold); `environment.sdk` in `pubspec.yaml` |
| Android | `minSdk 26` (scaffold default, revisit before release); target/compile SDK from the Flutter toolchain |
| iOS | Platform folder kept and must keep compiling; not shipped in V1 (ADR-009). Builds through Swift Package Manager (enabled in this Flutter install), so **CocoaPods isn't needed for the current plugins**. Re-check whenever a plugin is added. Verified: simulator build plus the integration test on an iOS 27 simulator |
| IDE | Android Studio / IntelliJ (`.idea/` present) or VS Code |

Scaffold command used: `flutter create --org com.ourapp --project-name daylog --platforms android,ios .`

### 2.1 Product naming (temporary)

The product name is **undecided** (ADR-010).
- `daylog` / `com.ourapp.daylog` are **internal technical identifiers only**: the Dart package, Android application ID and iOS bundle ID. Never use "Daylog" as the product name in UI, copy, docs prose or marketing.
- "Daylight" is the provisional **design direction** name (ADR-016), not the product name.
- The temporary visible name is **OurApp**. It lives in exactly three places; change all three together when the real name is chosen:
  1. `lib/l10n/app_en.arb` → `appTitle`
  2. `android/app/src/main/res/values/strings.xml` → `app_name` (used by `android:label`)
  3. `ios/Runner/Info.plist` → `CFBundleDisplayName` and `CFBundleName`

## 3. Daily commands

```bash
flutter pub get                       # also regenerates localizations (generate: true)
dart format lib test integration_test # must be clean
flutter analyze                       # must be zero issues
flutter test                          # unit + widget + repository
flutter test integration_test -d <device-id>   # on an emulator/device
dart run build_runner build -d        # drift code generation (ADR-011); commit the generated files
dart run drift_dev make-migrations    # after bumping schemaVersion (database.md §7)
python3 tool/generate_phosphor_glyphs.py <@phosphor-icons/web package dir>   # after adding icons (ADR-024)
flutter gen-l10n                      # regenerate localizations explicitly after editing ARB files
```

A pre-merge check runs format, analyze and tests. CI is not set up yet; add it when a remote repository exists (GitHub Actions or equivalent, no deployment).

### 3.1 Running on the Android emulator

```bash
flutter emulators                                  # list AVDs
flutter emulators --launch Medium_Phone_API_37.0   # or start it from Android Studio's Device Manager
flutter devices                                    # wait until the emulator is listed (e.g. emulator-5554)
flutter run -d emulator-5554
```

On first launch the app shows the placeholder onboarding screen; "Get started" leads to Today. Developer tools show under Me → Developer in debug builds, or in any build made with `--dart-define=DEV_TOOLS=true` (`lib/app/dev/dev_tools.dart`): "Design tokens" opens the token showcase (theme switch, "Show onboarding again"); "Load demo data (6 weeks)" adds six weeks of sample records up to today plus today's/tomorrow's plans, measurements and charts; "Load demo data (last 10 days)" adds records for the 10 days ending yesterday. Both write through the normal use cases (`lib/app/dev/demo_data.dart`), add to existing data once (a second tap does nothing) and refuse when Gym, Reading, Walking or Focused work already exist; the records can only be removed one by one, so use them on test installs. To put demo data on a phone running a release build: install a release built with `DEV_TOOLS=true`, load it, then reinstall the plain release (same signing key, so the data stays).

## 4. Workflow

1. **Read before changing.** For architectural or cross-feature work, read `CLAUDE.md`, [architecture.md](../architecture/architecture.md), and the relevant architecture doc first.
2. **Small vertical slices.** Each change delivers one coherent behavior through all needed layers with tests.
3. **Branches:** `feature/<short-name>`, `fix/<short-name>`, `docs/<short-name>`. Default branch `main` stays releasable.
4. **Commits:** imperative, scoped messages (Conventional Commits style recommended: `feat(logs): add set table editor`).
5. **Review checklist:** layer boundaries respected; no hardcoded visual values; states covered; tests for business rules; docs updated if behavior or architecture changed.
6. **Docs are part of the change.** Follow §4.1. A change is not complete while any document describes behavior the code no longer follows.

### 4.1 Documentation maintenance (binding)

The Markdown documentation is **living engineering documentation**, not a one-time setup artifact. Code and docs must never intentionally diverge: a future developer or AI agent should be able to understand the current product, architecture, design system, database, conventions and implementation from the repository alone.

**Before** a significant change: check which documents describe the area you are touching and whether the change contradicts them. If it contradicts an accepted ADR or a documented architecture, stop and raise it. Don't silently diverge.

**After** the change, in the **same task/commit**, update what changed:

| When this changes… | Update |
|---|---|
| Architecture (layers, structure, data flow, dependencies between features) | `docs/architecture/architecture.md`, `application_architecture.md`, `ai/context/architecture_context.md`, `ai/rules/architecture_rules.md` |
| An architectural decision is made, changed or reversed | `docs/decisions/architecture_decisions.md` (move pending → accepted with date; superseded ADRs are marked, never deleted) |
| A feature is added, changed or removed | `docs/product/requirements.md` (and resolved Open Questions), `docs/product/user_flows.md`, `docs/product/product_spec.md` if scope changes, `ai/context/product_context.md` |
| Database schema, migrations, value encoding, JSON contracts | `docs/architecture/database.md`, `data_architecture.md`, `ai/rules/database_rules.md` |
| State management patterns | `docs/architecture/state_management.md` |
| Design tokens, components, patterns, motion, responsive rules | `docs/ui/design_system.md`, `ui_guidelines.md`, `responsive_design.md`, `ai/context/design_context.md`, `ai/rules/ui_rules.md` |
| Coding conventions, lint rules, dependencies, testing approach, error handling, performance budgets | the matching `docs/development/*.md` and `ai/rules/*.md` |
| Stack, project layout, phase, workflow, prohibitions | `CLAUDE.md`, `README.md`, `ai/tasks/current_task.md` |
| Phase progress / next task | `ai/tasks/current_task.md` |

Rules:
- **Accuracy over volume.** Don't edit docs for the sake of changing them. Keep them concise; update the single main document and link to it rather than copying text.
- **Describe what exists**, and label what is planned or proposed as such. Never document intended behavior as if it were implemented.
- Remove or correct outdated statements. Don't append contradicting notes.
- If code and docs are found to disagree, fix the drift in the same task (or flag it explicitly if the correct side is unclear).
- Review includes docs: a PR that changes behavior without the corresponding doc update is incomplete.

## 5. How to implement a feature (recipe)

1. Confirm the requirement ID(s) in [requirements.md](../product/requirements.md) and the flow in [user_flows.md](../product/user_flows.md). If unclear → raise it as an Open Question; do not invent.
2. **Domain first:** entities/value objects, rules, repository interface, use case (only if justified). Unit tests.
3. **Data:** tables/DAO (if schema changes: migration + migration test), repository implementation, mappers. Repository tests against in-memory SQLite.
4. **Providers:** repository binding, query/derived providers, notifier for editing.
5. **Presentation:** compose from `shared/` components and design tokens; handle loading/empty/error/success; responsive layout; motion per guidelines. Widget tests for meaningful behavior.
6. **Route** registration in `app/router.dart` if needed.
7. Run the [visual quality checklist](../ui/ui_guidelines.md#10-visual-quality-checklist) on compact and expanded widths, light and dark.
8. Update docs/ADRs per §4.1, including `ai/tasks/current_task.md`.

### Adding a new field type
Field types are a closed catalog (OQ-01). Prefer composing existing types (e.g. Number + dimension) over adding one. If a new type is genuinely needed:
1. **Domain** (`features/activity_types/domain/`):
   - add it to `FieldType` with its storage key
   - add a sealed `FieldConfig` variant and its validation in `ActivityTypeValidator`
2. **Values** (`features/activity_logs/domain/`):
   - add a sealed `FieldValue` variant
   - add a validation case in `LogValidator`
3. **Data:**
   - `FieldConfigCodec` and `LogValueCodec` mappings
   - a **migration** that adds the key to the `field_type` CHECK and the trigger `CASE` in `activity_engine.drift` (12-step rebuild for the CHECK)
   - `make-migrations` and migration tests
4. **Presentation:**
   - editor in `FieldEditorRegistry` (compile error until done)
   - config UI in `field_editor_sheet.dart`
   - copy in `field_type_copy.dart` and the ARB file
5. **Tests:**
   - config round-trip
   - value validation
   - repository round-trip
   - trigger acceptance
   - editor widget test
6. **Docs:** [data_architecture.md §4](../architecture/data_architecture.md#4-field-type-catalog), [database.md §3.5](../architecture/database.md#35-log_values-v2-rebuilt-in-v3).

### Adding a new activity type
Nothing to implement. It is user data. If you are adding a **starter template**, add an entry to `features/activity_types/presentation/activity_templates.dart` (localized names, placeholder option IDs) and make sure it passes `ActivityTypeValidator`.

## 6. Proposed implementation phases

Proposed, for approval. Order is driven by the V1 success criterion (§43): build the generic engine first, then the flows that prove it.

| Phase | Scope | Exit criteria |
|---|---|---|
| 0 | Documentation (this) | Approved docs; pending ADRs decided |
| 1 ✅ | Scaffold (done 2026-10-03): Flutter project (Android + iOS), git init, lints/analyzer, `app/core/shared` skeleton, drift DB bootstrap + migration runner with **schema v1 = `app_preferences` only** (ADR-012), Clock, ID generator, AppLogger, design tokens + light/dark theme, adaptive 5-tab shell (placeholder tabs), go_router with onboarding redirect (placeholder onboarding), dev-only token showcase, gen-l10n localization, format/analyze/test checks | App builds and launches on Android; iOS project compiles; analyze/format/tests green; tokens reviewable on the showcase |
| 2 ✅ | Generic engine (**done 2026-10-04**; schema v2 = activity tables; decisions ADR-017–026, OQ-01): activity types + fields (domain/data), the nine scalar/select field types (Repeating Group moves to Phase 3), generic form renderer, log save/edit/delete, builder with preview, starter templates | Create Reading & Language Learning types via the builder and log them with zero type-specific code |
| 3 ✅ | Structured fields (**done 2026-10-04**, awaiting owner review): Repeating Group with **relational storage** (ADR-027, schema v3: sub-fields with `parent_field_id`, `log_group_items`, `log_values.group_item_id`), nested sets (Set Table = nested Repeating Group + Number), Gym/Meeting/Cooking templates, exercise autocomplete | §43 gym step works (widget + repository tests; device test written, not yet run) |
| 4 ✅ | Plans & Tasks (**done 2026-10-04**, awaiting owner review): schema v4 (ADR-018 incl. the owner-confirmed `planned_duration_ms`); plan → record flow; Today (plan + records + planned vs actual) | §43 night/morning steps (widget + repository tests; device test written, not yet run) |
| 5 ✅ | Focus mode (**done 2026-10-04**, awaiting owner review): schema v5 `focus_sessions` (ADR-031), timestamp-derived timer, start from plans/activities, finish → record form (since ADR-035: finish fills the item) → one transaction, In-progress plans, DM Mono timer digits (ADR-032) | §43 work/reading steps (repository + widget tests) |
| 6 ✅ | Insights + body measurements (**done 2026-10-04**, awaiting owner review): schema v6 `measurements` + `insight_charts`, generic engine (time, count, any field incl. nested with text filter, volume, PRs, body, planned vs actual), fl_chart via `AppChart` (ADR-033), Me → Body measurements (ADR-034) | §43 "see progress over time" (repository + widget tests) |
| R | **Flow rework (owner, 2026-10-04; replaces the old Phase 7 scope, ADR-035):** (1) ✅ item screen + live logging; (2) ✅ log anything inline: Add to log, ready-made shapes, Add detail in lists; (3) ✅ Plan next + Day/Week/Month planner + repeating plans (schema v7, ADR-036); (4) ✅ automatic per-activity insights (ADR-037). All done 2026-10-04 | Plan Gym → open at the gym → log sets live; any new name logs without setup; progress graphs without building charts |
| 7 | Onboarding narrative; history/search | First-run to first record in < 1 minute |
| 8 | Hardening: performance pass, accessibility pass, tablet layouts, export (if OQ-03 approved), integration test of the full §43 scenario | Release candidate |

Design work (identity validation, illustrations) runs alongside Phases 1–3 so screens aren't built on placeholder visuals.
