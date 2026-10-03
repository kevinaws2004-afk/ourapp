# User Flows

> Key flows derived from the spec. Requirement IDs refer to [requirements.md](requirements.md). Visual/interaction treatment is in [ui_guidelines.md](../ui/ui_guidelines.md).
> Every flow must handle: empty state, loading, error, success, and interruption (app backgrounded/killed).

---

## F1. First-run onboarding (FR-UX-01, FR-UX-02, FR-AT-12)

Narrative arc (§33.4): **understand → one question → personalize → show value → begin**.

1. **Welcome:** a single, warm statement of what the product helps with (plan your day, see what actually happened, understand your progress) and the privacy promise ("Your data stays on this device. No account needed.", §39). One primary action.
2. **One meaningful question:** "What would you like to understand about your days?" Multi-select of outcome-phrased intents (e.g. train consistently, read more, focus deeper, stay on top of tasks, track my body). Optional; skippable.
3. **Personalize:** suggested starter activities based on the answer, shown as selectable previews (icon, color, the fields they include). User toggles which to add. Nothing is pre-selected without a visible reason.
4. **Optional quick preference:** units (kg/lb, km/mi) only if a selected template uses them.
5. **Show what you'll get:** a preview of *their* Today with their chosen activities, illustrating plan vs actual.
6. **Begin:** primary "Plan tomorrow" or "Log something now", secondary "Explore". Lands on Today.

Constraints: ≤ 5 screens; every step skippable; back navigation allowed; progress indicator; no account; no forms with more than one decision per screen. Completion sets `onboarding_completed`. Killing the app mid-onboarding restarts onboarding (nothing partially installed: templates install in one transaction at the end).

## F2. Build a custom activity (FR-AT-01…08, FR-AT-11)

1. Me → Activities → "New activity" (or "Start from a template").
2. Name → icon → color (picked from the curated activity palette).
3. Add fields: the field-type picker lists the ten generic types (OQ-01), each with a one-line plain-language description. Domain-specific needs are compositions (e.g. Number + "Measured in: Weight"). Repeating Group shows "Coming soon" until Phase 3.
4. Configure each field in a sheet (name, required, type-specific options; "measurable" defaulted sensibly per type).
5. Reorder via drag handle (haptic on pick-up/drop).
6. Toggle "Supports timer/focus" (warn + offer to add a Timer field if none) and "Can be planned".
7. Live preview of the log form (same renderer as real logging).
8. Save → success feedback → lands on the activity's page with a "Log it now" affordance.

Edge cases: unsaved-changes guard; duplicate name warning; editing a type with existing logs shows which changes are restricted (field type locked) and why.

## F3. Plan a date (FR-PL-01…04, FR-PL-09, §43 "Night")

