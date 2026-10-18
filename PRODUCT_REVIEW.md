# Daylog — Product Review & Improvement List

_Reviewed: 2026-10-17 · Build: 1.0.0+1 · Reviewer lens: senior product developer + product designer_

---

## 1. Verdict

**The app is well built. As a product, it isn't ready to make money yet.**

| Area | Score | Notes |
|---|---|---|
| Engineering quality | 9/10 | Clean feature layers, generic field engine, drift + migrations, 56 test files, design tokens. Far above a typical first app. |
| Visual / UX craft | 8/10 | Consistent design system, 3 themes × light/dark, haptics, empty states, tablet rail. |
| Feature depth | 7/10 | Plans, logs, custom fields, focus, goals, measurements, notes, insights, custom charts. A lot. |
| Positioning / clarity | 3/10 | "Track anything" — nobody searches for that. Hard to explain in a 2-second store glance. |
| Monetization | 0/10 | No billing, no ads, no paywall. Earns ₹0 as is. |
| Retention hooks | 4/10 | Reminders exist. No widget, no weekly recap, no running-timer notification, goals are basic. |
| Data safety (trust) | 4/10 | Export exists, **restore does not**. A local-first app with no restore will get 1-star reviews. |

**Yes, there are improvements to make, and they matter more than adding new features.** In priority order:
1. Fix trust gaps (restore, visible backup).
2. Sharpen positioning to one niche.
3. Add a way to get paid.
4. Add retention hooks.

---

## 2. P0 — Must fix before launch

These will cause bad reviews or uninstalls in week one.

### 2.1 Backup restore (critical)
- **Problem:** `lib/features/settings/data/data_export.dart` exports every table to JSON, but there is no import. A user who changes phones or reinstalls loses everything, and the export file is useless to them.
- **Do:** Me → Data → "Restore from backup". Pick a file → validate `app == 'Daylog'`, `format`, `schemaVersion` → show a preview ("142 records, 12 activities, 3 goals, exported 12 Oct") → confirm "This replaces your current data" → restore in one transaction → restart the providers.
- **Also:** handle older `schemaVersion` (run the migration path) and reject newer ones with a clear message.

### 2.2 Make Android Auto Backup explicit
- **Problem:** `AndroidManifest.xml` doesn't set `android:allowBackup` / `dataExtractionRules`. Defaults may back up the DB through Google, but that's invisible, unreliable, and the privacy policy says "no cloud".
- **Do:** Decide deliberately. Recommended: keep Auto Backup on, add `data_extraction_rules.xml` that includes the database, and write it in the privacy policy ("Android may include your data in your Google device backup"). Then the privacy policy and Data safety answers stay truthful.

