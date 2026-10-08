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

## 1.0 App frame

- **Tabs:** Today · Plan · Challenges · Progress · Me (Progress = the
  renamed Insights; Challenges stays first-class, ADR-044/046).
- **One add control:** a round **+** on Today and Plan (bottom right, above
  the tab bar). It is not a "Record" button: it opens the add sheet (§1.8).
- **Feedback rule:** every action that changes data shows its consequence on
  the screen where it was taken, plus Undo for anything destructive or
  accidental. No confirmation pop-ups for reversible actions.
- **Loading:** content areas show nothing for ~150 ms, then quiet skeleton
  rows (existing `DelayedLoadingPlaceholder`); never a spinner over the whole
  screen.
- **Errors:** a calm inline card ("Couldn't load your day. Try again.") with
  **Try again**; anything typed is kept. Writes that fail show a snackbar
  with the reason and leave the screen as it was.
- **Time:** the screen re-evaluates its state when the app comes to the
  foreground and when a minute passes (Now/Next, "now" line, evening review).

---

## 1.1 Today

**Purpose:** "Here is my day. Here is what matters. Let me do it."

### Hierarchy (top to bottom)

1. **Header:** greeting ("Good morning") and the date ("Thursday, Oct 8").
2. **Status line:** one sentence that changes through the day (below).
3. **From yesterday** (only in the morning, only if something is left).
4. **Evening review** (only in the evening, §1.1 E).
5. **Now/Next card:** the one thing to do now, with one action.
6. **Your day:** the timeline, in time order, with a "now" line; untimed
   things under **Anytime** at the end.
7. **+** (floating, bottom right).

Challenges are **not** a section on Today; their streaks appear as a 🔥
badge on the activity's row and as "streak at risk" in the evening review.

### Timeline row (the building block)

```
07:00   ◯  Meditation              🔥 12
           15 min
```

