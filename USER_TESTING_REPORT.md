# DayCraft: first-time user test, 10 days

_Tested 2026-10-18 · fixes 2026-10-19 · Android emulator (API 37) · fresh install, no data · screenshots in `build/e2e/ut/`, raw diary in `build/e2e/ut/notes.md`_

## How this was tested

I installed the app fresh and used it as one realistic person for 10 simulated days. I moved the phone's clock through each day and did what that person would do, not just tap every button.

**Persona: "Aarav", a college student.** He wants to study every weekday morning, go to the gym Mon/Wed/Fri at 6 PM, and read 30 min every night. He isn't technical and has never used a planner app. On day 2 he sets two goals: "Gym 3× a week" and "Read every day".

The 19 bugs found during the test and the ~35 "felt odd" items are all fixed, so they've been removed from this report. Only what's still open is listed below.

---

## Still open

| Area | What felt odd | What I expected |
|---|---|---|
| Weekly recap | "12/12 Plans kept" though 2 Readings were skipped: skips drop out of the count instead of counting as not kept | Count skipped plans as not kept |
| Timer | When the planned length is reached, the timer turns "over" but nothing alerts you | A chime or vibration when the planned length ends |
| Onboarding · first plan | Only Right now / In an hour / This evening / Anytime; no custom time | Offer "Pick a time…" |
| Notes | Notes can't be linked to a day or an activity | A short journal line per day, or a note attached to an activity (needs a database change) |

## Tests to update

13 tests fail only because they still expect the old UI. They don't point to bugs. Per your instruction they haven't been edited.

- "Recent" label
- Progress opening on Month
- A chip adding in one tap
- The old full-screen timer button
- No "How long?" sheet after Done
- Folded target rows after "Use"

Another 15 tests were already failing before this round (listed in `build/e2e/fail6.txt`).

---

## What worked well (keep it)

- **"Last time · Use last time"** for study, reading and per exercise: the single best feature for repeat use.
- **Exercise name suggestions** from a real catalog, with my own names first.
- **Sets**: a completed set collapses to "40 kg × 10 ✓"; the summary "Push · Bench press 40 kg × 10 (×3)" reads well.
- **Evening review**: "Reading streak at risk · Do it now", Tomorrow / Let it go, Plan tomorrow.
- **Weekly recap** notification arrives on time; the recap shows where the time went, the best day and personal bests, and can be shared.
- **Notes** and **measurements**: simple and fast.
- **Undo** everywhere (delete, skip, move).
- **Widget and Quick Settings tile** both open Quick start, including from a cold start.
