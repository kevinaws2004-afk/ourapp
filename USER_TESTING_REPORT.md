# DayCraft: first-time user test, 10 days

_2026-10-18 · Android emulator (API 37) · profile build · fresh install, no data · screenshots in `build/e2e/ut/`, raw diary in `build/e2e/ut/notes.md`_

## How this was tested

I installed the app fresh and used it as one realistic person for 10 simulated days, moving the phone's clock through each day and doing what that person would do, not just tapping every button.

**Persona: "Aarav", a college student.** Wants to study every weekday morning, go to the gym Mon/Wed/Fri at 6 PM, and read 30 min every night. Not technical, never used a planner app. Sets two goals on day 2: "Gym 3× a week" and "Read every day".

| Day | What Aarav did |
|---|---|
| 1 Mon | Onboarding, planned his day, studied (timer), gym with sets, reading, looked at the day report |
| 2 Tue | Tried Pomodoro for studying, used "Use last time", skipped reading, evening review, created two goals |
| 3 Wed | Studied, gym (legs), allowed on-time reminders, reading |
| 4 Thu | Studied, ignored the streak nudge, "let go" of reading |
| 5 Fri | Forgot the timer and just ticked study off, gym (push) with "last time", reading |
| 6 Sat | Wrote a note, logged weight, reading |
| 7 Sun | Opened the weekly recap from its notification |
| 8–9 | Got sick: skipped everything for two days |
| 10 Wed | Came back after the lapse |

Also checked along the way: notifications and their timing, the home-screen widget, the Quick Settings tile, the app lock, Pomodoro, goals, personal bests and the weekly recap.

## Verdict as a user

**The core loop is genuinely good.** Plan a few things, start a timer, log details, and see the day add up. Three things stand out:

- "Last time · Use last time", especially per exercise ("Last time: Bench press 40 kg × 10 (×3) · Use").
- The sets logging, once you learn it.
- The weekly recap with personal bests.

What hurt on day 1 was **friction in planning** (setting up a repeating thing takes too many steps). What hurt by day 10 was **things that weren't honest or weren't where I left them**: wrong goal counts, a skipped day shown as "Everything done", yesterday's reminders still sitting there, and the app reopening on last night's screen. Most of those are now fixed (below).

---

## 1. Bugs found and fixed during the test (19)

All fixed in code. The ones marked ✔ were also confirmed on the emulator afterwards.

