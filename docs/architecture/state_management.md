# State Management (Riverpod)

> How state flows from SQLite to widgets. Decisions: ADR-004 (Riverpod), ADR-014 (hand-written providers; no riverpod_generator, no freezed).

---

## 1. State categories

| Category | Example | Owner |
|---|---|---|
| **Persistent domain state** | activity types, logs, plans, measurements | SQLite → repository streams → `StreamProvider` |
| **Derived state** | today's timeline, planned vs actual, chart series | `Provider`/`FutureProvider` combining other providers + domain functions |
| **Editing/draft state** | log form in progress, builder draft | `Notifier` / `AsyncNotifier` scoped to the screen (`autoDispose`) |
| **Ephemeral widget state** | text controllers, animation controllers, scroll position, expanded/collapsed | `StatefulWidget` local state. Not Riverpod. |
| **App preferences** | theme mode, units, onboarding complete | `settings` repository stream → provider |
| **Ticking state** | focus timer display | small widget-local ticker reading persisted session timestamps |

Rule: **if it must survive a screen being closed, it is in SQLite.** Riverpod holds no authoritative long-lived state of its own.

## 2. Provider layers

```text
core providers          databaseProvider, clockProvider, idGeneratorProvider, loggerProvider
        ▼
repository providers    activityTypeRepositoryProvider = Provider<ActivityTypeRepository>((ref) => DbActivityTypeRepository(ref.watch(databaseProvider), ...))
        ▼
query providers         activeActivityTypesProvider = StreamProvider(...)
                        logsForDayProvider = StreamProvider.family<List<ActivityLog>, LocalDate>(...)
        ▼
derived providers       dayTimelineProvider.family(LocalDate) → combines plans + logs + types via domain BuildDayTimeline
        ▼
controllers/notifiers   LogFormNotifier, ActivityBuilderNotifier, FocusSessionController, QuickLogController
                        (illustrative names; the single Notifier-vs-Controller suffix is chosen at scaffold, see coding_standards.md §2)
        ▼
widgets                 ref.watch(...) to render; ref.read(notifier).intent() to act
```

- Repository providers are typed to the **interface** and overridden in tests.
- `databaseProvider` is overridden in `main` with the opened DB (bootstrap) and in tests with an in-memory DB.

## 3. Rules

