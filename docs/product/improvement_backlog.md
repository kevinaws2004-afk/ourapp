# Improvement Backlog (proposal)

> **Status: proposal, not approved scope.** Written 2026-10-05 after a hands-on evaluation of the app on the Android emulator (fresh install, then demo data). Nothing here is a requirement until the owner approves it and it moves into [`requirements.md`](requirements.md) / [`ai/tasks/current_task.md`](../../ai/tasks/current_task.md). Items marked **(decision)** need the owner first; some conflict with the current spec and are flagged.
>
> **Done:** A1–A8 (2026-10-05, ADR-039); A9–A19 (2026-10-05, ADR-040, schema v8); A20–A27 (2026-10-05). Phase A is complete. B1–B8 (2026-10-05, ADR-041; B6 is the row check from A17). Phase B is complete.
>
> Size: **S** = hours, **M** = 1–2 days, **L** = several days.

## Evaluation summary

The core works and some parts are strong, but the app does not yet feel like something people would pay for. The problems are mostly clarity and trust: overlapping controls, internal vocabulary in the UI, inconsistent states, and Insights numbers that contradict each other.

**Keep (already good):**
- Name recognition: typing "Gym" or "Reading" applies the matching template automatically.
- Set logging: "Add Set" copies the previous set.
- Automatic insights: per-exercise best weight, personal best and volume after one session, no setup.
- Save-as-you-type and the inline timer.
- Week and Month planner views.
- The restricted color set (ADR-038).

**Top 5 problems found:**
1. Today and Plan → Day are the same screen; Plan also shows two "+" buttons.
2. Adding an item is confusing: "Now" is a hidden toggle, "Time" opens two clock dialogs and defaults to 9 AM in the evening, the shortcut chips have no label.
3. An unknown item ("Meditation") leads to a field-type menu and a "New field" form (Required, Decimal places, Min/Max): a database editor, not a tracker. Tapping outside the sheet silently discards it.
4. Done / planned / logged look inconsistent (a logged session shown outlined like a plan, a done task still outlined, ticks on different sides). The row summary hides the numbers ("Bench press", not "2×8 · 60 kg") and repeats "Done". Adding one exercise silently marks the session done.
5. Insights contradicts itself: the list said "Gym · once" next to a "37,759 kg" chart. *(Root cause found while fixing A20: the activity list stopped updating after its first value, and the chart was for a second, duplicate "Gym"; both used the same 30-day window.)* "960 kg total" next to "Personal best 480 kg" reads as an error. The y-axis showed "1, 1, 0". There's an empty "Time: No data" card for an activity that never used a timer.

**Smaller issues:** internal wording in the pop-up ("Added the Gym activity, so you can record it from the plan"); an unexplained "Focus" field and "Add detail" link in the Gym template; Duration fields have no labels and stayed empty after a 1-minute timer; duplicate activities with the same name are allowed; onboarding is one Welcome screen; stock Android date and time pickers; a thin Me tab with placeholder text and visible debug items; icons read aloud by file name ("person-simple-walk"); the activity editor shows 56 icons before the fields; the keyboard covers new set rows.

---

## Phase A: Fix trust and confusion (do first)

### Navigation and structure
- [x] A1. Remove Plan → Day; Plan = Week | Month, and tapping a day opens that day's list (same screen as Today). **M**
- [x] A2. One "+" per screen; remove the extra "+" next to "Planned". **S**
- [x] A3. Clean up Me: no placeholder text, debug items hidden in release builds, real sections (Activities, Body, Settings, Data). **S**

### Adding an item
- [x] A4. Replace the "Now" toggle with real actions: **Start now** (starts and opens) and **Add** (adds to the day). **S**
- [x] A5. One time sheet instead of two dialogs: start time, duration chips (15/30/60 min) and a custom option; default to the next round hour. **M**
- [x] A6. Suggestions while typing: recent activities and matching templates ("Gym · Sets & reps"). **M**
- [x] A7. Label the shortcut chips ("Recent") and order them by use. **S**
- [x] A8. Prevent duplicate activities: typing an existing name reuses it; creating a same-named one asks first. **M**

### Item screen
- [x] A9. Rewrite or remove the pop-up after adding; no "activity/record/plan" jargon. **S**
- [x] A10. Don't auto-mark done when an exercise is added; offer "Mark done" at the bottom. **S**
- [x] A11. Label the Duration fields (h / min) and fill them when the timer finishes (bug: they stayed empty). **S**
- [x] A12. Gym template: rename or remove "Focus", or make it choices (Push / Pull / Legs / Full body). **S**
- [x] A13. Move "Add detail" into a "…" menu named "Customise this list". **S**
- [x] A14. Scroll a new set row into view above the keyboard. **S**
- [x] A15. Ask before discarding a half-filled sheet when the user taps outside it. **S**

### Planned / done / logged look
- [x] A16. One visual rule everywhere: planned = outline, done = filled tint + tick, skipped/missed = muted; the same for tasks, activities and logged items. **M**
- [x] A17. The check sits on the left for every row type and is tappable to mark done. **M**
- [x] A18. Show real numbers in the row summary ("Bench 2×8 · 60 kg", "30 min · 20 pages"); remove the duplicate "Done". **M**
- [x] A19. Untimed items in a clear "Anytime" group below the timed ones. **S**

