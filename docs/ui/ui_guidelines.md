# UI & UX Guidelines

> How screens, components and interactions behave. Visual values come from [design_system.md](design_system.md); layout adaptation from [responsive_design.md](responsive_design.md); flows from [user_flows.md](../product/user_flows.md).

---

## 1. Experience principles

1. **One product, one world.** Every screen (onboarding, Today, a field editor, an empty chart) must look like the same product: same surfaces, type voice, motion and Plan-vs-Reality grammar.
2. **Calm by default.** Generous whitespace, one primary action per view, muted chrome, color reserved for meaning (activity identity, primary action, status).
3. **Progressive disclosure.** Show the essential first; advanced options appear on demand (expanders, "More options", sheets). Never show every field config option at once.
4. **Speed is a feature.** Common actions take ≤ 2 taps (log, start focus, complete task). Defaults are smart (now, last-used values, frequent activities first).
5. **Personal, not prescriptive.** The UI reflects the user's own activities, colors and words. No judgment about skipped plans or missed days.
6. **Data is the hero on data screens.** Decoration recedes on Insights/History; illustration lives in onboarding, empty and completion states.
7. **Composition over custom one-offs.** Build screens from shared components; if a new pattern is needed, add it to `shared/` and document it here.

## 2. Navigation & screen anatomy

- **Primary navigation:** Today · Plan · Insights · Me (ADR-028; supersedes §34). Bottom navigation bar on compact, navigation rail on medium/expanded. Selected item: filled icon + label + soft brand pill. Unselected: regular icon + label. Labels are always visible.
- **Adding to the day** (ADR-035, ADR-039): the quick add on Today and on a planner day. Once something is typed it offers **Start now** (today only: adds the item at the current time and opens it) and **Set a time** (one time sheet). There is no floating action button, no rail action and no Quick Record sheet.
- **Screen header:** large display-type title that collapses to a compact title on scroll (large-title pattern). Contextual actions as at most 1–2 icon buttons in the header.
- **Sheets over pages** for short tasks (quick log, add plan, pick value, field config). Full screens for long tasks (log editor with structured data, builder, focus).
- **Back behavior:** system back/gesture always works. Items save as you type (ADR-035), so leaving never loses input and never asks.

## 3. Component inventory (`lib/shared/`)