1. **Widgets never call repositories directly.** They watch query/derived providers and call notifier methods.
2. **Business rules live in domain**, not in notifiers. Notifiers orchestrate: collect input, call a use case/repository, expose `AsyncValue` state.
3. **No global mutable singletons.** Everything injectable via providers.
4. **`autoDispose` by default** for screen-scoped and `family` providers; keep-alive only for app-wide streams (active types, preferences, active focus session).
5. **`family` keys are values** (IDs, `LocalDate`, value-object query params with `==`/`hashCode`), never entities or closures.
6. **Use `select`** to limit rebuilds when a widget needs one property of a large state.
7. **One provider file per concern**, colocated in the feature's `presentation/` (or `presentation/providers/`). No giant `providers.dart` per app or feature.
8. **Async UI states are exhaustive:** every `AsyncValue` is rendered with data, loading and error branches using the shared state components ([ui_guidelines.md §States](../ui/ui_guidelines.md#5-states)).
9. **Side effects (navigation, snackbars, haptics) are triggered from widgets** reacting to notifier results (`ref.listen`), not from inside notifiers, so notifiers stay testable without a `BuildContext`.
10. **Time:** providers and domain read time from `clockProvider`; never `DateTime.now()` directly. A "current day" provider ticks at local midnight so Today rolls over.

## 3a. Implemented providers (Phase 1)

Riverpod **3.4** (`flutter_riverpod`), hand-written providers (ADR-014).

| Provider | Kind | Where | Notes |
|---|---|---|---|
| `appDatabaseProvider` | `Provider<AppDatabase>` | `core/database/` | Throws unless overridden (bootstrap: on-device DB; tests: in-memory) |
| `clockProvider`, `idGeneratorProvider`, `loggerProvider` | `Provider` | `core/` | Overridable in tests |
| `appPreferencesRepositoryProvider` | `Provider<AppPreferencesRepository>` | `features/settings/presentation/` | Typed to the domain interface |
| `initialPreferencesProvider` | `Provider<PreferencesSnapshot>` | same | Startup snapshot overridden by bootstrap, so the first frame needs no loading state |
| `themePreferenceProvider`, `onboardingCompletedProvider` | `StreamProvider` | same | Live DB streams |
| `effectiveThemePreferenceProvider` | `Provider` | same | Stream value, else the startup snapshot |
| `preferencesNotifierProvider` | `NotifierProvider<PreferencesNotifier, void>` | same | Intents: `setThemePreference`, `completeOnboarding`, `resetOnboarding` (debug) |
| `routerProvider` | `Provider<GoRouter>` | `app/router.dart` | Listens to `onboardingCompletedProvider`; disposes the router with the provider |

**Startup-snapshot pattern:** values needed on the first frame (theme, first route) are read once in `bootstrap()` and overridden into `initialPreferencesProvider`. Live streams take over as soon as they emit. Tests must seed the database with the same values they pass as the snapshot, as `pumpTestApp` does, because the live stream always wins.

Riverpod 3 notes: `AsyncValue.value` returns `null` while loading or on error (there is no `valueOrNull`). `ProviderObserver` callbacks receive a `ProviderObserverContext`.

## 3b. Implemented providers (Phase 2)

| Provider | Kind | Where |
|---|---|---|
| `activityTypeRepositoryProvider`, `activityLogRepositoryProvider` | `Provider<…Repository>` (interface-typed) | `features/*/presentation/*_providers.dart` |
| `activeActivityTypesProvider` | `StreamProvider<List<ActivityType>>` | activity_types |
| `activityTypeProvider(id)` | `StreamProvider.autoDispose.family` (includes deleted types, for history) | activity_types |
| `logsForTypeProvider(typeId)` | `StreamProvider.autoDispose.family` | activity_logs |
| Use-case providers (`createActivityTypeProvider`, `logActivityProvider`, …) | `Provider` | per feature |
| `activityBuilderProvider(typeId?)` | `AsyncNotifierProvider.autoDispose.family<ActivityBuilderNotifier, …>` | activity_types/presentation/builder |
| `logEditorProvider(LogEditorArgs)` | `AsyncNotifierProvider.autoDispose.family<LogEditorNotifier, …>` | activity_logs/presentation |
| `recordsForDayProvider(LocalDate)` | `StreamProvider.autoDispose.family<List<DayRecord>, …>` (composite read: `WatchRecordsForDay` = logs for the day + all types via `combineLatest2`) | activity_logs/presentation |
| `planSelectedDateProvider` | `NotifierProvider<PlanDateNotifier, LocalDate>` (kept while the app runs; starts on today via `Clock`) | plans/presentation |

- Riverpod 3 family notifiers receive their argument through the **constructor** (`LogEditorNotifier(this.args)`). Family keys are value types (`ActivityTypeId`, `LogEditorArgs` with `==`).
- **Riverpod 3 pauses providers whose widgets are hidden** (e.g. a screen under a pushed route). Repository streams are built with `reactiveQuery` (`core/database/reactive_query.dart`):
  - Loads are driven by drift `tableUpdates`.
  - While paused, it defers loading.
  - On resume, it re-queries once if anything changed.

  This fixed a real bug found in Phase 2: a list didn't refresh after saving from a covering screen. Don't build live queries any other way. In particular, never watch a constant trigger query such as `SELECT 1`, because drift won't re-emit unchanged results.

## 4. Editing pattern (log form, implemented as `LogEditorNotifier`)

```text
LogEditorScreen(typeId, logId?, planId?)
  └─ ref.watch(logFormProvider(args))          // AutoDisposeAsyncNotifier
        build(): loads ActivityType (+ existing log) → LogFormState(draft values, validation = empty)
        setValue(fieldId, value)                 → updates draft, clears that field's error
        submit()                                 → domain validation → SaveActivityLog use case → AsyncValue result
  └─ ref.listen(logFormProvider(args), ...)    // on success: haptic + success feedback + pop
```

The draft is plain immutable state (`copyWith`). Unsaved-changes guarding (on back) reads `state.isDirty`.

## 5. Focus timer pattern

- `activeFocusSessionProvider`: keep-alive `StreamProvider<FocusSession?>` from the repository.
- `FocusSessionController` (Notifier): `start(typeId, planId?)`, `pause()`, `resume()`, `finish(notes?)`, `discard()`. Each persists via repository/use case; the stream updates the UI.
- `ElapsedText` widget: local ticker (1s, aligned to whole seconds) computing elapsed from the session's timestamps via a pure domain function. Only this widget rebuilds every second.

## 6. Testing providers

- Use `ProviderContainer(overrides: [...])` for notifier/unit tests.
- Override repository providers with in-memory DB-backed real implementations (preferred) or fakes; avoid mocking Riverpod itself.
- Override `clockProvider` with a controllable fake clock.

See [testing_strategy.md](../development/testing_strategy.md).

## 7. Anti-patterns (reject in review)

- `ref.read` inside `build` to "avoid rebuilds" (hides dependencies).
- Copying stream data into a notifier and mutating it locally (two sources of truth).
- Providers that hold `BuildContext`, controllers or widgets.
- Business logic in `ConsumerWidget.build`.
- A single "AppState" god notifier.
- Watching a stream provider inside a hot loop/list item for each row when the parent already has the data.
