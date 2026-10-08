# Visual redesign plan: Stitch reference → three light themes

> **Status: approved by the owner 2026-10-08 → ADR-045. First vertical slice
> built** (theme foundation, shared components, Me → Appearance, Today, the item
> screen). Next: the owner reviews it on the phone; then an explicit Stitch-based
> screen pass for Plan, Challenges, Insights and Me (step 6 onwards).
>
> Owner adjustments on approval: the first slice is Today → open an item →
> record → done → back, in all three themes; Stitch guides screen composition,
> not only tokens; typography decided deliberately (Plus Jakarta Sans, see
> design_system.md §3.1); scope boundaries (§8) unchanged; nothing beyond the
> slice before the review.
>
> Decisions as built: D1 Rose/Lavender/Papaya (Lavender default) · D2 rose
> rebuilt from our own colors · D3 Plus Jakarta Sans · D4 no floating button ·
> D5 not yet (Plan comes after the review) · D6 no name in the greeting · D7
> one layout + treatments · D8 light only, dark code removed · D9 five tabs.
>
> The sections below are the plan as proposed; the canonical description of
> what's built is design_system.md and ui_guidelines.md.

Inputs studied:
- **Stitch project "Personal Life OS"**: 22 exported screens (HTML + PNG) in
  `design/stitch_personal_life_os*/` on `master`, plus the 5 design systems,
  read through the Stitch API (tokens, type scale, spacing, radii, shadow and
  component rules).
- **The Flutter app** on `master` (`c88fb13`): design tokens, theme, shared
  widgets, every presentation file, preferences storage, router.

---

## 0. Decisions the owner must make first

Each has a recommendation. These shape the code, so they're asked up front,
not discovered later.

| # | Decision | Why it matters | Recommendation |
|---|---|---|---|
| D1 | **Theme working names** | Shown in Me → Appearance | **Rose**, **Lavender**, **Papaya** (plain color words, no brand). Internal IDs `rose`, `lavender`, `papaya`, so names can change without touching stored data. |
| D2 | **The rose theme's colors** | Stitch's pastel export literally names its colors `flowfy-pink` `#FF5D9E` and `flowfy-teal` `#3DC4BA`: it *is* Flowfy's palette | Rebuild it from **our own lineage**: our existing rose (`#B04E62` family) + our brand teal (`#2F8180` family) + mist. Same mood (blush canvas, rose accent, teal action), our values. |
| D3 | **One font for all themes: Plus Jakarta Sans** | All 5 Stitch systems use it; today we bundle Fraunces + DM Sans + DM Mono | Bundle Plus Jakarta Sans (OFL, variable) as the only UI font; tabular figures for timers. Retire Fraunces, DM Sans, DM Mono (supersedes ADR-032, settles ADR-016). |
| D4 | **Quick Log floating button** | Every Stitch Today has a "+ Quick Log" pill FAB; ADR-028 says *no floating Record button* | Keep ADR-028: no FAB. The existing inline quick add gets the Stitch pill styling. (Alternative if you want it: a FAB that opens the *same* quick add, not a second way to record.) |
| D5 | **Plan navigation** | Stitch Plan = week strip with a ring per day + the selected day inline (Day/Week). Ours = Week \| Month, a tapped day opens a day screen (ADR-039) | Adopt Stitch's pattern: week strip on top, the selected day's items inline below, month via the month header. Uses the same `DayItems`; no data change. Amends ADR-039. |
| D6 | **Greeting with a name** ("Good morning, Elena") | We have no profile/name | Name-less greeting ("Good morning"). An optional local "Your name" in Me is a small later add, not in the first slice. |
| D7 | **Papaya's different layout details** (floating pill nav, segmented toggles, icon-led rows, chips instead of stat tiles) | See §1.3: two layout families exist | One layout for all themes. Papaya's differences become **theme treatments** read only by shared components (nav style, card style, progress style), never by screens. |
| D8 | **Dark mode code** | Code has a full dark theme and follows the phone's system setting today | Light only: force light, remove the unused dark tokens and the system/light/dark preference (it's never shown in the UI). Dark mode returns later as its own piece of work for all three themes. |
| D9 | **Bottom navigation** | Stitch shows 4 tabs; we have 5 (Challenges, ADR-044) | Keep 5 tabs. Style them as Stitch does; the 5th fits in both bar styles. |

