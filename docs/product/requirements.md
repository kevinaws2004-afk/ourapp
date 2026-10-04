# Requirements

> Traceable, numbered requirements derived from the spec ([`personal_activity_tracker_spec_updated.md`](../../personal_activity_tracker_spec_updated.md)). Each requirement cites its spec section.
> **Priority:** `V1` = must ship in the first version. `V1?` = V1 status ambiguous; see Open Questions. `Later` = explicitly future.
> Requirement IDs are stable. Never renumber; deprecate instead.

---

## 1. Functional requirements

### 1.1 Activity Types & Builder

Activity Types are created and configured under **Me → Activities** (ADR-028).

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-AT-01 | User can create an Activity Type with name, icon, color/appearance and optional description. | V1 | §3.1, §11, §27 |
| FR-AT-02 | User can add fields to an Activity Type from the field type catalog (FR-FT-*). | V1 | §9, §11 |
| FR-AT-03 | User can reorder fields; order determines form rendering order. | V1 | §11 |
| FR-AT-04 | User can mark a field as required. | V1 | §10 |
| FR-AT-05 | User can configure field-type-specific options (unit, dropdown options, rating max, etc.). | V1 | §10 |
| FR-AT-06 | Activity Type declares which fields are measurable (available to analytics). | V1 | §3.1 |
| FR-AT-07 | Activity Type declares whether it supports a timer / Focus Mode. | V1 | §3.1, §16 |
| FR-AT-08 | Activity Type declares whether it can be planned. | V1 | §3.1 |
| FR-AT-09 | User can edit an Activity Type after logs exist without corrupting historical logs. | V1 | implied by §3.1, §5 |
| FR-AT-10 | User can remove (archive) an Activity Type; its historical logs remain in history and analytics. | V1 | implied |
| FR-AT-11 | Creating a new Activity Type requires no schema migration and no developer code. | V1 | §5, §31, §32, §46 |
| FR-AT-12 | First-run onboarding can create starter Activity Types based on what the user wants to track. | V1 | §33.4 |

### 1.2 Field types (§9; resolved by OQ-01)

V1 ships **ten generic field types**. Domain-specific types from §9 (Weight, Distance, Count, Percentage, Timer, Set Table, Checklist, Person…) are **composed** from these, never added as their own types (OQ-01, ADR-019/020/021).

