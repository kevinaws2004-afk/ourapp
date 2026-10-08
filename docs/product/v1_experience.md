# V1 Product Experience

> **Status: PROPOSAL for owner review (2026-10-08).** Nothing here is built
> yet. When approved, this becomes the product definition the screens are
> redesigned around (Stitch redesign second, implementation third), and the
> affected docs (user_flows, ui_guidelines, ADRs) are updated to match.
>
> It is a **re-arrangement of what already exists**, not new features. The
> generic activity engine, the data model and the database stay as they are.
> The only new presentations are three views of existing data: the result on
> a done row, the evening review, and progress in sentences.

---

## 0. The product in one sentence

**Plan your day, live it, and see how you're really doing.**

A person opens the app to run their day. They see what's planned, do it
(one tap to start, one to finish), and the day visibly changes. Over days and
weeks, the app tells them in plain sentences how their life is actually going
compared with what they planned, and tomorrow gets shaped from that.

What only this app shows: **plan vs reality** and **progress per activity**,
for anything a person does, from one daily list.

### Principles

1. **Today is the product.** Everything else supports it.
2. **Doing beats entering.** The primary action is always Start or Done, never
   "add" or "fill in".
3. **Details are optional.** The loop works with nothing but time and done.
   Details (pages, kg, notes) make it richer for those who want them.
4. **Every action has a visible consequence** on the same screen: the row
   shows its result, the day's progress moves, the streak goes up.
5. **Answers before charts.** Progress speaks in sentences; charts back them up.
6. **The engine stays out of sight.** Setup lives in Me or behind +, and
   appears when it's needed.
7. **No feature explosion.** No AI, finance, goals, social, XP or gamification.

### Words the user sees

| The user sees | Internal name (code, docs) |
|---|---|
| your day, today | day overview |
| an activity (Gym, Reading) | ActivityType |
| something on your day ("Gym at 6 PM") | plan / item |
| done, how it went | ActivityLog, marked done |
| details (pages, weight, notes) | fields, values |
| a list of sets / exercises | Repeating Group |
| a challenge, a streak | Challenge |
| progress | insights |

Not shown to users: item, record, log, field, list, detail, activity type,
schema, task (a plan without an activity is simply "something to do").

---

## 1. Today: "my day"

**Purpose:** see my day at a glance and execute it. The screen changes with
the time of day but stays the same screen.

### Layout (all states)

```
Good morning                         ← greeting (by local time)
Thursday, Oct 8 · 2 of 5 done        ← date + one line status

┌ NOW / NEXT ───────────────────────┐ ← one card, one action
│ Deep work · 9:30–11:30            │
│ in 20 min        [ Start ]        │
└───────────────────────────────────┘

Your day                             ← timeline, time order
07:00  ● Meditation · 15 min   🔥13   ✓ 15 min
09:30  ○ Deep work · 2 h                       ← "now" line sits between
───────── now 9:10 ─────────
13:00  ○ Lunch
18:00  ○ Gym                   🔥 4
Anytime ○ Read                         

                                  ( + )      ← the only add control
```

### Rows (one row per thing on the day)

- **Shows:** time (or "Anytime"), the circle, name, its planned length, the
  streak badge if the activity is in a running challenge (🔥 + current
  streak), and once done its **result** in a few words.
