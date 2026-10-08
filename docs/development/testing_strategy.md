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
| **Repeating groups** (Phase 3) | Relational storage (ADR-027): v2→v3 migration with data; partial unique indexes; parent/child trigger rules; stable item IDs on edit/reorder; nesting limit (2) enforced; canonical unit storage for nested numbers. Analytics extraction of nested values is tested in Phase 6 |
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
- `test/support/fixtures.dart`: `SequentialIdGenerator` (deterministic UUIDv7-shaped IDs) and reference definitions (`readingDefinition`, `languageDefinition`, which covers every Phase 2 field type, `walkingDefinition`, a dimensioned number, and `gymDefinition`, two levels of Repeating Groups). Group item IDs in tests must be UUID-shaped (36 chars; the schema CHECKs it).
- **Lazy lists:** forms are `ListView`s, so off-screen widgets don't exist. Use `scrollUntilVisible(..., scrollable: find.byType(Scrollable).hitTestable().first)` and find inputs by their field label (`find.descendant(of: find.widgetWithText(FieldEditorShell, 'Book *'), matching: find.byType(TextField))`), never by index.
- **On a real device**, dismiss the soft keyboard (`FocusManager.instance.primaryFocus?.unfocus()`) before tapping buttons near the bottom.
- **Query plans:** `test/core/database/schema_integrity_test.dart` asserts with `EXPLAIN QUERY PLAN` that every hot path uses its index and history needs no temp sort.

Current suites (269 tests):
- **core:**
  - UUIDv7
  - `LocalDate`/`LocalTime` (offsets, midnight crossing)
  - unit registry conversions (affine temperature)
  - icon/color registries
  - WCAG contrast; palette consistency (ADR-029/038: brand/accent/status equal palette colors; six keys; legacy keys resolve)
  - window size classes
  - schema v6 shape and STRICT tables
  - every trigger and CHECK, including the v3 Repeating Group triggers (parent/nesting, item structure, value scope, cascade)
  - query plans (incl. a log's items, a group's sub-fields, a date's plans with no temp sort, records fulfilling a date's plans, a measurement series, the active focus session)
  - plan CHECKs and triggers (completed only for tasks, one planned-duration source, record ↔ plan activity, fulfilled plan keeps its activity)
  - `reactiveQuery` (pause/resume, ordering, drift `tableUpdates`)
  - `combineLatest2` (emission, pause propagation)
  - `LocalDate.addDays`/`weekday`
  - generated drift migration tests v1→…→v6 (schema; preference data survives v1→v2; values survive v2→v3; logs survive v3→v4; v4→v5 and v5→v6 verified)
- **activity_types:**
  - validator rules (incl. groups: sub-fields required, item label, nesting limit, per-group name uniqueness, sub-field issue keys)
  - config codec round-trips (incl. `suggest`, `itemLabel`)
  - repository/use cases: create, ordered fields, update with reorder/rename/add/remove, soft delete/restore, using a built-in activity gives fresh option IDs, live stream
- **plans:**
  - repeating plans (ADR-036): weekdays, every-other-week and end date rules; Mon/Wed/Fri occurrences at 18:00 local, generated once; a deleted occurrence isn't regenerated; changing the rule from a date keeps logged occurrences; stop repeating; invalid rules rejected; moving an occurrence moves a copy; Plan next copies title, activity and length
  - widgets: Repeat… → Mon + Sat → "Repeats Mon, Sat" → both show in the next week; Month → tap a day → Day; Plan next from an item → "Planned for Sat, Oct 10" → it's there next week
  - items (ADR-035): a new name gets a plain activity of its own once, an existing name is reused; Mark done logs the planned time and length once, ticks a task off; partial logs save without required values; deleting an item deletes its log and Undo restores both; a day's items in time order with untimed plans last; `getLogForPlan` ignores deleted logs
  - domain: effective status (a running timer wins, then reality), planned length, display order, validator (title, plannable activity, locked activity, time rules), wall-clock day shift across DST, `daysUntil`, record start for a plan (planned start; else today → now, another day → that date at the current time), name matching
  - repository/use cases: title from activity, appended order, record from plan links and derives completion (and reopens on record delete), records on other days pair with their plan, mismatched plan rejected, task-only completion, move to tomorrow (time kept, reopened, appended), reorder, locked activity, delete/restore, live overview
