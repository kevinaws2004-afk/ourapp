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
3. Quick add (implemented): type what you'll do and optionally a **from–to time** (day planner slots: 07:30 Gym, 09:00 Bath, 14:00 Meeting). Typing an activity's name ("Gym") plans that activity, and its chip lights up. A starter template's name installs that template first. Anything else ("Bath") is a task. Chips can also be tapped.
4. Repeat rapidly; keyboard stays open; each item animates into the list.
5. Reorder by drag; timed items sort by time.
6. Items without an activity are Tasks.

## F3a. Review a past date (FR-PL-10)

Plan → select a past date → see what was planned and what was recorded side by side (each plan shows its records and "Recorded 45 min of 1 h"; unplanned records are listed under "Also recorded") → open a record to edit it.

## F4. Morning: see the plan (FR-TD-01, FR-TD-05)

Open app → Today shows a greeting appropriate to the time of day and today's plan in order. Tapping a planned activity records it (F5); tasks have a check control. Plan and Record are one workflow (ADR-030).

## F5. Start an activity from a plan (FR-PL-05, FR-LG-05)

Plan and Record are one workflow (ADR-030). Example: Plan Oct 4 → Gym, Reading, Work.

1. Today/Plan → **tap the planned activity** (e.g. Gym).
2. Its record form opens, linked to the plan and showing "Planned · …". It prefills the slot: start = the planned start (else now / that date at the current time), duration = the planned length (e.g. Reading 21:10–21:55 → 45 min). The user corrects them to reality.
3. Enter what actually happened. For Gym, the focus ("Chest"), exercises and their sets (60 kg × 10, 65 kg × 8, 70 kg × 6…), duration, notes. One session = one record; sets are rows inside it (ADR-027).
4. Save → the record links to the plan → the plan shows **Gym ✓ · Recorded 1 h 5 min of 1 h** on Plan and Today (completion derived from the link, ADR-018).
5. Tapping a recorded plan opens its record. "Record again" (in the plan's More options) adds a second session.
6. While recording, **Edit what to track** (record form app bar) opens the activity's builder to add or change fields. The form keeps what was entered.
7. Phase 5 adds "Start focus" for timer activities and the `in_progress` status.

## F6. Gym workout (FR-LG-07, §43 "Gym")

1. Tap the planned Gym (F5) or use Quick Record. The record form opens; start time set; optional live workout timer.
2. **Add exercise** → name with autocomplete from history (e.g. "Chest Press").
3. **Add set** row: weight, reps. New row pre-fills from the previous row (and from the last session for that exercise when available: a speed affordance, clearly shown as a suggestion).
4. Repeat sets, add more exercises; reorder/delete via swipe or handle with undo.
5. Finish → end time set; workout duration computed/confirmed → save → completion feedback summarizing (exercises, sets, duration).

Interruption: draft must not be lost if the app is backgrounded during a long workout. The draft is persisted (save log early as in-progress or persist the draft; see ADR-P18).

## F7. Focus session (FR-FO-01…06, §43 "Work"/"Reading")

Implemented in Phase 5 (ADR-031).
1. Start focus: tap a planned timer activity → **Start focus** (or Record now), or the activity's page → **Start focus**. Only one session runs at a time.
2. Full-screen timer: activity badge and name, large elapsed time in DM Mono, state (Focusing / Paused), Pause/Resume, Finish, Discard.
3. Pause/resume any number of times. Leaving the app or the process dying doesn't affect elapsed time: it is computed from stored timestamps. Today shows a live "Reading · 23:14 · Return" banner, and the plan shows "In progress".
4. Finish → the session pauses → the record form opens prefilled (start, focused time, "Planned · …") → add notes and fields (e.g. pages) → save → "Reading session complete · 42 min". The record links to the plan, which shows ✓. Backing out of the form keeps the session paused.
5. Discard asks for confirmation and creates no record.

## F8. Quick Record (FR-LG-06, ADR-028)

Today → **Record something** (no floating button since 2026-10-04) → sheet titled "What did you do?" listing the user's activities (most frequent/recent first later; Phase 2 lists them in display order) → tap → record form. Two taps for an unplanned activity. With no activities yet, the sheet offers "New activity". Task quick-add joins the sheet with plans (Phase 4); instant save for activities without required fields is a later polish.

## F9. Record a meeting retroactively (§22, §43 "Meeting")

Quick Record → Meeting → set start time in the past and duration 48m → People (multi-person), Topics, Decisions, Action items (checklist) → save. Retroactive logging (time pickers for past start/end) is supported for every activity (see OQ-17).

## F10. Complete a task (FR-PL-07)

Tap the task's check control (or tap the task → **Mark as done**) on Today/Plan → status `completed` with brief feedback; undo available. No record created. Or tap the task → **Track details**: the activity builder opens named after the task ("Food"). Add any fields you want to log, save, and the plan links to the new activity and its record form opens. Later "Food" plans link to it automatically. "Mark as done" exists only for tasks; activity plans complete by being recorded (ADR-030).

## F11. Evening review (FR-TD-04, §43 "Night")

Today in the evening shows **What you planned vs What actually happened**: each plan paired with its linked log(s) and actual duration; unplanned logs shown as additions; unfinished plans can still be tapped to record them, or skipped / moved to tomorrow from their More options (move = edit planned date). Copy stays neutral; no guilt messaging.

## F12. Insights (FR-AN-01…07)

Implemented in Phase 6 (ADR-034).
1. The Insights tab shows a range (Week / Month / 3 months / Year) and the **Activities** totals: recorded time and how often per activity, with the change vs the previous period.
2. **Your charts**: **Add chart** → what to chart:
   - Time, How often, A field (any number at any depth, e.g. Exercises › Sets › Weight, optionally "Only where Exercise = Chest Press")
   - Volume (weight × reps)
   - Body measurement
   - Planned vs actual

   Then choose how to show it (total / average / best / lowest / count / latest), group by day / week / month, line or bars, and a title. Save.
3. Each chart card shows the headline value, "+12 % vs previous period", "Personal best 70 kg · Oct 2" (field/volume) and the chart. More → Edit / Delete (with Undo).
4. Empty states explain what can be charted.

## F13. Body measurement (FR-BM-01…03)

Implemented in Phase 6. Me → **Body measurements** → the seven types with their latest value → pick one → **Add measurement**: value, unit (kg/lb, cm/in, %), date (default now), notes → save → the history and line chart update. Tap an entry to edit or delete it (with Undo). Measurements can also be charted in Insights.

## F14. Search & history (FR-SH-*, FR-AN-10)

History (from an activity's page under Me → Activities, or from Plan by date) → chronological list grouped by day → filter by activity and date range → text search across notes and text values. Tap → log detail → edit/delete (with undo).

## F15. Edit / delete (FR-LG-04)

Log detail → Edit (same generic form) → save. Delete → immediate soft delete with an **Undo** snackbar (no blocking confirm dialog for reversible actions). Destructive *irreversible* actions (none in V1 except discarding an unsaved draft or focus session) use a confirm.

## F16. Export (FR-DA-01; V1 status pending OQ-03)

Me → Data → Export → choose JSON (complete backup) or CSV (per activity type) → system save/share sheet → success state with file name.
