# DayCraft: Google Play listing

> Positioning (PRODUCT_REVIEW §3): lead with **study & deep-work planning**
> (plan → focus timer → planned vs. actual), keep "it grows with you" (gym,
> reading, anything) as the second story.
>
> ⚠️ Name check (2026-10-18): an iOS app "DayCraft: ToDo List & Tasks"
> (planner + time tracking) exists, and "DayCraft" is a registered trademark
> for paper planners/diaries. Check Play for a clash before publishing and
> consider a distinct name (e.g. "Studycraft", "Focusday", "PlanStudy"). If
> you rename, change `android:label`, `appBrandName` and this file.

## App name (30 chars max)
DayCraft: Study Planner & Focus

## Short description (80 chars max)
Plan study sessions, focus with a timer, and see planned vs. actual hours.

## Full description (4000 chars max)
DayCraft is a calm, private study planner and focus timer. Plan your day, focus on one thing at a time, and see how many hours you actually put in — not just how many you planned.

PLAN YOUR STUDY DAY
• Today shows what's next, what's done and how much time you've focused.
• Plan sessions at a time or "anytime", and repeat them on the days you choose.
• Save a day as a routine ("Exam week", "Gym day") and use it again in one tap.
• Copy yesterday, or drag a session to another day in the week view.

FOCUS, FOR REAL
• Start a timer on anything in one tap. It keeps running even if you close the app.
• Pomodoro rounds (25/5 or your own lengths) for study and deep work.
• Block distracting apps while you focus — opening one brings you back.
• Do Not Disturb while a session runs, if you want it.
• Pause, resume or finish right from the notification.

PLANNED VS. ACTUAL
• See the hours you planned next to the hours you really did.
• A weekly recap every Sunday: where your time went, your best day and your personal bests. Share it as an image.
• Day reports, a consistency calendar and charts that build themselves.

GOALS AND STREAKS
• Every day ("30 days of study"), a few times a week ("Gym 3× a week"), or an amount ("2 hours of study a day").
• Rest days, so one missed day doesn't wipe your streak.

IT GROWS WITH YOU
• Track the rest of your life the same way: gym sets and reps, reading pages, runs, water, sleep, mood — over 100 ready-made activities.
• "Use last time" fills in what you did before, so logging takes seconds.
• Build your own activity with exactly the fields you need.
• Body measurements, notes, and a home-screen widget.

PRIVATE BY DESIGN
• No account. No sign-in. No ads. No tracking. Everything stays on your phone.
• Daily automatic backups on the phone, full export, CSV spreadsheets and restore.
• Optional app lock with your fingerprint, face or screen lock.

15 hand-tuned themes, each in light and dark.

DayCraft: plan it, focus, see it add up.

## Category
Education (primary choice for the study niche) — or Productivity

## Tags / keywords
study planner, study timer, focus timer, pomodoro, deep work, exam planner, time tracker, study tracker, app blocker, habit tracker

## Screenshots (in order) — `store/screenshots/`
1. `01-today.png` — "Plan your study day" (Today with Study / Gym / Reading)
2. `02-focus.png` — "Focus with Pomodoro" (running Study timer with rounds)
3. `03-recap.png` — "See planned vs. actual" (weekly recap)
4. `04-goals.png` — "Keep your streak" (goals)
5. `05-gym.png` — "It grows with you" (gym sets)
6. `06-block.png` — "Block distractions" (focus settings)
7. `07-dark.png` — dark mode

Caption each in the Play Console with the quoted line.

## Data safety form (answers)
- Does the app collect or share user data? **No.** All data is stored on the device only.
- Is data encrypted in transit? Not applicable (no data leaves the device).
- Can users request data deletion? Users delete their data in the app or by uninstalling.

## Accessibility API declaration (Play Console → App content → Sensitive permissions)
DayCraft uses the AccessibilityService API for one opt-in feature: focus-mode app blocking. While a focus session the user started is running, the service notices which app comes to the foreground (TYPE_WINDOW_STATE_CHANGED, package name only, `canRetrieveWindowContent="false"`); if it is an app the user chose to block, DayCraft returns to the front. It does not read screen content, collect data or send anything off the device. A prominent in-app disclosure is shown and must be accepted before the user is taken to Accessibility settings. Video for the declaration: record Me → Focus → Block apps → disclosure → enable → start a session → open a blocked app.

## Content rating
Questionnaire: no violence, no user-generated content shared with others, no ads → expected rating: Everyone / PEGI 3.

## Graphics in this folder
- `icon-512.png` — hi-res icon (512×512)
- `feature-graphic-1024x500.png` — feature graphic
- `screenshots/` — phone screenshots (from the emulator; retake on a real phone if you can)
