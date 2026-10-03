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
- **Quick Record** (implemented): a persistent **Record** action on every tab. It's a floating action button on compact and the rail's leading action on larger layouts. It opens the Quick Record sheet for recording an unplanned activity.
- **Screen header:** large display-type title that collapses to a compact title on scroll (large-title pattern). Contextual actions as at most 1–2 icon buttons in the header.
- **Sheets over pages** for short tasks (quick log, add plan, pick value, field config). Full screens for long tasks (log editor with structured data, builder, focus).
- **Back behavior:** system back/gesture always works; unsaved drafts trigger a calm "Keep editing / Discard" choice.

## 3. Component inventory (`lib/shared/`)

Each component consumes tokens only and implements all states from [design_system.md §11](design_system.md#11-component-states).

**Status (Phase 2):**
- **Implemented:**
  - `AppButton`: four variants and the large 52dp size. The medium size and loading state aren't built yet.
  - `ActivityBadge`, `SectionHeader`.
  - State views: `AsyncValueView`, `DelayedLoadingPlaceholder` (blank for ~150 ms, then quiet skeleton bars), `AppEmptyState`, `AppErrorState`.
  - Snackbar helpers: `showUndoSnackBar`, `showMessageSnackBar`.
  - `TabPlaceholder`, `CenteredScrollBody`.
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
| `TimelineItem` | Planned (outline) / actual (filled) variants; time column, badge, title, duration, summary |
| `DayArc` | Signature motif (Today header, focus, onboarding) |
| `Chart` primitives | `LineChart`, `BarChart`, `SparkLine`, `StatTile` (number + delta + sparkline) |
| `ReorderableFieldList` | Drag handle, haptic, lift animation |
| `SetTableEditor` | Shared by any Set Table field (not gym-specific) |

Do not use raw Material `Card`, `ElevatedButton`, `AlertDialog` etc. in features when a shared component exists.

## 4. Core screens

### 4.1 Today (most important screen, §18, §35)
- **Header:** time-of-day greeting in display type ("Good morning, …" if a name is known; otherwise without name) + date + Day Arc showing the day so far with logged segments.
- **Morning state:** today's plan as outline (planned) items with time, activity badge, title and a **Start** affordance; tasks with a check control.
- **During the day:** started/logged items become filled actual items; an in-progress focus session appears as a live item at the top ("Reading · 23:14 · Return").
- **Evening state:** **What you planned / What actually happened** pairs: plan item with its linked log (actual duration vs planned), unplanned logs listed as extras, open plans offering Skip / Move to tomorrow. Concise day summary line (e.g. total tracked time, count of activities) without scores or grades.
- Timeline items show: start time, activity, duration, one-line summary from the field type `summarize()` (e.g. "Chest / Shoulders", "Fooled by Randomness").
- Empty Today: illustration + two clear paths: "Plan your day" and "Log something you've done".

### 4.2 Plan (date-based; calendar implemented, plans in Phase 4)
- **Date selector:**
  - a week strip (seven days, previous/next week) plus a calendar button that opens a month picker for any past or future date
  - the selected date shows as a display-type heading with a relative label (Today / Tomorrow / Yesterday)
  - "Today" jumps back to the current date
- **Planned:** that date's plans. Timed items are ordered by time, and untimed ones follow in manual order (drag to reorder). Tasks and activity plans share the list, using the outline grammar. Fast inline add: title → optional activity chip → optional time. Until Phase 4 this section shows a calm placeholder.
- **Recorded:** for today and past dates, what was actually recorded that day: filled grammar, badge, time, duration, summary. Tapping a record opens it. Future dates hide this section.
- Flow: select date → plans → select a planned activity → do it → record what happened.

### 4.3 Me → Activities (implemented)
The reusable Activity Types, managed under Me rather than in a primary tab (ADR-028).
- The list shows badge, name, field count and a **Record** shortcut, with entry points for "New activity" and "Start from a template".
- An activity's page shows a **Record** button, edit/delete, and recent records.
- This area is for configuration. Daily recording happens through Today, Plan and Quick Record.

### 4.4 Log editor (generic form renderer, implemented in Phase 2)
- Header: activity badge + name; time row (start, end/duration) editable with sensible defaults.
- Fields rendered in configured order with consistent field shells (label, editor, helper/error).
- Structured fields (Repeating Group, Set Table) expand inline; add-row/add-item actions sit at the end of each group; previous values offered as suggestions.
- Notes (built-in) last.
- Sticky bottom primary action ("Save"); validation on submit, then live.
- Same layout for create, edit, plan→log and post-focus.

### 4.5 Activity builder (implemented in Phase 2: one scrolling screen with live preview; two-pane layout on expanded windows later)
Steps on one screen with progressive sections: Identity (name, icon, color) → Fields (list, add, reorder, configure in sheets) → Behavior (timer, plannable) → live Preview (rendered with the real form renderer). Field type picker groups types like §9 with plain-language descriptions and an example for each.

### 4.6 Focus Mode
Full-screen, minimal chrome, activity soft color wash on canvas (dark-leaning in dark theme). Activity name + context (e.g. book), `numericHero` elapsed time, slow arc progress, two controls (Pause/Resume, Finish) as large pill buttons. Discard behind an overflow. Screen stays awake while visible (wakelock is a platform service; decide implementation at Phase 5). Completion: celebration motion + "Reading session complete · 42 minutes" → optional notes and remaining fields.

### 4.7 Insights
Default cards generated from the user's data (stat tiles with deltas and sparklines; one featured chart). Chart detail: metric selector (e.g. Weight / Reps / Volume / Frequency for an exercise), range segmented control, aggregation, accessible summary text. Comparisons phrased plainly ("+38 min vs last week"). No decoration; data first.

### 4.8 Me
**Activities** (implemented, §4.3), body measurements (latest values + trends), preferences (theme, units), data (export if approved), about/privacy statement. A calm settings list built from shared list items, not default settings screens.

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

### 7.1 Quick Record (§37, ADR-028)
- **Implemented:** the **Record** action opens a sheet titled "What did you do?" listing the user's activities (badge + name). Tapping one opens the record form, so it takes two taps. With no activities yet, the sheet offers "New activity".
- **Later:** recent/frequent ordering, "Task" quick add (Phase 4), search for long lists, and **instant record** for activities without required fields (saved immediately, with "Add details" and Undo).
- Long-press an activity (Activities list / Quick Record) → "Start focus" for timer-capable types (Phase 5).
- User-facing copy says **Record**, never "Log" (ADR-028). Activity Log stays the internal name.

### 7.2 Confirmation & feedback
- **Reversible actions** (delete log/plan/measurement, archive type, complete task): act immediately + Undo snackbar (≈5s). No "Are you sure?" dialogs.
- **Irreversible actions** (discard unsaved draft, discard focus session): confirmation sheet with the destructive option clearly labeled.
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
- [ ] **Accessibility:** semantics labels, focus order, color-independent meaning.

## 11. Avoid (§33.5)

Generic white CRUD screens · generic black productivity dashboards · excessive gradients · excessive cards (boxes inside boxes) · too many buttons · spreadsheet-like layouts (set tables are compact rows, not grids of borders) · unadapted default Material components · random one-off colors/spacing · modal tours · confirmation dialogs for reversible actions · motion that delays common actions · copying another product's visual identity.