---

## 1. Stitch design audit

### 1.1 What the project contains

22 exported screens in three folders (the 23rd in Stitch is a duplicate
"Log Activity" at 390 px). By theme:

| Screen | Rose (pastel) | Lavender & Mint | Papaya & Mint | Unthemed |
|---|---|---|---|---|
| Today – Living Pulse | ✓ | ✓ | ✓ | |
| Today – first-time empty | ✓ | | ✓ | |
| Plan – Timeline & Horizon | ✓ | ✓ | ✓ | |
| Plan – first-time empty | ✓ | | ✓ | ✓ (lavender look) |
| Record – Live Workout Session | ✓ | ✓ | ✓ | |
| Insights – Self-Understanding | ✓ | ✓ | ✓ | |
| Insights – first-time empty | | | | ✓ (lavender look) |
| Me – Activity Studio & Profile | | ✓ | | |
| Log Activity – Dynamic Schema Form | | | | ✓ |
| Quick Log – Spontaneous Moment | | | | ✓ |
| Onboarding – Rhythm Calibration | | | | ✓ |

Rendering quality: Log Activity, Quick Log, Onboarding, Insights empty and
the Lavender Insights exported with styles partly missing (serif fallback,
overlapping text). They're useful for **content and structure only**, not
looks.

### 1.2 Screen by screen

For each: what it is · hierarchy · entry point · components · what to take ·
what to leave.

**Today – Living Pulse** (3 themes)
- *Is:* the day's home. Tab 1.
- *Hierarchy:* (1) hero card: date pill, greeting, one-line state, ring
  "3/6"; (2) **Up next** card: time pill + "in 25 mins", category chip,
  title, description, two stat tiles (target, duration), full-width
  **Start & Record** CTA; (3) "Living Stream" list header with Today/Timeline
  toggle; (4) item cards in time order; (5) Quick Log FAB; bottom nav.
- *Item card anatomy:* tinted icon circle · time (or range) · status chip
  (Recorded / Scheduled / Ritual / "3h 15m") · title (1 line, ellipsis) ·
  summary line ("24 min • 2.1 km") · trailing: done check (open items),
  photo thumb, ⋯, or a quick action ("+ 250 ML").
- *Take:* hero with day progress ring (done / planned today), Up next card
  with Start, item card anatomy, status chips, the two-level card rhythm.
- *Leave:* "Energy Reserve" (invented metric), name, avatar/notification
  dot, photos, "Fuel Logged/Ritual" category semantics, ₹ amounts, hydration
  "+250 ML" (no generic quick-amount yet, see §8).
- *Theme-specific:* Papaya puts stats as inline chips, uses a segmented
  Today/Timeline toggle, a tinted full-surface "milestone" card with a
  progress bar, a centered FAB and a floating pill nav. Rose/Lavender use
  bordered stat tiles, a text toggle, right-aligned FAB, full-width nav bar.

**Today – first-time empty** (Rose, Papaya)
- *Hierarchy:* welcome hero with a setup progress bar · "Daily intentions
  0/3 + Set Focus" · "Quick start guide" checklist (step 2 of 3, "Pick an
  activity") · empty card: orb illustration, "No activities logged yet",
  one-tap starter chips ("+ 20m Walk", "+ 45m Deep Work", "+ 500ml Water") ·
  recommendation cards.
- *Take:* the empty card (illustration orb + one sentence + one-tap starter
  activities), the calm tone, "Pick an activity".
- *Leave:* calibration/baseline/biometrics, "Sync Ready", intentions as a
  separate concept (our "intentions" are just planned items), checklists
  with fake progress.

**Plan – Timeline & Horizon** (3 themes)
- *Hierarchy:* month header + Day/Week toggle · **week strip**: 7 day pills,
  each with a small completion ring, selected day filled · **day summary
  card**: "Thursday target", status chip (In rhythm), planned time per
  category chips ("4h Focus · 1h Fitness · 45m Learning"), **plan fidelity
  bar** (actual vs planned time, % fulfilled) · "Rituals" quick-add chips ·
  "Timeline Horizon" list: per item time column (or icon), title, status
  chip (Completed / Scheduled / +15m flow), description, **plan vs actual
  bar** ("Plan 30m · Actual 24m"), "Start now" on upcoming items, **NOW**
  divider between past and upcoming · "Add planned activity" CTA.
