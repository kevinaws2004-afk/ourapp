# Product Specification

> **Canonical source:** [`personal_activity_tracker_spec_updated.md`](../../personal_activity_tracker_spec_updated.md) (referred to below as "the spec", sections cited as §N).
> This document is the engineering-facing condensation of the spec. If the two ever disagree, the spec wins and this file must be corrected.
> Numbered requirements live in [requirements.md](requirements.md). Flows live in [user_flows.md](user_flows.md).

---

## 1. One-sentence definition

> A customizable local-first personal activity system that lets users plan their day, record what they actually do, capture the data that matters for each activity, and understand their progress over time. (§47)

Working title: **Personal Activity & Life Tracking App**. No final product name has been decided. The temporary in-app display name is "OurApp". `daylog` is only an internal technical codename and "Daylight" only the provisional design direction; neither is the product name (ADR-010).

## 2. Core loop

```text
Plan → Do → Log → Measure → Understand
```

The product is **not** a habit tracker, to-do list, gym tracker or calendar (§1). It is one generic system that can express all of those as configuration.

## 3. Product philosophy

1. **Customizable, not prescriptive (§2).** Users decide what information matters for each activity. The app provides reusable field types; users combine them.
2. **Configuration-driven (§46).** Gym, Reading, Work, Meetings, Body Weight and every future category are different expressions of the same underlying system. Adding an activity never requires developer code or a schema migration (§31, §32).
3. **Plan and reality are both preserved (§20).** Intention (Plan) and reality (Log) are separate records, so the user can see the difference.
4. **Lightweight when it should be (§21).** Not everything deserves a detailed log. "Buy milk" must not require configuring fields.
5. **Local-first and private (§6, §39).** All data stays on the device. No account. Future cloud features are opt-in.
6. **Experience is the product (§33, §46A).** The underlying functionality can be simple; the experience must feel intentional, coherent and distinctly valuable.

## 4. Core concepts (glossary)

Use these terms exactly in code, UI discussions and docs.

| Term | Definition | Spec |
|---|---|---|
| **Activity Type** | A reusable definition (UI: an activity, e.g. Gym, Reading); built-in ones and the user's own are the same thing (ADR-042). Defines name, icon, appearance, ordered fields, which fields are measurable, timer support, plannability. **Not an event.** | §3.1 |
| **Activity Field** (Field) | One configurable input belonging to an Activity Type: name, field type, position, required, config. | §10 |
| **Field Type** | The kind of input/value a field holds (Text, Number, Duration, Set Table…). A fixed catalog provided by the app. | §9 |
| **Activity Log** (Log) | Internal/domain name for what actually happened: an Activity Type instance with times and field values. Represents **reality**. In the UI this is a **record**: users *record* an activity (ADR-028). | §3.3 |
| **Record** | The user-facing action for capturing what actually happened (creates an Activity Log). Done inside an item on a day: open it and log into it, saved as you type; something unplanned is added with "Start now" (ADR-035, ADR-039). | ADR-028, ADR-035 |
| **Field Value** (Log Value) | The value a Log holds for one Field. | §4, §27 |
| **Plan** | An intended activity or task for a specific date (past, present or future). May optionally link to an Activity Type. Represents **intention**. | §3.2, §19, ADR-028 |
| **Task** | A lightweight plan item with no detailed logging (e.g. "Pay bill"). | §21 |
| **Measurement** | A tracked value that can be analyzed over time. Used in two senses: (a) any measurable value derived from logs; (b) **Body Measurements**, a conceptually separate record type (weight, height, body fat…). | §3.4, §23 |
| **Challenge** | "Complete this activity every day for X days" on one Activity Type. Recording the activity counts the day. Has **progress** (total successful days), a **current streak** and a **best streak**; a missed day resets only the current streak. Daily only; not a goal system. | ADR-044 |
| **Focus Session / Focus Mode** | A full-screen timer for any timer-capable activity whose duration is automatically stored in the resulting Log. | §16, §17 |
| **Repeating Group** | A structured field whose value is a list of items, each with its own sub-values (e.g. a list of exercises). | §9, §12 |
| **Set Table** | A structured field whose value is a table of rows (sets) with numeric columns (e.g. weight × reps). | §9, §12 |
| **Timeline** | The chronological view of a day's Logs (and Plans), primarily on Today. | §18, §35 |
| **Insights** | The analytics area: graphs, totals, counts, averages, comparisons. | §24–§26, §34 |

## 5. Fundamental model

```text
Activity Type ──defines──▶ Fields ──used when creating──▶ Activity Log ──contains──▶ Field Values ──analyzed by──▶ Analytics
                                         ▲
Plan ──(optionally linked to Activity Type; completing it can create)──┘

Body Measurements ─────────────────────────────────────────────────────▶ Analytics (same time-series principles)
```

