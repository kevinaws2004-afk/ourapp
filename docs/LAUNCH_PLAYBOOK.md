# Launch playbook

The parts of launching that aren't code: getting through Google's closed
test, getting the first users, and knowing whether it's working.
(PRODUCT_REVIEW §2.4 and §7.)

---

## 1. Closed test (required before production)

New **personal** Play Console accounts must run a closed test with
**at least 12 testers opted in for 14 days in a row** before they can apply
for production access. Check the current rule in Play Console when you sign
up — it has changed before.

**Week 0 (before paying the $25):** line up 15–20 testers, not 12 — some
won't opt in or will uninstall, and the count must stay ≥ 12 for all 14 days.

Where to find them:
- Friends and classmates with Android phones (best: they actually study).
- r/AndroidClosedTesting, r/TestersCommunity — people swap testing.
- Your college WhatsApp/Telegram groups: "I built a study planner, need
  testers for 2 weeks, it's free and private."

**Setup:**
1. Play Console → Testing → Closed testing → create track → add testers by
   email list (or a Google Group).
2. Upload the `.aab` (`flutter build appbundle --release`).
3. Send testers the opt-in link. They must **opt in and install**.
4. Ask each to open it a few times over the 14 days (Google looks at
   engagement) and send one piece of feedback (Me → Send feedback).
5. On day 15, apply for production access; answer the questions honestly
   (what you tested, what you changed from feedback).

Message to testers (copy):
> Hi! I built DayCraft, a study planner + focus timer. Google needs 12
> people to test it for 14 days before I can publish. Could you:
> 1) open this link and tap "Become a tester": <link>
> 2) install it from Play, and
> 3) use it a few times (plan a study session, start the timer).
> Everything stays on your phone, no account. Thank you 🙏

---

## 2. First users

The hook is **planned vs. actual**: "I planned 6 hours, actually studied
4h 12m." Everything below leads with it.

### Short videos (YouTube Shorts / Instagram Reels / TikTok)
15–30 s, vertical, screen recording + text on screen. Post 3–4 a week for
the first month; the algorithm needs volume.

1. **"I tracked my study hours for a week"** — weekly recap scrolling;
   text: "planned 12h… actually did 7h 51m 😬". End: app name.
2. **"Pomodoro that blocks Instagram"** — start a session, open Instagram,
   get bounced back. Text: "my phone won't let me procrastinate anymore".
3. **"Study with me: 2 rounds"** — timer + break screen sped up, lo-fi music.
4. **"My gym log takes 3 taps"** — "Use last time" → three sets ticked.
5. **"Exam week routine in one tap"** — Plan → Use a routine.

### Reddit (post as a builder story, not an ad; read each sub's rules)
- r/GetStudying, r/studytips: share the planned-vs-actual idea and what you
  learned from your own numbers; mention the app in the post body.
- r/productivity, r/selfimprovement: "I built a private planner that shows
  planned vs. actual hours — no account, no ads."
- r/androidapps: launch post with screenshots on release day.

Draft (r/GetStudying):
> **I measured how much I actually study vs. what I plan. The gap was
> 35%.**
> I kept planning 6-hour study days and feeling bad. So I built a small
> app that times what I actually do next to what I planned. First week:
> planned 12h, did 7h 51m. What helped most: 25-min rounds, blocking
> Instagram during them, and a weekly recap every Sunday.
> It's free, no account, data stays on your phone: <Play link>.
> Happy to hear what would make it more useful for exam prep.

### Ask for reviews
The 12+ testers are your first reviewers: on launch day, message them the
Play link and ask for an honest review. The first 10 reviews strongly shape
conversion. The app already asks happy users for a review after good
moments (it never asks after an error).

---

## 3. Know if it's working (check weekly)

| Number | Where | Aim |
|---|---|---|
| Installs | Play Console → Statistics | growing week over week |
| Day-7 retention | Play Console → Statistics → Retention | > 15 % |
| Crash-free users / ANRs | Play Console → Android vitals | > 99 % crash-free |
| Store listing conversion | Play Console → Store performance | > 25 % visitors install |
| Ratings | Play Console → Ratings | ≥ 4.3, reply to every review |

Monthly: run a **store listing experiment** (Play Console → Store
listing experiments) on the first screenshot or the short description.
Change one thing at a time.

---

## 4. Launch-day checklist

- [ ] Production access granted after the closed test
- [ ] Release `.aab` built from a clean tree, version bumped
- [ ] Listing: title, short + full description, 7 screenshots with
      captions, feature graphic, privacy policy URL
- [ ] Accessibility declaration approved
- [ ] Staged rollout 20 % → watch vitals 2 days → 100 %
- [ ] Testers messaged for reviews; Reddit + first video posted
