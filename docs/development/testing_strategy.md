# Testing Strategy

> Test behavior and business rules that matter. No tests written only to raise a count.

---

## 1. Test pyramid

| Level | Purpose | Speed | Share |
|---|---|---|---|
| **Unit** | Domain logic, value encoding, analytics math, timer math, state transitions, mappers | ms | Most tests |
| **Repository / DB** | Real SQL against in-memory SQLite: queries, transactions, constraints, migrations | fast | Every repository |
| **Widget** | Behavior of meaningful widgets: generic form renderer, field editors, set table, key screen states | fast | Targeted |
| **Integration** | End-to-end flows on device/emulator with a real DB file | slow | Few, high value |
| **Golden** (optional) | Design system components in light/dark | fast | Small set, if they prove stable |

## 2. When to use what

- **Unit tests:** any pure function or class with rules. *If it can be a unit test, it should be.* Domain code is designed to be pure for this reason.
- **Repository tests:** whenever SQL, mapping, transactions or constraints are involved. **Use a real in-memory SQLite DB, not mocks.** Mocks of the DB prove nothing about SQL.
- **Widget tests:** when user-visible behavior depends on widget logic: rendering a form from field definitions, validation messages appearing, adding/removing set rows, empty/error state switching, accessibility semantics. Do not widget-test pure layout trivia.
- **Integration tests:** the critical journeys, especially the §43 success scenario, onboarding → first log, focus session survival.

## 3. Critical areas and what must be tested

| Area | Must cover |
|---|---|
| **Activity Type creation** | Create with fields; reorder positions persist; required/measurable flags; soft-delete type keeps logs readable; field type locked after values exist; duplicate active name warning |
| **Custom fields (catalog)** | For every field type: config parse/serialize round-trip; encode/decode round-trip to (text/number/json); validation (required, ranges, rating max, dropdown option exists/archived); summary text; metric descriptors |
| **Activity Logs** | Save log + values atomically (failure mid-way leaves nothing); edit diff preserves value row IDs; empty values not stored; values for deleted fields still load; `ended_at ≥ started_at`; soft delete + undo |
| **Repeating groups** (Phase 3) | Relational storage (ADR-027): v2→v3 migration with data; partial unique indexes; parent/child trigger rules; stable item IDs on edit/reorder; nesting limit (2) enforced; canonical unit storage for nested numbers; analytics extraction of nested values |
| **Plans** (Phase 4) | Effective status derivation (a linked log means completed; reality wins over stored `skipped`); stored `completed` only for tasks (CHECK); plan → log links `plan_id`; planned duration from planned times; day ordering |
| **Timers / Focus** (Phase 5) | Elapsed formula with fake clock across pause/resume cycles; process-death restore (state rebuilt from DB); finish transaction creates the log with `duration_ms` (ADR-021) and links it; discard creates no log; single active session (DB unique index) |
| **Measurements** | Canonical unit storage and display conversion; series by type/range |
| **Analytics calculations** (Phase 6) | Bucketing by `local_date` day/week/month across DST and tz-offset changes; sum/avg/max/min/count over `normalized_value`; nested Repeating Group extraction; derived volume/max load; comparisons (this vs last period); empty and single-point series |
| **Time model** | Day assignment by start; midnight-crossing logs; tz offset persistence |
| **Repository behavior** | Default filtering of soft-deleted rows; streams emit after writes; keyset pagination; `AppException` mapping of constraint violations |
| **Migrations** | For each schema version: upgrade from previous version fixture preserves data |
| **Form renderer (widget)** | Renders fields in position order; shows correct editor per type; required validation on submit; prefilled duration from focus |
| **States (widget)** | Key screens render loading, empty, error, data |

## 4. Tooling & conventions

- `flutter_test`, `integration_test` (SDK). Add `mocktail` only where a fake is impractical; **prefer hand-written fakes** (e.g. `FakeClock`, `SequentialIdGenerator`).
- In-memory DB per test (fresh schema), created via the same migration path as production.
- **Deterministic time and IDs**: tests override `clockProvider` and `idGeneratorProvider`.
- Test file mirrors source path: `lib/features/plans/domain/plan_status.dart` → `test/features/plans/domain/plan_status_test.dart`.
- Test names describe behavior: `'finishing a paused session excludes the open pause from active duration'`.
- Arrange/Act/Assert structure; one behavior per test; shared builders/fixtures in `test/support/` (e.g. `aGymType()`, `aReadingLog()`).
- Fixture activity types mirror the spec's reference activities (Gym, Reading, Meeting, Language Learning, Cooking) to keep the generic engine honest.

### 4.1 Harness (implemented)

| Helper | File | Use |
|---|---|---|
| `FakeClock` | `test/support/fake_clock.dart` | Controllable `Clock` (`advance()`) |
| `newTestDatabase()` | `test/support/test_app.dart` | `AppDatabase(NativeDatabase.memory())`, built through the production migration |
| `testAppWidgets(...)` | same | Use **instead of `testWidgets`** for any test that pumps the app |
| `pumpTestApp(tester, size:, preferences:)` | same | Seeds the DB with `preferences`, overrides DB/clock/snapshot, pumps `App` at a window size |

