# Product Context (AI quick-load)

> Compressed context for AI agents. Canonical: [docs/product/product_spec.md](../../docs/product/product_spec.md), [requirements.md](../../docs/product/requirements.md), [user_flows.md](../../docs/product/user_flows.md), and the source spec `personal_activity_tracker_spec_updated.md`.

**What:** A customizable, local-first personal activity system. Users plan their day, log what they actually did, capture the data that matters per activity, and understand progress over time.

**Core loop:** Plan → Do → Log → Measure → Understand.

**Not:** a habit tracker, to-do app, gym app, or calendar. It is one generic engine expressing all of them as configuration.

**Glossary (use exactly):**
- **Activity Type**: template (name, icon, color, ordered fields, timer support, plannable). Not an event.
- **Activity Field**: a configurable input of an Activity Type (field type + config).
- **Activity Log**: what actually happened (times, notes, field values). Reality.
- **Plan**: what the user intends (date, optional time/duration, optional Activity Type, status). Intention.
- **Task**: a lightweight plan item with no detailed logging (e.g. "Buy milk"). It is a Plan with no Activity Type (ADR-018).
- **Plan → Record is one workflow (ADR-030):** tapping a planned activity opens its record form linked to the plan; saving completes the plan. One session = one record (sets are rows inside it). Only tasks have "Mark as done".
- **Measurement**: a value analyzable over time; also **Body Measurements** (weight, height, body fat, chest, waist, arms, legs), stored separately.
- **Focus Session**: full-screen timer whose active duration lands in a Log.
- **Repeating Group**: the structured field type (exercise list; sets = a nested Repeating Group of Numbers). "Set Table" from the spec is a composition, not a type (OQ-01).

**Navigation (ADR-028):** Today · Plan · Insights · Me, plus a global **Quick Record** action.
- **Plan:** the date-based planning system: pick any date, see its plans and what was recorded.
- **Today:** today's plan plus today's reality.
- **Me → Activities:** reusable Activity Type setup.

**Terminology:** users **record** activities (UI word); Activity Log is the internal name.

**V1 success scenario (§43):** plan tomorrow at night → see plan in morning → log Gym sets → 1h42m focus on Work → 43m Reading timer → log 48m Meeting → evening Today shows planned vs actual → Insights shows progress. This is the primary acceptance test.

**Out of V1:** accounts, cloud sync, social, leaderboards, multiplayer, AI, subscriptions, recommendations, web/desktop, cross-device sync, app blocking, wearables, automation. Also unspecified (so not V1): recurring plans, reminders, goals, streaks, widgets, import.

**Field types (OQ-01, resolved):** Text, Number (+ optional unit dimension), Boolean, Single Select, Multi Select, Date, Time, Duration, Rating, Repeating Group (implemented in Phase 3; Gym, Meeting and Cooking templates use it). Domain-specific types are compositions, never new types. Every log also has a built-in start, actual duration and notes.

**Open product questions:** in [requirements.md](../../docs/product/requirements.md#open-questions). OQ-01, 02, 04, 06, 07, 10 and 16 are resolved (ADRs 017–034). OQ-09 (fixed measurement types) and OQ-13 (no focus notification) follow their recommendations. OQ-14 (saved charts) was implemented ahead of confirmation. Do not resolve the others silently; follow the interim assumption or ask.
