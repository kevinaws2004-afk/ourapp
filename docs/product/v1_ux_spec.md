# V1 UX Specification, Stitch Redesign Plan and Implementation Plan

> **Status: PROPOSAL for owner review (2026-10-08).** Built on the approved
> V1 product definition ([v1_experience.md](v1_experience.md), ADR-046).
> Three phases in one document:
> 1. **UX specification**: every important screen and state.
> 2. **Stitch redesign plan**: each state mapped to the Stitch references and
>    the three themes.
> 3. **Implementation plan**: the order, starting with the first slice.
>
> No Flutter code changes until the owner approves this document.
> Nothing here is a new feature: it re-arranges what exists around the loop
> **Plan → Do → Record → Measure → Understand → Improve**.

**Words used below** are the user's words (v1_experience.md §0): an
*activity* (Gym), a *thing on your day* ("Gym at 6 PM"; internally a plan),
*done*, *details* (pages, sets, notes), *a challenge*, *progress*.

---

# Phase 1: UX specification

## How to read this

Every screen and state is described with the same template:

| Field | Meaning |
|---|---|
| **Purpose** | Why this state exists for the user |
| **Hierarchy** | What's on screen, top to bottom, most important first |
| **Primary** | The one action the screen is built around (exact label) |
| **Secondary** | Other actions, in order of importance |
| **Shows / Hides** | Information shown; information deliberately kept off this state |
| **Navigation** | Where each action goes |
| **Empty · Loading · Error** | When relevant |
| **Completion** | What "finished" looks like here |
| **Transitions** | Which state comes next, and what the user sees change |

State IDs (T1, A3, P2…) are used in Phase 2 and Phase 3.
Small states (a sheet, a variant) list only the fields that differ from the
state they belong to; anything not listed is as in that parent state.

---

## 1.0 Product-wide rules

### 1.0.1 Navigation frame

- **Tabs (bottom bar on phones, rail on tablets):** Today · Plan · Challenges ·
  Progress · Me. Icons: sun, calendar, target, chart, person. Re-tapping a
  tab returns to its top.
- **+** (floating, round, bottom right) on **Today** and **Plan** only. It
  opens the add sheet (AD1). It never records by itself.
- **Back** returns to where the user came from; an activity opened from
  Today returns to Today scrolled to its row.
- **Sheets** (add, How did it go?, options, time) slide up, close by swipe
  down or tap outside; sheets with typed input ask "Discard?" first
  (existing `DiscardGuard`).

### 1.0.2 Words

