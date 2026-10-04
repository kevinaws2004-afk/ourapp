# Coding Standards

> Senior-engineering standards for this codebase. Goal: maintainable production code, **not** architecture for its own sake.

---

## 1. General

- **Clarity over cleverness.** Code is read far more than written.
- **Single responsibility.** A class/function does one thing; its name says what.
- **Explicit dependencies.** Pass collaborators in (constructors/providers). No hidden globals, service locators or static mutable state.
- **Don't abstract prematurely.** Introduce an interface/generic only when there are two real uses or a necessary test/sync seam (repositories). Three similar lines are better than a wrong abstraction.
- **Don't duplicate knowledge.** Business rules exist in exactly one place (domain). Visual values exist in exactly one place (design tokens).
- **Delete dead code.** No commented-out code, no unused parameters "for later".

## 2. Naming

| Kind | Convention | Example |
|---|---|---|
| Files | `snake_case.dart`, one primary public type per file | `activity_log_repository.dart` |
| Types | `UpperCamelCase`, domain terms from the glossary | `ActivityType`, `LogValue`, `FocusSession` |
| Members | `lowerCamelCase`, verbs for actions, nouns for values | `startSession()`, `plannedDuration` |
| Booleans | `is/has/can/should` prefix | `isArchived`, `supportsTimer` |
| Providers | `<thing>Provider` | `activeActivityTypesProvider` |
| Notifiers | `<Screen/Concern>Notifier` (scaffold default) | `ItemNotifier`, `ActivityBuilderNotifier` |
| Repositories | interface `XRepository`, impl `DbXRepository` | |
| Use cases | Verb + domain object, one `call()` method (ADR-023) | `CreateActivityType`, `LogActivity` |

Use the **spec's vocabulary** (Activity Type, Activity Log, Plan, Measurement, Field). Do not invent synonyms (`Entry`, `Record`, `Template`, `Session` for logs, etc.).

## 3. Dart

- Sound null safety. Avoid `!` except where an invariant is proven locally; prefer pattern matching / early returns.
- Prefer `final` and immutable data. Domain entities are immutable with value equality.
- Use Dart 3 features: `sealed` classes for closed hierarchies (field types, metric sources, failures), exhaustive `switch`, records for small tuples, patterns.
- No `dynamic` outside JSON boundary code in the data layer. Decode JSON into typed objects immediately.
- Avoid `late` for things that can be constructor-initialized.
- Enums/sealed types for states; no stringly-typed state in domain (strings exist only in DB mapping).
- Time: never call `DateTime.now()` outside `Clock`. Never store local `DateTime` in DB.
- Money/precision: weights/distances are `double` in canonical units; format/round only at presentation.

## 4. Flutter / widgets

- **Small widgets.** Extract when a `build` exceeds ~80–100 lines or has distinct regions. Prefer extracting **widget classes** (not helper methods returning widgets) for rebuild efficiency and testability.
- Screen widget = layout + composition of feature widgets; minimal logic.
- `const` constructors wherever possible.
- **No hardcoded visual values** in feature code: colors, text styles, spacing, radii, durations and curves come from design tokens (`context.tokens`, `Theme.of(context)`). Lints/review enforce this. Exceptions require a comment with justification.
- No raw default Material widgets where a shared product component exists (`AppButton`, `AppSheet`, etc.; see [ui_guidelines.md](../ui/ui_guidelines.md)).
- All user-visible strings come from a central place (localization-ready). V1 ships English only, through `flutter_localizations` + gen-l10n ARB files in `lib/l10n/` (ADR-015). Never inline user-visible strings. **Exception:** debug-only developer tooling (the token showcase and its "Design tokens (debug)" entry, and the "Load demo data (debug)" entry) may use literal English, because it isn't reachable in release builds. Mark such strings with a comment.
- Semantics labels for icon-only buttons and custom-painted content.
- Lists use builders (`ListView.builder`, slivers) for unbounded data.

## 5. File & module size

- Soft limits: ~300 lines per file, ~100 lines per `build`, ~40 lines per function. Exceeding them is a signal to split, not a hard rule.
- No giant provider files. Providers live next to the feature concern they serve.
- No `utils.dart` dumping grounds; name helpers by what they do (`duration_format.dart`).

## 6. Architecture conformance

