# DayMeter: a day in the life, six people

_Tested 2026-11-20/21 on the Android emulator (API 37), current build, fresh installs, the phone clock moved through the day. Screenshots: the scratchpad `ht/` folder of this session._

---

## 0. Round 2: everything above, fixed (Nov 20, evening)

_All bugs, all confusions and the suggestions below were worked through, then I used the app again as new people (fresh install as "Alex": a morning routine, water, a weight goal, studying in focus mode, groceries, an evening check-in)._

### The new daily loop: why people will open it every day

Research says people return for **something that grows, a streak they don't want to lose (with forgiveness), and a small reward right when they act**. Nagging doesn't work. DayMeter now has all three, kindly:

| What | How it works | Why it pulls people back |
|---|---|---|
| **Pip, your plant** (on Today and the home-screen widget) | Grows with every day something gets done: seed → sprout → seedling → young plant → bud → flowers → little tree → blossom tree. Droops a little ("thirsty") until you do one thing today, then perks up. Never shrinks. You can rename it. | Something alive that's *yours* (Finch's pet effect), and visible progress that never disappears |
| **Day streak with rest days** | Any one thing a day counts. Every 7 days in a row earns a rest day (up to 2); a missed day uses one instead of breaking the streak | Loss aversion without guilt (Duolingo's streak freeze cut churn of at-risk users by about 21%) |
| **The moment** | The first thing done each day: confetti, Pip perks up, "6 days in a row!", what it grew into, a rest day earned. Once a day | Reward at the moment of action (Hook model, peak-end rule) |
| **Finish screen** for timed sessions | The ring fills: "+27 min", today's total, 🔥 | Peak-end: sessions end on a high |
| **Evening check-in** | After 6 PM: how did today feel (5 faces) + one line. Two seconds | A closing ritual; fills the year view |
| **Year in pixels** + **month by month** | Every day of the year as a square: mood color, green when something got done, ice blue for a rest day. Months list days done and the usual mood | Something to look back on |
| **12 milestones** | First step, 3/7/30/100 days in a row, 10/50/100 good days, saved by a rest day, in bloom, goal getter, 7 check-ins | Long-term goals beyond the streak |
| **One kind evening nudge** | 7:30 PM, only if the streak needs today: "Pip is thirsty 🌱 One small thing keeps your 5-day streak going." Mentions a saved rest day as a way out | Brings people back without guilt; once a day at most |

### Bugs (section 5): all fixed

| # | Status | What changed | Checked on the emulator |
|---|---|---|---|
| B1 | Fixed | The summary says "Type the amount above" / "Type where you are now and your target" | ✔ ("Weight from 80 kg to 72 kg within 3 months") |
| B2 | Fixed | Items that repeat tomorrow show "On tomorrow already" instead of a Tomorrow button | Code (no repeating leftover in the test evening) |
| B3 | Fixed | Ranges are now "7 days / 30 days / 90 days / 12 months", so they don't clash with "Your week" | ✔ |
| B4 | Fixed | Today's timed items count toward "Plan completed" once their time is over | ✔ |
| B5 | Fixed | Week streaks show only from the second week | Code |
| B6 | Fixed | Past, open items say "Not done yet" (today) or "Not done" (earlier days), on Today and Plan | ✔ |
| B7 | Fixed | Quick start uses today's planned one if it's open | Code |
| B8 | Fixed | Finishing from focus mode: the item stays behind the sheet, then the finish screen | ✔ |
| B9 | Fixed | "Morning routine already repeats. Set a goal to count the days you keep it." | ✔ |
| B10 | Fixed | "0 of 20 pages today" | ✔ (earlier) |
| B11 | Fixed | "✓ Drink water, ✓ Stretch, ✓ Make bed" | ✔ |

### Confusions (section 6): all addressed

| Confusion | Now |
|---|---|
| Missing life areas | **Self-care & mornings**, **Home & chores**, **Faith & prayer** added. Picking them pre-ticks Morning routine + Skincare, Cleaning, Prayer & worship ✔ |
| Missing activities in onboarding | A **More…** tile searches all 200+ built-ins; what you pick joins the grid, ticked ✔ |
| First plan: only Weekdays / Every day | **Pick days** with M T W T F S S (solid when on) ✔ |
| No Back on the first-plan step | Back is there ✔ |
| Morning Next card says "in 11h 30m" | With the next timed thing 2+ hours away, Next suggests an Anytime one ✔ |
| Water makes a row per glass | **+1** on the row and "Add 1 · 3 so far" on the Next card; one row a day ✔ |
| No partial progress | Rows say "2 of 4 done" (steps), "Glasses: 3" (counters), "2 of 5 today" (the same thing several times a day) ✔ |
| Routine steps are heavy | **Tick boxes.** Set the steps once ("Add step…", Enter for the next), tick daily; they come back unticked tomorrow. Ticking the last one completes it. Writing steps alone doesn't count as done ✔ |
| Weight can't be a goal | **"My weight"** in New goal: a Body weight activity whose goal also follows the weights in Me → Body measurements; "where you are now" fills from your latest weight ✔ (goal created; measurement link in code) |
| Focus counts up only | A ring that fills to the planned length, with "12 min left of 30 min", then "30 min done. Keep going or finish." Code; Study had no length in the test |
| Scary Android dialogs | Our own heads-up first: "Your phone will ask to pin DayMeter… its standard wording…" ✔. The Accessibility disclosure now warns about "full control" wording too |
| Back twice from Accessibility | Opens DayMeter's own switch (Android 13+), so one Back returns |
| App picker | App icons; **Usual distractions** (games, social, video, plus a known list) first |
| Search ranking | Exact name, then starts-with, then a word in the name, then contains, group, and fields last ("read" → Reading first) |
| Notes are plain text | **Checklist** button on a note: tick boxes, Enter adds the next, "Clear ticked"; the text keeps ☐/☑ so nothing is lost ✔ |

### The 20 suggestions (section 8)

| # | Status |
|---|---|
| 1 Checklist routines | Done ✔ |
| 2 Counters | Done ✔ |
| 3 Weight goal | Done ✔ |
| 4 Several times a day | Done: in the + sheet, after a time, **Another time** adds more times the same day (each its own item and reminder), rows show "2 of 5 today" |
| 5 Morning card | Done (Next suggests an Anytime item) |
| 6 Celebrations | Done ✔ (confetti, once a day; perfect day and new best moments already existed) |
| 7 Finish screen | Done ✔ |
| 8 Focus ring + calm sounds | Done: ring and time left; **Sound**: Rain, Deep noise, White noise, generated on the phone (no files, nothing downloaded), playing only while the timer runs ✔ |
| 9 Badges | Done: 12 milestones in the garden ✔ |
| 10 Year in pixels | Done ✔ |
| 11 Monthly review | Done: month by month on the Year screen |
| 12 Starter packs | Covered by the life areas (each sets up its activities) |
| 13 Areas + More… | Done ✔ |
| 14 Pick days | Done ✔ |
| 15 "You usually…" | Already there (an empty day suggests what you usually do that weekday) |
| 16 Weekly insights | Already there (weekly recap) |
| 17 Prayer times | **Not done on purpose:** it needs your location, which goes against "private by design". "Another time" covers five prayers with reminders |
| 18 Share cards | Not now (removed on request); the weekly recap's share stays |
| 19 Accountability | Not now (removed on request) |
| 20 Checklist notes | Done ✔ |

### Found while re-testing, and fixed

- **Typing routine steps counted as "done" and fired the celebration.** Steps are now remembered as the routine's template, and nothing counts until something is ticked.
- **"Sprout grew into a sprout!"** The plant is now called **Pip**, and day 1 says "Pip sprouted!"
- **Water jumped from Anytime into the timeline after the first +1.** Open Anytime items now stay put.
- **"1 glasses".** Now "Glasses: 1".
- **The year view crashed on dates like Feb 30.** Fixed.
- **The finish screen said "<1 min today" after a 27-min session.** Fixed.
- **Day chips in Pick days were hard to tell apart.** Now solid purple when on.
- **Today didn't say "Not done yet".** Only the Plan tab did; now both do.
- **A plant that never stops swaying** is tiring (and kept the screen busy). It now sways a few times when it appears or changes.
- **Earned and locked milestones looked alike.** Earned ones are outlined.
- **Checklist notes counted "☐" as a word.** Fixed. The checklist/plain-text button is now clearer ("Aa").
- **Enter in "Add item…" closed the keyboard without adding the item.** It now adds it and stays ready for the next (notes and routine steps) ✔

### Still open (honest list)

- **Tests:** 631 pass, 42 fail (37 before this round). The new failures expect old wording or layout: "in 1h 0m", old goal copy, and the garden card pushing cards below the 800×600 test window. Per your rule I didn't edit tests; say the word and I'll update them.
- **Not seen on a real phone yet:** the home-screen widget's new streak line, the Accessibility details page (Android 13+), the evening nudge at 7:30 PM, and the sound through real speakers (the emulator confirmed it plays).
- **The emulator was very slow** during this round, so some checks above are code-level, as marked.

---

## 1. Short version

**DayMeter works.** Across six very different people, nothing crashed. Every main path worked end to end:
- planning, then reminder, then timer, then logging, then wrap-up, then the next morning
- focus mode and app blocking
- goals

The parts people will love:
- "Last time · Use last time"
- adding several things at once
- the evening "Wrap up today"
- the honest, private feel

**What will lose people** is not bugs. It's four everyday habits that the app models awkwardly:

1. **Routines.** A morning or skincare routine is a checklist you set up once and tick daily. In DayMeter each step is a heavy form card, re-entered every day.
2. **Counting.** Water ("+1 glass") becomes a new item each time, cluttering the day.
3. **Weight loss.** Your weight lives in Body measurements, but a "reach a number" goal can't use it. The goal screen literally says "like your weight down to 72 kg", and there's no way to pick your weight.
4. **Several times a day.** Prayer (5×), medicine (2×), water: one item a day with no partial progress shown.

Fix those four and the app covers what most people actually track. The details and a prioritized list are below.

---

## 2. Who I was, and what each person did

| Person | Why they'd install it | What I did as them |
|---|---|---|
| **Maya**, 26, office job | A calm, consistent morning and night routine | Onboarding, added Skincare + Cleaning + Morning routine at once, logged skincare, 7 PM meditation from the reminder notification, evening wrap-up, a 30-day skincare goal, next morning |
| **Rahul**, 31, wants to lose 8 kg | See progress, stay consistent at the gym | Gym plan, logged 80 kg, tried a "reach 72 kg" goal, water through the day |
| **Sara**, 22, wants to read more | Read 20 pages every night | Reading at 10 PM daily, "20 pages a day" goal, focus mode while reading, logged book + pages, "Use last time" |
| **Dev**, 19, student | Stop scrolling while studying | Turned on app blocking (Accessibility), blocked YouTube, started a session, YouTube bounced back |
| **Fatima**, 35 | Keep her five daily prayers | Added Salah, ticked Fajr and Dhuhr during the day |
| **A busy parent** | Remember chores, keep lists | Grocery note, large text (1.5×), Plan week view |

---

## 3. Why should someone use DayMeter? (the pitch)

Most apps do one of these: a to-do list, a habit tracker, a focus timer, a gym log, a journal. DayMeter is **one place for your day**: plan it, do it with a timer, log what actually happened, and see it add up.

| For… | The reason, in their words |
|---|---|
| Students (Dev) | "I plan 6 hours, it shows I really did 4h 12m, and it **locks my phone** while I study." |
| Routine people (Maya) | "My morning and night routine in one tap each, with a gentle reminder and a streak that keeps me honest." |
| Fitness (Rahul) | "My gym sets with **last time's weights** ready, plus my weight trend." |
| Readers (Sara) | "Pages per day, the book I'm on, and a calm screen while I read." |
| Faith (Fatima) | "Five prayers ticked through the day, privately." |
| Everyone | **Private by design**: no account, no ads, nothing leaves the phone. Works offline. Free core. |

**One-line store pitch:** _"Plan your day, focus, and see what you actually did. Private, no account."_

Being honest with yourself (planned vs actual) is the real differentiator. Lead with it everywhere: store page, onboarding, weekly recap.

---

## 4. What worked well (keep it)

- **Adding:** search, tick several (even across searches), shared Repeat, then **Add 3**. Fast and obvious.
- **Reminders:** they arrive on time with **Start / Snooze 10 min / Skip**, and Start opens the timer already running.
- **Logging:**
  - skincare as product chips plus a rating takes three taps
  - "How did it go?" right after Finish
  - **"Last time · Atomic Habits · 25 pages · Use last time"** is the single best repeat-use feature
- **Evening wrap-up:** at 10:30 PM, "Wrap up your day" with Tomorrow / Let it go / Plan tomorrow is a healthy ritual.
- **Focus mode:** pins the phone; Home can't escape it. **App blocking** really bounced YouTube back. The disclosure before Accessibility is honest and clear.
- **New goal flow:** "Skincare every day for 1 month. It counts on its own when you record Skincare." Clear.
- **Salah** as a built-in activity with Fajr…Isha chips; Skincare, Cleaning and Morning routine all exist and are found by search.
- **Large text (1.5×):** Today and Plan still lay out cleanly.
- **Notes:** the new Save button works.

---

## 5. Bugs and wrong wording

| # | Where | What happens | Why it matters | Fix |
|---|---|---|---|---|
| B1 | New goal, "An amount" / "Reach a number" | The summary says **"Pick an activity first."** after an activity was picked, until the numbers are typed | Makes people think the tap didn't work | Say "Enter the amount" / "Enter your current and target number" |
| B2 | Evening wrap-up | Chose **Tomorrow** for Cleaning (repeats daily) and the summary says **"2 done, 2 let go"** | Looks like the app ignored her choice | Say "Cleaning is on tomorrow already" and don't count it as let go. Or hide "Tomorrow" for items that already repeat tomorrow |
| B3 | Progress | Header "Your week · **Nov 16 – Nov 22**", stats below "**Nov 14 – Nov 20**" | Two different "weeks" side by side | Use the calendar week for both, or label the second "Last 7 days" |
| B4 | Progress | "**Plan completed 100%**" while Gym (7 PM) and a water entry are open or missed | Feels fake, so the number gets ignored | Count today's past-due items, or say "so far" |
| B5 | Progress, day 1 | "**1 week in a row · best 1**" after a single day | Reads like a bug | Show week streaks only from the second week |
| B6 | Plan tab | Past timed items not done still say **"Planned"** | Wrong state | "Missed" (or "Not done") once the time has passed |
| B7 | Quick start | Starting Reading while a Reading is planned today creates a **second Reading row** | Duplicates, double counting | If today has that activity open, start that one |
| B8 | "How did it go?" after Finish in focus mode | A blank page with only a Back arrow behind the sheet | Looks broken | Show Today (or the item) behind the sheet |
| B9 | "Make it a habit" card | "Repeat Meditation on the days you want…" for something already repeating every day | Nags about something done | Hide "Repeat it" when it repeats; just offer the goal |
| B10 | Goal card | "Today: 0 pages of 20 pages" | Wordy | "0 of 20 pages today" |
| B11 | Item summary (routine steps) | "Drink water Done: Yes" | Robotic | "✓ Drink water" |

---

## 6. What confused or slowed people down

**Onboarding**
- **Missing life areas.** There's no Self-care, Home & chores or Faith area, so Maya and Fatima don't see themselves.
- **Missing activities.** The 13-tile grid has no Skincare, Cleaning, Morning routine or Prayer, and no search or "More…". They'd assume the app can't do it, even though the catalog has all of these.
- **First plan:** repeat offers only Weekdays / Every day / Just today. Rahul wanted Mon, Wed, Fri.
- **No Back** on the first-plan step, only Skip.

**Today**
- **Morning focus.** At 7:30 AM the big **Next** card shows Meditation "in 11h 30m", while the thing to do now (Morning routine, Anytime) is buried lower down. With nothing timed soon, Next should suggest an Anytime item, or say "This morning: Morning routine · Skincare".
- **Water** makes a new row per glass and counts as a "task" in "1 of 3 done".
- **No partial progress.** Partially done things show nothing (Salah 2/5 prayers, a routine 2/4 steps).

**Routines (biggest friction)**
- **"Steps" are heavy.** Each step is a card with a "Step *" text box and Done Yes/No. Nothing carries over to tomorrow, so Maya would rebuild her routine every morning.

**Goals**
- **Weight can't be a goal.** "Reach a number: like your weight down to 72 kg", but Body measurements weight can't be chosen.

**Focus**
- **No time left.** The focus screen counts up only: "25 min left" or a ring is missing, even with a planned length.
- **Scary Android dialogs.**
  - Pinning says "Personal data may be accessible…".
  - Accessibility says "full control of your device".
  - The app should prepare people for both in one friendly line.
- **Coming back from Android settings** after enabling app blocking needs Back twice.
- **App picker** has no icons and no "common distractions" (Instagram, YouTube, games) at the top.

**Search**
- **Wrong order.** "read" shows Blood sugar (a field called "Reading") and Read textbook before **Reading**. Rank exact and starts-with name matches first, field matches last.

**Notes**
- **Plain text only.** No checkboxes for lists like groceries.

---

## 7. What the research says about apps people come back to (and how DayMeter does)

Habit apps that keep users don't rely on tricks. They make the next step easy, reward it in the moment, and make progress visible. These ideas are well studied:

| Idea | In short | DayMeter today | What to do |
|---|---|---|---|
| **Fogg Behavior Model** (B = Motivation × Ability × Prompt) | People act when it's easy and they're prompted at the right moment | Strong on prompts (reminders with Start). Ability is weak for routines and water | Make the common action one tap: tick a routine step, +1 glass |
| **Hook model** (Nir Eyal): trigger, action, reward, investment | Each use should end with something to look forward to and something saved | Triggers ✔, action ✔. Rewards are thin: goal met and perfect day get little or no moment | Small varied celebrations; "Use last time" is good investment |
| **Endowed progress** (Nunes & Drèze, 2006) | People finish more often when they start partly done (the pre-stamped loyalty card) | New goals start at 0 | Count today if it's already done; show "1 of 30 already" |
| **Goal-gradient effect** (Kivetz et al., 2006) | Effort speeds up near the finish | Goal bars exist, but no "almost there" moments | "3 days to go!" near the end; 50%/75% moments |
| **Loss aversion** (streaks) | People protect what they'd lose | Streaks and rest days ✔ | "Streak safe tonight? Do 1 thing" at 8 PM ✔. Add a visible "rest day available" token |
| **Zeigarnik effect** | Unfinished things stay on the mind | The wrap-up card uses this well | Partial progress on rows ("2/5 prayers") keeps the loop open |
| **Peak-end rule** | People remember the best moment and the end | Session end = a snackbar | A satisfying finish screen: ring fills, "+25 pages · 3-day streak" |
| **Implementation intentions** (Gollwitzer) | "When X, I'll do Y" plans roughly double follow-through | Times plus reminders ✔ | Onboarding: "When will you do it? After brushing teeth / at 7 PM" |
| **Identity** (Atomic Habits idea) | "I'm a reader", not "I read" | Not used | Recap line: "You read on 6 of 7 days. You're a reader." |

**Ethics:** keep it kind. No guilt notifications, no infinite feeds, no fake urgency. "Private, calm, honest" is part of the brand. The wrap-up card ("Tomorrow is a fresh start") already sets this tone well.

---

## 8. Free (non-AI) things to add, by impact

All of these run on the phone, with no server and no paid service.

### Highest impact (do first)
1. **Checklist routines.** Set steps once ("Cleanser → Toner → Serum → Moisturizer"); each day shows them as tick boxes. The row shows "2/4", and finishing all of them completes the item. This covers morning and night routines, skincare, cleaning and packing lists.
2. **Counter activities.** Water, glasses, pushups, cigarettes avoided: tap **+1** on the Today row or the home-screen widget, see "5/8 today", one row per day. A daily target can be the goal.
3. **Weight goal from Body measurements.** "Reach a number" can pick Weight (or Waist), using the measurements already logged and charted.
4. **Several times a day.** Times per day (e.g. 5×, at set times, each with its own reminder), with progress "3/5" on the row. This covers prayer, medicine and meals.
5. **Morning "Start your day" card.** Before noon, with nothing timed soon, show this morning's Anytime items as quick ticks.

### Delight and motivation
6. **Celebrations:** a small confetti or ring animation plus haptic when the day is fully done, a goal day is met, or a streak hits 7, 30 or 100 days. Keep them varied so they don't get boring.
7. **Finish screen** for timed sessions: the ring fills, "+45 min Study · 2h 15m today · 🔥 4".
8. **Focus screen:**
   - a progress ring with time left
   - optional calm sounds (rain, café, white noise) bundled as small free audio files
   - a "pages read?" quick box at the end
9. **Badges and milestones** (local only): First week, 30-day streak, 100 hours focused, 1,000 pages. Shown in Me.
10. **Year in pixels / heatmap** per activity (the calendar exists; make a shareable full-year view).
11. **Monthly review** like the weekly recap, with a shareable card. Word of mouth costs nothing.

### Easier to start
12. **Starter packs** in onboarding: "Morning person", "Student", "Weight loss", "Mindful", "Faith". Each sets up 3–4 activities, times and a goal in one tap.
13. **More onboarding areas** (Self-care, Home & chores, Faith) plus **search / More…** in the activity grid.
14. **Pick days** (Mon/Wed/Fri) in the first-plan step.

### Smarter (still no AI, just counting)
15. **"You usually…" suggestions:** "You usually read at 10 PM. Plan it?" from simple averages.
16. **Weekly insights** from plain stats: best day, most consistent habit, planned-vs-actual gap trend.
17. **Prayer times**, optional and offline: calculated on the phone from location with a free library (e.g. the `adhan` package), with reminders per prayer.

### Social without accounts
18. **Share a progress card** (streak, recap, goal completed) to WhatsApp or Instagram. Image only, nothing uploaded by the app.
19. **Accountability buddy:** "Send today's summary to a friend" as a share. No backend needed.

### Lists
20. **Checklist notes** (groceries, packing) with tick boxes.

---

## 9. Suggested order before and after launch

**Before launch (small, fast, removes the "looks broken" moments)**
- **Bugs:** B1, B2, B3, B5, B6, B7, B8, B9 (wording and logic, a few hours in total).
- **Onboarding:** add Self-care, Home & chores and Faith areas, and a "More…" search in the activity grid.
- **Search:** rank name matches first.
- **Morning:** let the Next card suggest an Anytime item in the morning.

**First update (1–2 weeks after launch)**
- Checklist routines (8.1), counters (8.2), weight goal from measurements (8.3), times per day (8.4).
- Celebrations, finish screen, focus ring (8.6–8.8).

**Later**
- Starter packs, badges, year in pixels, monthly review, prayer times, checklist notes.

---

## 10. Overall feeling

As a new user, DayMeter feels **calm, trustworthy and well made**. It respects you: no account, no ads, honest numbers, a gentle evening wrap-up. Some apps have plenty of features but tire people out; this one doesn't.

**Where it still frustrates:**
- The everyday shapes of habits (routines as checklists, counts, several-times-a-day, weight) are missing.
- A few numbers don't add up: 100% with misses, two different weeks, "1 week in a row" on day one.

Fix those, and add a little joy at the moments that matter (finishing a day, a streak, a goal). That turns "nice app" into "the app I open every morning".