| Element | Content | Rule |
|---|---|---|
| Time | "07:00", "07:00–08:00", or nothing (Anytime) | Left column, quiet |
| Circle | open (in the activity's color), filled ✓ (done), live dot (running), dash (skipped) | 48 dp tap target |
| Name | The thing's title | One line, ellipsis |
| Sub-line | Before: planned length. Running: live time. Done: **result** | See result rules |
| Streak | 🔥 + current streak, if the activity has a running challenge | Updates the moment it's done |

**Result rules** (done rows), first that exists:
1. Details summary: "32 pages", "Bench 60 kg × 8 ×3, Squat 80 kg × 5 ×3",
   "5.2 km".
2. Time spent: "45 min" (with "of 1 h" only if it differs from the plan by
   more than 10 minutes).
3. "Done".

**Row actions:** tap row → open the thing (§1.2). Tap circle → Done (simple
activity) or Done + "How did it go?" (activity with meaningful details,
§1.2.4). Long-press → sheet: Move to tomorrow, Skip, Change time, Delete
(each with Undo). Nothing else on the row: no ⋮, no drag handle, no status
chip.

**Row states:**

| State | Look |
|---|---|
| Upcoming | Normal weight, open circle |
| Now (its time window contains now) | Slightly emphasized (soft brand tint), also in the Now/Next card |
| Running (timer) | Live dot, sub-line counts up ("Running · 12:04") |
| Done | Filled ✓ circle, result sub-line, text one step quieter |
| Passed, not done | Same as upcoming (no red, no "late"); handled by the evening review |
| Skipped | Faded, sub-line "Skipped" |
| Done without a plan ("Start now", or added as done) | In time order, done look |

### Status line by moment

| Moment | Status line |
|---|---|
| Morning, nothing done | "5 things today · first at 7:00" |
| During, some done | "2 of 5 done · 1 h 15 min so far" |
| Running | "Meditation running · 2 of 5 done" |
| All done | "All 5 done · 3 h 20 min" |
| Nothing planned | "Nothing planned yet" |

### Now/Next card

| Situation | Card |
|---|---|
| Something running | "RUNNING" · name · big live time · **Finish** (primary) · tap card → open it |
| A thing's time window contains now | "NOW" · name · time · **Start** (timer activities) or **Done** |
| Next timed thing later today | "NEXT · 9:30" · name · "in 20 min" · **Start** / **Done** |
| Only Anytime things open | "ANYTIME" · first open one · **Start** / **Done** |
| Everything done | Card hidden (the status line says "All done") |
| Another thing is running and this one is next | Shows the running one (only one card) |

The card shows planned length and notes (first line) if any. Nothing else.

### State A: Morning

- **When:** before the first thing is done, on a day with things planned.
- **Shows:** header, "5 things today · first at 7:00", From yesterday (if
  any), Now/Next = the first thing, the timeline all open.
- **Primary:** Now/Next action (Start / Done).
- **Secondary:** any row's circle, open a row, +, long-press options.
- **Hidden:** add controls (behind +), progress numbers beyond the status line.

### State A1: From yesterday

- **When:** yesterday had things neither done nor skipped, and yesterday's
  evening review wasn't completed. Shown only until noon or until handled.
- **Shows:** "From yesterday" and each unfinished thing as a compact row with
  two actions: **Do today** (moves it to today, keeping its time if it has
  one) and **Let it go** (marks it skipped on yesterday). "Handle all"
  shortcuts: **All today** / **Let all go**.
- **Wording note:** the owner's "Move to tomorrow" seen from yesterday means
  today, so the button says **Do today**.
- **Completion:** when the list is empty the section disappears with a short
  "Done" confirmation.

### State B: During the day

- **Shows:** status "2 of 5 done · 1 h 15 min so far", Now/Next per the
  table, the "now" line between the last passed and the next thing, done rows
  with results.
- **Primary:** Now/Next action.
- **Transition, Start:** tapping Start on a row or the card starts its timer
  **and opens the thing** in its running state (§1.2.2). Back on Today the
  row and card show it running.
- **Transition, Done (one tap):** the circle fills (short animation, reduced
  motion = instant), the sub-line becomes the result, the 🔥 number counts
  up, the status line updates, the Now/Next card moves to the next thing, and
  a snackbar "Meditation done · 🔥 13" with **Undo**.

### State C: Running

- **Shows:** the running row with live time; Now/Next = RUNNING card with
  **Finish**; status line names it.
- **Primary:** Finish (from the card) or open it.
- **Rule:** one timer at a time. Start on another thing while one runs asks:
  "Finish Meditation and start Deep work?" (**Finish and start** / Cancel).

### State D: Completed (a thing just finished)

- The row: ✓, result, streak; quieter text.
- Tap → the thing in its done state (§1.2.5).
- Tap its circle → reopen (not done) with Undo.

### State E: Evening review

- **When (approved rule):** local time ≥ 17:00 **and** (every planned thing
  is done or skipped, **or** the last planned thing's end time has passed).
  Not shown on days with nothing planned.
- **Shows (a card above Now/Next, which is hidden by then):**
  - "Your day" headline sentence: "4 of 5 done · 3 h 20 min."
  - Streaks: "🔥 Meditation 13 · Reading 5" (kept today); "Streak at risk:
    Yoga (not yet today)" with **Do it now** if a running challenge's
    activity isn't done today.
  - **Not done:** each unfinished thing with **Tomorrow** / **Let it go**.
  - **Plan tomorrow →** (opens Plan on tomorrow).
- **Completion:** once every unfinished thing is decided, the card collapses
  to one line "Day closed · 4 of 5 done · Plan tomorrow →". Nothing is stored:
  "closed" means nothing is left undecided.
- **All done day:** "All 5 done today. 🔥 Meditation 13." + Plan tomorrow.

### State F: No plan

- **No activities exist yet (very first use):** a card "Your day is empty.
  Add the first thing you're doing today." with **+ Add to today** and three
  common activities as one-tap chips (each adds it to today, no time).
- **Activities exist, today empty:** "Nothing planned today." + **your usual
  things for a Thursday** (from repeats and the activities done on this
  weekday in the last four weeks, at most five) as one-tap chips that add
  them with their usual time + **Start something now** (opens add with
  "Now" selected).
- Things done without a plan still appear on the timeline.

### Navigation

- Row / card → the thing (§1.2). + → add sheet (§1.8). Plan tomorrow → Plan
  on tomorrow. 🔥 badge long-press → the challenge.
- Pull to refresh is not needed (data is live).

### Today: intentionally hidden

Quick-add field, Browse activities, Make your own, Recent chips (all in the
add sheet); ⋮ and drag handles; status chips on every row; the Challenges
section; progress charts; activity setup.

---

## 1.2 Activity execution and recording ("the thing")

**Purpose:** do one thing and record how it went, with as little as needed.

One screen with four states. Opened from Today, Plan, a challenge or
Progress. The app bar shows the activity badge, the title and ⋯ (Edit time
and notes, Repeat, Move, Skip, Delete, Edit details setup).

### 1.2.1 Ready (not started, not done)

- **Hierarchy:** header card (time "07:00 · 15 min", "Planned" chip,
  first line of notes) → **Start** (full width, action color) for timer
  activities → **Done** (secondary, full width) → the details (each in its
  card, empty, with "Last time: …" and **Use last time** when there's
  history) → Details card (notes, when, duration).
- **Primary:** Start (timer activities) / **Done** (others: Done is primary).
- **Secondary:** fill details before starting (allowed), ⋯ options.
- **Hidden:** Add-a-detail, field setup (in ⋯ → Edit details setup).

### 1.2.2 Running

- **Hierarchy (Stitch "Record – Live Session"):**
  1. Live header card: "LIVE" chip, name, **big timer** (tabular), **Pause**
     (round, soft) and **Finish** (dark pill, primary), a small "Focus" icon
     that opens the optional full-screen timer.
  2. The details, ready to fill **while** it runs (sets: done sets fold to one
     line, the set being filled has steppers, **Add set**, **Rest**).
- **Primary:** Finish.
- **Secondary:** Pause/Resume, fill details, Focus mode, Rest.
- **Leaving:** back returns to Today with the thing still running (row + card
  show it). The timer survives the app being closed (existing).
- **Hidden:** Done (Finish is the done), Plan next, the Details card collapses
  to "Notes" (when/duration are set by the timer).

### 1.2.3 Focus mode (optional)

Full screen: name, big timer, Pause, Finish, screen stays awake. Close (×)
returns to the running thing. Reached only from the running thing; never a
separate place in the app.

### 1.2.4 Finishing → "How did it go?"

**One Done.** Finish, the circle on Today, and **Done** here all mark the
thing done (with the timed length if timed).

Then:
- **Activity with meaningful details → "How did it go?" sheet opens
  automatically.**
  - *Meaningful details* (rule, pure and testable): the activity has a list
    (e.g. exercises/sets) or a **number** detail that shows in Progress
    (pages, km, kg). Text, yes/no, ratings, choices and durations alone are
    not meaningful (the check and the timer already cover them).
  - The sheet shows only the activity's details (top-level), prefilled from
    what's already filled in this thing; empty ones show last time's values
    as hints with **Use last time**.
  - **Save** (primary) and **Skip** (keeps it done, no details).
  - If the details were already filled while running, the sheet still
    appears, prefilled, so it's one tap to confirm.
- **Simple activity → no sheet.** Done is one tap. The done row offers
  "Add details" for later.

### 1.2.5 Done

- **Hierarchy:** header card with "Done ✓" chip and the **result** in big
  type ("32 pages", "45 min"), then **what this changed**: 🔥 streak if any
  ("Meditation · 13 days in a row"), "3 of 5 done today"; then the details
  (editable, save as you type), then notes.
- **Primary:** none forced; **Back to today** (full width, quiet) is the
  natural next step.
- **Secondary:** edit details, **Not done** (reopen, with Undo), **Plan
  next…**, ⋯.
- **Coming back from it:** Today shows the row done with its result (State D).

### 1.2.6 Errors and edge cases

- Saving details fails → inline "Not saved yet: check the highlighted
  details", values kept.
- Required details are hints while recording, never blockers (ADR-035).
- A thing deleted elsewhere while open → "This was deleted." + Back.

---

## 1.3 Plan: "shape my days"

**Purpose:** decide what the coming days look like; manage routines.

- **Hierarchy:**
  1. Title "Plan" + month name (tap → month view) + **Today** pill.
  2. **Week strip:** seven day pills (weekday + date). Past days: a small
     ring done/planned. Today: brand fill. Future: the count of things.
  3. **Selected day:** its heading ("Tomorrow · Friday, Oct 9") and its
     things as timeline rows (same row component as Today; no Start; future
     rows show their repeat "Mon, Wed, Fri").
  4. **+** (adds to the selected day).
- **Opens on:** tomorrow when coming from the evening review; otherwise
  today.
- **Primary:** + (add to the selected day).
- **Secondary:** swipe the week strip to change week; tap a row → the thing
  (future: edit time/notes/repeat; past: what happened); long-press → Move
  to…, Repeat…, Skip, Delete; drag untimed things to reorder.
- **Past days:** rows show results; a one-line "4 of 5 done" under the day
  heading.
- **Month view:** a calendar grid with up to four colored dots per day; tap a
  day → back to week view on that day.
- **Hidden:** Start/Done for future days, details, charts.
- **Empty day:** "Nothing planned for Friday." + your usual things for that
  weekday as one-tap chips + "Add something".
- **Loading/error:** as §1.0.
- **Transitions:** adding a repeat fills later weeks immediately; "Move to
  tomorrow" from Today/evening review shows up here.

---

## 1.4 Progress: "how am I really doing"

**Purpose:** understand how life is going compared with plans; sentences
first, charts second.

- **Hierarchy:**
  1. Title "Progress" + period pills **Week · Month · Year** (default Week)
     and the dates ("Oct 5–11").
  2. **Headline card** (one sentence with the key number big): "You did
     **17 of 20** planned things this week." + vs last week ("3 more than last
     week").
  3. **Where your time went:** sentence ("Most of your time: Deep work 9 h,
     Gym 3 h, Reading 2 h") + the stacked bar.
  4. **Your activities:** one row each, sorted by time spent: badge, name,
     one-line story ("4 times · 120 pages · ↑"), 🔥 if in a challenge. Tap →
     activity page.
  5. **Consistency:** calendar of days with something done.
  6. **Plan vs reality:** the existing chart (planned vs recorded per day).
  7. **Not done this week:** neutral list ("Yoga · last done Sep 28") with
     **Plan it** (opens add for that activity).
  8. **Body:** latest measurement values with a small trend (if any).
  9. **Your charts:** saved custom charts, then **Build a chart**.
- **Activity page:** sentence ("You read 6 of the last 7 days, 32 pages a day
  on average"), its calendar, best, the charts from its details, most-used
  rows (exercises), recent records.
- **Primary:** read; tap an activity.
- **Secondary:** period switch, Plan it, Build a chart.
- **Hidden:** the chart builder (behind Your charts), numbers without a
  sentence, scores/grades/advice.
- **Empty (fewer than 3 days with something done):** "Progress builds as
  you go. After a few days you'll see your week here." + what's already
  true ("2 things done so far") + the consistency calendar.
- **Loading/error:** per card (one failing card doesn't blank the screen).
- **Sentence rules:** only from numbers already computed (ADR-043); neutral
  wording; no "you should".

---

## 1.5 Challenges

**Purpose:** promises to myself ("every day for 75 days") and how I'm
keeping them.

- **List hierarchy:** title "Challenges" + **New challenge**; running
  challenges as cards (badge, name, "21 / 75", progress bar, 🔥 current
  streak, today: "Done today ✓" or "Not yet today"); then **Completed**.
- **Challenge page:** big progress ring "21 / 75", 🔥 current and best
  streak, days done / days left, the calendar of days, **Do it today**
  (primary while not done today: adds the activity to today if it's not
  there and opens it; when done: "Done today ✓"), ⋯ Edit / Restart from
  today / End (Undo).
- **New challenge sheet:** activity (from yours or built-in), days (chips 7 /
  21 / 30 / 75 / 100 or a number), first day, name (auto: "30 days of
  Reading"). **Create**.
- **Primary:** New challenge (list) / Do it today (page).
- **Hidden:** anything beyond "every day for N days" (ADR-044).
- **Empty:** "A challenge is a promise to yourself: one thing, every day, for
  a number of days." + **New challenge** + two example chips ("21 days of
  Meditation", "30 days of Reading") that prefill the sheet.
- **Completion:** reaching the target: the card shows "Completed Oct 3 ·
  75 / 75" and moves to Completed; the 🔥 badge leaves Today.
- **On Today:** only the badge and the evening review's "streak at risk".

---

## 1.6 Me: "my setup"

**Purpose:** configure the product, away from daily use.

- **Hierarchy:** title "Me"; groups as cards with icon rows and a value on
  the right:
  - **Your activities** (count) → list of yours (search, archive), each →
    activity setup (name, icon, color, what it records, timer on/off).
  - **Body measurements** → latest values; add measurement.
  - **Appearance** → theme (value: "Lavender").
  - **Units**, **About** (privacy statement: data stays on this phone).
  - Developer (debug builds only).
- **Primary:** open a row.
- **Hidden:** the 147 built-in activities (they're offered in the add sheet
  and when creating a challenge, not listed here).
- **Empty:** Your activities with none: "Activities appear here as you add
  them to your days."

## 1.7 Appearance

**Purpose:** choose one of three looks for the whole app.

- **Hierarchy:** intro line; three previews (Rose, Lavender, Papaya), each
  drawn in its own theme (canvas, name, description, a sample Today row and a
  Start button); the one in use has a ring and "In use".
- **Primary:** tap a preview (applies at once with a cross-fade, saved).
- **Hidden:** dark mode (not offered).
- Already built (ADR-045); only its sample row changes to the new timeline
  row.

## 1.8 Add (the + sheet)

**Purpose:** put something on a day in seconds, without setup.

- **Hierarchy (bottom sheet):**
  1. Field "What are you doing?" with autofocus.
  2. **Recent** chips (your most used, up to eight) under it while empty.
  3. While typing: suggestions (yours first, then built-in; each with what it
     records in a few words); a new name shows **Make "Pottery" your own**.
  4. **When:** **Now** (starts it) · a time (picker sheet with suggested
     times and length) · **Anytime**. Default: Anytime for a future day; for
     today, Anytime.
  5. **Repeat** (optional): weekday chips.
  6. **Add** (primary, full width); with Now selected it reads **Start**.
  7. **Browse all activities** (link at the bottom) → the catalog screen.
- **Primary:** Add / Start.
- **Secondary:** pick a time, repeat, browse.
- **Hidden:** icons, colors, details setup (a new activity gets defaults; set
  up later in Me or from the thing's ⋯).
- **Completion:** the sheet closes; the row appears on the day (scrolled into
  view, briefly highlighted). With Now: the thing opens running.
- **Empty:** first use: six common activities as chips.

---

## 1.9 The day, end to end

| Moment | Screen / state | User does | Sees change |
|---|---|---|---|
| 07:05 open | Today · Morning (+ From yesterday) | Do today / Let it go | Section clears; Reading joins today |
| 07:06 | Now/Next: Meditation · NOW | **Start** | Meditation opens running |
| 07:21 | The thing · Running | **Finish** | Simple activity: done at once |
| 07:21 | Back on Today · Completed | — | ✓ · "15 min" · 🔥 13 · "1 of 5 done" · Now/Next → Deep work at 9:30 |
| 09:30 | Today · During · Now/Next: Deep work | **Start** … **Finish** | ✓ · "2 h" |
| 18:00 | Gym · Start → running, fill sets with steppers | **Finish** → "How did it go?" (sets prefilled) → **Save** | ✓ · "Bench 60 kg × 8 ×3 …" · 🔥 4 |
| 21:30 | Today · Evening review | Reading: **Tomorrow** | "Day closed · 4 of 5 done" |
| 21:31 | Plan tomorrow → Plan on Friday | adjust, + | Friday ready |
| Sunday | Progress · Week | read | "17 of 20 planned", activity stories |

**Loop map:** Plan (+, Plan tab, evening review) → Do (Now/Next, Start,
running) → Record (Finish/Done, "How did it go?") → Measure (row result, 🔥,
status line) → Understand (evening review, Progress) → Improve (Tomorrow /
Let it go, Plan tomorrow, Plan it from Progress).

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

From yesterday, evening review (rule, Tomorrow / Let it go, streak at risk,
Plan tomorrow → Plan on tomorrow), no-plan states (usual-activity chips),
the full **add sheet** (§1.8) replacing the inline quick add everywhere.

## 3.3 Slice 3: Plan

Week strip with rings/counts, selected day timeline (shared rows), opens on
tomorrow from the review, month view restyle, empty day chips, repeat shown
on rows.

## 3.4 Slice 4: Progress

Rename Insights → Progress (UI only), headline sentence, where-your-time-went
sentence, activity stories, not done this week with Plan it, consistency,
plan vs reality, body, your charts last; activity page sentence first; empty
state.

## 3.5 Slice 5: Challenges

List cards with today's state, page with ring + Do it today, empty state with
example chips, new challenge sheet restyle.

## 3.6 Slice 6: Me and the rest

Me grouped cards (activities, body, appearance, units, about), activity setup
screens restyled, built-in catalog moved to the add sheet's Browse, language
sweep (no item/log/record/field in the UI), visual quality checklist in every
theme.

## 3.7 After V1 experience (not now)

Onboarding, reminders (challenges step 2), backup/export, naming/icon/splash,
store listing: the launch layers, in that order, after the owner judges the
experience.