The analytics engine does not know what an activity *means*. It only understands **Time + Measurement + Unit** (§24).

## 6. Product areas (primary navigation, ADR-028)

**Today | Plan | Challenges | Insights | Me** (Challenges added by ADR-044). This is the owner's decision (ADR-028), and it supersedes the spec's suggested Today/Plan/Track/Insights/Me (§34).

| Tab | Purpose |
|---|---|
| **Today** | The specialized view of the current date: today's plan, today's reality (what was recorded) and their planned-vs-actual relationship (§35). |
| **Plan** | The date-based planning system. A calendar/date selector reaches any past, present or future date and shows that date's plans next to what was actually recorded. Flow: select a date → its plans → select a planned activity → do it → record what happened. Plans include tasks. |
| **Insights** | Progress, measurements and patterns. |
| **Me** | **Activities** (one list of activities: yours and built-in ones; builder), body measurements, preferences, settings, export. |

Cross-cutting: **logging into items** (anything unplanned is added to the day with "Start now" and opened; §37, ADR-035), **Focus Mode** (§16), **Search & History** (§38), **Onboarding** (§33.4).

## 7. Reference activities

These are *examples of configuration*, not hardcoded features. They are the canonical test cases for the generic engine.

Every log already has a built-in start time, actual **duration** (ADR-021) and **notes**, so the spec's "Duration"/"Notes" fields for an activity's own time aren't separate fields. The other fields are compositions of the ten V1 field types (OQ-01).

| Activity | Spec fields → V1 composition | Status |
|---|---|---|
| Gym (§12) | Exercises → Repeating Group { Exercise: Text, Sets → Repeating Group { Weight: Number (mass), Reps: Number } } | Phase 3 (Repeating Group) |
| Reading (§14) | Book: Text · Pages: Number · Rating: Rating; the timer fills the log's duration | Phase 2 built-in |
| Meeting (§22) | People: Multi Select or Text · Topics/Decisions: Text (multi-line) · Action items: Repeating Group { Item: Text, Done: Boolean } | Phase 3 |
| Walking (§2.1) | Distance: Number (distance) · Steps: Number · Calories: Number (energy) · Location: Text | Phase 2 built-in |
| Focused Work | Project: Text; timer | Phase 2 built-in |
| Language Learning (§31) | Language: Single Select · Words learned: Number · Lesson: Text · Difficulty: Rating | Phase 2 built-in |
| Cooking (§32) | Recipe: Text · Servings: Number · Calories: Number (energy) · Rating · Ingredients: Repeating Group { Item, Done } | Phase 3 |

## 8. V1 scope summary

In V1 (§41): local SQLite; Activity Types; custom fields; Activity Logs; Plans; basic Tasks; Daily Timeline; Timer and Focus sessions; number/duration/text/rating/checklist/set-table fields; Gym (exercises, sets, reps, weight, workout duration); Reading (book, duration, pages, notes); basic history, line graphs, totals, counts, time-based measurements; body weight, height and basic body measurements; premium distinct visual design, centralized design system, light/dark themes (owner change, ADR-045: three selectable light themes, dark later), smooth navigation, short onboarding, complete state coverage, micro-interactions, responsive phone/tablet layouts, fast logging.

Explicitly **out of V1** (§42): user accounts, cloud sync, social network, public profiles, leaderboards, multiplayer, AI assistant/coaching, subscriptions, complex recommendations, web app, desktop app, cross-device sync, advanced app blocking, wearable integrations, complex automation engine.

Items whose V1 status is ambiguous are listed in [requirements.md §Open Questions](requirements.md#open-questions).

## 9. V1 success criterion (§43)

A user can:

1. **Night:** create tomorrow's plan: Gym, Work, Read, Meeting, Walk.
2. **Morning:** see the plan.
3. **Gym:** start Gym; log Chest Press 50×12, 55×10, 60×8.
4. **Work:** start Focus Mode; work 1h 42m.
5. **Reading:** start the Reading timer; read 43m.
6. **Meeting:** log 48m with topics, decisions, action items.
7. **Night:** open Today and see planned vs actual (Gym 1h 04m, Work 1h 42m, Reading 43m, Meeting 48m, Walk 31m).
8. Open Insights and see progress over time.

"If this works smoothly, the core product is real." This scenario is the **primary end-to-end acceptance test** (see [testing_strategy.md](../development/testing_strategy.md)).

## 10. Future expansion (not V1; architecture must not block it)

From §44: cloud account/backup/multi-device sync; AI summaries and natural-language logging; integrations (calendar, health data, wearables, email); advanced focus (app/website blocking, scheduled sessions, DND); advanced analytics (correlations, goals, trends, consistency, time allocation). See [future_sync.md](../architecture/future_sync.md).