Why `testAppWidgets` exists:
- drift stream subscriptions schedule zero-length timers when they're cancelled, which the widget-test fake clock reports as "Timer still pending".
- Closing the database needs real async, which never completes inside the fake-async zone. Doing it in a tear-down callback therefore hangs.
- The wrapper unmounts the tree, pumps, then closes the databases with `tester.runAsync` *inside* the test body.

Other conventions:
- Pump the app **once per test**. Re-pumping a second `ProviderScope` over the first keeps the old router state.
- Integration tests (`integration_test/`) run the real `bootstrap()` against the on-device database. Restore `FlutterError.onError` after calling `bootstrap()`, because the framework requires its own handler at test end.
- `pumpTestApp(seed: (db, clock) async {...})` seeds data through real repositories/use cases before the app starts.
- `test/support/fixtures.dart`: `SequentialIdGenerator` (deterministic UUIDv7-shaped IDs) and reference definitions (`readingDefinition`, `languageDefinition`, which covers every Phase 2 field type, and `walkingDefinition`, a dimensioned number).
- **Lazy lists:** forms are `ListView`s, so off-screen widgets don't exist. Use `scrollUntilVisible(..., scrollable: find.byType(Scrollable).hitTestable().first)` and find inputs by their field label (`find.descendant(of: find.widgetWithText(FieldEditorShell, 'Book *'), matching: find.byType(TextField))`), never by index.
- **On a real device**, dismiss the soft keyboard (`FocusManager.instance.primaryFocus?.unfocus()`) before tapping buttons near the bottom.
- **Query plans:** `test/core/database/schema_integrity_test.dart` asserts with `EXPLAIN QUERY PLAN` that every hot path uses its index and history needs no temp sort.

Current suites (153 tests):
- **core:**
  - UUIDv7
  - `LocalDate`/`LocalTime` (offsets, midnight crossing)
  - unit registry conversions (affine temperature)
  - icon/color registries
  - WCAG contrast; palette consistency (ADR-029: brand/accent/status equal palette colors; sand removed)
  - window size classes
  - schema v2 shape and STRICT tables
  - every trigger and CHECK
  - query plans
  - `reactiveQuery` (pause/resume, ordering, drift `tableUpdates`)
  - `combineLatest2` (emission, pause propagation)
  - `LocalDate.addDays`/`weekday`
  - generated drift migration tests v1→v2 (schema plus preference data integrity)
- **activity_types:**
  - validator rules
  - config codec round-trips
  - repository/use cases: create, ordered fields, update with reorder/rename/add/remove, soft delete/restore, template install with fresh option IDs, live stream
- **activity_logs:**
  - value validation for all nine types
  - logs for a day (local day, active, time order); `WatchRecordsForDay` pairs records with their types, including archived ones
  - repository/use cases: every storage path round-trips, `local_date` from offset, write-time unit normalization, diffed edits keep row identity, soft delete/undo, history order, removed fields keep values, semantics lock enforced by the domain **and** the DB trigger, live stream
- **widgets:**
  - app shell/theme/showcase/l10n/200% text scale
  - Activities (Me → Activities) empty state
  - template install
  - builder create + inline validation
  - log with required-field validation and history summary
  - delete + Undo
  - navigation (ADR-028): four tabs, Quick Record on every tab and in the rail, two-tap Quick Record, empty Quick Record → builder, Me → Activities
  - Plan tab: opens on today with Planned and Recorded sections, week navigation, future dates hide Recorded, record → edit, calendar picker
  - renderer: every editor in order, archived options hidden, typed emission and clearing, invalid numbers
- **integration (device):**
  - `app_launch_test` (real bootstrap/DB)
  - `activity_engine_flow_test` (Me → Activities → template → record → history on native SQLite, in-memory DB)

  Both pass on the Android API 37 emulator and the iOS 27 simulator.

## 5. Coverage

No numeric coverage gate. Expectation: domain and data layers are thoroughly tested; every bug fix adds a regression test; every migration has a test. Coverage reports are used to find untested *rules*, not to chase percentages.

## 6. Acceptance test: V1 success scenario (§43)

One integration test scripts the full day (with a fake/advanced clock where possible):
night plan creation (5 plans) → morning view → gym log with 3 sets → 1h42m focus session → 43m reading timer → retroactive 48m meeting with checklist → retroactive walk → evening Today shows planned vs actual with correct durations → Insights shows series. This test must stay green from Phase 5 onward.

## 7. Manual QA checklist (per release)

Light/dark; compact phone, large phone, 7" and 10" tablet, landscape; text scale 1.0 / 1.3 / 2.0; TalkBack pass on main flows; airplane mode; kill app during focus session and during gym log; low-end device performance smoke test.