- **Result line** (from what was recorded, in order of what exists):
  details summary ("32 pages", "Bench 60 kg × 8 ×3") → time spent ("45 min") →
  "Done". Plan vs reality appears only when it says something ("45 min of
  1 h").
- **Tap the circle:** Done (see §6). Tap the row: open it.
- **Long-press:** Move to tomorrow, Skip, Edit time, Delete (all with Undo).
- **Hidden from rows:** the ⋮ button, drag handles (reorder moves to Plan),
  "Planned" chips on every row, activity type names when the title says it.
- **Visual states:** upcoming (normal), now (highlighted, it's in the Now card
  too), running (live time instead of planned length), done (filled circle +
  result, quieter), skipped (faded, "Skipped"), passed and not done (shown as
  open, no red; it waits for the evening review).

### State A: morning (nothing done yet, things planned)

- Status line: "5 things planned · first at 7:00".
- Now/Next card: the first thing, "at 7:00" or "in 20 min", **Start**
  (or **Done** for an activity without a timer).
- Timeline as above, all open.
- **Primary action:** Start / Done on Now/Next.
- **Secondary:** tap any row, the circle on any row, +.

### State B: during the day

- Status line: "2 of 5 done · 1 h 15 min so far".
- Now/Next card shows, in order: the thing **running** (live time, **Finish**),
  else the thing **happening now** (its time window contains now: **Start**),
  else the **next** timed thing ("in 40 min", **Start**), else the first
  "Anytime" thing. Things whose time passed without being done drop out of
  the card (they stay on the timeline).
- The "now" line moves through the timeline.
- **Primary action:** the Now/Next card's action.
- **Transition, finishing something** (§6): the row fills, its result
  appears, the streak badge counts up, the status line updates ("3 of 5
  done"), the Now/Next card moves on. One short, quiet confirmation, no
  pop-up.

### State C: a completed thing

- On the timeline: filled circle, result line, streak badge updated, slightly
  quieter than open rows (done is calm, not loud).
- Tapping it opens it to see or change what was recorded.
- Tapping its circle undoes Done (with Undo in a snackbar).

### State D: no plan (nothing on today)

Two different cases:

- **First days of using the app (no activities yet):** a calm card: "Your
  day is empty. Add the first thing you're doing today." with **+ Add to
  today** and three suggestions from the built-in activities as one-tap chips
  (a starting point, not onboarding).
- **A day with nothing planned (the person uses the app):**
  "Nothing planned today." + their **usual activities for this weekday**
  (from repeats and the last weeks) as one-tap "Add" chips, and
  **Start something now** (opens add, then starts it).
- Anything done without a plan still appears on the timeline as done.

### State E: evening review (closing the day)

- **Appears** at the top of Today when the day is mostly over: after the last
  planned thing's time has passed **or** everything is done, and not before
  late afternoon. (Exact rule: owner decision, §9.)
- **Shows:**
  - "Today: 4 of 5 done · 3 h 20 min" (plan vs reality in one line, never a
    grade).
  - Streaks kept today ("Meditation 13 · Reading 5").
  - What didn't happen, each with **Tomorrow** / **Let it go** (= skip).
  - **Plan tomorrow →** opens Plan on tomorrow, already holding repeats and
    what was moved.
- After it's handled it collapses to one line ("Day closed · 4 of 5").
- The timeline stays below, unchanged.
- **Primary action:** decide the unfinished things, then Plan tomorrow.

### Today: summary

| | |
|---|---|
| Purpose | See my day and do it |
| Sees | Greeting, status line, Now/Next, timeline with results and streaks, evening review in the evening |
| Primary | Start / Done (Now/Next card, circles) |
| Secondary | Open a thing, long-press options, +, Plan tomorrow |
| Hidden | Add controls (behind +), reorder, ⋮, chips on every row, setup, charts |
| Empty | §1 D |

---

## 2. Plan: "shape my days"

**Purpose:** decide what my coming days look like. Not a second copy of Today.

- **Sees:** a **week strip** (Mon–Sun, each day with a small ring of done /
  planned for past days and a count for future days), then the selected
  day's timeline (same rows as Today, without Start), opening on **tomorrow**
  when coming from the evening review and on today otherwise.
- **Routines:** repeating things show their repeat ("Mon, Wed, Fri") and are
  managed here (repeat, stop repeating, change time).
- **Primary action:** **+** to add to the selected day (same add sheet as
  Today, with a time).
- **Secondary:** drag to reorder untimed things, long-press (move, skip,
  repeat, delete), month view from the month name, jump to any date.
- **Past days:** read-only feel: what was planned vs what happened (the same
  rows with results); tapping opens the record.
- **Hidden:** recording details (that's Today), charts.
- **Empty (a day with nothing):** "Nothing planned for Thursday" + usual
  activities for that weekday as one-tap chips + **+**.
- **Transitions:** "Move to tomorrow" from Today lands here; adding a repeat
  fills the following weeks.

---

## 3. Progress: "how am I really doing"

**Purpose:** understand how my life is going, in sentences first.

- **Sees, top to bottom:**
  1. **This week** (switchable: week / month / year), in sentences:
     - "You did 17 of 20 planned things (85%)." with last period's number.
     - "Most of your time went to Deep work (9 h), Gym (3 h), Reading (2 h)."
     - "Not done this week: Yoga." (neutral)
  2. **Your activities:** one row each, with a one-line story and a tiny
     trend: "Reading · 4 times · 120 pages · ↑ vs last week",
     "Gym · 3 of 3 · Bench 72.5 kg (best)". Tap → that activity's page.
  3. **Consistency:** the calendar of days with something done.
  4. **Plan vs reality** chart and **where your time went** chart (the
     existing ones, as backing for the sentences).
  5. **Body** (measurements' latest values and trend, one row each) if any.
  6. **Your charts** (saved custom charts) at the very end, for the curious.
- **Activity page:** its sentence ("You've read 6 of the last 7 days,
  32 pages a day on average"), calendar, best, the charts worked out from its
  details, rows (exercises) most used.
- **Primary action:** read; tap an activity.
- **Secondary:** period switch, build a chart (in "Your charts").
- **Hidden:** the chart builder (behind "Your charts"), raw numbers without a
  sentence.
- **Empty (less than a few days of data):** "Progress builds as you do
  things. After a few days you'll see your week here." + what's already true
  ("2 things done so far").
- **Rules:** every sentence comes from numbers the app already computes; no
  advice, no scores, no judgments ("missed" is neutral).

---

## 4. Challenges

**Purpose:** commitments I'm keeping: "Meditate every day for 75 days".
A separate first-class tab (owner decision), but it doesn't dominate Today.

- **On Today:** only the 🔥 streak badge on the activity's row, and "streak
  at risk" in the evening review if today isn't done yet. No separate
  Challenges section on Today.
- **The tab sees:** running challenges first (each: name, progress "21 / 75",
  progress bar, current streak, today's state: done / not yet), then
  completed ones.
- **Challenge page:** big progress, current and best streak, days done and
  left, the calendar, **Do it today** (adds it to today if it isn't there and
  opens it), Edit / Restart / End.
- **Primary action:** **New challenge** (pick an activity, number of days).
- **Hidden:** settings beyond name and days.
- **Empty:** "A challenge is a promise to yourself: do one thing every day
  for a number of days." + **New challenge** + two examples as chips
  ("21 days of Meditation", "30 days of Reading").
- **Transitions:** doing the activity anywhere counts the day automatically;
  the badge on Today and the tab both update.
- Rules unchanged (ADR-044): progress and streak are separate and derived.

---

## 5. Me: "my setup"

**Purpose:** everything that configures the product, out of the daily way.

- **Sees:**
  - **Your activities** (create, edit what each records, archive); the
    built-in activities are offered when adding, not as a big catalog here.
  - **Body measurements** (record weight etc.).
  - **Appearance** (theme).
  - Units, data (export later), about.
- **Primary action:** open an activity to change it.
- **Hidden:** nothing important; this is where infrastructure lives.
- **Empty:** n/a (always has Appearance etc.); no activities: "Activities
  appear here as you add them to your days."

---

## 6. Completing an activity (the Do → Record flow)

One idea of finishing: **Done**. Three ways in, one result.

1. **Timed (Start → Finish):**
   - **Start** (Now/Next or the open thing) → the row and card show live
     time; the open thing shows a big timer with **Pause** and **Finish**.
   - **Finish** = Done, with the timed length.
2. **Quick (the circle):** tap the circle → Done. If the thing has a planned
   length and no time was recorded, it counts as planned.
3. **Inside the thing:** open it, record whatever you like, tap **Done**.

**After Done, "How did it go?"** (only for activities with details):
- A short sheet with **only that activity's details**, prefilled from last
  time ("Use last time" for sets), one **Save** and a **Skip** that keeps it
  done without details.
- Activities without details never see it.
- Whether the sheet appears automatically or only via a "+ Add how it went"
  link on the done row: **owner decision** (§9). Recommendation: automatic
  for activities with required or main details (sets, pages), link for the
  rest.

**After that, back on Today:** the visible consequences (§1 B). Closing a
thing always returns to where it was opened; there are no pop-ups.

**Undo:** tapping a done circle reopens it (with Undo); details stay.

**Changes from today's behavior (for the ADR):** "In progress after logging"
and a separate "Mark done" (ADR-040) become one Done; recording details no
longer leaves a thing half-finished. The data model doesn't change.

---

## 7. Adding something (the Plan flow, behind +)

**+** on Today or Plan opens **one sheet**, the same everywhere:

1. **Type** what it is: suggestions from your activities, then built-in ones.
   **Recent** activities as chips above the field.
2. **When** (optional): Now (starts it), a time, or Anytime; and a length.
3. **Repeat** (optional): days of the week.
4. **Add.**

- A new name offers **"Make it your own"**: it's created right there with no
  details; details can be added later (inside the thing, or in Me), so adding
  never turns into setup.
- **Browse all activities** sits at the bottom of the sheet.
- **Primary action:** Add (or Start now).
- **Hidden:** field configuration, icons, colors (defaults; changeable in Me).
- **Empty (first use):** a few common activities as chips.

---

## 8. How the loop connects

| Step | Where | What the user does | What they see change |
|---|---|---|---|
| **Plan** | + (Today/Plan), Plan tab, evening review | Add things, set repeats, Plan tomorrow | Their day/week filled |
| **Do** | Today: Now/Next, timeline | Start, Finish, Done | Live time; Now/Next moves on |
| **Record** | Done + "How did it go?" (optional) | One tap; optional details | The row's result line |
| **Measure** | The row, the streak badge, the status line | Nothing; it happens | "3 of 5 done", 🔥13, "32 pages" |
| **Understand** | Evening review (today), Progress (week) | Read | "4 of 5 done · 3 h 20 min", "85% of planned this week" |
| **Improve** | Evening review → Plan tomorrow; Progress → Plan | Move, let go, adjust repeats | Tomorrow shaped from today |

Every screen hands off to the next step: Today's evening review → Plan
(tomorrow); Plan's days → Today (when they arrive); Today's rows → Progress
(the activity's page from a done row); Progress → Plan ("not done this week"
→ add it to a day); Challenges → Today (Do it today).

---

## 9. Owner decisions needed before the Stitch redesign

| # | Question | Recommendation |
|---|---|---|
| 1 | When does the evening review appear? | After the last planned thing's time has passed or everything is done, and not before 17:00 |
| 2 | "How did it go?" automatic or on demand? | Automatic only for activities whose details matter (required details or lists such as sets); otherwise a link on the done row |
| 3 | Unfinished things the next morning (if the review wasn't done) | Shown at the top of Today as "From yesterday: Reading · Tomorrow / Let it go" |
| 4 | Keep a full-screen timer? | Keep as an option from the running thing; not a separate place |
| 5 | Plain "something to do" without an activity (old tasks) | Keep for old data; new things always come from an activity (ADR-042) |
| 6 | Progress tab name | "Progress" |

## 10. What changes vs today (for planning, not a feature list)

- **Today:** quick add, Browse, Make your own and Recent move behind +; rows
  lose ⋮, drag and chips and gain results and streak badges; the Challenges
  section leaves Today; the evening review appears.
- **Finishing:** Finish / Mark done / circle become one Done; "How did it
  go?" sheet.
- **Plan:** week strip + selected day; opens on tomorrow from the review.
- **Insights → Progress:** sentences on top; existing charts below; saved
  charts last.
- **Challenges:** stays a tab; "Do it today"; Today shows only badges.
- **Me:** activities as setup; the big built-in catalog moves into add.
- **Language:** the words table in §0.
- **Unchanged:** data model, database, the activity engine, the form
  renderer, challenge rules, insight maths, themes.