1. Plan tab → the **calendar/date selector** (week strip + month calendar) chooses any date; it opens on today. Common picks: "Tomorrow" in the evening (§43).
2. The selected date shows **Planned** (that date's plans) and, for today and past dates, **Recorded** (what actually happened).
3. Quick add (Phase 4): type a title, optionally pick an activity (chips of frequent types), optionally a time.
4. Repeat rapidly; keyboard stays open; each item animates into the list.
5. Reorder by drag; timed items sort by time.
6. Items without an activity are Tasks.

## F3a. Review a past date (FR-PL-10)

Plan → select a past date → see what was planned and what was recorded side by side (planned-vs-actual pairing arrives with plans in Phase 4; the Recorded list already works) → open a record to edit it.

## F4. Morning: see the plan (FR-TD-01, FR-TD-05)

Open app → Today shows greeting appropriate to time of day and today's plan in order, each linked item with a "Start" action, tasks with a check control.

## F5. Start an activity from a plan (FR-PL-05, FR-LG-05)

1. Today/Plan → item → **Start**.
2. If the activity supports timer: choose "Start focus" (F7) or "Record manually".
3. Otherwise open the record form prefilled: activity type, `planId`, `startedAt = now`.
4. Plan status → `in_progress` on start; → `completed` when the log is saved.

## F6. Gym workout (FR-LG-07, §43 "Gym")

1. Start Gym (from a plan or Quick Record). The record form opens; start time set; optional live workout timer.
2. **Add exercise** → name with autocomplete from history (e.g. "Chest Press").
3. **Add set** row: weight, reps. New row pre-fills from the previous row (and from the last session for that exercise when available: a speed affordance, clearly shown as a suggestion).
4. Repeat sets, add more exercises; reorder/delete via swipe or handle with undo.
5. Finish → end time set; workout duration computed/confirmed → save → completion feedback summarizing (exercises, sets, duration).

Interruption: draft must not be lost if the app is backgrounded during a long workout. The draft is persisted (save log early as in-progress or persist the draft; see ADR-P18).

## F7. Focus session (FR-FO-01…06, §43 "Work"/"Reading")

1. Start focus for an activity (from Today, a Plan, the activity's page, or Quick Record).
2. Full-screen timer: activity name/context, large elapsed time, Pause and Finish.
3. Pause/resume any number of times. Leaving the app or the process dying does not affect elapsed time; reopening returns to the session.
4. Finish → completion state ("Reading session complete, 42 minutes") → optional notes and remaining fields (e.g. pages) in the same generic form → save.
5. Discard is available, requires confirmation, creates no log.

## F8. Quick Record (FR-LG-06, ADR-028)

Global **Record** action (on every tab) → sheet titled "What did you do?" listing the user's activities (most frequent/recent first later; Phase 2 lists them in display order) → tap → record form. Two taps for an unplanned activity. With no activities yet, the sheet offers "New activity". Task quick-add joins the sheet with plans (Phase 4); instant save for activities without required fields is a later polish.

## F9. Record a meeting retroactively (§22, §43 "Meeting")

Quick Record → Meeting → set start time in the past and duration 48m → People (multi-person), Topics, Decisions, Action items (checklist) → save. Retroactive logging (time pickers for past start/end) is supported for every activity (see OQ-17).

## F10. Complete a task (FR-PL-07)

Tap the check control on Today/Plan → status `completed` with satisfying but brief feedback; undo available. No log created.

## F11. Evening review (FR-TD-04, §43 "Night")

Today in the evening shows **What you planned vs What actually happened**: each plan paired with its linked log(s) and actual duration; unplanned logs shown as additions; unfinished plans offered "Skip" or "Move to tomorrow" (move = edit planned date). Copy stays neutral; no guilt messaging.

## F12. Insights (FR-AN-01…07)

1. Insights tab shows auto-generated default cards based on the user's activity types and measurable fields (e.g. weekly reading minutes, workouts this week vs last).
2. Tap a card → chart detail; change metric (e.g. Weight / Reps / Volume / Frequency for an exercise, §13), range, aggregation.
3. "Explore" → pick activity → field (→ exercise for nested data) → metric → range → chart.
Empty state when there is not enough data explains what will appear and how to get there.

## F13. Body measurement (FR-BM-01…03)

Me → Body → pick measurement → enter value (unit per preference) and date (default now) → save → the trend chart updates with an animated transition.

## F14. Search & history (FR-SH-*, FR-AN-10)

History (from an activity's page under Me → Activities, or from Plan by date) → chronological list grouped by day → filter by activity and date range → text search across notes and text values. Tap → log detail → edit/delete (with undo).

## F15. Edit / delete (FR-LG-04)

Log detail → Edit (same generic form) → save. Delete → immediate soft delete with an **Undo** snackbar (no blocking confirm dialog for reversible actions). Destructive *irreversible* actions (none in V1 except discarding an unsaved draft or focus session) use a confirm.

## F16. Export (FR-DA-01; V1 status pending OQ-03)

Me → Data → Export → choose JSON (complete backup) or CSV (per activity type) → system save/share sheet → success state with file name.