- **focus (Phase 5):**
  - elapsed time excludes pauses; a paused session stands still
  - survives a restart (a new repository reads the same elapsed time)
  - only timer activities; one active session (domain and DB unique index)
  - finish writes the record (duration, end, plan) and the finished state atomically, and the plan goes In progress → completed
  - discard creates no record
  - finishing fills the item's existing log (values kept, start = session start), a second session adds its time; a session without a plan creates its own record (ADR-035)
  - widgets: open item → Start timer → log while it runs → Finish → "session complete", values kept, ✓ "Done · 42 min of 1h 0m"; Today banner → Return → the item → full-screen timer
- **insights & measurements (Phase 6):**
  - automatic charts (ADR-037): Gym → time, count, then per exercise best Weight and volume with real values behind them; Reading → Pages total and Rating average; days done counts distinct days; Insights → tap Gym → progress page with "Chest Press · best Weight" and no chart menu
  - domain: Monday weeks/month buckets, gaps vs zero-fill, every aggregation, this vs previous period, chart JSON round-trip for every source, measurement validation
  - repository on real SQLite: nested set weights filtered by exercise (case-insensitive) and personal best; volume = Σ weight × reps; time, count and per-activity totals; planned vs actual by plan date; lb → kg canonical measurements; save/list/delete charts
  - widgets: empty Insights; build a body-weight chart → latest value + line; record a measurement from Me
  - Challenges (ADR-044): `ChallengeProgress` (the 20 days / miss / 1 day example: progress 21, streak 1, best 20; today open keeps the streak at risk; no streak means nothing at risk; days before the start and after today ignored; several records one day; month/year ends; completion and capping); repository over real SQLite (recording the activity counts the day, other activities don't, empty records don't, notes or the item marked done do, deleting/restoring a record, live updates, completed sort last, local date by offset, validation, rename, restart + Undo, end + Undo); migration v8→v9 keeps data and guards the table; widgets: empty state, Today section at risk → done, missed day, detail stats, create flow, activity required, Edit / Restart / End with Undo, completed leaves Today
  - Insights rework (ADR-043): whole buckets, coarser saved-chart buckets, best by direction, week streaks, option counts, parts of day, plan share per bucket, change by count, fitted line axis, volume formula codec, number summary/better codec; repository: duration / yes-no / time values, lowest best and none, choice picks, period-limited reads with a separate all-time best, empty records not counted, skipped and today's open plans not planned, plan adherence, active days, time by activity, local start minutes, row names most used first; automatic charts by field type (Gym: best, estimated max, volume, total reps per exercise); widgets: home at a glance + calendar + "Not done this period" → activity page with the longer-period hint; activity page with yes share, "How often each" and "When you do it"
- **activity_logs:**
  - value validation for all nine scalar types; group validation (required group, item-scoped issue targets, value scope, unique item IDs)
  - Repeating Group repository: sub-fields under their group, the §43 workout round-trip (Chest Press 50×12, 55×10, 60×8), empty items dropped, edits keep item identity/reorder/remove with cascade, groups lock semantics, sub-field add/remove, text suggestions (distinct, newest first, deleted logs excluded)
  - logs for a day (local day, active, time order); `WatchRecordsForDay` pairs records with their types, including archived ones
  - repository/use cases: every storage path round-trips, `local_date` from offset, write-time unit normalization, diffed edits keep row identity, soft delete/undo, history order, removed fields keep values, semantics lock enforced by the domain **and** the DB trigger, live stream