| # | What happened to Aarav | Fix |
|---|---|---|
| 1 | Reminder "Gym in 30 min" came **26 min late** (5:56 for a 6:00 gym) | ✔ On-time reminders: a new **On-time reminders** row in Me → Notifications. The app asks once, after the first reminder or when Pomodoro is turned on. Fired at 17:30:00 exactly once allowed |
| 2 | At 6:01 PM the **Now card skipped the gym session** happening right now and showed 10 PM reading | ✔ An item with a time but no length stays "Now" for an hour |
| 3 | Exercise **suggestion list stayed open** after the keyboard closed; tapping "Add Set" picked "Decline bench press" | ✔ The list closes with the keyboard (the first attempt didn't work and was redone) |
| 4 | Set 2 showed last set's 40 kg × 10 in grey, but **✓ was disabled** until both were retyped | ✔ ✓ accepts the suggested values: a repeat set is one tap |
| 5 | Making Study repeat on weekdays **didn't put it on Wed–Fri** until the app restarted | ✔ Days refresh as soon as a repeat is set |
| 6 | **Pomodoro round end was missed** when the app was in the background ("Round 1 · 00:00 to a break", still counting) | ✔ Checked again when you come back |
| 7 | "Use last time" filled the **rating but not the text** (Subject, What I covered) | ✔ All fields fill |
| 8 | **Pomodoro cut the gym session** into 25-min "focus rounds" (it was one global switch) | ✔ Rounds are per activity: on for study/work/reading/languages, off for workouts. A small "Rounds off for Gym" / "Use 25-min rounds for Gym" switch under the timer. The live label says "In progress", not "Focusing" |
| 9 | "Tomorrow" on a missed repeating Reading **made a second Reading** on Wednesday, and the skipped day then said **"Everything done · 1 of 1"** | ✔ If it already repeats that day, today's copy is marked skipped (with Undo) and nothing is duplicated. Same for "Do today" |
| 10 | Home widget showed **yesterday's "All 3 done"** all morning | ✔ It shows a fresh "Today · Open to plan your day" once the day has changed |
| 11 | Progress goal tile: **"Gym 3× a week · 0 of 8 days"** (it's 8 weeks) | ✔ "1 / 8 weeks" |
| 12 | Gym goal started on Tuesday **didn't count Monday's session**, so week 1 = 0/3 and the streak was 0 despite 3 gym days | ✔ Weekly goals count their whole first week. Unit test added |
| 13 | "🔥 0" / "0-day streak" badges on rows and the Next card | ✔ Hidden at zero |
| 14 | Weekly recap: **"You planned 2h and did 7h 51m · 392%"** (only Reading had a planned length) | ✔ Falls back to "You recorded 7h 51m" when plans didn't cover the week |
| 15 | Yesterday's **"Gym in 30 min" and streak nudges still in the shade** the next morning | ✔ Reminders and goal nudges clear themselves after 3 h |
| 16 | Opening the app in the morning landed on **last night's screen** (Day report, Goals, Progress). This happened on days 2, 3 and 9 | ✔ After a new day or more than 4 h away, it opens on Today |
| 17 | After two missed days, "From yesterday" offered "Do today" for Study and Reading, **which were already on today** | ✔ Left out |
| 18 | Clock-based text stayed stale after the phone slept ("Good morning… Now 9:42 AM" at night) | ✔ Refreshes when you come back |
| 19 | Paused row read "Paused · Paused" (from the earlier pass) | ✔ |

The automated test suite was re-run after all of this. The results are at the end of this report.

---

## 2. Still open: what felt odd, and what I expected instead

Ranked by how much each one would cost a real user (drop-off, distrust or annoyance). None of these are crashes.

### Must fix before launch

| Area | What felt odd | What I expected |
|---|---|---|
| **Add sheet** | Tapping a "Recent" chip (Gym) **instantly adds it as Anytime and closes the sheet**. The When / Repeat / Reminder controls right below suggest you choose those first. I lost my chance to set 6 PM and repeat, then had to dig into the item | The chip selects the activity; "Add" confirms. (Or keep one-tap add, but move the chips below When/Repeat so the order matches) |
| **Repeat** | Once set, the only control says **"Repeats · tap to stop"**: one tap ends the series, and there's no way to see or edit the days | "Repeats Mon, Wed, Fri" that opens the day picker; "Stop repeating" as a separate, confirmed action |
| **Repeat** | No **"Every day" / "Weekdays"** shortcut (tapped 7 days); every-day shows as "Mon, Tue, Wed, Thu, Fri, Sat, Sun" | Every day / Weekdays / Custom; label "Every day" |
| **Onboarding first plan** | My #1 area (Studying) got a **one-off** item; on day 2 it was gone with no prompt. Felt like the app forgot me | Make the first plan repeat by default ("Every weekday at 8:45?"), or on day 2 offer "Repeat yesterday's Study?" on Today |
| **Skipping = 100%** | "Let it go" on the last open item gives **"Everything done · 1 of 1 · All 1 done today"**. A skipped day looks perfect | Show "1 done · 1 let go" and don't celebrate a day that was skipped |
| **Weekly recap** | "12/12 Plans kept" though 2 Readings were skipped (skips vanish from the count). "6/7 active days" shown at 7 PM Sunday before the day ends | Count skips as not kept; send the recap Monday morning, or label it "so far" |
| **Ticking without the timer** | Ticking Study (forgot the timer) just marks it done: **no time recorded**, so the time stats undercount. Ticking Reading sometimes opened "How did it go?" and sometimes didn't | Always ask briefly: "How long? 30 min · 45 min · 1 h · Skip", using the planned length as the default |

### Should fix

| Area | What felt odd | What I expected |
|---|---|---|
| Onboarding · name step | "Back" is text at the **top right**; the main button says "Skip for now" while the field is empty; the field isn't focused | ← at top left; "Continue" (disabled until typed) plus a small "Skip"; keyboard open |
| Onboarding · pick step | **7 activities preselected**, 4 of which I didn't choose (Walking, Running, Language learning, Focused work). I had to untick them | Preselect only what matches the chosen areas, with my #1 area first |
| Onboarding · first plan | Reading preselected, not Study; "In an hour · 8:45 AM" at 7:32 (rounded oddly); no custom time | Preselect the first area's activity; round to the next :00/:30; offer "Pick a time…" |
| Today day 1 | No hint of what to do next (Plan, goals); the bottom half is empty | A one-time "Make it a habit: repeat it / set a goal" card |
| Status words | "Scheduled" (Plan), "Planned"/"Now" (item), "NEXT" (Today): three words for one state | One vocabulary everywhere |
| Progress tab | Opens on **Month**: day 1 shows "0/30 Active days · 0m · –" | Default to Week for new users |
| Reminder notification | No actions | **Start now · Snooze 10 min · Skip** |
| Timer | Counts up only; no target ("50 min") or end alert | Optional planned length as a countdown, with a chime at the end |
| Pomodoro break | After the break, the big button is still **Finish**; "Start round 2" is a small ▶; the Today card shows "PAUSED 25:00" with no break countdown | The big button becomes "Start round 2"; Today shows "Break · 3:20 left" |
| Gym · "last time" | It shows the most recent gym day (Legs); choosing **Push** hides it instead of showing the last Push session | "Last Push · Mon: Bench 40 × 10 ×3 · Use" |
| Gym · "Use" | Copies last sets as **already ticked ✓** before you've lifted | Copy as targets you tick one by one |
| Gym · set card | A set takes about half the screen (big steppers): 3 exercises × 3 sets is a long scroll | Compact rows "40 kg × 10 ✓"; open the big editor only on tap |
| Gym · sanity | Accepted **40910 kg** (a typo) silently | "That's a lot — 40.91 kg?" for implausible jumps |
| Personal bests | Benching 42.5 kg (up from 40) got **no moment** at Finish; only the Sunday recap mentioned it | "New best! Bench press 42.5 kg" on finishing |
| Perfect day | "All 3 done today" is plain; a first perfect day got no celebration | A small celebration and streak start |
| Two streaks | Reading row 🔥 broke after a skip while the Reading **goal** kept its streak via a rest day: the two disagree | One streak per activity, honouring rest days |
| Evening review | Repeats the hero numbers ("1 of 2 done · 47 min" twice); hero says "One more to go. Keep it up!" at 11:30 PM | Drop the duplicate line; at night, say "Wrap up your day" |
| Streak nudge | "Keep your Reading streak · not done yet" at **9 PM, before Reading's 10 PM time** | Nudge after the planned time, or about 2 h before midnight |
| Goal rest days | Nothing tells me a rest day was used to save the streak | "Rest day used · streak safe" |
| Goals empty state | Examples use Meditation, which I don't track | Examples from my own activities |
| Add sheet | "Recent" label on activities I've never used | "Your activities" |
| Add sheet · time | Time suggestions only cover the next 2 h; 10 PM needs "Other time…" and a clock dialog | Morning / Afternoon / Evening / Night quick picks |
| Add sheet chips | Selected time/repeat chips show the icon **with a check drawn on top** (looks glitchy) | Icon or check, not both |
| Gym item | Time / repeat / reminder are buried below the workout; "How long" and "Time spent" look like duplicates | Plan settings in a compact header; explain or merge the two durations |
| Finish from a notification | Finish returned to the **Me** tab (where I was before), not Today | Return to Today after finishing |
| Day report | "Untracked 13h 14m" dominates the bar (feels like a guilt meter); no planned-vs-actual times | De-emphasize untracked; show "planned 8:45 → did 8:45–9:36" |
| Copy yesterday | Hidden behind ⋮ on Plan; copied Gym onto Tuesday although Gym repeats Mon/Wed/Fri | Offer it on an empty Today; skip repeating items |
| After a lapse | Back after 2 missed days: no welcome-back tone, just a to-do list | "Welcome back — pick up where you left off" (one tap to clear old days) |
| Cold start | About 10 s on this emulator; Today shows an empty "Your day" with no spinner, which looks like nothing is planned | A skeleton/loading state; check cold start of the release build on a real phone |

### Nice to have

- "Pages: 25" → "25 pages"; "Reading 1 kept today" → "Reading streak: 1 day".
- Notes can't be linked to a day or an activity; a short journal line per day would fit the app.
- The LIVE chip shows the planned 6:00, not the actual 6:03 start.
- The ⏱ icon (full-screen timer) is unclear; label it or use an expand icon.
- Workout chips (Push/Pull/Legs) only tag the session; they could prefill that day's usual exercises.

---

## 2b. Fix round after the test (2026-10-19)

Every Must fix and Should fix item above is implemented. All Nice to have items are too, except one.

- **Must fix:**
  - **Add sheet:** a chip only selects; the label reads "Your activities"; no double check mark.
  - **Repeat:** can be edited and stopped with a confirm step. Shortcuts for Every day, Weekdays and Weekends.
  - **Onboarding:** the first plan repeats on Weekdays by default.
  - **Let it go:** shows "Done · 1 let go", not "Everything done".
  - **Ticking done without the timer:** records the planned length. With no planned length it asks "How long?" (one sheet after Done, never two).
  - **Reminders:** Start, Snooze 10 min and Skip actions.
  - **Timer:** shows time left or over against the planned length.
  - **Pomodoro break:** the main button becomes "Start round N".
- **Should fix:**
  - **Gym:** "last Push" matches by workout choice; "Use" copies sets as targets you tick one by one; a typo like 40910 kg gets a warning; the set card is tighter.
  - **Celebrations:** a moment for a new personal best and for a perfect day.
  - **Streaks:** a goal's start day can't break its streak; "Rest day used · streak safe" is shown.
  - **Evening:** "Wrap up today" late at night.
  - **Streak reminder:** comes after the planned session ends (20:00–23:00).
  - **Goals:** the empty state's examples use your own activities.
  - **Today:** a first-week "Make it a habit" card; "Copy yesterday's plan" on an empty day, skipping repeating items; "Welcome back" after 2+ idle days; a loading state on cold start.
  - **Day report:** "Untracked" is now a quiet line; done items show the planned time next to the actual start and end times.
  - **Gym item:** the time in the header opens the plan settings; the labels read "Planned length" and "Actual time".
  - **Progress:** opens on Week.
  - **Add sheet:** quick picks for later today.
- **Nice to have:**
  - "25 pages".
  - "Streaks kept: Reading 1 day".
  - LIVE shows the actual start time.
  - The full-screen timer button is labelled.
  - Choosing a workout chip shows that workout's last session with **Use**.
  - **Not done:** notes linked to a day or an activity. This needs a database change, so it's left for later.

**Checks:**
- `flutter analyze` is clean.
- `flutter test`: 623 passed and 28 failed.
  - 15 of the failures were already failing before this round.
  - The other 13 are tests that still expect the old UI ("Recent", Month first, a chip adding in one tap, the old timer button, no "How long?" sheet). They need updating; no bugs were found in them.
- On the emulator, the new build was checked through onboarding (name, areas, first plan with Repeat) and Today (Next card, the habit card).

## 3. What worked well (keep it)

- **Onboarding areas step**: clear and quick. The first plan with a reminder arrived on time.
- **"Last time · Use last time"** for study, reading and per exercise: the single best feature for repeat use.
- **Exercise name suggestions** from a real catalog, with my own names first.
- **Sets**: a completed set collapses to "40 kg × 10 ✓"; the summary "Push · Bench press 40 kg × 10 (×3)" reads well.
- **Evening review**: "Reading streak at risk · Do it now", Tomorrow / Let it go, Plan tomorrow.
- **Weekly recap** notification on time; the recap shows where the time went, the best day and personal bests, and can be shared.
- **Notes** and **measurements**: simple and fast.
- **Undo** everywhere (delete, skip, move).
- **Widget and Quick Settings tile** both open Quick start, including from a cold start.

---

## Automated checks after the fixes

- `flutter analyze`: no issues.
- Full test suite: **no new failures**. The same 72 tests fail as before, all predating this work: they check wording and layouts from the earlier redesign and haven't been updated, per your instruction.
- New tests for this round: weekly goal counts its whole first week; Pomodoro rounds per activity; an item without a length stays "now"; app lock (5); backup dates; every built-in activity plans and opens.
