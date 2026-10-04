# Current Task

> Keep this file current. It tells any agent what phase the project is in, what is allowed now, and what comes next.

## Status

**Phases 5 (Focus) and 6 (Insights + body measurements): complete in code (2026-10-04), waiting for owner review.** Don't start Phase 7 until the owner approves it. Phases 3–6 aren't committed yet (branch `feature/phase-3-structured-fields`); commit only when the owner asks.

Owner decisions this round:
- ADR-031: record on finish (P09)
- ADR-032: DM Mono (P21)
- ADR-033: fl_chart (P11)
- ADR-034: core + gym & PRs (OQ-02, FR-AN-05/06/08/09)

Recommendations followed (say so if asked): OQ-09 fixed measurement types; OQ-13 no focus notification. **Needs owner confirmation:** OQ-14. Saved charts were built; the recommendation was ad hoc charts.

Phase 5 (schema v5):
- `focus_sessions` with timestamp-derived elapsed time and one active session (DB index)
- Start focus from a planned timer activity ("Start focus" / "Record now") or an activity's page
- full-screen timer in DM Mono with Pause/Resume, Finish and Discard (confirmed)
- Finish → paused → record form prefilled (start, focused time, plan) → `FinishFocusSession` writes record + session in one `UnitOfWork` → "Reading session complete · 42 min"
- plans show In progress; Today shows a live Return banner
- `ActivityLogDraft.endedAt` with end/duration validation

Phase 6 (schema v6):
- `measurements` (weight, height, body fat, chest, waist, arms, legs; units cm/in/% added) with Me → Body measurements (latest, history + line chart, add/edit/delete with Undo)
- `insight_charts` (saved configs)
- generic engine: time, count, any Number/Rating field at any depth with a text filter (e.g. Exercise = Chest Press), volume (weight × reps), body measurement, planned vs actual
- aggregations total/average/best/lowest/count/latest; day/week/month buckets; Week/Month/3 months/Year ranges; change vs previous period; personal best
- Insights tab: activity totals + chart cards + chart builder
- `AppChart` wraps fl_chart

Verified:
- `dart format` clean.
- `flutter analyze`: no issues.
- `flutter test`: 269 tests pass.
- **Not run:** device integration tests (deferred by the owner).

Not built yet (documented): keep-awake and the arc/wash on the focus screen; sparklines; a separate chart-detail screen; charting Duration fields as values; a task-completion source; draft persistence for long records (ADR-P18).

**Navigation change (owner, 2026-10-04):** the floating "+ Record" button and rail action were removed. Quick Record opens from Today's "Record something" (ADR-028 amended). 270 tests pass.

Earlier: Phases 1–4; ADR-028/029/030 (navigation, palette, plan → record workflow, customizable tracking from any plan).

## Standing rule (all phases)

Docs stay synchronized with the code in the same task as every change: [development_guide.md §4.1](../../docs/development/development_guide.md#41-documentation-maintenance-binding). Update this file when the phase or the next task changes.

## Not allowed

- Any Phase 7+ feature until the owner approves it.
- Any backend, auth, sync, AI, subscriptions, telemetry/analytics/crash-reporting SDKs, social or other V1-excluded work.
- Redesigning the visual identity (ADR-016 values remain provisional pending the owner's review).

## Owner decisions needed

| Item | Needed before | Recommendation |
|---|---|---|
| Visual identity review of the remaining provisional values (neutrals, fonts; ADR-016) | Before screens multiply | Owner's on-device showcase review |
| Splash screen polish | Later | Deferred by the owner |

Other pending ADRs (P09, P11, P15, P17, P18) and the remaining open questions belong to later phases.

## Next task (proposed, not started): Phase 7, Onboarding + Quick Record polish + history

See [development_guide.md §6](../../docs/development/development_guide.md#6-proposed-implementation-phases). Starts only after the owner's approval. Open first: OQ-14 confirmation and running the device integration tests for Phases 3–6.

**Planned after core functionality (owner direction, 2026-10-04):** one dedicated visual/product-design pass across the whole app (brief at the top of design_system.md). Until then: no visual redesign, no architecture changes for looks, no features from that direction. Keep UI token-driven and in shared components.
