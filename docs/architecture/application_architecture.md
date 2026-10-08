# Application Architecture

> Where code lives and how the pieces fit together. Principles are in [architecture.md](architecture.md); the data model is in [data_architecture.md](data_architecture.md).
>
> **Implementation status (Phase 2 complete):**
> - **Implemented:**
>   - `app/` and `shared/`
>   - the `core/` folders marked *implemented* below
>   - `l10n/`
>   - `settings` (preferences)
>   - `activity_types`: domain, data and presentation (Me → Activities and Browse activities = one list, activity detail, builder, built-in activities)
>   - `activity_logs`: domain, data and presentation (the generic form renderer and the day's record tile)
>   - `plans`: domain, data and presentation (plans and tasks, `WatchDayOverview` + `DayOverview.entries`, the item screen where you log into an item (`presentation/item/`, ADR-035), the date-based Plan tab with quick add, reorder and the plan sheet)
>   - `today` (presentation): greeting, quick add with Now, today's items as one list (tap to open the item, task check; ADR-035), planned vs actual
>   - `focus` (Phase 5, ADR-031): domain/data/presentation (session model and use cases, `DbFocusSessionRepository`, full-screen `FocusScreen`, `FocusBanner`; the timer also runs inside the item); `core/transactions/UnitOfWork` + `core/database/DbUnitOfWork`
>   - `measurements` (Phase 6): domain/data/presentation (Me → Body measurements, per-type history + chart, add/edit sheet)
>   - `challenges` (ADR-044): `Challenge`, `ChallengeProgress` (pure progress and streak maths), `WatchChallenges`, `DbChallengeRepository`, Today's section, the Challenges tab, the sheet and the challenge screen
>   - `insights` (Phase 6, ADR-034): the generic engine (`insight.dart`, `WatchInsight`), `DbInsightRepository`, the Insights tab, chart cards and the chart builder; shared `AppChart` (fl_chart, ADR-033)
> - Everything else here is target design.

---

## 1. Project layout

```text
lib/
├── main.dart                  # Entry: calls bootstrap(), runApp(ProviderScope(child: App()))
├── app/                       # App composition: root widget, router, shell, theme wiring, bootstrap
├── core/                      # Cross-cutting infrastructure (no feature knowledge)
├── shared/                    # Reusable presentation components built on the design system
├── l10n/                      # ARB files + committed gen-l10n output (ADR-015)
└── features/
    └── <feature>/
        ├── data/              # Repository implementations (and DAOs when useful), mappers
        ├── domain/            # Entities, value objects, repository interfaces, use cases
        └── presentation/      # Screens, widgets, notifiers/providers
```

**Do not create empty folders.** A feature gets a `data/` folder only when it persists something, and a `domain/` folder only when it has real domain logic. Create folders when the first file needs them.

### 1.1 `app/` (implemented)

| File | Purpose |
|---|---|
| `app.dart` | `MaterialApp.router`: the chosen theme (`AppTheme.of(effectiveThemeProvider)`, always light, ADR-045), localization delegates |
| `router.dart` | `GoRouter` provider, `AppRoutes` path constants, `onboardingRedirect()` |
| `app_shell.dart` | Adaptive navigation scaffold (bottom bar on compact, rail on medium/expanded) |
| `bootstrap.dart` | Error handlers → open + migrate DB → read preferences snapshot → `runApp` |
| `startup_failure_app.dart` | Shown if the DB can't be opened/migrated; offers retry, never deletes data |
| `provider_logger.dart` | Riverpod `ProviderObserver` that logs provider failures |
| `dev/` | Developer tools, only when `devToolsEnabled` (`dev_tools.dart`: debug builds or `--dart-define=DEV_TOOLS=true`): token showcase (`token_showcase_screen.dart`, `showcase_sections.dart`); demo data loader (`demo_data.dart`, Me → Developer → "Load demo data (6 weeks)" / "(last 10 days)", an optional date range, writes through the normal use cases) |

### 1.2 `core/`

| Folder | Purpose |
|---|---|
| `core/database/` *(implemented)* | drift `AppDatabase`, **all table definitions** (`tables/app_preferences_table.dart`, `tables/activity_engine.drift`; ADR-011), the generated v1→v2 step helpers (`app_database.steps.dart`), `openAppDatabaseConnection()` (WAL, synchronous=NORMAL), `appDatabaseProvider`, plus data-layer helpers: `guardStorage` (raw error → `AppException`), `isActive` (shared soft-delete predicate), `reactiveQuery` (pause-safe live queries driven by drift `tableUpdates`) |
| `core/design/` *(implemented)* | Design tokens (`tokens/`), `AppTheme`, `AppTokens`, `context.tokens`/`context.colors`, `AppIcons`, `WindowSizeClass`. Icons: `icons/phosphor_glyphs.dart` and `icons/activity_icon_registry.dart` (generated, ADR-024). Pure-Dart registry keys the domain may import: `keys/activity_icon_ids.dart`, `keys/activity_color_key.dart` |
| `core/time/` *(implemented)* | `Clock` (`nowUtc()`, `offsetAt()`), `SystemClock`, `clockProvider`, `LocalDate`, `LocalTime` |
| `core/ids/` *(implemented)* | `IdGenerator`, `Uuid7IdGenerator` (ADR-017), `idGeneratorProvider` |
| `core/units/` *(implemented)* | `UnitRegistry`, `Dimension`, `Unit` (ADR-020). Pure Dart |
| `core/errors/` *(implemented)* | Sealed `AppException` (`ValidationException`, `NotFoundException`, `StorageException`, `MigrationException`, `UnsupportedException`), `ValidationIssue`/`ValidationCode`/`ValidationResult` (ADR-025) |
| `core/logging/` *(implemented)* | `AppLogger` (local only), `loggerProvider` |
| `core/platform/` | Interfaces for platform services when needed (file saving for export, haptics wrapper). Only created when a feature needs one. |

`core/` never imports from `features/`.

### 1.3 `shared/`

Reusable, feature-agnostic UI built from design tokens.
- Implemented:
  - `AppButton` (all variants take an optional icon), `CenteredScrollBody`
  - `ActivityBadge`, `SectionHeader`
  - state views: `AsyncValueView`, `DelayedLoadingPlaceholder`, `AppEmptyState`, `AppErrorState`
  - snackbar helpers: `showUndoSnackBar`, `showMessageSnackBar`
  - `shared/errors/error_copy.dart`, which maps `AppException`/`ValidationCode` to localized copy
- Planned: surfaces, sheets, chips, input shells, chart primitives. See [ui_guidelines.md](../ui/ui_guidelines.md) for the component inventory. `shared/` may import `core/` but never `features/`.

### 1.4 Features

`lib/l10n/` (implemented) holds `app_en.arb` and the committed gen-l10n output in `l10n/generated/` (ADR-015). It sits beside `app/core/shared` because every layer's presentation code reads strings from it.

| Feature | Owns | Layers |
|---|---|---|
| `activity_types` | Activity Type + Field definitions, **field type catalog** (domain), builder screens, field config editors, built-in activities | data, domain, presentation |
| `activity_logs` | Logs + values, value encoding/decoding, **generic form renderer**, field value editors (incl. Set Table, Repeating Group), log detail | data, domain, presentation |
| `plans` | Plans and Tasks, status transitions, plan-to-log start flow | data, domain, presentation |
| `focus` | Focus sessions, timer state machine, full-screen focus UI | data, domain, presentation |
| `today` | Composes plans + logs into the current-date view and planned-vs-actual | domain (timeline merge), presentation |
| `challenges` | Daily challenges: definition, progress and streaks derived from an activity's logs, Today section, Me list, sheet, detail | domain, data, presentation (reads logs through its own query; activity types through their repository) |
| `insights` | Analytics engine (metric sources, extraction, aggregation), chart configuration UI | domain, presentation (reads via other features' repositories) |
| `measurements` | Body measurements | data, domain, presentation |
| `history` | Search and filtered history | presentation (+ domain query objects; queries implemented in `activity_logs` data layer) |
| `onboarding` | First-run narrative, choosing starter activities, initial preferences | presentation (+ uses `activity_types` and `settings`) |
| `settings` | "Me" tab: preferences (theme, units), export | data, domain, presentation |

Tab ↔ feature mapping (ADR-028): Today → `today`; Plan → `plans` (+ records for the date from `activity_logs`); Challenges → `challenges`; Insights → `insights`; Me → `settings` + `measurements` + **Activities** (`activity_types`). Quick Record (global) → `activity_logs`.

## 2. Dependency rules

```text
presentation ──▶ domain ◀── data
      │             ▲
      ▼             │
   shared ──▶ core ◀┘
```

1. `domain` imports only Dart core, `core/` pure utilities (time, ids, errors), and other features' **domain**.
2. `data` imports its own `domain`, `core/`, and the DB library.
3. `presentation` imports its own and other features' `domain`, `shared/`, `core/`, and Riverpod/Flutter.
4. **Cross-feature access goes through domain only.** Feature A must never import feature B's `data/` or `presentation/`, with one exception: the app router may import screens from any feature. Composition of providers across features happens in presentation.
5. Repository implementations are bound to interfaces in providers (see [state_management.md](state_management.md)). Tests override those providers.
6. Cyclic imports between features are forbidden. If two features need each other, the shared concept belongs in the lower one's domain (e.g. `activity_logs` depends on `activity_types` domain, never the reverse).

Expected feature dependency direction (lower depends on nothing above it):

```text
activity_types  ◀── activity_logs ◀── focus
       ▲                 ▲    ▲
       │                 │    └──── plans (plan → start log)
       │                 │
     insights ───────────┘     today ──▶ plans, activity_logs, activity_types, focus
     history  ──▶ activity_logs, activity_types
     onboarding ──▶ activity_types, settings
     measurements (independent); insights ──▶ measurements
```

`plans` depends on `activity_types` (optional link). `activity_logs` holds a nullable `planId` but does not import the `plans` feature; the plan-to-log flow is orchestrated by a `plans` use case.

## 3. Domain layer details

### 3.1 Entities

Pure Dart, immutable, value equality. Examples: `ActivityType`, `ActivityField`, `ActivityLog`, `LogValue`, `Plan`, `Measurement`, `FocusSession`. Field configs and values are **typed** in the domain (sealed classes), never raw `Map<String, dynamic>` beyond the data layer boundary. See [data_architecture.md](data_architecture.md).

### 3.2 Use cases (ADR-023)

- **Naming:** verb + domain object/capability, e.g. `CreateActivityType`, `UpdateActivityType`, `DeleteActivityType`, `RestoreActivityType`, `AddBuiltInActivity`, `LogActivity`, `UpdateActivityLog`, `DeleteActivityLog`, `RestoreActivityLog`. No `Manager`/`Handler`/`Processor`/`Service`.
- **Shape:** a small class with a single `call(...)` method; dependencies are injected through the constructor.
- **When:** **every write** goes through a use case, because use cases validate domain rules and assign UUIDv7 IDs. Composite reads (e.g. a future `WatchToday`) are use cases too. Simple single-repository reads are watched directly through repository providers.
- **Implemented (Phase 2):** `features/activity_types/domain/activity_type_use_cases.dart`, `features/activity_logs/domain/activity_log_use_cases.dart`.

### 3.3 Repository interfaces

Defined in domain, implemented in data. Contract:
- Return/accept domain entities.
- Expose `watch…` methods (streams) for anything displayed live, and `get…` for one-off reads.
- Hide soft-deleted rows by default; an explicit `includeDeleted` option is available where history needs it.
- Throw only `AppException` subtypes: every public method is wrapped in `guardStorage` ([error_handling.md](../development/error_handling.md)).
- Live reads use `reactiveQuery(db.tableUpdates(...), load)`. Lists load in one query plus one batched child query (no N+1).
- Multi-row writes are atomic inside the repository.

## 4. Generic form renderer

*Implemented in Phase 2.*

The heart of the configuration-driven UI (§46).

```text
ActivityType.fields (position order; removed fields only if the log has a value)
        │
        ▼
ActivityLogFormFields                      features/activity_logs/presentation/form/
  for each field:
     FieldEditorShell (label, required *, inline error)
       └─ FieldEditorRegistry.editorFor(field, value, onChanged)
        │
        ▼
ItemNotifier (item: plan, type, logId?, startedAt, durationMs, notes, Map<ActivityFieldId, FieldValue>)
  └─ debounced auto-save ─▶ LogActivity / UpdateActivityLog (partial: true) ─▶ LogValidator ─▶ repository
```

Rules:
- `FieldEditorRegistry` is an exhaustive `switch` over `FieldType`, so adding a field type without an editor is a compile error. It is the only place presentation branches on field type.
- Editors hold no persisted state: they receive the current typed `FieldValue?` and an `onChanged` callback. The item's state lives in the notifier, which saves it shortly after each change (ADR-035). Clearing an input emits `null` (no value).
- Validation is domain logic (`LogValidator`). The UI shows the returned `ValidationIssue`s next to the matching field.
- The log's built-in **start time, duration (ADR-021) and notes** sit outside the renderer, in the item screen.
- Used by: the item screen (ADR-035: `ItemScreen` / `ItemNotifier` in `plans/presentation/item/`, routes `/item/:planId` and `/item/log/:logId`; the first change creates the log through `EnsureItemActivity` + `LogActivity`, later ones `UpdateActivityLog`, all `partial`). Earlier: new/edit log (Phase 2), plan → log (Phase 4, ADR-030: tapping a plan opens `LogEditorArgs.create(typeId, planId:)`, route `/logs/new/:typeId?plan=<planId>`; `LogEditorNotifier` loads the plan into `LogEditorState.plan` for the "Planned" line and the default start time); post-focus completion (Phase 5).
- The builder's live **preview** renders the same `ActivityLogFormFields` with a throwaway draft. There is one renderer, never two.
- **Repeating Group** (`RepeatingGroupEditor`, ADR-027) is generic: it never knows what an item represents.
  - Items render as cards holding a nested `ActivityLogFormFields` for the group's sub-fields, with issue targets prefixed `<itemId>/`.
  - When every sub-field is a Number, items render as compact rows instead, and a new row starts from the previous row's values (repeat a set in one tap).
  - "Add {itemLabel}" appends an item whose `GroupItemId` comes from `idGeneratorProvider`. A nested group renders recursively.
  - The renderer therefore takes the `ActivityType` (`ActivityLogFormFields.type`) to read sub-fields.
- **Autocomplete:** a single-line Text field with `suggestFromHistory` offers previously recorded values (`textSuggestionsProvider` → `ActivityLogRepository.textSuggestions`), matched case-insensitively anywhere in the text.
- **Builder:** a group's settings (item name, ordered sub-fields) live in its field sheet; each sub-field is edited in a nested sheet. The type picker hides Repeating Group once the nesting limit is reached.

## 5. Focus timer architecture

- Timer state is **derived from persisted timestamps**, never from an accumulating in-memory counter. `elapsed = (now or ended_at) − started_at − paused_total − (paused_at ? now − paused_at : 0)`.
- The ticking UI uses a periodic rebuild (`Ticker`/`Stream.periodic`) scoped to the smallest widget showing the time. The rest of the screen does not rebuild per second.
- State machine (domain): `running ⇄ paused → finished` and `running|paused → discarded`. Transitions persist immediately.
- On app start, `bootstrap` restores any active session so the user lands back in focus mode or sees an "in progress" banner.
- No foreground service in V1 (see OQ-13). Correctness does not depend on the process staying alive.

## 6. Navigation

- `go_router` with a `StatefulShellRoute` for the five tabs (Today, Plan, Challenges, Insights, Me; ADR-028, ADR-044) preserving each tab's stack. The shell has no Record action (owner, 2026-10-04); items are added from the quick add (ADR-035).
- Full-screen routes outside the shell: Item, Focus Mode, Activity Builder, Onboarding.
- Modal bottom sheets for the plan sheet and pickers. Sheets are not routes unless deep-linking is needed.
- Onboarding gate (implemented): the router's `redirect` calls `onboardingRedirect()` with the current `onboarding_completed` preference. A `ValueNotifier` fed by the preference stream is the router's `refreshListenable`; the startup snapshot gives the correct first route with no flash.
- Route paths are constants in `app/router.dart`. Features expose screen widgets; they do not build `GoRoute`s themselves, which keeps routing in one place.
- Route arguments are IDs (strings), never entity objects, so routes survive restoration.

Implemented:
- Phase 1: `/onboarding`, `/today`, `/plan`, `/insights`, `/me` (and `/challenges` from ADR-044), debug-only `/dev/tokens` (`/track` was removed by ADR-028).
- Phase 2:
  - Inside the Me tab: `/me/activities` (Activities) and `/me/activities/:typeId` (activity detail). The Challenges tab is `/challenges` (ADR-044); a challenge opens full screen at `/challenge/:id` on the root navigator, from Today or the tab.
  - Full-screen on the root navigator: `/activities/new`, `/activities/browse`, `/activities/:typeId/edit`. (`/logs/…` were replaced by `/item/…`, ADR-035.)

Route parameters are public IDs (ADR-017). Indicative full route map (paths will be reconciled with the implemented ones as features land):

```text
/today                           (implemented)
/plan                            (implemented: Week | Month)
/plan/day                        (implemented: the selected date as a day; ADR-039)
/me/activities                   (implemented)
/me/activities/:typeId           (implemented)
/challenges                      (implemented: the Challenges tab, ADR-044)
/challenge/:id                   (implemented, ADR-044)
/activities/new, /activities/browse, /activities/:typeId/edit   (implemented)
/item/:planId                    (implemented: an item, where you log into it; ADR-035)
/item/log/:logId                 (implemented: a record without a plan, as an item)
/focus                           (implemented: the active session, full screen)
/insights                        (implemented)
/me
/me/measurements[/:type]         (implemented)
/me/settings
/history
/onboarding
```

## 7. Startup sequence

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Install error handlers (`FlutterError.onError`, `PlatformDispatcher.instance.onError`) → `AppLogger`.
3. Open DB, apply pragmas, run migrations, and read the preferences snapshot (the first query triggers open + migration). Failure → `StartupFailureApp` with retry (never silently recreate the DB). Export/diagnostic guidance is added when export exists.
4. Create `ProviderScope` with overrides for the opened DB, the logger and the preferences snapshot, plus the `ProviderLogger` observer.
5. Router decides: onboarding or `/today`. (Restoring an active focus session is added in Phase 5.)

Startup budget: [performance.md](../development/performance.md).

## 8. Platform independence (Android first, iOS later)

- No `dart:io` `Platform.isAndroid` checks in domain/data. Presentation may adapt (e.g. back-gesture behaviors) via a small helper in `core/platform/`.
- File paths via a path-provider abstraction; never hardcode Android paths.
- Fonts and icons are bundled (no runtime downloads) so behavior is identical offline on both platforms.
- Haptics through a wrapper so iOS/Android differences are centralized.
- Test on at least one compact and one expanded Android device class; keep iOS buildable in mind (no Android-only plugins without an iOS story or an interface).
