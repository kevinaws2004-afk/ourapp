# Current Task

> Keep this file current. It tells any agent what phase the project is in, what is allowed now, and what comes next.

## Status

**Flow rework (owner-approved plan, 2026-10-04; ADR-035–037): all 4 steps done, on the emulator for the owner to try.** The owner tested Phases 1–6 on their phone and found the flow broken: plan, record and activity setup felt like three separate places. Approved plan: the planner is the app; open an item on your day and log into it as you go. This replaces the old Phase 7 scope. Phases 3–6 are committed (`4b8431a`); the rework isn't committed yet (commit only when the owner asks).

Step 1 (done): item screen + live logging
- One list of items on Today and Plan (plans + records made without a plan, time order, untimed last); "Recorded / Also recorded" sections removed
- `ItemScreen` (`/item/:planId`, `/item/log/:logId`): fields, notes, when/duration; **saves as you type** (`ItemNotifier`, 600 ms debounce, saves on leaving); "Saving…" / "Saved"
- Required is a hint while logging (`partial` validation); a new name takes notes straight away and gets an activity of its own (`EnsureItemActivity`)
- Mark done (`MarkItemDone`), Start timer inside the item (finish fills the item's log; a second session adds time), Delete = plan + log with Undo (`DeleteItem`/`RestoreItem`)
- Quick add has **Now** (today; now the **Start now** action, ADR-039): adds the item at the current time and opens it; an activity's "Record" does the same
- Removed: record form, Quick Record sheet, Start focus / Record now sheet, Track details, Record again
- Bug fixed on the way: Undo after deleting from inside an item (the screen had closed)

Step 2 (done, after the owner found a plain item had nothing to log but notes): **Add to log** in every item (Sets & reps / Checklist in one tap, or any one thing: number with unit, text, list, yes/no, rating, choice, date, time), **Add detail** inside lists, pencil → builder; `AddItemField` saves it onto the item's activity.

Verified:
- `dart format` clean, `flutter analyze` no issues, `flutter test`: 306 pass
- **Not run:** device integration tests (owner's standing preference); they were updated to the item flow and compile

Step 3 (done, ADR-036, schema v7): Plan tab **Day | Week | Month** (now Week | Month + day screen, ADR-039); **Repeat…** (weekdays, every 1–4 weeks, until) with occurrences generated for the dates viewed, "Stop repeating after this", moving one occurrence moves a copy; **Plan next…** in every item.

Step 4 (done, ADR-037): Insights rows show days done · time · times · change and open an activity's **progress page** with charts worked out from its fields (time, count, numbers, ratings, per list row best and volume, e.g. per exercise). Saved charts stay below as "Your own charts".

Owner decisions this round: the item model (one concept, recording happens inside the item); logging must not require setup; follow-ups are a generic action, not a doctor feature; scope = all four steps; functionality first, visual design later.

**Needs owner confirmation:** OQ-14 (saved charts kept, now planned as secondary to automatic insights).

**Color restriction (owner, 2026-10-04, ADR-038):** done. The app uses only white shades, mist `#DDF0EF` and sky, lilac, teal, rose, slate, coral. Linen/night neutrals replaced; sage/apricot/moss removed (stored keys map to teal/coral). Flow/UX improvements are next, per the owner.

**UX evaluation (2026-10-05):** hands-on findings and a proposed fix/feature list are in [improvement_backlog.md](../../docs/product/improvement_backlog.md). Only items the owner picks are approved scope.

**Backlog A1–A8 (owner-approved 2026-10-05, ADR-039): done, not committed.** Plan tab = Week | Month, a tapped day opens a day screen that shares Today's `DayItems`; quick add: Start now + Set a time appear once typing, one time sheet, suggestions (your activities, then templates), Recent chips ordered by use; activity names unique; Me = Your setup + debug-only Developer section. Verified: format clean, analyze clean, `flutter test` 323 pass. **Not run:** device integration tests (updated for the day screen). Next candidates: A9–A27 when the owner picks them.

**Backlog A9–A19 (owner-approved 2026-10-05; A10 as the "proper fix", ADR-040, schema v8): done, not committed.** Any item can be marked done (stored), logging makes it In progress (done by itself once its day has passed), finishing the timer finishes it; Mark done at the bottom of the item; every row starts with a check that toggles done (Undo removes a log it created); one visual rule (outline / filled + ✓ / faded); summaries show numbers with repeats folded; "Anytime" heading; Duration boxes labeled and filled by the timer; list ⋯ menu for adding a detail; new rows scroll into view; field and plan sheets ask before discarding; Gym "Workout" is a choice (Push/Pull/Legs…); no pop-up after adding a template. Verified: format clean, analyze clean, `flutter test` 340 pass (incl. migration v7→v8). **Not run:** device integration tests. Next candidates: A20–A27.

**Backlog A20–A27 (owner-approved 2026-10-05): done, not committed. Phase A of the backlog is complete.** Insights: the activity list updates live (it stalled after its first value: the real cause of the "Gym · once" vs 37,759 kg mismatch, together with a duplicate Gym); the period's dates under the range chips; automatic charts bucket by range and hide when empty; "total/best this period", "All-time best", "Best day" / "Best {item}" labels; round axis steps (`ChartAxis`); duplicate names marked. Builder: fields before icon/color, 12 icons + More; icons and colors have screen-reader names. Date/time pickers themed from tokens. Verified: format clean, analyze clean, `flutter test` 352 pass. **Not run:** device integration tests. Next: Phase B (B1–B3) when the owner picks it.

**Backlog Phase B, B1–B8 (owner-approved 2026-10-05, ADR-041): done, not committed.** Use last time (empty item → copy the previous log, fresh row IDs); row memory ("Last time: Chest Press 60 kg × 8 (×2)" + Use); quick choices for an item with nothing to log (How it went / An amount / Sets & reps / More…) and a Quick-first Add to log sheet; plain field type names and an Advanced section in the field sheet; rest timer for number lists (memory only); long-press quick actions incl. Duplicate; template gallery with live form preview and six new templates. B6 = the A17 row check. Verified: format clean, analyze clean, `flutter test` 365 pass. **Not run:** device integration tests (updated for the template preview). Next: Phase C (first run and retention) when the owner picks it.

## Standing rule (all phases)

Docs stay synchronized with the code in the same task as every change: [development_guide.md §4.1](../../docs/development/development_guide.md#41-documentation-maintenance-binding). Update this file when the phase or the next task changes.

## Not allowed

- Any Phase 7+ feature until the owner approves it.
- Any backend, auth, sync, AI, subscriptions, telemetry/analytics/crash-reporting SDKs, social or other V1-excluded work.
- Redesigning the visual identity (ADR-016 values remain provisional pending the owner's review).

## Owner decisions needed

| Item | Needed before | Recommendation |
|---|---|---|
| Visual identity review of the remaining provisional values (fonts; ADR-016; colors settled by ADR-038) | Before screens multiply | Owner's on-device showcase review |
| Splash screen polish | Later | Deferred by the owner |

Other pending ADRs (P15, P17; P18 resolved by ADR-035) and the remaining open questions belong to later phases.

## After the rework: Phase 7, Onboarding + history/search

See [development_guide.md §6](../../docs/development/development_guide.md#6-proposed-implementation-phases). Starts only after the owner's approval. Open first: OQ-14 confirmation and running the device integration tests for Phases 3–6.

**Planned after core functionality (owner direction, 2026-10-04):** one dedicated visual/product-design pass across the whole app (brief at the top of design_system.md). Until then: no visual redesign, no architecture changes for looks, no features from that direction. Keep UI token-driven and in shared components.