### Insights correctness
- [x] A20. One date range for the whole screen (list, headline numbers, charts). **M**
- [x] A21. Clear volume labels: "Total this period · Best session · Best set". **S**
- [x] A22. Fix chart axes: no duplicate ticks; whole numbers for counts. **S**
- [x] A23. Hide empty cards (no "Time: No data" for activities without timer data). **S**
- [x] A24. Merge or mark duplicate activities in Insights (after A8). **S**

### Accessibility and polish
- [x] A25. Readable screen-reader labels for icons ("Walking", not "person-simple-walk"). **S**
- [x] A26. Restyle the date and time pickers to match the design system. **M**
- [x] A27. Activity editor: 12 likely icons plus "More"; put "What you record" above the icons. **S**

## Phase B: Effortless logging (the main improvement)

- [x] B1. **Repeat last time:** reopening an activity pre-fills the previous session's exercises and weights ("Same as Tuesday"), ready to adjust. **L**
- [x] B2. **Per-exercise memory:** typing "Bench" suggests "Bench press" and shows "last: 60 kg × 8". **M**
- [x] B3. **Unknown item → smart suggestions** ("How long?", "How did it go?" rating, "Note") instead of the field-type menu; the full builder moves behind **Advanced**. **M**
- [x] B4. Friendlier builder wording ("Number" → "An amount (kg, km, pages…)"); Required / Decimal places / Min-Max under Advanced. **S**
- [x] B5. Optional rest timer between sets. **M**
- [x] B6. Quick finish: tap "Done ✓" on the Today row for simple items without opening them. **S**
- [x] B7. Long-press row actions: Move to tomorrow, Duplicate, Skip, Delete. **M**
- [x] B8. Template gallery with previews (Gym, Running, Reading, Study, Meditation, Water, Sleep, Mood, Weight, Work blocks, Language). **M**

## Phase C: First run and retention

- [ ] C1. Onboarding (3 screens): pick interests → activities created → log the first one and see the first chart. **L**
- [ ] C2. Better empty Today: "Start with one of these" cards. **S**
- [ ] C3. **(decision)** Local reminders and notifications: planned-item reminders, an evening "log your day" nudge, the running timer in the notification bar. Local only. **L**
- [ ] C4. Home-screen widget: today's items plus quick add / Start. **L**
- [ ] C5. Consistency without guilt: "4 of 7 days this week", a monthly heatmap; neutral about misses. **M**
- [ ] C6. Weekly review: planned vs done, highlights, new personal bests. **L**
- [ ] C7. A tasteful personal-best celebration. **S**
- [ ] C8. **(decision)** Goals per activity ("3× gym a week", "20 pages a day") with progress on Today and in Insights. New concept. **L**

## Phase D: Insights worth paying for

- [ ] D1. Insights home redesign: summary at the top (this week vs last), activities sorted by biggest change. **M**
- [ ] D2. Per-activity page: consistency calendar, trend line, records list, recent sessions; tapping a point opens that day. **L**
- [ ] D3. Body measurements in Insights: smoothed weight trend next to training data. **M**
- [ ] D4. Plan vs reality stats ("You complete 72% of what you plan; mornings go best"). **M**
- [ ] D5. Export a period to CSV / PDF (local). **M**

## Phase E: Business (owner decisions)

- [ ] E1. **(decision)** Target user and one-line promise. Drives onboarding, templates, copy and store listing. Suggested angle: "your day planner that shows you're improving".
- [ ] E2. **(decision)** Product name (ADR-010, still undecided); needed before the store and branding.
- [ ] E3. **(decision)** Free vs paid split, e.g. free = plan + log + 30 days of insights; paid = full history, personal bests, weekly review, export, widgets, themes.
- [ ] E4. **(decision, conflicts with spec §42)** In-app purchase / subscription via Google Play and App Store. Needs a scope change and an ADR. **L**
- [ ] E5. Local backup and restore (user-chosen file location; no server). **M**
- [ ] E6. Store assets: icon, screenshots, short video, privacy page ("your data never leaves your phone"). **M**
- [ ] E7. Dark mode polish; theme accents as a possible paid extra. **M**
- [ ] E8. Settings basics: units (kg/lb, km/mi), week start, 12/24 h, language (check which exist). **M**
- [ ] E9. "Send feedback" that opens email (no SDK). **S**

## Phase F: Quality

- [ ] F1. Run the device integration tests (skipped so far) before any release. **S**
- [ ] F2. Release build check: no debug banner or debug menu; size and startup time. **S**
- [ ] F3. Screenshot / golden tests for the main screens. **M**
- [ ] F4. Closed beta on Google Play internal testing with 10–20 users before charging. **M**

---

## Owner decisions needed

| Item | Why it's needed |
|---|---|
| E1 target user and promise | Shapes onboarding, templates, copy and the store page |
| E2 product name | Required for store listing and branding (ADR-010) |
| C3 reminders and notifications | New feature; local only |
| C8 goals | New concept in the domain |
| E3 free vs paid split | Determines what's built as premium |
| E4 subscriptions | The spec currently excludes them (§42); needs a scope change and an ADR |

## Recommended order

Phase A, then B1–B3. That fixes everything found in the evaluation and makes logging fast, which is the core of the product. Then C1 (onboarding) and D1–D2, alongside the E decisions.
