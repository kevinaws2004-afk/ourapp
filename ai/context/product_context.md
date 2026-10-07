# Product Context (AI quick-load)

> Compressed context for AI agents. Canonical: [docs/product/product_spec.md](../../docs/product/product_spec.md), [requirements.md](../../docs/product/requirements.md), [user_flows.md](../../docs/product/user_flows.md), and the source spec `personal_activity_tracker_spec_updated.md`.

**What:** A customizable, local-first personal activity system. Users plan their day, log what they actually did, capture the data that matters per activity, and understand progress over time.

**Core loop:** Plan → Do → Log → Measure → Understand.

**Not:** a habit tracker, to-do app, gym app, or calendar. It is one generic engine expressing all of them as configuration.

**Glossary (use exactly):**
- **Activity Type** (UI: activity): a reusable definition (name, icon, color, ordered fields, timer support, plannable). Not an event. Built-in ones and the user's own are the same thing (ADR-042); never call them templates.
- **Activity Field**: a configurable input of an Activity Type (field type + config).
- **Activity Log**: what actually happened (times, notes, field values). Reality.
- **Plan**: what the user intends (date, optional time/duration, optional Activity Type, status). Intention.
- **Task**: a lightweight plan item with no detailed logging (e.g. "Buy milk"). It is a Plan with no Activity Type (ADR-018). *New items always come from an activity (ADR-042); plans without one remain only in older data.*
- **An item on your day is where you log (ADR-035):** opening a plan opens the item; what you log saves as you type, and the first thing logged makes it done. Leave and come back to add more. Older items without an activity get one when first logged into. "Mark done" logs the planned time. One session = one record (sets are rows inside it).
- **Measurement**: a value analyzable over time; also **Body Measurements** (weight, height, body fat, chest, waist, arms, legs), stored separately.
- **Focus Session**: full-screen timer whose active duration lands in a Log.
- **Repeating Group**: the structured field type (exercise list; sets = a nested Repeating Group of Numbers). "Set Table" from the spec is a composition, not a type (OQ-01).

**Planner (ADR-036, ADR-039):** Plan is Week | Month, and a tapped day opens like Today; plans can repeat (weekdays, every N weeks; occurrences are ordinary items); any item offers Plan next.
**Insights (ADR-037, ADR-043):** a home with the period at a glance, a consistency calendar, where the time went, plan vs reality, activities with streaks (and those not done this period); each activity opens an automatic progress page built from its fields by type (numbers by their "show as" total/average/latest and "better is" higher/lower/neither, yes/no as a share, times of day, durations, choices as how often each; per exercise best weight, estimated 1-rep max, volume, reps). Only records with something in them count.
**Activities (ADR-042), the product rule:** one concept, the activity: what you put on a day and log inside. Built-in activities = convenient starting points (by life area, searchable; common activities across cultures, never "every activity"); your own = unlimited flexibility (**Make your own** is first-class: name it, choose what to record, saved and reused); generic fields = the user decides what matters; Activity Log = what actually happened. One list (Yours, then built-in by category) in Me → Activities and Browse activities. Every item added to a day comes from an activity.
**Navigation (ADR-028):** Today · Plan · Insights · Me. Add to a day from the quick add (suggestions while typing, **Start now**, one time sheet, Recent chips; ADR-039); no global record action (ADR-035). Activity names are unique. Logging helpers (ADR-041): Use last time, row memory, quick choices, rest timer, long-press quick actions, built-in activities with a form preview. Logging into an item makes it in progress; Mark done / the row check / finishing the timer makes it done (ADR-040).
- **Plan:** the date-based planning system: pick any date, see its plans and what was recorded.
- **Today:** today's plan plus today's reality.
- **Me → Activities:** reusable Activity Type setup.

**Terminology:** users **record** activities (UI word); Activity Log is the internal name.

**V1 success scenario (§43):** plan tomorrow at night → see plan in morning → log Gym sets → 1h42m focus on Work → 43m Reading timer → log 48m Meeting → evening Today shows planned vs actual → Insights shows progress. This is the primary acceptance test.

**Out of V1:** accounts, cloud sync, social, leaderboards, multiplayer, AI, subscriptions, recommendations, web/desktop, cross-device sync, app blocking, wearables, automation. Also unspecified (so not V1): recurring plans, reminders, goals, streaks, widgets, import.

**Field types (OQ-01, resolved):** Text, Number (+ optional unit dimension), Boolean, Single Select, Multi Select, Date, Time, Duration, Rating, Repeating Group (implemented in Phase 3; the built-in Gym, Meeting and Cooking activities use it). Domain-specific types are compositions, never new types. Every log also has a built-in start, actual duration and notes.

**Open product questions:** in [requirements.md](../../docs/product/requirements.md#open-questions). OQ-01, 02, 04, 06, 07, 10 and 16 are resolved (ADRs 017–034). OQ-09 (fixed measurement types) and OQ-13 (no focus notification) follow their recommendations. OQ-14 (saved charts) was implemented ahead of confirmation. Do not resolve the others silently; follow the interim assumption or ask.
