# DayCraft: product review, what's left

_Reviewed 2026-10-17 · updated 2026-10-19_

Everything in the original review that could be built is now built. That covers:

- restore and Android backup rules
- the running-timer notification
- study-first positioning and a rewritten listing
- onboarding
- routines and copying a day
- Pomodoro
- app blocking
- the weekly recap and personal bests
- weekly, amount and rest-day goals
- CSV export, automatic backups and app lock
- the widget, Quick Settings tile and Health Connect
- crash log, review prompt, Rate and Feedback
- the release checklist
- the accessibility and contrast pass
- screenshots
- the upload-key script

Those items have been removed. The list below is only what's still open.

---

## 1. Your actions before the first upload

- [ ] **Name check:** there's an iOS app "DayCraft: ToDo List & Tasks" (a planner with time tracking), and "DayCraft" is also a stationery trademark. Search Play and decide on the name before the first upload, because changing it later costs reviews and search ranking.
- [ ] **Upload key:** run `bash tool/make_upload_key.sh`, then back up the `.jks` file and its password somewhere off this computer.
- [ ] **Privacy policy URL:** add your support email to `docs/privacy-policy.md`, then turn on GitHub Pages (folder `/docs`) and put the URL in Play Console.
- [ ] **Closed test:** new personal accounts need at least 12 testers opted in for 14 days in a row. Line up 15–20 people. The steps and a tester message are in `docs/LAUNCH_PLAYBOOK.md`.
- [ ] **Accessibility declaration** for app blocking in Play Console. The text is in `store/listing.md`.
- [ ] **Real-phone check:** test the release build on your phone (cold start, reminders, widget).

---

## 2. Monetization (left out on purpose for now)

**Model: freemium with a one-time Pro unlock.** No ads: they contradict "private by design".

- Package: `in_app_purchase` (Google Play Billing).
- Suggested price: ₹299–499 / $4–6 one-time, with launch pricing.
- Store the entitlement locally and re-verify against Play purchases on launch (works offline).

| Free | Pro |
|---|---|
| Today, Plan, Quick start, focus timer, Pomodoro | Unlimited custom activities + field builder (free: ~3 custom) |
| Built-in activities | Custom chart builder |
| Insights: last 30 days | Insights: 3 months / year / all-time |
| 1–2 active goals | Unlimited goals |
| Manual export + restore | Automatic backups |
| Light/dark | All themes |

**Paywall rules:** never block logging or viewing your own data. Show it at moments of intent (tapping "Add chart", picking "Year", creating a 4th custom activity), never on launch. Use one clean screen: 3 benefits, the price, "Unlock forever" and "Restore purchase".

---

## 3. Not built yet

- [ ] **Google Drive backup upload.** It needs a Google Cloud project and OAuth. For now, backups travel with Android's device backup.
- [ ] **Notes linked to a day or an activity** (from user testing; needs a database change).

---

## 4. After launch (your actions)

Distribution matters more than features from here on. The details are in `docs/LAUNCH_PLAYBOOK.md`.

- [ ] Short videos (YouTube Shorts / Reels / TikTok) built around "planned 6h, actually studied 4h 12m". Post 3–4 a week in the first month.
- [ ] Reddit builder-story posts: r/GetStudying, r/studytips, r/productivity, r/androidapps.
- [ ] Ask the closed testers for honest reviews on launch day.
- [ ] Each week, check installs, day-7 retention (aim for more than 15%), crash-free users (more than 99%) and ratings.
- [ ] Each month, run a store listing experiment (first screenshot or short description).
- [ ] Before every release that changes the database: test upgrading from the published version with real data.

## 5. Honest expectation

Without monetization and steady posting, expect a handful of installs and ₹0. With a clear niche (study planner + focus), a fair one-time Pro unlock and regular short videos, a realistic first 6–12 months is pocket money up to a modest side income. Most of the upside comes from retention (widget, weekly recap, goals) and word of mouth (share cards).
