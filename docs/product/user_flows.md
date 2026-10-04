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
2. The selected date shows **one list of items** (ADR-035): its plans and anything done without a plan, in time order, then untimed plans.
3. Quick add: type what you'll do and optionally a **from–to time** (day planner slots: 07:30 Gym, 09:00 Bath, 14:00 Meeting). Typing an activity's name ("Gym") plans that activity, and its chip lights up. A starter template's name installs that template first. Anything else ("Bath", "Doctor call") is a plain item. On today, **Now** adds it at the current time and opens it (F8).
4. Repeat rapidly; keyboard stays open.
5. Reorder untimed items by drag; timed items sort by time.
6. **Day | Week | Month** (ADR-036): Week shows the seven days with their items (tap a day's heading to open it, "+" to plan on it); Month shows a calendar with a dot per item (tap a day to open it).
7. **Repeat** (item options → Repeat…): pick weekdays, every 1–4 weeks, and an optional last date. Each occurrence is an ordinary item on its day. From an occurrence, Repeat… again changes it from that day on; "Stop repeating after this" ends it. Deleting or moving one occurrence affects only that one.

## F3a. Review a past date (FR-PL-10)

Plan → select a past date → the same list of items: each plan with what was logged into it ("Done · 45 min of 1 h" and a summary), plus anything done without a plan → open any item to see or change it.

## F4. Morning: see the plan (FR-TD-01, FR-TD-05)

Open app → Today shows a greeting, quick add, and today's items in order. Tapping an item opens it to log into it (F5); tasks also have a check control.

## F5. Do an item: open it and log into it (FR-PL-05, FR-LG-05, ADR-035)

Example: Plan Oct 4 → Gym, Reading, Doctor call.

1. Today/Plan → **tap the item** (e.g. Gym). The item opens: its planned time, **Mark done**, **Start timer**, the activity's fields, notes, and when/how long.
2. Log what's happening, as it happens. For Gym: exercises and their sets (60 kg × 10, 65 kg × 8, 70 kg × 6…). Everything **saves as you type** ("Saving…" / "Saved"); there's no Save button.
3. The first thing logged links a log to the plan, so the item shows **Gym ✓ · Done** with a summary on Plan and Today (completion derived from the link, ADR-018). Its start defaults to the planned start (else now), and its duration can be entered or filled by the timer.
4. Leave any time and come back: the item shows what's logged so far, ready for more (another set).
5. Nothing to log? **Mark done** records the planned time and length (e.g. Reading 21:10–21:55 → 45 min).
6. **Add to log** (any item): pick a ready-made shape (*Sets & reps*, *Checklist*) or one thing (a number with a unit, text, a list, yes/no, a rating, a choice, a date, time spent), name it, and log into it right away. Inside a list, **Add detail** adds another column (e.g. Dose on a medicines list). A new name ("Doctor call") gets an activity of its own on the first thing added or logged, so the next "Doctor call" has the same things to log. The pencil opens the builder to rename, reorder or remove.
7. Item options (⋯): edit title/time/notes, Repeat… / Stop repeating, Skip, Reopen, Move to tomorrow, Delete (with Undo).
8. **Plan next…** (bottom of any item): pick a date (a week later is suggested) and, for a timed item, a time → the same thing is planned there, with the same things to log (e.g. the next doctor's appointment). The snackbar offers Open.

## F6. Gym workout (FR-LG-07, §43 "Gym")

1. Open the planned Gym (F5), or add "Gym" with **Now** (F8). Optionally **Start timer**.
2. **Add exercise** → name with autocomplete from history (e.g. "Chest Press").
3. **Add set** row: weight, reps. A new row pre-fills from the previous row.
4. Repeat sets, add more exercises. Each change is saved, so nothing is lost if the app is backgrounded or killed mid-workout.
5. Finish the timer (if running) → its time fills the workout's duration.

## F7. Timer (FR-FO-01…06, §43 "Work"/"Reading")

Phase 5 (ADR-031), moved into the item by ADR-035.
1. In an item → **Start timer**. From an activity's page, **Start focus** adds an item for now with its timer running. Only one timer runs at a time.
2. The timer shows at the top of the item (DM Mono) with Pause/Resume and Finish; keep logging while it runs. The full-screen timer is optional.
3. Pause/resume any number of times. Leaving the app or the process dying doesn't affect elapsed time: it is computed from stored timestamps. Today shows a live "Reading · 23:14 · Return" banner (Return opens the item), and the item shows "In progress".
4. Finish → the timed span becomes the item's start, end and duration, keeping everything logged → "Reading session complete · 42 min". A second timer on the same item adds its time.
5. Discard (full-screen timer) asks for confirmation and logs nothing.

## F8. Log something you're doing now (FR-LG-06, ADR-035)

Today → quick add → type it ("Walk", "Gym") → **Now** → it's added at the current time and opens to log into it. Or an activity's page → **Record**, which does the same for that activity. There is no separate Quick Record sheet.

## F9. Record a meeting retroactively (§22, §43 "Meeting")

Add "Meeting" to the day (or open its plan) → set when it started and how long (48m) → People, Topics, Decisions, Action items. Retroactive logging (past start and duration) works for every item (see OQ-17).

## F10. Complete a task (FR-PL-07)

Tap the task's check control on Today/Plan, or open it → **Mark done** → status `completed` with brief feedback; undo available. Writing notes into a task instead gives it an activity of its own (F5 step 6), so it counts as done by what was logged.

## F11. Evening review (FR-TD-04, §43 "Night")

Today in the evening shows the day's items: what was done (with what was logged and how long against what was planned), unplanned additions in time order, and what's still open, which can be opened to log, or skipped / moved to tomorrow from its options. Copy stays neutral; no guilt messaging.

## F12. Insights (FR-AN-01…07)

Implemented in Phase 6 (ADR-034); automatic progress added by ADR-037.
1. The Insights tab shows a range (Week / Month / 3 months / Year) and each activity done in it: **days done**, time and how often, with the change vs the previous period.
2. **Tap an activity → its progress**, worked out automatically from what it logs: time and times done per week, each number and rating, and for lists, each row's best and volume (Gym: "Chest Press · best Weight", "Chest Press · volume", per exercise). Nothing to build.
3. **Your own charts** (below, optional): **Add chart** → what to chart:
   - Time, How often, A field (any number at any depth, e.g. Exercises › Sets › Weight, optionally "Only where Exercise = Chest Press")
   - Volume (weight × reps)
   - Body measurement
   - Planned vs actual

   Then choose how to show it (total / average / best / lowest / count / latest), group by day / week / month, line or bars, and a title. Save.
4. Each chart card shows the headline value, "+12 % vs previous period", "Personal best 70 kg · Oct 2" (field/volume) and the chart. More → Edit / Delete (with Undo).
5. Empty states explain what can be charted.

## F13. Body measurement (FR-BM-01…03)

Implemented in Phase 6. Me → **Body measurements** → the seven types with their latest value → pick one → **Add measurement**: value, unit (kg/lb, cm/in, %), date (default now), notes → save → the history and line chart update. Tap an entry to edit or delete it (with Undo). Measurements can also be charted in Insights.

## F14. Search & history (FR-SH-*, FR-AN-10)

History (from an activity's page under Me → Activities, or from Plan by date) → chronological list grouped by day → filter by activity and date range → text search across notes and text values. Tap → log detail → edit/delete (with undo).

## F15. Edit / delete (FR-LG-04)

Log detail → Edit (same generic form) → save. Delete → immediate soft delete with an **Undo** snackbar (no blocking confirm dialog for reversible actions). Destructive *irreversible* actions (none in V1 except discarding an unsaved draft or focus session) use a confirm.

## F16. Export (FR-DA-01; V1 status pending OQ-03)

Me → Data → Export → choose JSON (complete backup) or CSV (per activity type) → system save/share sheet → success state with file name.