| ID | Field type | Covers spec types | Priority |
|---|---|---|---|
| FR-FT-01 | Text (single-line or multi-line presentation) | Text, Long Text, Person (as text) | V1 |
| FR-FT-02 | Number (optional unit dimension: mass, distance, volume, temperature, energy) | Number, Weight, Distance, Count, Percentage, Calories, Steps | V1 |
| FR-FT-03 | Boolean | Boolean | V1 |
| FR-FT-04 | Single Select | Dropdown | V1 |
| FR-FT-05 | Multi Select | Multi-person (as options), tags-like lists | V1 |
| FR-FT-06 | Date | Date | V1 |
| FR-FT-07 | Time | Time (Date + Time = Date + Time fields, or the log's own start) | V1 |
| FR-FT-08 | Duration | Duration (additional durations; the activity's own elapsed time is built into every log, ADR-021) | V1 |
| FR-FT-09 | Rating | Rating | V1 |
| FR-FT-10 | Repeating Group | Set Table, Checklist, Exercise list (implemented in Phase 3; relational storage, ADR-027) | V1 |
| — | Timer | Not a field type: `supports_timer` on the Activity Type plus the log's built-in duration | V1 |

Each type has defined value semantics, validation, storage mapping, rendering and serialization ([data_architecture.md §4](../architecture/data_architecture.md#4-field-type-catalog)).

### 1.3 Activity Logs

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-LG-01 | User can create a Log for any Activity Type; the form is rendered generically from field definitions. | V1 | §5, §31, §46 |
| FR-LG-02 | A Log records start time, optional end time and notes. | V1 | §27 |
| FR-LG-03 | Required fields are validated before saving. | V1 | §10 |
| FR-LG-04 | User can edit and delete a Log. | V1 | implied |
| FR-LG-05 | An activity can be recorded from Today, from a Plan item, from an activity's page (Me → Activities), from Focus, or via Quick Record. | V1 | §36, ADR-028 |
| FR-LG-06 | **Quick Record:** a global action on every tab records an unplanned activity in at most two taps (pick activity → record form). | V1 | §37, ADR-028 |
| FR-LG-07 | Gym: user can add exercises, add sets per exercise (weight × reps), and record workout duration. | V1 | §12, §41 |
| FR-LG-08 | Logs for archived Activity Types or removed fields remain viewable. | V1 | implied |

### 1.4 Plans & Tasks

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-PL-01 | User can create a Plan for today, tomorrow or a future date. | V1 | §19 |
| FR-PL-02 | A Plan has a title, optional description, optional scheduled start/end. | V1 | §28 |
| FR-PL-03 | A Plan can optionally link to an Activity Type. | V1 | §19 |
| FR-PL-04 | A Plan has a status. Stored: planned, skipped, cancelled, and completed (tasks only). Activity-plan completion and in-progress are **derived** from linked logs/focus sessions (ADR-018). | V1 | §28 |
| FR-PL-05 | Starting/completing a linked Plan lets the user create the corresponding Log. Tapping a planned activity opens its record form, linked to the plan (ADR-030). | V1 | §19, §36, ADR-030 |
| FR-PL-06 | Plan and Log are preserved independently to allow planned-vs-actual comparison. | V1 | §20, §43 |
| FR-PL-07 | Lightweight Tasks can be created and completed without detailed logging. | V1 | §21, §41 |
| FR-PL-08 | Plans can be reordered (drag and drop). | V1? | §6 lists drag & drop in stack |
| FR-PL-09 | The Plan tab is date-based: a calendar/date selector navigates to any past, present or future date and shows that date's plans. | V1 | ADR-028 |
| FR-PL-10 | For a selected date, the user sees what was planned next to what was actually recorded, including past dates (review). | V1 | §20, ADR-028 |

### 1.5 Focus Mode & Timer

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-FO-01 | Any timer-capable Activity Type can start a full-screen focus timer. | V1 | §16, §17 |
| FR-FO-02 | Start, pause, resume, finish. | V1 | §17 |
| FR-FO-03 | On finish, duration is automatically stored in the Activity Log. | V1 | §16, §17 |
| FR-FO-04 | Optional notes after the session. | V1 | §17 |
| FR-FO-05 | Session-complete feedback ("Reading session complete, 42 minutes"). | V1 | §16 |
| FR-FO-06 | The timer must survive app backgrounding and process death (timestamp-based, not tick-based). | V1 | implied by §43 (1h 42m session) |
| FR-FO-07 | Blocking other apps. | Later | §17, §44 |

### 1.6 Today / Timeline

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-TD-01 | Today shows today's plan. | V1 | §35 |
| FR-TD-02 | Today shows a chronological timeline of today's Logs with time, activity, duration and a summary line. | V1 | §18 |
| FR-TD-03 | User can start activities from Today. | V1 | §35, §36 |
| FR-TD-04 | Today shows planned vs actual (per item, with durations). | V1 | §35, §43 |
| FR-TD-05 | Greeting/context adapts to time of day ("Good morning"). | V1 | §35 |

### 1.7 Insights / Analytics

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-AN-01 | Analytics operate generically on (time, value, unit) series; no activity-specific chart code. | V1 | §24, §26 |
| FR-AN-02 | Time series line graphs (e.g. reading minutes, body weight, exercise weight). | V1 | §25, §41 |
| FR-AN-03 | Totals (e.g. total reading time this week). | V1 | §25, §41 |
| FR-AN-04 | Counts (workouts, sessions, completed tasks). | V1 | §25, §41 |
| FR-AN-05 | Averages. | V1 (ADR-034) | §25 lists; §41 omits |
| FR-AN-06 | Comparisons (this week vs last week, this month vs last month). | V1 (ADR-034) | §25 lists; §41 omits |
| FR-AN-07 | Chart configuration: activity, field, metric, time range, aggregation, chart type. | V1 | §26 |
| FR-AN-08 | Gym-derived metrics: max weight, max reps, total sets, volume, exercise frequency, progression, PRs. | V1 (ADR-034: generic best/volume/count over any activity) | §13 vs §44 |
| FR-AN-09 | Planned vs actual analytics. | V1 (ADR-034) | §20, §43 vs §44 |
| FR-AN-10 | Basic history list. | V1 | §41 |

### 1.8 Body Measurements

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-BM-01 | User can record weight and height with date. | V1 | §23, §29, §41 |
| FR-BM-02 | User can record basic body measurements (body fat %, chest, waist, arms, legs). | V1 | §23, §41 |
| FR-BM-03 | Body measurements are viewable as time-series graphs through the same analytics engine. | V1 | §23, §24 |

### 1.9 Search & History

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-SH-01 | User can search logs by text (e.g. "Chest Press", "Fooled by Randomness"). | V1? | §38 (not in §41) |
| FR-SH-02 | Filter history by Activity and Date. | V1 | §38, §41 |
| FR-SH-03 | Filter by Measurement, Tag, Person, Project. | V1? | §38; see OQ-08 |

### 1.10 Data ownership

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-DA-01 | Export data to JSON and/or CSV saved on device. | V1? | §40 ("should eventually support") |
| FR-DA-02 | No account required; no data leaves the device for core functionality. | V1 | §39 |

### 1.11 Onboarding & Experience

| ID | Requirement | Priority | Spec |
|---|---|---|---|
| FR-UX-01 | Short first-run onboarding with a narrative: understand the user → one meaningful question at a time → personalize → show what they'll get → begin. | V1 | §33.4, §41 |
| FR-UX-02 | Onboarding must not force configuring the whole system. | V1 | §33.4 |
| FR-UX-03 | Light and dark themes. | V1 | §33.2, §41 |
| FR-UX-04 | Empty, loading, error and success states for every data-bearing screen. | V1 | §41 |
| FR-UX-05 | Meaningful micro-interactions and smooth navigation. | V1 | §33.6, §41 |
| FR-UX-06 | Responsive phone and tablet layouts (no stretched phone UI). | V1 | §33.7, §41 |
| FR-UX-07 | Outcome-oriented copy where appropriate. | V1 | §33.3 |

## 2. Non-functional requirements

| ID | Requirement | Spec |
|---|---|---|
| NFR-01 | **Offline:** 100% of V1 functionality works with no network. | §6, §7 |
| NFR-02 | **Zero backend cost:** no servers, no cloud services. | §7 |
| NFR-03 | **Privacy:** no analytics/telemetry/crash reporting that sends data off-device unless explicitly approved later (see OQ-12). | §39 |
| NFR-04 | **Scale:** remain fast with thousands of logs and years of data. Targets in [performance.md](../development/performance.md). | §8 |
| NFR-05 | **Data integrity:** multi-row writes (log + values, type + fields, focus finish) are transactional. | §8 |
| NFR-06 | **Extensibility:** new activity types are data; new *field types* are code but must not require schema changes. | §5, §46 |
| NFR-07 | **Platform:** Android first; no Android-only assumptions in domain/data layers; iOS later. | §33.7, setup §5 |
| NFR-08 | **Accessibility:** WCAG AA contrast, 48dp touch targets, text scaling, screen reader semantics. | §33.5, setup §8 |
| NFR-09 | **Future sync readiness:** stable IDs, timestamps, soft deletion. | setup §5, §11 |
| NFR-10 | **Visual consistency:** all visual values come from the centralized design system. | §33.2 |

## 3. Out of scope for V1

User accounts · cloud sync · social network · public profiles · leaderboards · multiplayer · AI assistant · AI coaching · subscriptions · complex recommendation engine · web app · desktop app · cross-device sync · advanced app blocking · wearable integrations · complex automation engine (§42). Also not specified anywhere and therefore not in V1 unless added: **recurring plans, reminders/notifications, goals, streaks, home-screen widgets, import.**

---

## Open Questions

Product ambiguities found in the spec. **Each needs an owner decision.** Until decided, implementation follows the *interim assumption*. Architecture-level pending decisions are tracked separately in [architecture_decisions.md](../decisions/architecture_decisions.md#pending-decisions).

| ID | Question | Conflict / source | Interim assumption |
|---|---|---|---|
| OQ-01 | ~~Which field types ship in V1?~~ | **Resolved 2026-10-04 (owner):** Text, Number, Boolean, Single Select, Multi Select, Date, Time, Duration, Rating, Repeating Group. Domain-specific types are compositions (Number + Unit, Repeating Group + scalars). See §1.2. | — |
| OQ-02 | ~~Are Personal Records and Planned-vs-Actual analytics V1?~~ **Resolved 2026-10-04 (owner): yes**, plus volume, averages and comparisons (ADR-034). §13/§20/§43 imply yes; §44 lists both as future "Advanced Analytics". | §13, §43 vs §44 | Planned-vs-actual **on Today** is V1 (required by §43). PRs and planned-vs-actual *trend charts* are V1? (deferred unless approved). |
| OQ-03 | Is Export (JSON/CSV) part of V1? "V1 should eventually support" but not in §41. | §40 vs §41 | Design for it; implement after the core success flow. |
| OQ-04 | ~~What is a Task in the data model?~~ | **Resolved by ADR-018:** a Task is a Plan with `activity_type_id` NULL; its title is its identity. | — |
| OQ-05 | Can a Task/Plan exist without a date ("inbox")? | §19 lists dates only | No: every plan has a planned date. |
| OQ-06 | ~~How is a Plan linked to the Log that fulfils it?~~ | **Resolved by ADR-018:** `activity_logs.plan_id` (implemented in Phase 4). Activity-plan completion is derived from linked logs. | — |
| OQ-07 | ~~How is "planned duration" expressed when a plan has no times?~~ | §20, §28; ADR-018 | **Resolved 2026-10-04 (owner):** `plans.planned_duration_ms`, exclusive with `planned_end_at` (ADR-018). Implemented in Phase 4. |
| OQ-08 | History filters by Tag, Person, Project: no Tag or Project concept exists anywhere else; Person is only a field type. | §38 | V1 filters: Activity, Date, free-text. Person filter = match on Person/Multi-person field values. Tags/Projects deferred until defined. |
| OQ-09 | Which body measurement types exist, and can users add custom ones? | §23, §29 | Fixed V1 set: weight, height, body_fat, chest, waist, arms, legs. Custom types deferred. |
| OQ-10 | ~~Log notes/duration vs "Notes"/"Duration" fields~~ | **Resolved by ADR-021:** the activity's actual elapsed duration is `activity_logs.duration_ms`, and notes are a built-in log property. Duration fields are only for additional durations. Templates don't add Notes/Duration fields for these. | — |
| OQ-11 | Can more than one Focus Session run at once? | §16, §17 | No: one active session at a time. |
| OQ-12 | Is any crash reporting/diagnostics allowed (would send data off-device)? | §39 | No: local logging only. |
| OQ-13 | Is an ongoing notification for a running focus timer desired? (Requires notification permission on Android 13+.) | §17 | Not in V1 unless approved; timer correctness does not depend on it. |
| OQ-14 | Are Insights chart configurations saved by the user (a "dashboard"), or chosen ad hoc? | §26 | Recommendation was ad hoc with no persistence. **Phase 6 implemented saved charts (`insight_charts`, ADR-034) and awaits owner confirmation.** |
| OQ-15 | Exercise identity: is "Chest Press" free text (autocomplete) or a managed entity? Analytics group by it. | §12, §13 | Free text with autocomplete from history; analytics group by normalized (trimmed, case-folded) text. |
| OQ-16 | ~~Units: kg/lb, km/mi?~~ | **Resolved by ADR-020:** values keep the user's unit (`unit_code`) plus a write-time `normalized_value` in the dimension's canonical unit. The unit registry is in code. | — |
| OQ-17 | §43 shows "Walk 31m" under Actual but the narrative never logs the walk. | §43 | Treated as an editorial omission: the walk is logged retroactively (manual log). Confirms manual/retroactive logging is required. |
| OQ-18 | Do starter templates (Gym, Reading, …) ship pre-installed, or only via onboarding choice? | §33.4 | Offered during onboarding and from "Start from a template" in Me → Activities; nothing forced. |
| OQ-19 | "Lunch" appears on the Today timeline (§18) with no duration: is it a log, a plan, or a task? | §18 | A Log of a user-created type with no duration fields (instant log). |
| OQ-20 | Flowfy reference screenshots are referenced but not present in the repository. | setup §8 | Design docs rely on the principles written in §33.1. Add screenshots to `docs/ui/reference/` if visual review is wanted (for principles only). |