- **widgets:**
  - app shell/theme/showcase/l10n/200% text scale
  - Activities (Me → Activities) empty state
  - using a built-in activity
  - builder create + inline validation
  - Record on an activity's page opens an item for now; what's logged shows in its history summary
  - deleting an item (plan + log) + Undo
  - navigation (ADR-028, ADR-044): five tabs (Today, Plan, Challenges, Insights, Me), no floating Record button (compact or rail), Me → Activities
  - Plan tab: opens on today with one list of items (unplanned records included), week navigation, a record without a plan opens as an item, calendar picker
  - renderer: every editor in order, archived options hidden, typed emission and clearing, invalid numbers
  - Quick add and planner (ADR-039): Start now / Set a time appear once typing; Recent label; suggestions (yours, then built-in, unlabeled); one time sheet sets start + length; Plan opens on Week, a tapped day opens the day screen, which steps days and has a date picker; a built-in name you already have isn't installed twice. Domain: unique activity names, `PlanTimeSuggestions`, `suggestByName`, `rankByUse`.
  - Phase B (ADR-041): `copyValues` gives fresh row IDs; `findLastRow` newest first, any depth, case-insensitive; `LastLogOfType` skips the item's own and empty logs; `DuplicatePlan`; every built-in activity valid with a unique name; widget flows for Use last time, row memory + Use, rest timer (start, +15 s, stop), long-press Duplicate with Undo, quick "How it went" chip, field sheet Advanced, built-in activity preview + Use.
  - Insights clarity (A20–A27): `ChartAxis` steps (no repeated labels); the activity list updates live after a new log; dates of the period shown; "best this period", "All-time best", "Best day" and "Best Set" labels; empty automatic charts hidden; duplicate names marked; builder order, 12 icons + More, icon names for screen readers; picker theme from tokens.
  - Done state and rows (ADR-040, A9–A19): logging makes an item in progress, Mark done (bottom of the item) or the row check makes it done, Undo removes a log that marking created; past-day logs count as done; finishing a timer finishes the item and fills the duration boxes; folded summaries ("60 kg × 8 (×2)"); "Anytime" heading; discard question on a half-filled sheet; list ⋯ menu adds a detail; no pop-up after using a built-in activity. Migration v7→v8 keeps plans, logs, series links and triggers.
  - Items (ADR-035): quick-add task + complete; opening a planned activity → typing saves ("Saved", no Save button) → ✓ with summary → reopening shows it; leaving right after typing still saves; plan options (no "Record it") → move to tomorrow with Undo; a task opens and is marked done; notes on a new name save it with an activity of its own; Today "Start now" opens a new item; empty Today invitation; Add to log → Sets & reps → log a set ✓; Add to log → Number "Calories" → 650 in the summary; Checklist → Add detail "Dose" appears in each row; "Mark done" on 21:10–21:55 → "Done · 45 min of 45 min"
  - planned Gym → open → one exercise, three sets (auto-saved) → leave → back → a fourth set → stored as one linked record with five group items
  - quick add: typing "reading" links the Reading activity (its item has its fields); typing "Gym" saves the built-in Gym activity and plans it
  - Repeating Groups: recording the §43 workout from an activity's page (sets prefilled from the previous set, reopened intact), an exercise without a name is still saved (partial), exercise autocomplete; builder creates a group with a sub-field in a nested sheet
- **integration (device):**
  - `app_launch_test` (real bootstrap/DB)
  - `activity_engine_flow_test` (Me → Activities → built-in Walking → record → history on native SQLite, in-memory DB)
  - `repeating_group_flow_test` (built-in Gym → exercise with three sets → reopen, on native SQLite; Phase 3)
  - `plan_flow_test` (built-in Reading → quick-add activity plan → tap it → record → Today shows ✓; Phase 4, ADR-030)

  The first two pass on the Android API 37 emulator and the iOS 27 simulator. `repeating_group_flow_test` (Phase 3) and `plan_flow_test` (Phase 4) are written but **not yet run on a device** (owner asked to skip device runs while coding).

## 5. Coverage

No numeric coverage gate. Expectation: domain and data layers are thoroughly tested; every bug fix adds a regression test; every migration has a test. Coverage reports are used to find untested *rules*, not to chase percentages.

## 6. Acceptance test: V1 success scenario (§43)

One integration test scripts the full day (with a fake/advanced clock where possible):
night plan creation (5 plans) → morning view → gym log with 3 sets → 1h42m focus session → 43m reading timer → retroactive 48m meeting with checklist → retroactive walk → evening Today shows planned vs actual with correct durations → Insights shows series. This test must stay green from Phase 5 onward.

## 7. Manual QA checklist (per release)

Light/dark; compact phone, large phone, 7" and 10" tablet, landscape; text scale 1.0 / 1.3 / 2.0; TalkBack pass on main flows; airplane mode; kill app during focus session and during gym log; low-end device performance smoke test.