- Respect layers and cross-feature rules ([application_architecture.md §2](../architecture/application_architecture.md#2-dependency-rules)).
- Domain imports no Flutter and no DB library.
- No `if (activityType.name == 'Gym')` or any branching on activity identity. Branch only on **field types** (in the registry) or **config/roles**.
- Repositories return domain entities, never DB row classes.

## 7. Error handling & logging

See [error_handling.md](error_handling.md). Summary: typed `AppException`s from data layer; validation as values; no swallowed exceptions; `AppLogger` (local only, no PII in logs beyond what is needed for debugging, never logged off-device).

## 8. Comments & documentation

- Comment **why**, not what. Public domain APIs get a short doc comment when the name alone isn't sufficient.
- Non-obvious invariants (e.g. timer elapsed formula, JSON payload versions) are documented at the definition.
- Link to the relevant doc/ADR for architectural decisions in code comments sparingly (`// See ADR-019.`).

## 9. Linting & formatting

- `dart format` with default settings; any diff fails the pre-merge check (and CI, once CI is set up; see [development_guide.md §3](development_guide.md#3-daily-commands)).
- `analysis_options.yaml`: start from `flutter_lints` (or `very_good_analysis` if the team prefers stricter; decide at scaffold) plus at minimum:
  `always_declare_return_types`, `prefer_final_locals`, `prefer_const_constructors`, `avoid_dynamic_calls`, `unawaited_futures`, `discarded_futures`, `avoid_print`, `prefer_single_quotes`, `require_trailing_commas` (if using the older formatter style), `strict-casts`, `strict-raw-types`, `strict-inference`.
- Zero analyzer warnings on `main`.
- Consider a custom lint/grep check in CI forbidding `Color(0x`, `EdgeInsets.all(<literal>)`, `DateTime.now()` outside allowed folders.

## Dependencies

**Direct dependencies in use (through Phase 6).** `pubspec.yaml` is authoritative; keep this list in sync.

| Package | Purpose | Decision |
|---|---|---|
| `flutter_riverpod` 3.x | State/DI | ADR-004, ADR-014 |
| `go_router` | Routing | Spec / architecture.md §7 |
| `drift`, `drift_flutter` | SQLite access, on-device connection | ADR-011 |
| `flutter_localizations` (SDK), `intl` | Localization | ADR-015 |
| `fl_chart` ^1.2 | Charts, only through `shared/widgets/charts/AppChart` (Phase 6) | ADR-033 |
| dev: `drift_dev`, `build_runner` | drift code generation | ADR-011 |
| dev: `flutter_lints`, `flutter_test`, `integration_test` (SDK) | Lints and tests | — |

Transitive notes:
- `sqlite3` 3.x bundles SQLite through Dart build hooks, so no CocoaPods or Gradle setup is needed for SQLite.
- `sqlite3_flutter_libs`/`sqlcipher_flutter_libs` appear as empty `+eol` shims pulled in by `drift_flutter`.

The ID generator is hand-written (no `uuid` package) to keep the dependency list minimal. Phase 2 added **no packages**. Phosphor icons are bundled font assets (`assets/fonts/phosphor/`, MIT) with generated constants (`tool/generate_phosphor_glyphs.py`), because `phosphor_flutter` doesn't compile on Flutter 3.47 (ADR-024).


1. **Prefer Flutter/Dart built-ins** when adequate (animations, drag & drop, CustomPaint, `Intl`).
2. Every new package needs: a clear need, active maintenance, permissive license, Android **and** iOS support, no network/telemetry behavior, acceptable size.
3. **Packages that shape architecture** (DB layer, state, routing, codegen, charts) require an ADR.
4. Wrap third-party APIs that leak widely (e.g. file saving, haptics) behind a small interface in `core/`.
5. No packages that send data off-device (analytics, crash reporting, ads) in V1 (NFR-03).
6. Pin with caret constraints; commit `pubspec.lock` (application).
7. Fonts and icons are **bundled assets**, not fetched at runtime (e.g. do not use runtime-fetching font loaders).

## 10. Git & quality gates

- `main` always builds; all checks green before merge.
- Small, focused PRs with a description of *what/why* and screenshots (light + dark, phone + tablet) for UI changes.
- Never commit secrets (there should be none in V1), generated build output, or local IDE state.
- Generated code (drift `*.g.dart`, gen-l10n output) is committed (ADR-011, ADR-015). Regenerate in the same change as its source.