Each component consumes tokens only and implements all states from [design_system.md §11](design_system.md#11-component-states).

**Status (Phase 4):**
- **Implemented:**
  - `AppButton`: four variants and the large 52dp size. The medium size and loading state aren't built yet.
  - `ActivityBadge`, `SectionHeader`.
  - State views: `AsyncValueView`, `DelayedLoadingPlaceholder` (blank for ~150 ms, then quiet skeleton bars), `AppEmptyState`, `AppErrorState`.
  - Snackbar helpers: `showUndoSnackBar`, `showMessageSnackBar`.
  - `CenteredScrollBody`.
  - The adaptive shell: Material `NavigationBar`/`NavigationRail` themed from tokens.
  - The generic form renderer, `FieldEditorShell` and one editor per field type (`features/activity_logs/presentation/form/`).
  - `DurationInput`.
- **All other rows are planned.**
- **Snackbar rule (learned in Phase 2):** don't show a confirmation snackbar when the next screen already confirms the action (e.g. installing a template opens the new activity). Floating snackbars persist across navigation and can cover the next screen's primary button.

| Component | Notes |
|---|---|
| `QuickRecordSheet` | Implemented (`features/activity_logs/presentation/quick_record_sheet.dart`) |
| `AppButton` | Variants: primary (pill, brand), secondary (tonal soft), tertiary (text), destructive. Sizes: large (52dp), medium (44dp visual / 48 hit). Loading state keeps width. |
| `AppIconButton` | 48dp hit area, tooltip + semantics required |
| `AppSurface` / `AppGroup` | Grouped content on `surfaceBase` with hairline; replaces ad-hoc cards |
| `AppListItem` | Leading (activity badge/icon), title, subtitle, trailing (value/chevron/control) |
| `ActivityBadge` | Icon on soft color shape; sizes 24/32/48 |
| `AppChip` | Filter, choice and suggestion variants; pill radius |
| `AppSegmentedControl` | Range selection (Week/Month/6M), day selection |
| `AppTextField` | Label above, helper/error below, sunken fill, `radius.sm` |
| `AppNumberField` / `AppStepper` | Numeric entry with unit suffix, large tap targets, keyboard type numeric |
| `DurationPicker` | h/m(/s) wheel or segmented entry; tabular numerals |
| `DateTimePickers` | Themed wrappers; never raw default dialogs without theming |
| `AppSheet` | Top radius `lg`, drag handle, title row, safe-area aware, keyboard-aware |
| `AppDialog` | Only for irreversible confirmations |
| `AppSnackbar` | Undo/feedback; floating, `radius.md`, above nav |
| `EmptyState`, `LoadingState`, `ErrorState`, `SuccessState` | See §5 |
| `SectionHeader` | `labelMedium`/`titleLarge`, optional action |
| `DurationText` / `NumericText` | Tabular formatting, unit styling (unit in secondary color, smaller) |
| `PlanItemTile` | Implemented (`features/plans/presentation/widgets/`). Planned = outline in the activity color; done = filled soft color with ✓, "Done · 45 min of 1 h" and a summary of what was logged; skipped/cancelled = faint outline + label. **Tap = open the item** to log into it (ADR-035); a task also has a check control; a **More** button opens the plan options. No Start button |
| `DayRecordTile` | Implemented (`features/activity_logs/presentation/`). A done item made without a plan, in the same filled "done" grammar: badge, activity, time, duration, summary |
| `AppChart` | Implemented (`shared/widgets/charts/`, ADR-033): fl_chart line/bar styled only with tokens; gaps for empty buckets; grouped bars for planned vs actual; value axis in round steps (`ChartAxis`: 1/2/2.5/5 × 10ⁿ, whole steps for counts, minutes and whole units, so labels never repeat; A22) |
| `FocusBanner` | Implemented (`features/focus/presentation/`): the live "Reading · 23:14 · Return" item on Today |
| `TimelineItem` | Planned: a time-column timeline combining both tile kinds (later polish) |
| `DayArc` | Signature motif (Today header, focus, onboarding) |
| `Chart` primitives | `LineChart`, `BarChart`, `SparkLine`, `StatTile` (number + delta + sparkline) |
| `ReorderableFieldList` | Drag handle, haptic, lift animation |
| `RepeatingGroupEditor` | Any Repeating Group (exercises, sets, checklists). Item cards; compact number rows for all-number groups ("Set" = nested group, OQ-01). Not gym-specific |

Do not use raw Material `Card`, `ElevatedButton`, `AlertDialog` etc. in features when a shared component exists.

## 4. Core screens

### 4.1 Today (most important screen, §18, §35)
- **Header:** time-of-day greeting in display type ("Good morning, …" if a name is known; otherwise without name) + date + Day Arc showing the day so far with logged segments.
- **Morning state:** today's items as outline (planned) items with time, activity badge and title. **Tapping an item opens it to log into it** (ADR-035); tasks also have a check control.
- **During the day:** items with something logged become filled (done) items with a summary; a running timer appears as a live banner at the top ("Reading · 23:14 · Return") and its item shows "In progress".
- **Evening state:** the same list reads as planned vs what happened: done items with actual duration vs planned, unplanned items in time order, open items still tappable to log, with Skip / Move to tomorrow in their More options. Concise day summary line without scores or grades.
- **Long-press a row** for quick actions (mark done / not done, move to tomorrow, duplicate, skip, delete; each with Undo, B7).
- Items show: the check, start time, activity, duration, and a summary with the numbers (e.g. "Bench press 60 kg × 8 (×2), 65 kg × 6", "Fooled by Randomness"; generic `formatGroupSummary`, A18). Untimed items sit under an **Anytime** heading below the timed ones (A19). Adding something from quick add shows no pop-up (A9).
- **Implemented (ADR-035, ADR-039):** greeting by local hour, date, then the shared `DayItems` (also used by the planner's day screen): quick add, day summary ("3 done · 2 h 10 min"), and one list of items (shared `PlannedList`: plans and unplanned records in time order, then untimed plans), with task checks, ✓, planned-vs-actual outcomes and summaries. Empty Today: a one-line invitation under the quick add. Skip, Move to tomorrow and Delete are in each item's More options. **Not built yet:** the Day Arc header and a distinct evening layout.

### 4.2 Plan (date-based; implemented)
- **Week | Month** switch at the top (ADR-036, ADR-039); the tab opens on Week. There is no separate Day view: it duplicated Today. Week: a period header (‹ Oct 4–10 › and Today), then each day's heading (today in brand color; tap → that day) with "+" (full plan sheet) and its items, or "Nothing planned". Month: ‹ October 2026 ›, narrow weekday labels, a 7-column grid of day cells (`AppSizes.dayCell`) with up to four activity-colored dots (`AppSizes.monthDot`); tap → that day.
- **Day screen** (`/plan/day`, ADR-039): the selected date shown exactly like Today (shared `DayItems`), under a heading with a relative label (Today / Tomorrow / Yesterday), previous/next day arrows and a calendar button for any date. One "+" only: the quick add's.
- **Items:** that date's plans and anything done without a plan, as one list (ADR-035). Timed items are ordered by time (a plan logged without a planned time sorts by when it was logged), and untimed ones follow in manual order (drag to reorder). **Tapping an item opens it** (§4.4). Its **More** button opens the plan sheet: edit details, Mark as done (tasks), Skip, Reopen, Move to tomorrow, Delete (with Undo; deletes what was logged too).
- **Quick add** (ADR-039): type → enter or "+" adds it and keeps the keyboard open. While typing, up to four suggestions appear: your matching activities ("Your activity") and ready-made templates no activity has the name of yet ("Ready-made · fields"); tapping one fills the name. Typing an activity's exact name selects its chip, so "Gym" becomes a Gym item with its fields; a template's exact name installs it on add; any other name shows **Make “{name}” your own** ("New activity · choose what to log"), which opens the builder with the name and adds the saved activity (ADR-042). Empty, the field has **Templates** and **Make your own** below it. The plan sheet ("+" in Week) offers the same two as chips; "Just a task" appears only on older plans without an activity. Once something is typed: **Start now** (today) and **Set a time**, which opens one sheet (suggested starts: the next half hours today, typical times on other days, plus "Other time…"; then No end / 15 min / 30 min / 1 h / 2 h / "Until…"; lengths that would pass midnight are disabled). Below, **Recent**: activity chips, most used in the last four weeks first (up to eight).
- Repeating items show a repeat icon before More. The plan sheet offers Repeat… (weekday chips, every N weeks, until) and Stop repeating after this.
- Flow: select date → items → open one → log what happens.

### 4.3 Me → Activities (implemented)
The reusable Activity Types, managed under Me rather than in a primary tab (ADR-028).
- The list shows badge, name, field count and a **Record** shortcut, with entry points for "New activity" and "Start from a template".
- An activity's page shows a **Record** button, edit/delete, and recent records.
- This area is for configuration. Daily logging happens in items on Today and Plan. **Record** on an activity adds an item for now and opens it.

### 4.4 Item (where you log; ADR-035, replaces the log editor)
- App bar: activity badge + title, a quiet "Saving…" / "Saved" status, and ⋯ (plan options) or Delete for a record without a plan.
- Top: planned time; ✓ Done with "Mark as not done" once marked done; **Start timer**, which becomes the live timer (DM Mono) with Pause/Resume, Finish and full screen while it runs (finishing marks the item done, ADR-040).
- The activity's fields, rendered by the shared form renderer in configured order with consistent field shells. Structured fields (Repeating Group, incl. sets as a nested group) expand inline; "Add {item}" sits at the end of each group; a new all-number row starts from the previous row; text fields can offer previously recorded values as suggestions.
- **Last time (B1, ADR-041):** an empty item of an activity with history shows a brand-soft card "Last time · Fri, Oct 2", the summary and **Use last time**.
- An item with no fields shows one line ("What do you want to keep track of?…") and chips: **How it went**, **An amount**, **Sets & reps**, **More…** (B3). **Add to log** (after the fields, once there are some) opens "What do you want to log?": **Quick** (How it went, An amount, Sets & reps, Checklist) and a collapsed **More kinds of detail** with every field type in plain words ("Words", "An amount", "A list"…) → the field sheet to name it; its rare settings sit under **Advanced** (B4). A list's ⋯ menu ("{Item} list options") offers "Add a detail to each {item}" (A13), so "Add {item}" stands alone. A named row with nothing else filled shows "Last time: … · **Use**" (B2). Lists of numbers show **Rest** next to "Add {item}": a bar pinned to the bottom of the item counts down ("Rest 01:30", −15 s / +15 s, Stop; "Rest over" with a light buzz) (B5). Adding a row scrolls it into view above the keyboard (A14). A pencil in the app bar opens the builder for the item's activity.
- Notes, then **When** (start date/time) and duration (labeled **Hours** / **Minutes** boxes; a finished timer fills them, A11).
- Bottom: **Mark done** (primary, full width) until it's done; once something is logged a line says "Logged so far. Mark it done when you've finished." (A10, ADR-040). Then **Plan next…** (date picker, then a time for timed items; snackbar with Open).
- Sheets with typed input (field sheet, plan sheet) ask "Discard your changes?" before back or a tap outside closes them (shared `DiscardGuard`, A15).
- **No Save button:** changes save shortly after typing stops, and on leaving. Values that can't be saved show their issue inline with "Not saved yet: check the highlighted fields". Required fields (`*`) are a hint, not a blocker.

### 4.4a Template gallery (B8)
Me → Activities → Start from a template, or **Templates** in quick add (ADR-042): a **Search templates** field (name, category or what it logs; "No template matches. Go back and make your own instead."), then templates under category headings (`SectionHeader`). A card per template (activity-soft surface, large badge, name, its fields; "Already in your activities" when the name is taken). Tapping one opens a sheet with the real form ("What you'll log", rendered by the form renderer from `previewType`) and **Add {name}**, which installs it and opens the new activity.

### 4.5 Activity builder (implemented in Phase 2: one scrolling screen with live preview; two-pane layout on expanded windows later)
Steps on one screen with progressive sections: Name (and description) → Fields, "what you record" (list, add, reorder, configure in sheets) → Icon (12 suggested plus the chosen one; "More icons" shows all) → Color → Behavior (timer, plannable) → live Preview (rendered with the real form renderer) (A27). Icons and colors are read to screen readers by name ("Walking", "Sky"; `activity_appearance_copy.dart`, A25). Field type picker groups types like §9 with plain-language descriptions and an example for each.

### 4.6 Focus Mode
Full-screen, minimal chrome, activity soft color wash on canvas (dark-leaning in dark theme). Activity name + context (e.g. book), `numericHero` elapsed time, slow arc progress, two controls (Pause/Resume, Finish) as large pill buttons. Discard behind an overflow. Screen stays awake while visible (wakelock is a platform service; decide implementation at Phase 5). Completion: celebration motion + "Reading session complete · 42 minutes" → optional notes and remaining fields.
- **Implemented (Phase 5):**
  - activity badge and name, `numericHero` timer (DM Mono, `m:ss` / `h:mm:ss`), Focusing/Paused label
  - Pause/Resume as the primary pill, Finish (secondary), Discard (tertiary, confirmed)
  - Finish (here or in the item) writes the timed span into the item and shows "Reading session complete · 42 min" (ADR-035)
  - `FocusBanner` on Today returns to the session's item
- **Not built yet:** the soft color wash, arc progress, keep-awake (no wakelock dependency) and completion motion.

### 4.6a Date and time pickers
The stock Material pickers are themed from tokens in `AppTheme` (A26): raised surface, large radius, brand selection (days, years, hour/minute boxes, AM/PM, dial hand), `numericLarge` (DM Mono) for the time, no coral accent. Planning a time uses the app's own time sheet (§4.2).

### 4.7 Insights
Default cards generated from the user's data (stat tiles with deltas and sparklines; one featured chart). Chart detail: metric selector (e.g. Weight / Reps / Volume / Frequency for an exercise), range segmented control, aggregation, accessible summary text. Comparisons phrased plainly ("+38 min vs last week"). No decoration; data first.
- **Implemented (Phase 6):**
  - range chips
  - Activities totals with neutral "+12 % vs previous period"
  - saved chart cards: headline in `numericLarge`, change, personal best, `AppChart` line/bar; planned vs actual as grey planned bars next to activity-colored recorded bars
  - the chart builder sheet
  - empty states
- **Implemented (ADR-037):** activity rows show "4 days · 3h 20m · 5 times" and a chevron; tapping opens the activity's **progress page**: app bar with badge and name, range chips, a summary line (days · time · times · change), then "Progress" with automatic chart cards (no options menu). The saved charts section is titled "Your own charts".
- **One period, said plainly (A20–A24):** both screens use `InsightRangePicker`: the range chips plus the exact dates ("Sep 4 – Oct 3"); every list row, headline and chart covers that period, and the activity list updates live. Automatic charts bucket by the range (days for Week, weeks for Month / 3 months, months for Year); a partial first bucket is labelled with the period's first day. Headlines read "total / best / average this period". Records are named for what they are: "All-time best 60 kg · Oct 2"; for a volume "Best day 960 kg · Oct 2" and "Best Set 480 kg · Oct 2" (the list's item label). Automatic charts with nothing in the period are left out (saved charts still say "No data in this period yet."). Two activities with the same name each get "Another activity has this name. Rename one in Me → Activities."
- **Not built yet:** sparklines.

### 4.8 Me
**Activities** (implemented, §4.3), **Body measurements** (implemented in Phase 6: latest values, per-type history with a line chart, add/edit/delete with Undo), preferences (theme, units), data (export if approved), about/privacy statement. A calm settings list built from shared list items, not default settings screens.

## 5. States

Every data-bearing view handles all states with shared components. A screen is not done until each exists.

| State | Guidelines |
|---|---|
| **Loading** | DB is fast: show nothing for the first ~150ms, then content-shaped skeletons (surface tones, subtle shimmer ≤ 1.2s loop or static if reduced motion). Never full-screen spinners for local reads. |
| **Empty** | Explain what will appear here and offer the next action. Small illustration (onboarding-family style) on primary screens; text-only in nested contexts. Copy is inviting and specific ("Your reading time will show up here after your first session."). |
| **Error** | Calm, plain-language message + retry; preserve user input; never show technical details. See [error_handling.md](../development/error_handling.md). |
| **Success / completion** | Brief, meaningful: check/arc fill animation + summary of what was achieved ("3 exercises · 9 sets · 1h 04m"). Auto-dismiss or single "Done". Bigger celebration reserved for focus completion and first-ever milestones. |
| **Partial / degraded** | Show what works (e.g. a log with one undecodable field renders the rest with a notice). |
| **Offline** | Not a state. The app is always offline-capable; never show connectivity UI. |

## 6. Onboarding

Narrative arc (§33.4): **understand → one meaningful question → personalize → show what you'll get → begin**. Detailed steps in [user_flows.md F1](../product/user_flows.md#f1-first-run-onboarding-fr-ux-01-fr-ux-02-fr-at-12).
- One idea per screen; display-type statement + short supporting line + one primary action.
- The Day Arc rises across steps as the progress indicator.
- Choices are outcome-phrased cards with icons ("Read more", "Train consistently", "Focus deeper"), not technical options.
- The personalization result is visible: chosen activities appear in their colors on a preview of Today.
- Privacy promise is stated once, warmly, early.
- Skippable at every step; ≤ 5 screens; no account, no long forms.

## 7. Interaction patterns

### 7.1 Logging something now (§37, ADR-035)
- **Implemented:** quick add → type → **Start now** opens the new item straight away; an activity's **Record** does the same. Two steps for an unplanned activity, then log into it. The activity chips are labeled **Recent** and ordered by use (ADR-039).
- User-facing copy avoids "Log" as a noun; items are "done", the action inside an item is logging into it. Activity Log stays the internal name.

### 7.2 Confirmation & feedback
- **Reversible actions** (delete log/plan/measurement, archive type, complete task): act immediately + Undo snackbar (≈5s). No "Are you sure?" dialogs.
- **Irreversible actions** (discard a focus session): confirmation sheet with the destructive option clearly labeled. Items save as you type, so there are no drafts to discard.
- Every save gives feedback (success state, snackbar, or visible list change with animation). Silence is never success.

### 7.3 Micro-interactions
Purposeful only: task check fill; set row add (slides in, focus moves to weight); reorder lift; timer pause morph; chart range morph; Day Arc segment grows when a log is saved; stepper digits roll on change. Each must be short (see motion tokens) and skippable under reduced motion.

### 7.4 Transitions between major screens
Tabs: quick fade-through. List → detail: container transform from the tapped item when it aids orientation, otherwise shared-axis horizontal. Into Focus Mode: the activity badge/arc expands into the full-screen focus surface. Sheets: slide up with `standard`; scrim fades.

### 7.5 Forms & input
Labels always visible (no placeholder-only labels). Correct keyboard types. Units displayed as suffix in secondary style. Defaults pre-filled from context (now, last values). Large steppers for reps/weight. Inputs grouped by meaning, not boxed individually.

### 7.6 Charts
Consistent across features: same primitives, tooltips, ranges, empty states (§13 of design system). Charts always have a textual summary for accessibility and quick reading.

## 8. Voice & copy

The product talks like a calm, thoughtful companion: warm, concise, never pushy.

| Do | Don't |
|---|---|
| Outcome-oriented where it helps: "See how your week went" | Purely technical: "View Analytics" |
| Clear verbs on buttons: "Save", "Start focus", "Plan tomorrow" | Vague or cute: "Let's gooo!", "Submit" |
| Neutral about misses: "Moved to tomorrow", "Skipped" | Guilt: "You failed 3 plans", "Don't break your streak!" |
| Specific empty states: "Log a workout to see your progress here." | Generic: "No data" |
| Plain errors: "Couldn't save this log. Your entries are still here. Try again." | "Error 500", "SQLiteException" |
| Second person, sentence case | Title Case Everywhere, exclamation marks everywhere |

Spec examples like "Create Activity", "Add Log", "View Analytics" (§33.3) may remain as button labels where they are the clearest option; headlines and empty states carry the outcome framing. Copy lives in one localizable place (ARB files, ADR-015).

## 9. Product packaging

Packaging is part of the product (§33.3). The same visual language must carry across onboarding, empty states, core screens, feature introductions, completion states, screenshots and future store presentation.
- Every major screen should be "screenshot-ready": a clear focal point, real-looking (seeded) data, consistent framing.
- Feature introductions (first visit to Insights, first focus session) use a one-time, dismissible inline intro, not a modal tour.
- Store/marketing materials are separate from the app UI but reuse its tokens, typography and illustration style. Not part of V1 engineering scope.

## 10. Visual quality checklist

A UI change is not complete because it works. Review each item on **compact + expanded**, **light + dark**, **text scale 1.0 and 2.0**:

- [ ] **Hierarchy:** one clear focal point; title → content → actions order obvious.
- [ ] **Spacing:** only spacing tokens; consistent rhythm; nothing cramped against edges.
- [ ] **Alignment:** shared left edges; numbers right-aligned/tabular in tables.
- [ ] **Readability:** contrast meets tokens; no small text in `textTertiary`.
- [ ] **Touch targets:** ≥ 48dp.
- [ ] **Consistency:** shared components; same radius family; activity color grammar; Plan vs Reality grammar.
- [ ] **Motion:** purposeful, uses motion tokens, respects reduced motion, never blocks.
- [ ] **States:** loading, empty, error, success all implemented and on-brand.
- [ ] **Responsiveness:** no stretched phone layout on tablets; content max widths respected.
- [ ] **Same product:** would this screen look at home next to Today and onboarding?
- [ ] **No hardcoded values** (colors, sizes, durations) in the diff.
- [ ] **Accessibility:** semantics labels (human names, never stored ids), focus order, color-independent meaning.

## 11. Avoid (§33.5)

Generic white CRUD screens · generic black productivity dashboards · excessive gradients · excessive cards (boxes inside boxes) · too many buttons · spreadsheet-like layouts (set tables are compact rows, not grids of borders) · unadapted default Material components · random one-off colors/spacing · modal tours · confirmation dialogs for reversible actions · motion that delays common actions · copying another product's visual identity.