| Use | Never in the UI |
|---|---|
| your day, today, tomorrow | day overview, entries |
| activity (Gym, Reading) | activity type, template |
| "Meditation at 7:00" / "things today" | item, plan, task, entry |
| Start, Finish, Done, Not done | log, record, mark complete |
| details, How did it go? | fields, values, schema |
| sets, exercises (the user's own list names) | repeating group, list items |
| challenge, streak, 🔥 | goal, XP, score |
| Progress | insights, analytics |
| Skip, Let it go | cancel, delete (unless deleting) |

Tone: warm, short, neutral about misses ("Not done", never "Missed!"),
sentence case, numbers as digits.

### 1.0.3 Feedback, motion, haptics

| Event | Visual | Haptic |
|---|---|---|
| Done (circle or Finish) | Circle fills with ✓ (150 ms), result fades in, 🔥 number rolls up, status line updates | light success |
| Start | Row and card switch to live time; activity opens running | light impact |
| Undo available | Snackbar 4 s with **Undo** | none |
| Day closed | Evening review collapses to one line | light success |
| Error saving | Inline message, field highlighted | light warning |

Reduced motion: every animation becomes an instant change or a ≤150 ms
fade. Nothing waits on an animation.

### 1.0.4 Loading and errors (everywhere)

- **Loading:** blank for ~150 ms, then skeleton rows in the content's shape
  (existing `DelayedLoadingPlaceholder`). Headers and tabs render at once.
- **Read error:** inside the affected card only: "Couldn't load this. Try
  again." + **Try again**. Other cards keep working.
- **Write error:** snackbar with a plain reason; the screen stays as it was;
  typed input is kept.
- There is no network, so no offline states.

### 1.0.5 Time rules

- "Today" = the device's local date. At midnight with the app open, Today
  rolls to the new day on the next minute tick: yesterday's unfinished
  things become "From yesterday".
- A timer running across midnight belongs to the day it started.
- Now/Next, the "now" line and the evening review re-evaluate every minute
  and when the app returns to the foreground.

### 1.0.6 Accessibility (every state)

48 dp targets (the circle included); every row read as one sentence
("Meditation, 7:00, 15 minutes, done, 13 day streak. Double tap to open.
Actions: Not done, Move to tomorrow…"); text scales to 200% without
clipping (rows wrap, rings scale down); color never carries meaning alone
(chips and sub-lines say the state); focus order = visual order.

### 1.0.7 Shared building blocks

| Block | Used in | Content |
|---|---|---|
| **DayHeader** | Today, Plan day | Greeting or day name, date |
| **StatusLine** | Today, Plan past days | One sentence about the day (T-table) |
| **NowNextCard** | Today | Label, name, time/in-x, notes line, one action |
| **TimelineRow** | Today, Plan, From yesterday, evening review | Time, circle, name, sub-line (length / live / result), 🔥 |
| **NowLine** | Today, Plan (today) | "Now · 9:10" divider |
| **ResultHeader** | Activity Done (A7) | Big result, "what this changed" |
| **HowDidItGoSheet** | A6 | Details with Save / Skip |
| **AddSheet** | AD1–AD5 | What, When, Repeat, Add |
| **WeekStrip** | Plan | Seven day pills with rings/counts |
| **SentenceCard** | Progress, evening review | A sentence with the key number large |
| **StoryRow** | Progress | Badge, name, one-line story, trend arrow, 🔥 |
| **ChallengeCard** | Challenges | Name, x / y, bar, 🔥, today's state |
| **StreakBadge** | rows, story rows, challenge cards | 🔥 + number (a11y: "13 day streak") |

---

## 1.1 Today

Today is one screen whose content changes with the moment of the day. The
order of sections is fixed:

```
DayHeader            Good morning · Thursday, Oct 8
StatusLine           5 things today · first at 7:00
[From yesterday]     only mornings, only if something's left      (T2)
[Evening review]     only evenings, per the rule                  (T7/T8)
[NowNextCard]        hidden when nothing is open
Your day             TimelineRow… NowLine … Anytime …
                                                    (+)
```

### Status line (by moment)

| Moment | Text |
|---|---|
| Things planned, none done | "5 things today · first at 7:00" ("5 things today" if all are Anytime) |
| Some done | "2 of 5 done · 1 h 15 min so far" (time part only if any time was recorded) |
| Running | "Meditation running · 2 of 5 done" |
| All done | "All 5 done · 3 h 20 min" |
| Only unplanned done | "2 done today · 50 min" |
| Nothing at all | "Nothing planned yet" |

### Now/Next card (selection, highest first)

| # | Situation | Label | Shows | Action |
|---|---|---|---|---|
| 1 | A thing is running | RUNNING | name, big live time | **Finish** |
| 2 | A thing's time window contains now (or started ≤ 15 min ago, no length) | NOW | name, "7:00–7:15" | **Start** (timer activity) / **Done** |
| 3 | Next timed thing later today | NEXT · 9:30 | name, "in 20 min", length | **Start** / **Done** |
| 4 | Only Anytime things open | ANYTIME | first open Anytime thing | **Start** / **Done** |
| — | Nothing open | (hidden) | | |

Passed, unfinished timed things never appear in the card (they wait on the
timeline and in the evening review). Tapping the card body opens the thing.

### TimelineRow states (shared)

| State | Circle | Sub-line | Text weight |
|---|---|---|---|
| Upcoming | open, activity color | planned length ("15 min") or nothing | normal |
| Now window | open, emphasized row tint | "Now · 15 min" | normal |
| Running | live dot (pulsing; static if reduced motion) | "Running · 12:04" | normal |
| Done | filled ✓ (success) | **result** | quiet |
| Passed, not done | open | planned length | normal (no red) |
| Skipped | dash | "Skipped" | faded 55% |
| Done without plan | filled ✓ | result | quiet |

**Result** (first that exists): details summary ("32 pages"; "Bench 60 kg ×
8 ×3, Squat 80 kg × 5 ×3"; "5.2 km") → time ("45 min"; "45 min of 1 h" only
if it differs from the plan by > 10 min) → "Done".

**Row gestures:** tap row → the activity (A-states). Tap circle → Done, or
Not done if done (Undo). Long-press → **R1 options sheet**.

### T1 · Morning

- **Purpose:** see the shape of the day and begin it.
- **Hierarchy:** DayHeader · StatusLine ("5 things today · first at 7:00") ·
  [T2 From yesterday] · NowNextCard (NOW or NEXT) · Your day (all rows open;
  NowLine before the first thing) · +.
- **Primary:** NowNextCard action (**Start** / **Done**).
- **Secondary:** any row's circle; open a row; long-press options; +.
- **Shows:** every planned thing with time and length; 🔥 on activities with
  a running challenge (yesterday's streak number).
- **Hides:** add controls (behind +); charts; challenges list; per-row chips.
- **Navigation:** card/row → A1/A2; + → AD1; 🔥 long-press → C3.
- **Empty:** → T9/T10. **Loading/Error:** per 1.0.4 (header and status line
  show at once from cache when available).
- **Completion:** n/a (the day moves on).
- **Transitions:** Start → A3 (opens running); circle → T5; time passes →
  T3.

### T2 · From yesterday (morning section)

- **Purpose:** don't lose yesterday's unfinished things; decide fast.
- **When:** yesterday has things neither done nor skipped **and** it's before
  12:00 **and** the user hasn't handled them yet (handled = nothing left
  undecided; derived, not stored).
- **Hierarchy:** heading "From yesterday" · each unfinished thing as a compact
  row (name, its time yesterday) with **Do today** and **Let it go** · footer
  links **All today** · **Let all go**.
- **Primary:** per row **Do today**.
- **Secondary:** Let it go; the two "all" links.
- **Shows:** only names and yesterday's time.
- **Hides:** details, why it wasn't done (no judgment).
- **Navigation:** none (actions in place).
- **Completion:** last row decided → section collapses with "All set" for
  2 s, then disappears.
- **Transitions:** Do today → the thing moves to today (keeps its time; if
  that time has passed today it becomes Anytime) and appears on the timeline;
  Let it go → marked Skipped on yesterday; both with Undo.

### T3 · During the day

- **Purpose:** know what's next and keep going.
- **Hierarchy:** DayHeader · StatusLine ("2 of 5 done · 1 h 15 min so far") ·
  NowNextCard (per table) · Your day (done rows with results above the
  NowLine, upcoming below) · +.
- **Primary:** NowNextCard action.
- **Secondary:** circles; open rows; +.
- **Shows:** results of done things; live 🔥 numbers.
- **Hides:** what's late (no "overdue"); totals beyond the status line.
- **Navigation:** as T1.
- **Transitions:** Start → A3; Done → T5; all done → T6; evening rule met →
  T7.

### T4 · Running (on Today)

- **Purpose:** remember something is being timed; get back to it.
- **Hierarchy:** StatusLine "Meditation running · 2 of 5 done" · NowNextCard
  RUNNING (big live time, **Finish**) · its row shows "Running · 12:04".
- **Primary:** **Finish**.
- **Secondary:** tap card/row → A3; other circles (Done works for others).
- **Rule:** Start on another thing → **R2** dialog "Finish Meditation and
  start Deep work?" (**Finish and start** · Cancel). Only one timer.
- **Transitions:** Finish → T5 (simple) or A6 (meaningful details).

### T5 · Just completed (transition state, ~2 s)

- **Purpose:** feel the consequence of doing it.
- **What happens:** circle fills; sub-line becomes the result; 🔥 rolls
  from 12 to 13; status line updates ("3 of 5 done"); the NowNextCard slides
  to the next thing; snackbar "Meditation done · 🔥 13" with **Undo**.
- **Primary:** none (it's feedback). **Undo** reverts everything above.
- **Completion:** settles into T3/T6.

### T6 · All done

- **Purpose:** a finished day feels finished.
- **Hierarchy:** StatusLine "All 5 done · 3 h 20 min" · NowNextCard hidden ·
  timeline all done · (after 17:00 → T7's all-done variant).
- **Primary:** none; **+** remains.
- **Shows:** results on every row.
- **Transitions:** adding something → T3; 17:00 → T7.

### T7 · Evening review (open)

- **Purpose:** close the day honestly and set up tomorrow (Understand →
  Improve).
- **When:** local time ≥ 17:00 **and** (all planned things done or skipped
  **or** the last planned thing's end has passed) **and** at least one thing
  was planned.
- **Hierarchy (a card at the top, NowNextCard hidden):**
  1. SentenceCard: "**4 of 5** done · 3 h 20 min."
  2. Streaks: "🔥 Meditation 13 · Reading 5 kept today."
  3. At risk (if a running challenge's activity isn't done today): "Yoga
     streak at risk (8 days)" + **Do it now**.
  4. **Not done:** each unfinished thing with **Tomorrow** · **Let it go**.
  5. **Plan tomorrow →**
- **Primary:** per unfinished thing **Tomorrow**; then **Plan tomorrow**.
- **Secondary:** Let it go; Do it now (opens A1/A2 of that activity, adding
  it to today if needed).
- **Shows:** today's numbers only.
- **Hides:** comparisons with other days (that's Progress), any grade.
- **Navigation:** Plan tomorrow → P2 (tomorrow selected).
- **Completion:** no unfinished thing left → T8.
- **Variant, all done:** "All 5 done today. 🔥 Meditation 13." + Plan
  tomorrow (no Not done list).
- **Transitions:** Tomorrow → the thing moves to tomorrow (same time), leaves
  the list, Undo; Let it go → skipped, Undo.

### T8 · Evening review (closed)

- **Hierarchy:** one line at the top: "Day closed · 4 of 5 done · Plan
  tomorrow →".
- **Primary:** Plan tomorrow →.
- **Transitions:** adding/doing something new reopens T7 only if something
  becomes unfinished.

### T9 · No plan, first use (no activities exist)

- **Purpose:** give a new person one obvious first step.
- **Hierarchy:** DayHeader · StatusLine "Nothing planned yet" · empty card:
  orb, "Your day is empty.", "Add the first thing you're doing today.",
  **Add to today** (opens AD1), three common activities as chips (Walk,
  Read, Meditate) that add to today in one tap (Anytime).
- **Primary:** **Add to today**.
- **Hides:** everything else; no tour, no setup.
- **Transitions:** first thing added → T1/T3.

### T10 · No plan, returning user

- **Hierarchy:** StatusLine "Nothing planned yet" · card "Nothing planned
  today." · **Your usual Thursday:** up to five chips (activities from
  repeats and those done on this weekday in the last four weeks, with their
  usual time) — tap adds it · **Start something now** (opens AD1 with Now).
- **Primary:** a usual chip.
- **Transitions:** chip → T1/T3 with the thing on the timeline.

### R1 · Row options (long-press sheet)

- **Shows:** name + time. Actions: **Done / Not done**, **Move to tomorrow**,
  **Change time**, **Skip**, **Duplicate**, **Delete** (all with Undo; Delete
  also removes what was recorded, said in its label "Delete (and what was
  recorded)" when something was).
- **Hides:** repeat and notes editing (in A11).

### R2 · One timer at a time (dialog)

"Finish Meditation and start Deep work?" · **Finish and start** · Cancel.
Finishing follows the normal Finish (A6 if needed, then starts the other).

---

## 1.2 The activity ("the thing")

One screen, states A1–A13. App bar: back · badge + title · ⋯ (A11).
Always saves as you type ("Saved" appears briefly; no Save button).

### A1 · Ready, timer activity

- **Purpose:** start it.
- **Hierarchy:** header card (time "07:00 · 15 min", chip "Planned", notes'
  first line) · **Start** (full width, action color, glow) · **Done** (text
  button under it: for when it was done without timing) · "Last time ·
  Tue: 32 pages" card with **Use last time** (when history exists) · details,
  each in its card (empty) · Notes.
- **Primary:** **Start**.
- **Secondary:** Done; Use last time; fill details now; ⋯.
- **Hides:** When/Duration editors (set by the timer; editable in A8),
  Plan next (A7), Add-a-detail (⋯ → Edit details).
- **Transitions:** Start → A3; Done → A6 or A7.

### A2 · Ready, simple activity (no timer)

- Same as A1 with **Done** as the full-width primary and no Start; a quiet
  "Time it instead" link if the activity allows timing.
- **Transitions:** Done → A7 (simple) / A6 (meaningful details).

### A3 · Running

- **Purpose:** do it, recording as you go if you want.
- **Hierarchy:** live header card: chip **LIVE**, "Started 7:02", **big
  timer** (tabular), **Pause** (round, soft) · **Finish** (dark pill,
  primary) · Focus icon · then details ready to fill (sets: done sets fold
  into one line; the set being filled has − / + steppers; **Add set** ·
  **Rest**) · Notes.
- **Primary:** **Finish**.
- **Secondary:** Pause; fill details; Rest; Focus (A5).
- **Hides:** Done (Finish is Done), Start time/Duration editors, Plan next.
- **Navigation:** back → Today T4 (still running).
- **Transitions:** Pause → A4; Finish → A6/A7; Focus → A5.

### A4 · Paused

- Header shows "Paused" chip, the time dimmed, **Resume** (primary) and
  **Finish**. Everything else as A3.

### A5 · Focus mode (optional)

- Full screen: activity badge and name, very big timer, **Pause/Resume**,
  **Finish**; × returns to A3; screen stays awake; nothing else.
- **Transitions:** Finish → A6/A7 (closing focus).

### A6 · How did it go? (sheet, meaningful details only)

- **Purpose:** capture what matters in seconds.
- **When:** after Done/Finish, automatically, if the activity has
  **meaningful details**: a list (exercises/sets…) or a number detail shown
  in Progress (pages, km, kg). Never for text-, yes/no-, rating-, choice- or
  duration-only activities.
- **Hierarchy:** title "How did it go?" + name and time ("Gym · 1 h 05 min")
  · the activity's top-level details, prefilled with what was entered while
  running; empty ones show last time's value as a hint and **Use last time**
  · **Save** (primary, full width) · **Skip** (text).
- **Primary:** **Save**.
- **Hides:** notes (stay in A7), Add-a-detail, setup.
- **Completion:** Save or Skip closes it → A7. It's already Done either way.
- **Error:** a value that can't be saved stays highlighted; Save shows "Check
  the highlighted details"; Skip still works.

### A7 · Done

- **Purpose:** see the result and what it changed.
- **Hierarchy:** **ResultHeader**: chip "Done ✓", the result big ("32
  pages", "45 min"), "Meditation · 13 days in a row 🔥", "3 of 5 done today"
  · details (editable) · Notes · When + Duration (editable) · **Plan next…**
  (text) · **Back to today** (quiet full-width).
- **Primary:** **Back to today** (when opened from Today), otherwise back.
- **Secondary:** edit details/notes/time; **Not done** (in the header, with
  Undo); Plan next.
- **Hides:** Start (a second session is in ⋯ → "Time again").
- **Transitions:** back → Today T5 (if just finished) / T3.

### A8 · Done, editing

- Editing details or time on a done thing keeps it done; "Saved" shows;
  the result header updates live.

### A9 · Skipped

- Header chip "Skipped", faded; **Undo skip** (primary); details hidden.

### A10 · Started now without a plan

- From AD (Now): opens directly in A3 with title = activity; on Finish it
  becomes a done thing on today's timeline at its start time.

### A11 · Options (⋯ sheet)

**Change time and length**, **Repeat…**, **Move to another day**, **Skip**,
**Duplicate**, **Time again** (done things), **Edit details** (the
activity's setup: what it records; opens M3), **Delete**. Each with Undo
where possible.

### A12 · Past day's thing

- Opened from Plan's past day or Progress: same as A7/A9, without Start.
  **Not done** on a past day reopens it as unfinished on that day (it then
  shows as not done in that day's history and in Progress).

### A13 · Errors

- Deleted elsewhere → "This was deleted." + **Back**.
- Save failure → "Not saved yet: check the highlighted details"; values kept.

---

## 1.3 Add (the + sheet)

### AD1 · Empty

- **Purpose:** put something on a day in seconds.
- **Hierarchy:** handle · title "Add to Thursday" (or "Add to today") ·
  field "What are you doing?" (focused, keyboard up) · **Recent** chips (up
  to eight, most used in four weeks) · **When:** Anytime (selected) · Now
  (today only) · Time… · **Repeat** (collapsed) · **Add** (disabled until
  something is chosen) · "Browse all activities" link.
- **Primary:** a Recent chip (one tap adds it with its usual time) or type.
- **Hides:** icons, colors, details setup.
- **Empty (first use):** six common activities instead of Recent.

### AD2 · Typing

- Suggestions under the field: your activities first, then built-in ones,
  each with a one-line "what it records" ("pages, book"); tapping fills the
  field and selects it. Exact match selects automatically.

### AD3 · New name

- The first suggestion is **Make "Pottery" yours** ("New activity · nothing
  to set up"): selecting it creates the activity with defaults (icon,
  color) at Add. Details can be set later (A11 → Edit details / M3).

### AD4 · Time

- A small sheet: suggested starts (next half hours today; usual times on
  other days) + "Other time…", then length chips (No end · 15 min · 30 min ·
  1 h · 2 h · Until…). **Done** returns to AD1 showing "9:30 · 1 h".

### AD5 · Repeat

- Weekday chips (Mon–Sun), "Every week" (default) / "Every 2 weeks"; until
  (optional). Shows "Mon, Wed, Fri" in AD1.

### AD6 · Browse all activities

- Full screen: search, **Yours**, then built-in activities by life area.
  Tapping one returns to AD1 with it selected.

### AD-completion and errors

- **Add** → sheet closes; the new row appears on the day, scrolled into view
  and briefly highlighted. With **Now**: the label is **Start** and A10 opens.
- A name taken by one of yours selects yours (no duplicate activities).

---

## 1.4 Plan: "shape my days"

### P1 · Week, today selected (default)

- **Purpose:** see the week and change it.
- **Hierarchy:** title "Plan" · month name (tap → P5) · **Today** pill ·
  **WeekStrip** (Mon–Sun; past days: ring of done/planned; today: brand
  fill; future: a count) · selected day: DayHeader ("Today · Thursday") +
  timeline rows (same TimelineRow, no Start) · +.
- **Primary:** **+** (adds to the selected day).
- **Secondary:** tap a day pill; swipe the strip for other weeks; tap a row
  (A-states); long-press (R1 + **Repeat…**, **Move to…**); drag Anytime
  rows to reorder.
- **Hides:** Start/Finish (Today does that), results charts.
- **Empty:** P4. **Loading/Error:** 1.0.4.

### P2 · Future day (e.g. tomorrow from the evening review)

- DayHeader "Tomorrow · Friday, Oct 9" · rows with their repeat ("Mon, Wed,
  Fri") · things moved from today marked "From today" for that evening.
- **Primary:** **+**.
- **Transitions:** coming from T7 → opens here with tomorrow selected.

### P3 · Past day

- DayHeader "Yesterday · Wednesday" + StatusLine "4 of 5 done · 3 h" · rows
  with results; unfinished ones open.
- **Primary:** none (review); tap a row → A12.
- **Secondary:** + (add something that was done, as done).

### P4 · Empty day

- "Nothing planned for Friday." · **Your usual Friday** chips · "Add
  something" (= +).

### P5 · Month

- Month grid; each day shows up to four activity-colored dots; today ringed.
  Tap a day → P1–P4 on that day.

### P6 · Repeat sheet (from long-press or A11)

- Weekday chips, every 1–4 weeks, until; **Stop repeating after this** for
  an existing repeat. Saved → the following weeks update.

### P7 · Moving

- **Move to…** → date picker (and keep or change time) → the row leaves this
  day with Undo and appears on the target.

---

## 1.5 Progress: "how am I really doing"

### PR1 · Week (default), enough data

- **Purpose:** know how the week went and what's improving.
- **Hierarchy:** title "Progress" · period pills **Week · Month · Year** +
  dates ("Oct 5–11") with ‹ › · SentenceCard "You did **17 of 20** planned
  things this week." + "3 more than last week" · SentenceCard "Most of your
  time went to **Deep work** (9 h), Gym (3 h), Reading (2 h)" + stacked bar ·
  **Your activities**: StoryRows sorted by time ("Reading · 4 times · 120
  pages ↑", "Gym · 3 of 3 · Bench 72.5 kg, a new best", 🔥) · **Consistency**
  calendar · **Plan vs reality** chart · **Not done this week** (neutral
  rows with **Plan it**) · **Body** (if measurements) · **Your charts** +
  **Build a chart**.
- **Primary:** tap a StoryRow → PR5.
- **Secondary:** change period; Plan it (AD1 with the activity); Build a
  chart (PR7); open a measurement (M5).
- **Hides:** raw tables, advice, scores, correlations.
- **Loading/Error:** per card.

### PR2 · Month / Year

- Same structure; sentences say "this month" / "this year"; comparisons to
  the previous month/year; the calendar covers the period.

### PR3 · Early (fewer than three days with anything done)

- SentenceCard "Progress builds as you go." + "After a few days you'll see
  your week here." + what's true already ("2 things done so far: Walk,
  Read") · Consistency calendar · nothing else.

### PR4 · Things done but nothing planned

- The planned-vs-done sentence becomes "You did 12 things this week (8 h)."
  Plan vs reality chart hidden; everything else as PR1.

### PR5 · An activity

- **Hierarchy:** badge + name · period pills · SentenceCard ("You read 6 of
  the last 7 days, 32 pages a day on average.") · 🔥 if in a challenge (→ C3)
  · its calendar · **Best** ("Most pages: 58, Oct 2") · charts from its
  details (best per row, totals, trends) · most-used rows (exercises) ·
  recent things (tap → A12).
- **Primary:** read; tap a recent thing.
- **Empty period:** "No Reading this week. Last time: Sep 28." + **Plan it**.

### PR6 · Your charts

- The saved charts, each a card; **Build a chart** opens the existing chart
  builder (advanced, unchanged).

### PR7 · Body

- Latest value per measurement with a small trend line; tap → M5.

---

## 1.6 Challenges

### C1 · Empty

- "A challenge is a promise to yourself: one thing, every day, for a number
  of days." · **New challenge** · example chips "21 days of Meditation", "30
  days of Reading" (prefill C7).

### C2 · List

- **Hierarchy:** title "Challenges" + **New challenge** · running
  ChallengeCards (badge, name, "21 / 75", bar, 🔥 12, today: "Done today ✓" /
  "Not yet today") · **Completed** section (collapsed count).
- **Primary:** tap a card → C3–C6.
- **Secondary:** New challenge.

### C3 · Challenge, not yet today

- **Hierarchy:** big ring "21 / 75" · 🔥 current · best · days done · days
  left · **Do it today** (primary: adds the activity to today if it isn't
  there, then opens A1/A2) · "Your days" calendar · ⋯ (Edit, Restart from
  today, End).
- **Primary:** **Do it today**.

### C4 · Challenge, done today

- Same; the primary area shows "Done today ✓ · Meditation 15 min" (tap →
  A7); ring and 🔥 already updated.

### C5 · Challenge, at risk (evening, streak running, not done)

- Same as C3 with the line "Streak at risk · 8 days" above **Do it now**.

### C6 · Completed

- Ring full "75 / 75", "Completed Oct 3", best streak; ⋯ (Start again,
  Delete). No Do it today. Leaves Today's badges.

### C7 · New challenge (sheet)

- Activity (search yours + built-in), days (chips 7/21/30/75/100 or a
  number), first day (today default), name (auto "30 days of Reading",
  editable) · **Create**.
- **Completion:** the card appears on top of C2; the 🔥 badge appears on that
  activity's rows in Today.

### C8 · Edit / Restart / End

- Edit: name and number of days. Restart from today and End: done
  immediately with Undo (ADR-044).

---

## 1.7 Me: "my setup"

### M1 · Me

- **Hierarchy:** title "Me" · card **Your activities** (count) · card **Body
  measurements** (latest weight if any) · card **Appearance** (value
  "Lavender") · [Developer, debug builds only].
- **Primary:** open a card.
- **Hides:** the built-in catalog (it's in AD6), anything daily.

### M2 · Your activities

- Search · your activities (badge, name, "what it records" in a few words,
  🔥 if in a challenge) · **New activity**. Archived ones under "Archived".
- **Empty:** "Activities appear here as you add them to your days." + New
  activity.
- **Tap** → M3.

### M3 · An activity's setup

- Name, icon, color, **What you record** (details list: add, reorder,
  change, remove), **Time it** on/off. Saves as you type. ⋯: Archive /
  Delete.
- **Shows:** a live preview "How did it go?" of its details.
- **Hides:** its history (that's Progress, PR5; a link "See progress").

### M4 · Body measurements / M5 · one measurement

- Existing screens, restyled: latest values; per measurement a line chart,
  history, **Add measurement**.

### M6 · Appearance

- Intro; three theme previews (Rose, Lavender, Papaya) drawn in their own
  themes with a sample TimelineRow and a Start button; ring + "In use" on the
  current one. Tap applies instantly (cross-fade) and saves.

---

## 1.8 The day, end to end (storyboard)

| Time | State | User does | Sees change |
|---|---|---|---|
| 07:05 | T1 + T2 | "From yesterday: Reading" → **Do today** | Section says "All set"; Reading joins Anytime |
| 07:06 | T1, NowNext NOW · Meditation | **Start** | A3 opens: LIVE, 00:00 counting |
| 07:21 | A3 | **Finish** | Simple activity: A7 "15 min · 🔥 13 days in a row · 1 of 5 done" |
| 07:21 | back → T5 | — | Row ✓ "15 min", 🔥 13; status "1 of 5 done"; NEXT · 9:30 Deep work |
| 09:30 | T3 NOW · Deep work | **Start** … 11:30 **Finish** | ✓ "2 h"; "2 of 5 done · 2 h 15 min so far" |
| 13:00 | T3 NOW · Lunch | circle | ✓ "Done" |
| 18:00 | T3 NOW · Gym → A1 | **Use last time** → **Start** → A3 sets with steppers | done sets fold "1 · 60 kg × 8 ✓" |
| 19:05 | A3 | **Finish** → A6 (sets prefilled) → **Save** | A7 "Bench 60 kg × 8 ×3 · 🔥 4" |
| 21:30 | T7 | Reading → **Tomorrow** | T8 "Day closed · 4 of 5 done" |
| 21:31 | Plan tomorrow → P2 | adjust, + | Friday ready |
| Sunday | PR1 | read | "17 of 20 planned · Deep work 9 h · Bench 72.5 kg, a new best" |

**Loop map:**

| Step | Where it happens |
|---|---|
| Plan | AD (+), P1–P7, T7 → P2 |
| Do | T1/T3 NowNext, A1–A5 |
| Record | Finish/Done, A6, A8 |
| Measure | Row result, 🔥, StatusLine, A7 ResultHeader |
| Understand | T7 evening review, PR1–PR5 |
| Improve | T2 Do today/Let it go, T7 Tomorrow/Plan tomorrow, PR Plan it |

---

## 1.9 Edge cases

| Case | Behavior |
|---|---|
| Two things at the same time | Both rows; NowNext picks the first by time then order; the other stays on the timeline |
| A thing with a time but its activity isn't timed | NowNext shows **Done** |
| Finish with nothing recorded and no time | Done with the timed length (timer) or planned length counts as planned |
| Timer still running at 23:59 | Belongs to the day it started; Today rolls over, the running card stays until Finish |
| Activity archived while things are planned | Rows keep showing; the activity can still be done; it's not offered in AD |
| A challenge's activity done twice a day | Counts once (ADR-044) |
| 20+ things in a day | Timeline scrolls; NowNext stays near the top; Anytime collapses after 5 ("+ 7 more") |
| Very long names | One line with ellipsis on rows; full name in A-states |
| Delete a thing that fed a challenge | Streak recomputes; Undo restores it |
| Time zone change | Days follow the stored local date (ADR-013); no rewrites |


---

# Phase 2: Stitch redesign plan

## 2.0 Ground rules

- Stitch sets **composition, hierarchy, visual language, type, spacing,
  components, interactions and theme treatment**. Our product definition sets
  **what is on each screen**.
- One layout for all three themes; Rose and Lavender share Stitch's layout
  family, Papaya's differences are treatments only (floating nav, rimmed
  cards, chips for facts, gradient progress, sunken wells; ADR-045).
- Never: Flowfy's name, palette or identity; "LifeOS"; Stitch's out-of-scope
  content (energy reserve, calibration, sensors, AI, budgets, rituals,
  routines bundles, XP, photos, kcal/heart rate).
- Where Stitch has no screen for a state, compose it from the closest Stitch
  components (noted "composed").

## 2.1 State → Stitch reference

| Our screen / state | Stitch reference | Take | Change for V1 |
|---|---|---|---|
| Today header + status line | Today – Living Pulse: hero card (date pill, greeting, ring) | Date pill, greeting type, ring | Ring stays small in the header; the hero shrinks to header + one status sentence (no Energy Reserve) |
| Now/Next card | Today – Living Pulse: "Up next" card | UP NEXT pill + "in 25 mins", title, facts, full-width CTA with glow | One CTA (Start/Done/Finish); RUNNING variant with live time |
| Timeline rows | Plan – Timeline Horizon (time column, status icon, plan vs actual) + Today "Living Stream" rows | Time column (Rose/Lavender) or icon-led (Papaya); circle on the right; NOW divider | Result sub-line instead of description; 🔥 badge; no chips on every row |
| "Now" line | Plan – Timeline Horizon "NOW • 04:15 PM" divider | As is | — |
| From yesterday | composed: Today empty-state checklist rows | Pill rows with inline actions | Two actions per row |
| Evening review | composed: Insights headline card ("You complete 85%…") + Intent vs Reality rows | Big sentence with the number highlighted; rows with actions | Our sentence ("4 of 5 done · 3 h 20 min"); Tomorrow / Let it go |
| No plan / first use | Today – First-Time Empty State: empty card with orb + "start with one tap" chips | Orb, one sentence, one-tap chips | Chips = usual/common activities; no calibration/intentions |
| + button | Today "Quick Log" pill | Pill/circle with glow | A round + (not a "record" button) |
| Add sheet | Quick Log (category grid, duration chips), Log Activity form | Duration quick chips, segmented When, big rounded inputs | Search-first field + Recent chips; no categories grid on top |
| The thing · Ready | Log Activity – Dynamic Form (field cards) | Each detail in a card with icon header | Start/Done CTA on top |
| The thing · Running | Record – Live Workout Session | Live chip, big timer, Pause round + Finish dark pill, done rows folded, active row with steppers, Add set + Rest | No kcal/volume/video/RPE; generic details only (already built in slice 1) |
| "How did it go?" sheet | Record – active row card + Log Activity field cards | Prefilled steppers, field cards, one Save | Sheet form; Skip |
| The thing · Done | composed: Insights "Progression deep dive" header (big value + change) | Big result, change chips | Result + "what this changed" (streak, day progress) |
| Focus mode | Record header timer, full screen | Big timer, two pills | — |
| Plan | Plan – Timeline & Horizon (week strip with rings, Day/Week toggle) | Week strip with rings, selected day heading, timeline rows, NOW line | No "Rituals", no "In rhythm", no "Plan fidelity" judgments; + adds |
| Plan empty | Plan – First-Time Empty State | "Your day is wide open" card | Usual-activity chips; no "suggested architectures" |
| Progress | Insights – Self-Understanding | Headline sentence card, Intent vs Reality rows, Progression deep dive card, pill bars | Our sentences; no correlations, auto-adjust, share, budgets |
| Progress empty | Insights – First-Time Empty State | "Warming up" card | No calibration phases/locks |
| Activity page | Insights – Progression deep dive | Big current value + change, line with baseline/current chips, two stat tiles | Generic (any activity) |
| Challenges list/page | composed: Today hero ring + Insights progression card + Plan week strip rings | Ring with "21/75", streak chip, calendar | — |
| Me | Me – Activity Studio & Profile (grouped settings cards) | Grouped cards with icon rows and values; "Theme System" row | No profile/level/targets/sensors/blueprints |
| Appearance | Pastel Confection theme picker spec (cards with a ring + gap) | Ring selection | Previews drawn in each theme (built) |
| Bottom nav | All Today screens | Pill indicator; Papaya floating bar | Five tabs |

## 2.2 Theme treatment per component (one product, three personalities)

| Component | Rose | Lavender | Papaya |
|---|---|---|---|
| Header ring / progress | solid teal | lavender → mint gradient | papaya → peach gradient |
| Now/Next card | borderless, rose glow; CTA teal | hairline lavender edge; CTA deep mint | rimmed; CTA aqua mint with dark text |
| Timeline row | time column, borderless card | time column, hairline card | icon-led, rimmed card |
| Facts (length, time) | tiles | tiles | chips |
| Inputs / steppers | soft blush wells | soft lilac wells | sunken sand wells |
| Nav | full-width bar | full-width bar | floating pill |

Screens never branch on the theme; only shared components read treatments.

## 2.3 Stitch screens to update (optional, for review before coding)

If the owner wants to see the redesign in Stitch first, these screens would be
generated/edited in the "Personal Life OS" project (Lavender as the base,
then variants for Rose and Papaya): Today – Morning, Today – Running, Today –
Evening review, The thing – Running, "How did it go?", The thing – Done,
Plan – Week, Progress – Week, Challenges, Add sheet. This needs the owner's
OK because it changes their Stitch project; otherwise the Flutter build of
slice 1 is the first visual review (as with slice 1 of ADR-045).

---

# Phase 3: Implementation plan

## 3.0 Principles

- No schema change is expected for any slice (everything is derived from
  existing data).
- Domain rules as pure functions with unit tests first; then providers; then
  shared components (in the token showcase); then screens; widget tests for
  each flow in all three themes and at 200% text.
- Each slice ends runnable on the phone, with format/analyze/tests green and
  docs/ADRs updated in the same change. Stop for the owner's review after
  slice 1.

## 3.1 Slice 1: the core loop (first, as requested)

**Today → open → Start → running → Finish → optional details → done →
visible result/streak/progress → back to Today**, in all three themes.
States: T1, T3, T4, T5, T6 (Today), A1–A8 and A13 (the activity), R1, R2.

Domain (pure, tested):
1. **One Done** (ADR-046 changes ADR-040's UI rule): Finish, the circle and
   Done all mark the plan done; recording details alone no longer leaves it
   "in progress" in the UI (the status shown is Ready / Running / Done /
   Skipped). Data stays as is.
2. **`hasMeaningfulDetails(ActivityType)`**: a list, or a number detail that
   shows in Progress.
3. **Row result** (`resultOf(PlannedItem)`): details summary → time → "Done"
   (reuses `summarizeLog`, `formatPlanOutcome`).
4. **Streak by activity**: current streak of the running challenge for an
   activity (from existing `ChallengeProgress`), for the 🔥 badge.
5. **Now/Next** (extends `upNext`): running first, then now-window, next,
   anytime; and the **status line** (`DayStatus`).

Presentation:
6. Today: header + status line, Now/Next card (Start / Done / Finish,
   RUNNING variant), timeline rows (time column / icon-led per theme, circle,
   result, 🔥, "now" line, Anytime), long-press sheet, **+** opening the
   existing quick add moved into a sheet (full add-sheet redesign is slice 2),
   Today's Challenges section removed.
7. The thing: Ready / Running / Done states (Start or Done primary; live
   header with Pause + Finish; done header with result and "what this
   changed"); Focus as an option from Running.
8. "How did it go?" sheet (prefilled details, Save / Skip), shown after
   Done for meaningful activities; "Add details" link on simple done rows.
9. Feedback: circle fill, counts up, snackbar "Meditation done · 🔥 13" with
   Undo.

Tests: the loop in each theme (timer activity, simple activity, gym with
sets), 200% text, reduced motion; unit tests for the domain rules.

Docs: ADR-046 implementation note, ui_guidelines Today/the thing, user_flows
F3/F17, current_task.

## 3.2 Slice 2: the day's edges

States T2, T7, T8, T9, T10, AD1–AD6, A9–A12. From yesterday, evening review (rule, Tomorrow / Let it go, streak at risk,
Plan tomorrow → Plan on tomorrow), no-plan states (usual-activity chips),
the full **add sheet** (§1.8) replacing the inline quick add everywhere.

## 3.3 Slice 3: Plan

States P1–P7. Week strip with rings/counts, selected day timeline (shared rows), opens on
tomorrow from the review, month view restyle, empty day chips, repeat shown
on rows.

## 3.4 Slice 4: Progress

States PR1–PR7. Rename Insights → Progress (UI only), headline sentence, where-your-time-went
sentence, activity stories, not done this week with Plan it, consistency,
plan vs reality, body, your charts last; activity page sentence first; empty
state.

## 3.5 Slice 5: Challenges

States C1–C8. List cards with today's state, page with ring + Do it today, empty state with
example chips, new challenge sheet restyle.

## 3.6 Slice 6: Me and the rest

States M1–M6. Me grouped cards (M1: activities, body, appearance), activity setup (M3)
with its live preview, built-in catalog moved to the add sheet's Browse, language
sweep (no item/log/record/field in the UI), visual quality checklist in every
theme.

## 3.7 After V1 experience (not now)

Onboarding, reminders (challenges step 2), backup/export, naming/icon/splash,
store listing: the launch layers, in that order, after the owner judges the
experience.
