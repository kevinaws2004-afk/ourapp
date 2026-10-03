# Current Task

> Keep this file current. It tells any agent what phase the project is in, what is allowed now, and what comes next.

## Status

**Phase 2 (Generic Activity Engine): complete (2026-10-04), plus the navigation/terminology clarification (ADR-028) and the Repeating Group storage decision (ADR-027).** Waiting for owner approval. Do **not** start Phase 3 until the owner explicitly approves it.

The clarification added:
- Navigation is Today | Plan | Insights | Me, with Track removed.
- Me → Activities hosts the Activity Type list, detail and builder.
- A global Quick Record action (FAB on compact, rail action on larger windows) opens a sheet → record form.
- The date-based Plan tab has a week strip, calendar picker, "Today" jump, a Planned placeholder section (until Phase 4) and a Recorded section for today/past dates.
- UI copy says "Record" instead of "Log".
- Colors (ADR-029): only the nine activity-palette colors plus neutrals (sand removed). Brand = teal, accent = apricot, success = moss, warning = apricot, danger = rose.
- Repeating Group storage is designed as relational rows. It isn't implemented yet; that's Phase 3, schema v3.

Implemented:
- Schema v2: STRICT activity tables, triggers, partial indexes.
- The approved decisions ADR-017–026 and OQ-01.
- Activity types, fields, builder with live preview, four starter templates (Reading, Focused work, Walking, Language learning).
- Logs with nine typed field types, the generic form renderer, the log editor (built-in start/duration/notes), history, delete/undo.
- Phosphor icons (bundled official font).
- The `AppException` error model, the unit registry, and pause-safe live queries.

Verified:
- `dart format` clean.
- `flutter analyze`: no issues.
- `flutter test`: 153 tests pass.
- Integration tests pass on the Android API 37 emulator and the iOS 27 simulator.
- An Android release build succeeds, and the icon fonts tree-shake.

## Standing rule (all phases)

Docs stay synchronized with the code in the same task as every change: [development_guide.md §4.1](../../docs/development/development_guide.md#41-documentation-maintenance-binding). Update this file when the phase or the next task changes.

## Not allowed

- Any Phase 3+ feature until the owner approves it.
- Any backend, auth, sync, AI, subscriptions, telemetry/analytics/crash-reporting SDKs, social or other V1-excluded work.
- Redesigning the visual identity (ADR-016 values remain provisional pending the owner's review).

## Owner decisions needed

| Item | Needed before | Recommendation |
|---|---|---|
| ADR-018 sub-item: `plans.planned_duration_ms` for untimed planned durations | Phase 4 | Add it, with `CHECK` so it can't coexist with `planned_end_at` |
| ADR-P21: tabular digits for numeric tokens | Phase 5 | DM Mono for numeric tokens only |
| Visual identity review of the remaining provisional values (neutrals, fonts; ADR-016) | Before screens multiply | Owner's on-device showcase review |
| Splash screen polish | Later | Deferred by the owner |

Other pending ADRs (P09, P11, P15, P17, P18) and the remaining open questions belong to later phases.

## Next task (proposed, not started): Phase 3, structured fields

See [development_guide.md §6](../../docs/development/development_guide.md#6-proposed-implementation-phases). Relational Repeating Groups (ADR-027): schema v3 migration, nested sets, Gym/Meeting/Cooking templates. Starts only after the owner's approval.