### 2.3 Running-timer notification
- **Problem:** A focus/timer session survives an app kill (it's read from SQLite), but nothing appears in the notification shade. Users leave the app and forget the timer, or think it stopped.
- **Do:** An ongoing notification showing "Reading · 23:14" with Pause / Finish actions. This is expected for any timer app.

### 2.4 Closed test requirement
- New personal Play Console accounts have had to run a **closed test with ≥12 testers for 14 continuous days** before production access. Check the current rule before paying, and recruit testers now.

### 2.5 Store-readiness checklist
- [ ] Host `store/privacy-policy.md` at a public URL (GitHub Pages works). Play requires a URL.
- [ ] Real phone screenshots (listing.md says they're still to do).
- [ ] Release signing set up (`android/key.properties`) and a **backup of the keystore** stored somewhere safe.
- [ ] `applicationId` is `com.ourapp.daylog`. It's permanent after publishing, so pick your final one now (e.g. `com.<yourname>.daylog`).
- [ ] Check the "Daylog" name for trademark/name clashes on Play. Several journaling apps use similar names.
- [ ] "Rate the app" and "Send feedback" (mailto) entries in Me → About. Currently missing.

---

## 3. Positioning — the most important change

**Problem:** the listing leads with "everything you do — gym, reading, deep work, walks…". Generic trackers lose to specialist apps in every category search.

**Recommendation: lead with one niche and keep the generic engine underneath.**

The app's genuinely unique combo is **plan → focus timer → planned vs. actual**. That fits best:

> **Study & deep-work planner** — "Plan your study day. Focus. See planned vs. actual hours."

Why this niche:
- Large, motivated audience (students, exam prep, remote workers) who already pay for focus apps.
- "Planned vs actual" is a differentiator most study timers don't have.
- Your existing features map directly: plans, focus, time insights, streak goals, subject = activity.

What to change:
| Where | Change |
|---|---|
| Store title | e.g. "Daylog: Study Planner & Focus" (A/B test against the current one) |
| Short description | "Plan study sessions, focus with a timer, and see planned vs. actual hours." |
| Screenshots | 1. Today plan · 2. Focus timer · 3. Planned vs actual chart · 4. Streak/goal · 5. "Also works for gym, reading…" · 6. Dark mode |
| Onboarding | Step 3 starter picks: preselect study/work-style activities (subjects) first, gym/reading second |
| Keywords | study planner, study timer, focus timer, pomodoro, deep work, time tracker, exam planner |

Keep gym, reading and custom activities. They become "it grows with you", not the headline.

---

## 4. Monetization

**Model: freemium with a one-time Pro unlock** (optional yearly plan later). No ads: they contradict "private by design", which is a real selling point.

- Package: `in_app_purchase` (Google Play Billing).
- Suggested price: ₹299–499 / $4–6 one-time. Consider launch pricing.
- Store the entitlement locally and re-verify against Play purchases on launch (works offline, fits local-first).

| Free | Pro |
|---|---|
| Today, Plan, Quick start, focus timer | Unlimited custom activities + field builder (free: ~3 custom) |
| Built-in activities | Custom chart builder ("Your own charts") |
| Insights: last 30 days | Insights: 3 months / year / all-time, all-time bests |
| 1–2 active goals | Unlimited goals + advanced goal types (see 5.6) |
| Manual export + restore | Scheduled automatic backup (Drive/local folder) |
| 1 theme (light/dark) | All themes, true black, app icon variants |
| — | Home-screen widgets (or give 1 widget free, more in Pro) |

**Paywall design rules:**
- Never block logging or viewing your own data. Only gate power features.
- Show the paywall at moments of intent: tapping "Add chart", picking "Year" range, creating a 4th custom activity. Not on launch.
- One clean screen: 3 benefit bullets, price, "Unlock forever", "Restore purchase".

---

## 5. Feature improvements by area

### 5.1 Onboarding (`onboarding_screen.dart`)
- [ ] Add one "what do you want to improve?" step (Study / Work / Fitness / Reading / Habits) that picks the starter activities **and** sets the Today layout emphasis. It personalizes the app in 2 seconds.
- [ ] End onboarding by **creating the first plan item for today** ("When do you want to start?"). Users who leave onboarding with an empty Today churn.
- [ ] Ask for notification permission after the first plan exists, with context ("Remind me at 18:00?"), not cold.

### 5.2 Today
- [ ] A one-line daily score at the top: "3 of 5 planned · 2h 10m focused". The planned vs actual story should be visible without opening Insights.
- [ ] End-of-day prompt (evening): "Wrap up today" → mark undone items done/skip/move to tomorrow in one sheet. Builds a nightly habit loop.
- [ ] "Plan tomorrow" CTA in the evening state. This matches the spec's §43 night flow.

### 5.3 Plan
- [ ] Templates / routines: "Weekday study routine", "Gym day". Apply a whole day in one tap. A strong Pro candidate.
- [ ] Copy yesterday's plan / copy last Monday.
- [ ] Drag to reschedule in the week view.

### 5.4 Focus
- [ ] Pomodoro mode (25/5 cycles, configurable), the #1 searched focus feature.
- [ ] Ongoing notification with controls (see 2.3).
- [ ] Optional Do Not Disturb toggle during focus (needs notification policy access).
- [ ] Session end summary: "45 min Physics · 3rd session today · 2h 15m total".
- [ ] Later (v2): app blocking. Needs Accessibility/UsageStats permissions and extra Play policy review, so don't add it to v1.

### 5.5 Insights
- [ ] **Weekly recap** screen + Sunday notification: "You planned 12h of study, did 9h 40m (81%). Best day: Tuesday." Uses existing data and is the strongest retention lever.
- [ ] Shareable recap card (image) for Instagram/WhatsApp stories. Free marketing, and it fits students well.
- [ ] Personal records feed: "New best: 60 kg × 8 Chest Press", "Longest focus session". Already computed in places (`insightAllTimeBest`, estimated 1RM). Surface them as moments.

### 5.6 Goals (challenges)
- **Problem:** the only goal type is "do X every day for N days" (`challenge.dart`). Real goals are often weekly or quantity-based.
- [ ] **Frequency goals:** "Gym 3× per week".
- [ ] **Quantity goals:** "Study 10 h per week", "Read 20 pages a day".
- [ ] Streak protection: 1 "freeze" per week so a missed day doesn't wipe a 40-day streak (a big source of quitting).

### 5.7 Data & trust
- [ ] Restore (2.1).
- [ ] CSV export per activity (for people who want spreadsheets). Good for reviews from power users.
- [ ] Optional scheduled auto-backup to a user-chosen folder / Google Drive (Pro).
- [ ] Optional app lock (biometric) for a "private" app. Cheap to add, fits the brand.

### 5.8 Platform integrations (post-launch)
- [ ] **Home-screen widgets:** today's plan + "start focus" button; streak widget. Top retention driver for planner apps.
- [ ] Health Connect: read steps/weight into measurements so they're filled in without manual logging.
- [ ] Quick Settings tile: "Start focus".

### 5.9 Localization
- Only `app_en.arb` exists. The l10n setup is already done, so adding languages is cheap.
- [x] Decision (2026-10-18): English only for launch. (Was: add Hindi, then Spanish / Portuguese.)

---

## 6. Quality & operations

- [ ] **Crash reporting.** You'll be blind to crashes after launch. Options that respect privacy: Play Console vitals (free, built-in; check it weekly) or an opt-in crash reporter. If you add any SDK, update the Data safety form.
- [ ] **In-app review prompt** (`in_app_review`) after a positive moment (goal completed, 7-day streak). Never after an error.
- [ ] **Release checklist:** bump `version` in `pubspec.yaml` each upload; build an `.aab` with `flutter build appbundle --release`; test the release build on a real device (not just debug).
- [ ] **Migration safety:** before every release that changes the schema, test upgrading from the previously published version with real data (`drift_schemas/` is already in place; use it).
- [ ] **Accessibility pass:** TalkBack labels on icon-only buttons, text scale 200%, contrast on Rose/Papaya themes.

---

## 7. Growth & distribution

Features don't bring users; distribution does.

- [ ] 15–30 s screen recordings: "planned 6h, actually studied 4h 12m" → post on YouTube Shorts / Instagram Reels / TikTok. The planned vs actual reveal is the hook.
- [ ] Reddit: r/GetStudying, r/productivity, r/androidapps, r/selfimprovement. Post as a builder story, not an ad.
- [ ] Ask the 12+ closed testers for honest reviews at launch (first reviews shape conversion).
- [ ] Review Play Console → Store listing experiments monthly (title, icon, first screenshot).
- [ ] Track 3 numbers weekly: installs, day-7 retention, Pro conversion %. Benchmarks to aim for: D7 > 15%, conversion 1–3% of active users.

---

## 8. Roadmap

### Before launch (v1.0)
1. Backup restore + explicit Android backup rules
2. Running-timer notification
3. Positioning rewrite: listing, screenshots, onboarding preselection
4. Rate / Feedback links, hosted privacy policy, final `applicationId`
5. Pro unlock + paywall at intent moments
6. Closed test (14 days) → production

### v1.1 (first month)
7. Weekly recap screen + notification + share card
8. Home-screen widget
9. Pomodoro mode
10. Frequency & quantity goals, streak freeze

### v1.2+
11. Plan templates / routines
12. Scheduled auto-backup to Drive
13. ~~Hindi + 1–2 more languages~~ (English only for now)
14. Health Connect, Quick Settings tile, app lock
15. Focus-mode app blocking (with Play policy review)

---

## 9. Honest expectation

- Launching costs $25 once, and the app is good enough to publish. **Do it.**
- Without positioning + monetization + marketing, expect a handful of installs and ₹0.
- With a clear niche, a fair one-time Pro unlock, and steady short-video posting, a realistic outcome is **pocket money to a modest side income** in the first 6–12 months. The upside comes from retention (widgets, weekly recap, goals) and word of mouth (share cards).

---

## 10. Implementation status: sections 5 & 6 (2026-10-17)

| Item | Status |
|---|---|
| 5.1 Onboarding: focus-area step, first plan for today, contextual notification permission | ✅ Done |
| 5.2 Today: daily score, evening wrap-up, Plan tomorrow | ✅ Already existed (hero ring, evening review card, From yesterday) |
| 5.3 Plan: routines (save / use), copy a day, drag to another day in week view | ✅ Done |
| 5.4 Focus: Pomodoro, notification Pause/Resume/Finish, Do Not Disturb, session summary | ✅ Done |
| 5.4 Focus: app blocking | ⏭ Left for v2 as planned (needs extra Play policy review) |
| 5.5 Insights: weekly recap screen, Sunday notification, share card, personal bests | ✅ Done |
| 5.6 Goals: weekly goals, amount goals (time or a number), rest days | ✅ Done (database v11) |
| 5.7 Data: restore, CSV export, daily automatic backups, app lock | ✅ Done. Google Drive *direct* upload is not built (needs a Google Cloud project/OAuth); backups travel with Android's device backup instead |
| 5.8 Home-screen widget, Quick Settings tile, Health Connect import | ✅ Done (weight, height, body fat) |
| 5.9 Hindi translation | ❌ Removed (owner's decision): the app ships in English only |
| 6 Crash reporting (on-phone problem log + share), in-app review, Rate, Send feedback | ✅ Done |
| 6 Release checklist + `tool/release_check.sh` | ✅ Done (`docs/RELEASE_CHECKLIST.md`) |
| 6 Migration safety: v10→v11 test, backup→restore tests | ✅ Done |
| 6 Accessibility | ⚠️ Partial: tabs scale with large text; contrast test fails on most themes because the brand colors are below 4.5:1 (left as designed) |