- *Take:* week strip with day rings, day summary with planned-vs-actual
  bar, planned time per activity chips, per-item plan-vs-actual bar, NOW
  divider, Start now on upcoming items.
- *Leave:* "Rituals" (multi-activity routines: not an agreed concept),
  "In rhythm" judgement labels, "Overachieved/Flow" gamified wording (use
  plain "+15 min").
- *Theme-specific:* Rose/Lavender use a time column on the left with a
  status icon; Papaya uses the icon circle like Today, gradient bars and a
  calendar-month chip.

**Plan – first-time empty** (3 variants)
- *Take:* "Your day is wide open" + one sentence + add first item; the
  week strip stays visible so the screen still teaches navigation.
- *Leave:* "Suggested architectures / Apply" (routine bundles), "15-minute
  buffers" claims, photos.

**Record – Live Workout Session** (3 themes)
- *Is:* an item being recorded live (opened from Start).
- *Hierarchy:* header card: live chip, subtitle, pause, **Finish** ·
  big timer + summary stats (volume) · completed rows collapsed ("Incline
  DB press · 3 sets done · 30×10 • 32×8 • 32×8") · **active row card**:
  "Now active · Set 3 of 4", row title, logged sets, **entry block with
  steppers** (− 70 + with quick chips −2.5/+2.5; − 8 + with 6/10/12),
  "Log set & start rest", Add set, rest timer with +30s · next row
  ("Next · 3 sets planned") · effort rating chips · notes input.
- *Take (generically, from field definitions, never "if Gym"):* big timer
  header with Finish, collapsed done rows with their summary, an active-row
  card for lists, **number steppers with quick values** for Number fields
  inside lists, "log row & start rest", rest timer chip, rating as large
  chips.
- *Leave:* kcal burn, heart rate, video, "Target: progressive overload"
  coaching copy, RPE 6–10 labels (a Rating field already renders as chips).

**Log Activity – Dynamic Schema Form** (unstyled)
- *Take:* each field as its own soft card with an icon + label header and
  the value on the right; "logged vs target" for numbers that were planned;
  the duration row with ± steppers.
- *Leave:* "Schema v2.4", "dynamic fields", "Synced with Library", book
  covers, HealthKit, "Save routine blueprint". Developer words never reach
  the UI.

**Quick Log – Spontaneous Moment** (unstyled)
- *Take:* categories as a 2-column grid of tinted cards (maps to our 14
  life areas in Browse), duration quick chips (+15m … +90m), 1–5 rating
  segmented control, one save CTA.
- *Leave:* audio memo, "Whisper Live AI", photo attachments, Apple Watch
  "biometric nudge", "Expense & budget check".

**Insights – Self-Understanding** (3 themes)
- *Hierarchy:* range pill (Last 30 days) · **headline insight card**: big
  sentence with a highlighted number + small supporting chart (completion by
  start time, pill bars) · **Intent vs Reality** card: per activity row,
  "Planned 18 → Logged 15", % and a bar · **Progression deep dive**:
  activity row name, big current value with change ("72.5 kg e1RM +20.8%
  over 8 wks"), line chart with area fill, baseline and current chips, two
  stat tiles · cross-dimension discovery · actionable takeaway.
- *Take:* headline-card layout (big number in a sentence), intent-vs-reality
  rows (we already compute planned vs actual), the progression card layout
  for our existing per-row best / estimated max charts, pill-shaped bars,
  area-filled lines, baseline/current chips.
- *Leave:* correlations ("on nights with 7.5h sleep…", "94% r-factor"),
  "Lock early slots / Auto-adjust / Apply" automation, share, budgets.
  Headline sentences only from facts we actually compute (§8).

**Insights – first-time empty** (unstyled)
- *Take:* honest "warming up" card that says what appears after a few days
  of records; preview rows for activities.
- *Leave:* calibration phases, locked "Day 5 unlocks", "Set reminder".

**Me – Activity Studio & Profile** (Lavender)
- *Take:* grouped settings cards with icon rows and a value on the right;
  "Theme System → Pastel Lavender" row (= our Me → Appearance); a list of
  the user's activities with a primary action per row.
- *Leave:* level/XP, profile photo, "weekly target engine" (goals are
  excluded), routine blueprints, sensors (Oura, HealthKit), calendar
  ingest, PDF/Notion export (export is a separate open question, OQ-03),
  haptic/notification settings (no notifications yet).

**Onboarding – Rhythm Calibration** (unstyled)
- *Take, for Phase 7 later:* step progress ("Step 2 of 4"), one question
  per screen, selectable cards with a check, Continue + "Skip for now".
- *Leave:* chronotypes, "biological peak", daily targets (goals).

### 1.3 Two layout families, not three

- **Rose and Lavender are the same layout** with different tokens (same
  exported structure, even the same Tailwind config).
- **Papaya is a variant**: floating pill nav, segmented toggles, icon-led
  plan rows, stats as chips, tinted "milestone" cards, gradient bars,
  sunken input wells, header with a brand tile.
- None of the differences change what a screen *contains* or how you move
  through it. They're all presentation of the same component.
  → One layout; differences live in the theme as **treatments** read by
  shared components only (D7).

### 1.4 The five design systems

| System | Status | Use |
|---|---|---|
| Luminous Humanist LifeOS | hidden (early draft; black primary, orange secondary) | ignore |
| Luminous Pastel Humanist | hidden (early draft) | ignore |
| **Pastel Confection** | visible → Rose | structure only; its copy describes a *finance* app and its hero colors are Flowfy's (D2) |
| **Electric Lavender & Mint** | visible → Lavender | primary source |
| **Papaya Confection** | visible → Papaya | primary source |

What the three visible systems share (→ shared tokens):
- **Font:** Plus Jakarta Sans for everything; headlines 700–800 with
  negative tracking (−0.01 to −0.03 em), labels 600–700 with positive
  tracking, body 400–500.
- **Radii:** 8 · 16 · 24 · 32 · 48 · pill. Cards 24–32 (rounded-3xl),
  everything interactive is a pill.
- **Surfaces:** white cards on a tinted canvas; no hard 1 px dividers
  (separation by tone, tinted shadow or an 8%-alpha micro-border).
- **Shadows:** colored ambient glow (the theme's primary at 6–14% alpha,
  large blur, negative spread) + a tiny neutral contact shadow.
- **Buttons:** pill CTAs with a glow in their own color; soft buttons
  (tinted fill, saturated text); press scale 0.97 or −2 px.
- **Chips:** pills with pastel fill + saturated text, one family per
  meaning (mint = done, primary = active, periwinkle/sky = scheduled).
- **Progress:** pill tracks 8–12 px; rings with round caps.
- **Icons:** in a 40 px tinted circle/squircle (Material Symbols in
  Stitch; we keep Phosphor, ADR-024).
- **Nav:** translucent white bar with a pill indicator behind the active
  item.

What differs (→ per-theme tokens):

| | Rose | Lavender | Papaya |
|---|---|---|---|
| Canvas | blush | porcelain lilac `#F8F9FE` | warm porcelain `#FBF9F7` |
| Primary (accent) | rose (ours, D2) | electric lavender `#7C5CFC` | papaya `#FF6B4A` |
| Action / success | teal (ours) | mint `#10B981` | aqua mint `#2DD4BF` |
| Third accent | butter | sky `#38BDF8` | periwinkle `#818CF8` |
| Ink | charcoal | deep indigo `#1E1B4B` | midnight slate `#1E232F` |
| Card edge | none (tone + blush glow) | 1 px lavender at 8% | white rim + slate at 4% |
| Inputs | soft fill | soft lilac fill, pill | sunken sand well `#F4EFEA`, inset shadow |
| Progress fill | two-tone solid | lavender→mint gradient | coral→peach / mint gradient, 12 px |
| Card gap / padding | 14 / 20 | 24 / 24 | 16 / 24–32 |
| Nav | full-width bar | full-width bar | floating pill bar |

**Accessibility finding (measured):** the *token* colors in each system pass
(e.g. papaya primary `#AE3115` with white 6.5:1), but the bright fills the
screens actually render **fail with white text**: mint `#10B981` 2.5:1,
papaya `#FF6B4A` 2.8:1, pastel pink 2.9:1, pastel teal 2.1:1 (need 4.5:1).
Papaya's mint button already solves it with dark text (8.4:1). Rule for us:
bright hues for fills, glows, rings and large display numbers; text on a
bright fill is dark ink, or the fill is the deeper tone. Every theme pair
gets an automated contrast test (§5).

---

## 2. Final V1 screen inventory

Every screen we need, its states, and its Stitch reference. "Existing" =
already built and working; the work is visual unless noted.

| Screen | States | Stitch reference | Existing? |
|---|---|---|---|
| **Today** | loading · first-time empty · has items · all done · error | Today Living Pulse; Today first-time empty | yes; new hero + Up next |
| Item (open item, log into it) | planned · in progress · live timer running · done · list with active row · error/saving | Record Live Session; Log Activity (structure) | yes; restyle + steppers |
| Quick add / Start now (inline + time sheet) | idle · typing with suggestions · choosing activity | Quick Log (duration chips, grid) | yes |
| Browse activities | search · yours · 14 life areas | Quick Log category grid | yes |
| Activity builder ("Make your own") + field sheet | new · edit · discard guard | Log Activity (field cards) | yes |
| **Plan** (week strip + selected day) | empty week · has items · past day · future day | Plan Timeline; Plan empty | yes; layout change (D5) |
| Plan month | month grid with day rings | Plan header month chip | yes |
| Plan item sheet / repeat / time sheets | — | — | yes |
| **Challenges** tab | empty · running · completed | (none in Stitch) → Today hero ring + Insights progression card | yes |
| Challenge detail + sheet | running · done today · at risk · completed | (none) → same components | yes |
| **Insights** home | empty (warming up) · has data · per period | Insights Self-Understanding; Insights empty | yes |
| Activity insights page | empty period · charts · rows | Progression deep dive | yes |
| Chart builder sheet | — | — | yes |
| **Me** | — | Me Activity Studio (structure) | yes |
| **Me → Appearance** | three theme cards, selected | Me "Theme system" row; Pastel's theme picker spec | **new** |
| Me → Activities, Body measurements | — | Me (rows) | yes |
| Focus timer | running · paused | Record header (timer) | yes |
| Startup failure | — | — | yes |
| Onboarding | — | Onboarding (structure only) | Phase 7, later |

---

## 3. User flows (after the redesign)

Flows don't change unless marked **(change)**; they get the Stitch look.

1. **First launch.** App opens on Today in the default theme (Lavender
   suggested as default; owner picks). Today's first-time empty state:
   welcome line, one-tap starter activities (from built-ins), "Pick an
   activity" → Browse, and "Make your own". No forced setup (FR-UX-02).
   Real onboarding stays Phase 7.
2. **Today.** Hero: date, greeting, one-line state ("2 of 5 done"), ring.
   **Up next** card (first open item with a time ≥ now, else first untimed
   open item) with **Start** → opens the item and starts its timer. Below:
   items in time order as cards with status chips; check toggles done;
   tap opens the item. Running challenges below items. Quick add stays
   inline (D4).
3. **Planning (change, D5).** Plan tab: month header, week strip with a
   ring per day (done/planned), tap a day → its items appear inline below,
   with the day summary card (planned vs recorded time, per-activity
   chips). Add item → same quick add / plan sheet. Month view from the
   month header.
4. **Recording an activity.** Start now / Up next Start / open an item →
   item screen: live header (timer, Finish), fields as cards. For a list
   (e.g. sets): done rows collapsed with their summary, the active row
   expanded with **steppers + quick values**, "Add row & start rest", rest
   timer chip. Saves as you type (unchanged).
5. **Activity history / editing.** Done items open the same item screen
   (edit in place, saves as you type, delete with Undo). Activity insights
   page shows the history calendar and rows (unchanged behavior).
6. **Insights.** Range pill; at-a-glance; consistency calendar; **plan vs
   reality** as per-activity rows (planned → recorded, %); streaks; per
   activity → progression page (current value + change, area line,
   baseline/current chips).
7. **Challenges.** Tab: running first, then completed; card shows ring
   (progress/target), current streak, today's state. Detail: big ring,
   stats, calendar, **Record today** (the open question from last session:
   opens today's item for the challenge's activity). New challenge sheet.
8. **Theme switching (new).** Me → Appearance → three large preview cards
   (canvas, card, primary, action colors and a mini item row in each
   theme's own look) → tap = applied instantly app-wide with a short
   cross-fade, saved locally, restored on restart.
9. **Activity creation.** Unchanged flow (quick add "Make your own" or Me →
   Activities → builder); builder restyled to field cards.

---

## 4. Design system architecture

### 4.1 Layers

```
Raw palettes (private, per theme)          lib/core/design/themes/{rose,lavender,papaya}.dart
        ↓
ThemeSpec (one immutable value per theme)  colors · shadows · treatments · activity palette
        ↓
AppTokens (ThemeExtension, already exists) context.colors / context.tokens
        ↓
AppTheme.build(ThemeVariant) → ThemeData   Material component themes from tokens
        ↓
Shared components (lib/shared/widgets)     the ONLY place treatments are read
        ↓
Feature screens                            semantic tokens + shared components only
```

Today's code is already close: features read `context.colors`,
`context.textStyles` and `AppSpacing` (117 / 102 / 333 uses), not raw
colors. Only 2 places read shadows. So themes slot in at the top without
rewriting screens.

### 4.2 Shared (identical in every theme)

- **Typography roles** (D3), one scale: `display` 36/44 w800 −0.025em ·
  `headlineLarge` 28/36 w700 · `headlineMedium` 22/28 w700 · `headlineSmall`
  18/24 w600 · `titleMedium` 16/22 w600 · `bodyLarge` 16/24 · `bodyMedium`
  14/20 · `bodySmall` 12/16 w500 · `labelLarge` 14/20 w700 · `labelMedium`
  12/16 w700 +0.02em · `labelSmall` 11/14 w700 +0.04em (caps chips) ·
  `numericHero` / `numericLarge` (tabular figures).
- **Spacing:** keep the 4-pt scale (2…64). Screen margin 20, card padding
  20, card gap 16, section gap 32.
- **Radii:** 8 · 16 · 24 · 32 · 48 · pill (cards 28, sheets 32 top, chips
  and buttons pill, inputs pill).
- **Motion:** existing tokens; add press scale 0.97 and theme cross-fade
  (respects reduced motion).
- **Icons:** Phosphor (ADR-024), drawn in tinted circles.
- **Component APIs, sizes, touch targets (≥ 48 dp), behavior.**

### 4.3 Per theme (ThemeSpec)

- **Color roles** (existing set extended): `canvas`, `surface` (card),
  `surfaceSoft` (tinted well), `surfaceSunken` (input well), `ink`,
  `inkSecondary`, `inkTertiary`, `outline`, `hairline`, `primary`,
  `onPrimary`, `primarySoft`, `onPrimarySoft`, `action` (CTA/success),
  `onAction`, `actionSoft`, `accent` (third), `accentSoft`, `danger`,
  `dangerSoft`, `scrim`, and **status families**: done, active, scheduled,
  at risk (fill + text each).
- **Activity palette**: same six stored keys (sky, lilac, teal, rose,
  slate, coral; DB unchanged), values re-tuned per theme so activity chips
  sit in the theme (e.g. Papaya's teal key = aqua mint).
- **Shadows**: `card`, `floating`, `cta(color)` built from the theme's
  primary/action hue.
- **Treatments** (small enums, read only by shared components):
  `cardEdge` {none, microBorder, rim} · `navStyle` {bar, floatingPill} ·
  `progressFill` {solid, gradient} · `inputStyle` {soft, sunken} ·
  `statStyle` {tile, chip}.
- **Gradients**: hero wash and progress gradient stops.

### 4.4 Components (shared, theme-driven)

Restyle existing: `PanelCard` → **AppCard** (edge + shadow from theme) ·
`AppButton` (primary / action / soft / text; pill; glow; press scale) ·
`ActivityBadge` (tinted circle) · `ProgressBar` (solid/gradient, 8–12 px) ·
`StatTile` (tile/chip) · `SectionHeader` · `DoneCheck` · state views ·
`AppChart` (pill bars, area-filled lines, baseline/current chips) ·
`DayGrid` · `BreakdownBars` · bottom nav (bar/floating pill) · sheets ·
text fields · chips · switches.

New: **ProgressRing** (day, challenge) · **StatusChip** (done / in progress
/ scheduled / at risk) · **ItemCard** (icon · time · chip · title ·
summary · trailing) · **UpNextCard** · **DayHero** · **WeekStrip** (day
pills with rings) · **PlanActualBar** · **NowDivider** · **SegmentedPill**
· **NumberStepper** (± with quick values; generic for Number fields) ·
**RatingChips** · **EmptyStateCard** (orb + text + one-tap chips) ·
**ThemePreviewCard**.

---

## 5. Flutter architecture changes

**Stays as is (correct already):** all domain and data layers; the database
and schema (no migration needed: the theme is a row in `app_preferences`);
the activity engine and form renderer logic; plans, items, insights maths,
challenges; Riverpod providers; the router (one new route); `AppTokens` as a
`ThemeExtension`; feature code reading semantic tokens.

**Refactor:**
- `lib/core/design/tokens/color_tokens.dart`: palette per theme instead of
  light/dark; extend roles (§4.3).
- `app_tokens.dart`: add treatments, gradients, activity palette per theme;
  drop `dark`.
- `app_theme.dart`: `AppTheme.light/dark` → `AppTheme.build(ThemeVariant)`.
- `typography.dart`: Plus Jakarta Sans scale; `radius.dart`: new radii.
- `activity_palette.dart`: resolve by theme, not brightness.
- `settings`: replace `ThemePreference {system, light, dark}` with
  `ThemeVariant {rose, lavender, papaya}`; repository key `theme`
  (unreadable/missing → default); `App` uses `themeMode: ThemeMode.light`.
- `app/dev/token_showcase_screen.dart`: shows the three themes side by side
  (our review tool on the phone).

**New:** `lib/core/design/themes/` (three ThemeSpecs), the shared
components in §4.4, `features/settings/presentation/appearance_screen.dart`,
route `/me/appearance`.

**Tests:** preference round-trip and fallback; theme switch rebuilds the
app; **WCAG contrast test for every text/background pair in every theme**;
widget tests for new components (stepper, ring, week strip); existing 440
tests stay green (copy keys mostly unchanged); a smoke test that renders
each main screen in each theme without overflow.

**Docs (same change as code):** ADR-045 (themes; supersedes ADR-038 colors,
ADR-032 fonts, settles ADR-016, amends ADR-028 if D4 changes and ADR-039 for
D5); rewrite `design_system.md` (tokens per theme) and `ui_guidelines.md`
(components and patterns); `responsive_design.md` (nav styles);
`requirements.md` (Appearance FR); `user_flows.md`; `CLAUDE.md` §10 color
rule; `ai/rules/ui_rules.md`; `ai/context/design.md`; `current_task.md`.

---

## 6. Implementation order (screen by screen)

Each step ends with format / analyze / tests green and the app runnable.

1. **Theme foundation.** ADR-045 + docs skeleton; Plus Jakarta Sans
   bundled; ThemeSpecs for the 3 themes; `AppTheme.build`; `ThemeVariant`
   preference; light-only; contrast tests; token showcase.
2. **Shared components.** Restyle the existing ones and add the new ones in
   §4.4, all in the showcase first.
3. **Me → Appearance.** Theme picker; instant switch; persists.
4. **Today.** Hero + ring, Up next, item cards, empty state, challenges
   section.
5. **Item screen.** Live header, field cards, active-row steppers, rest
   chip, done rows collapsed.
6. **Plan.** Week strip + inline day (D5), day summary card, plan-vs-actual
   bars, NOW divider, month.
7. **Challenges.** Cards with ring, detail with big ring and **Record
   today**.
8. **Insights.** Home cards, plan vs reality rows, progression page.
9. **Everything else.** Browse, builder, field sheet, sheets, Me lists,
   measurements, focus timer, empty/error states.
10. **Polish pass.** Accessibility (200% text, TalkBack, reduced motion),
    visual checklist per theme, device run on the phone.

---

## 7. How to treat each Stitch screen

| Treatment | Screens |
|---|---|
| **Direct visual reference** (layout + look) | Today Living Pulse (×3) · Plan Timeline (×3) · Record Live Session (×3, generic version) · Insights Self-Understanding (×3, the cards we have data for) |
| **Inspiration only** (structure/content ideas) | Log Activity form · Quick Log · Me Activity Studio · Onboarding (for Phase 7) |
| **States to adapt** | Today first-time empty (×2) · Plan first-time empty (×3) · Insights first-time empty |
| **Do not copy** | Anything named LifeOS (name undecided, ADR-010) and its logo; Pastel Confection's finance copy and its Flowfy hex values; avatars/photos/levels; energy reserve, calibration, chronotype; HealthKit/Oura/Apple Watch, calendar ingest; AI transcription; budgets/₹; correlations and auto-actions; routines/rituals/blueprints; kcal/heart rate/video |

---

## 8. V1 scope boundaries

**Build now (this redesign):**
- Three light themes, Me → Appearance, saved locally.
- Plus Jakarta Sans; new tokens; restyled + new shared components.
- Every existing screen redesigned to the Stitch reference (§2).
- Today hero ring + Up next; item cards with status chips.
- Plan week strip + inline day + plan-vs-actual (D5).
- Item screen steppers for list numbers (generic).
- Challenges restyle + Record today.
- Insights: plan vs reality rows, progression cards.
- Empty states per screen.

**Build later (separate approval):**
- Onboarding (Phase 7) using the Stitch structure.
- Challenge reminders (step 2; needs a package + permission).
- Data export/backup (OQ-03).
- Optional local name for the greeting (D6).
- Generic quick-amount action ("+ 250 ml") for single-number activities.
- Factual headline insight on Insights ("You did Gym 12 days this month, 3
  more than September"), from numbers we already compute.
- Dark mode for the three themes.

**Do not build yet:** goals/targets, budgets/expenses, routines/rituals,
correlations, AI anything, sensors/health sync, photos/audio, levels/XP,
notifications bell, sharing, accounts/avatars.

---

## 9. Risks

| Risk | What could go wrong | Guard |
|---|---|---|
| Theme duplication | Screens grow `if (theme == papaya)` | Features never see the variant; only `ThemeSpec` values and shared components read treatments. A test/grep check in review: no `ThemeVariant` import under `lib/features/*` except settings. |
| Inconsistent components | One-off styled widgets per screen | Every visual element comes from `lib/shared/widgets`; built in the showcase first; ui_rules updated. |
| Overfitting to Stitch | Copying invented metrics, gym-only UI, broken renders | §7 table; generic components driven by field definitions; Stitch values adjusted for contrast. |
| Breaking functionality | Visual refactor regresses flows | No domain/data changes; 440 tests stay green; widget tests use keys/semantics, not colors; one screen per step. |
| Visual inconsistency between screens | New screens look new, old ones old | Step 2 restyles shared components first, so all screens move together; polish pass per theme. |
| Accessibility | Stitch's bright CTAs fail contrast | Automated contrast test per theme; dark text on bright fills. |
| Flowfy resemblance | Rose theme too close | D2: rebuilt from our own colors; no "flowfy" names anywhere. |
| Text scale | Big rounded cards overflow at 200% | Smoke test at 2.0 text scale per theme. |
| Performance | Glows/blur on low-end Android | Shadows only on cards (no live blur); measure list scroll on the phone. |
| Scope creep | Stitch concepts sneak in | §8 lists; anything else needs owner approval. |

---

## 10. Recommended first vertical slice

**"Today in three themes."** Something to run on the phone and judge as a
real product:

1. Theme foundation (step 1) with all three themes.
2. Shared components needed by Today and the item screen (cards, buttons,
   chips, status chip, ring, item card, up next card, nav in both styles,
   progress bar, empty state card).
3. **Me → Appearance** to switch themes.
4. **Today** fully redesigned: hero + ring, Up next with Start, item
   cards, challenges section, first-time empty state.
5. **Item screen** restyled enough that Today → open item → log → back
   feels like one product (header, field cards, steppers for list numbers).
6. Bottom nav restyled; the other tabs pick up the new tokens and fonts
   automatically (not yet redesigned, but no longer the old look).

Done when: the owner can switch between the three themes on the phone,
Today and an open item look like the Stitch reference in each, every check
is green, and the docs/ADR describe exactly that.

Rough size: steps 1–3 ≈ 1 session, Today + item ≈ 1–2 sessions. Plan,
Challenges, Insights and the rest follow one screen per step.
