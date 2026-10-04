# Design System

> The canonical source for every visual value in the app. Feature code consumes **semantic tokens** from here and never hardcodes colors, type styles, spacing, radii, shadows, durations or curves.
> Interaction patterns, screens and states: [ui_guidelines.md](ui_guidelines.md). Layout adaptation: [responsive_design.md](responsive_design.md).
>
> **Owner direction for the upcoming visual pass (2026-10-04).** The current look reads as a functional prototype: cream/white surfaces with basic cards and forms. After the core functionality is done, one **dedicated visual/product-design pass across the whole app** will replace the provisional v0 values. It won't patch screens one by one. The brief:
> - **Colorful, alive, polished, premium, enjoyable**: a product people *want* to open every day. Not the cream/yellow-heavy v0, not all dark, not plain white. A balanced system of soft but meaningful colors; activity colors stay colorful.
> - Typography, spacing, cards, buttons, icons, progress indicators, illustrations and empty states should feel like a real consumer product. Clean doesn't mean empty.
> - The product story is **Plan → Do → Record → Measure → Understand → Improve**, not just planning. Today = a living view of the day. Plan = designing the future. Record = naturally continuing a planned activity. Insights = "am I actually improving?" Me = personal configuration.
> - Planner apps such as PlanWiz are a reference for *quality of feel only*. Never copy their layouts, colors or branding.
> - **Until then:** no visual redesign, no architecture changes for looks, no new features from this direction. Keep everything token-driven (colors, type, spacing, radii, sizes in `AppSizes`, motion) and in shared components, so the pass can change the visual system without touching domain or database code.
>
> **Status: Accepted as provisional v0 (ADR-016).** The *structure* (token categories, semantic roles, rules) is binding. The concrete *values* (hex codes, font families, motif) are provisional until the owner reviews the dev token showcase on a device. "Daylight" is the design direction's name, never the product name (ADR-010). Contrast ratios listed were computed for the proposed values (WCAG 2.x formula).

---

## 1. Identity concept

**What the product is about:** understanding and improving how a person spends their time and lives their day (§33.1). The identity draws on **the shape and light of a day**: dawn, daylight, dusk, night. It does not borrow from fitness or productivity clichés.

Working concept name: **"Daylight"** (internal design language name, not the product name).

| Quality (§33) | How the identity delivers it |
|---|---|
| Calm, easy on the eyes | Warm paper-like neutrals instead of stark white; deep night blue-ink instead of pure black; low-saturation pastels |
| Premium, intentional | Confident editorial display type paired with a clean UI sans; generous spacing; restrained depth |
| Personal | Each activity owns a color from a curated palette; greetings and copy adapt to the time of day and the user's activities |
| Visually distinctive | Signature motifs: the **Day Arc** and the **Plan vs Reality** visual language (§1.1, §1.2) |
| Fast, uncluttered | Few surfaces, few buttons, progressive disclosure, motion that finishes quickly |

### 1.1 Signature motif: the Day Arc
A soft horizon arc that represents the hours of a day. Used sparingly and consistently:
- Today header: shows progress through the day; logged activities appear as colored segments along the arc.
- Onboarding: the narrative device (the arc rises as the user progresses).
- Focus Mode: a slow-filling arc/ring around the timer.
- Completion states: brief arc "fill" animation.
Never used as decoration on data-dense screens (Insights, History).

### 1.2 Plan vs Reality visual language (core, product-wide)
The product's central distinction (§20) gets a consistent visual grammar:
- **Planned** = *outline*: dashed or thin 1.5dp border in the activity color, transparent/canvas fill, secondary text.
- **Actual (logged)** = *filled*: activity `soft` surface with a solid activity-color accent (bar/dot/icon), primary text.
- **Completed task** = filled check with a brief fill animation; title in secondary color (not struck through by default; strike-through is visually noisy).
- **Skipped/cancelled** = outline at reduced emphasis + status label (never red; skipping is not an error).
Shape carries the meaning, not only color (accessibility).

### 1.3 Relationship to the reference (Flowfy)
Principles adopted (§33.1): cohesive visual world, soft pastel surfaces, large confident display type, rounded touch-friendly components, subtle borders over heavy shadows, small memorable accent set, purposeful illustration, conversational onboarding, progressive disclosure, personalization, outcome-oriented copy.
**Not adopted:** its palette, fonts, illustrations, mascot, layouts, wording, component designs. No mascot is planned for this product. Any resemblance found in review must be changed.

---

## 2. Color

### 2.1 Token architecture
```text
Raw palette (private)  →  Semantic roles (public, theme-aware)  →  Components
   e.g. linen100              surface.canvas                          AppSurface
```
- Feature code uses **semantic roles only** (`tokens.color.surfaceCanvas`, `tokens.color.textSecondary`, `tokens.activity(key).soft`).
- Raw palette values are referenced only inside `core/design/`.
- Every semantic role has a light and a dark value.

### 2.2 Semantic roles: neutrals & brand

**ADR-029 (owner decision):** apart from neutrals (surfaces, text, borders, scrims), **every color in the app is one of the nine activity-palette colors** (§2.4):
- brand = **teal**
- accent = **apricot**
- success = **moss**
- warning = **apricot** (sand was removed from the palette)
- danger = **rose**

`test/core/design/palette_consistency_test.dart` enforces this.

| Role | Light | Dark | Usage | Contrast notes |
|---|---|---|---|---|
| `surfaceCanvas` | `#F5F1EA` (Linen) | `#12141B` (Night ink) | App background | — |
| `surfaceBase` | `#FBF8F3` | `#1A1D26` | Primary content surfaces, sheets | — |
| `surfaceRaised` | `#FFFDF9` | `#232735` | Floating elements (menus, popovers, FAB container) | — |
| `surfaceSunken` | `#ECE6DB` | `#0D0F14` | Wells, input backgrounds, segmented control track | — |
| `borderSubtle` | `#E2DACB` | `#2C3040` | Hairline separators, card outlines (decorative) | decorative only |
| `borderStrong` | `#8C8270` | `#6E7488` | Input outlines, focus-adjacent boundaries | ≥ 3:1 on canvas (3.37 / 3.96) |
| `textPrimary` | `#1F1D2B` | `#F1EEE8` | Body and headings | 14.7 / 15.9 on canvas |
| `textSecondary` | `#5E5A6B` | `#B4B0BE` | Supporting text, metadata | 5.9 / 8.7 |
| `textTertiary` | `#8A8595` | `#86839A` | Placeholders, disabled, large-only decorative text | 3.2 / 5.0 (light: **not** for small essential text) |
| `brandPrimary` | `#2F8180` (**teal** solid) | `#7CCBC8` (teal solid) | Primary actions, selection, focus ring, links | white text on it 4.59:1; 4.1 / 9.8 vs canvas (graphics) |
| `onBrandPrimary` | `#FFFFFF` | `#12141B` (Night ink) | Text/icons on primary | 4.59 / 9.84 |
| `brandPrimarySoft` | `#DDF0EF` (teal soft) | `#162B2B` (teal soft) | Selected chips, highlighted rows, nav indicator | — |
| `onBrandPrimarySoft` | `#1F1D2B` (= textPrimary) | `#F1EEE8` (= textPrimary) | Text/icons on soft primary | ≥ 4.5 |
| `accentDawn` | `#B8642F` (**apricot** solid) | `#F2A877` (apricot solid) | Rating stars, highlights, Day Arc "now" marker, celebration accents | graphics only (3.8 / 9.3); **never small text** |
| `scrim` | `#1F1D2B` @ 40% | `#000000` @ 60% | Behind sheets/dialogs | — |

### 2.3 Semantic roles: status

| Role | Light | Dark | Container (light / dark) | Usage |
|---|---|---|---|---|
| `success` | `#6B7A2E` (**moss**) | `#B8C87A` | `#EDF0DA` / `#262A17` (moss soft) | Completion, saved. Icons/fills only, never small text (4.19:1 light) |
| `warning` | `#B8642F` (**apricot**) | `#F2A877` | `#FBE9DC` / `#33231A` (apricot soft) | Non-blocking caution. Icons/fills only, never small text (3.81:1 light) |
| `danger` | `#B04E62` (**rose**) | `#EE9AAA` | `#F8E3E7` / `#331E24` (rose soft) | Destructive actions, real errors; may be text (4.54:1 light) |
| `info` | = `brandPrimary` | = `brandPrimary` | = `brandPrimarySoft` | Neutral notices |

Status colors are never used to judge the user (a skipped plan is neutral, not `danger`).

### 2.4 Activity palette

Users pick an activity color from a curated set. The DB stores the **key**. Each key resolves to four theme-aware values:

| Key | `solid` light | `soft` light | `solid` dark | `soft` dark |
|---|---|---|---|---|
| `sage` | `#5E8B6B` | `#E3EEE5` | `#8FC29D` | `#1E2B23` |
| `sky` | `#4A78A8` | `#E1ECF7` | `#8DB6E3` | `#1B2533` |
| `lilac` | `#7A62B5` | `#ECE6F8` | `#B9A6EC` | `#251F35` |
| `apricot` | `#B8642F` | `#FBE9DC` | `#F2A877` | `#33231A` |
| `rose` | `#B04E62` | `#F8E3E7` | `#EE9AAA` | `#331E24` |
| `teal` | `#2F8180` | `#DDF0EF` | `#7CCBC8` | `#162B2B` |
| `coral` | `#C0503E` | `#FBE4DF` | `#F29A89` | `#341E1A` |
| `slate` | `#5D6A80` | `#E6E9EF` | `#A8B3C7` | `#20242C` |
| `moss` | `#6B7A2E` | `#EDF0DA` | `#B8C87A` | `#262A17` |

Usage rules:
- `solid` → icons, accent bars, chart lines/bars, dots (graphics; ≥ 3:1 in light, 3.5–4.9 against canvas and 3.3–4.5 against its own `soft`; ≥ 7:1 in dark against both).
- `soft` → tinted surfaces for logged items, activity headers, selected states.
- **Text on `soft` is always `textPrimary`/`textSecondary`**, never `solid` (light-mode solids are below 4.5:1 for small text).
- A screen may show many activity colors, but **one screen = one dominant accent** (brand or the focused activity) to avoid rainbow clutter.
- Adding or removing a palette key is a design-system change (tokens + contrast check + ADR), never a user-entered hex. `sand` was removed by owner decision (ADR-029). A stored key that no longer exists renders with the `slate` fallback until the user picks a new color.

### 2.5 Gradients
Allowed only for: the Day Arc sky wash (subtle, 2 stops, ≤ 15% lightness change) and onboarding/illustration backgrounds. Never on buttons, cards, charts or text. (Avoid "excessive gradients", §33.5.)

---

## 3. Typography

### 3.1 Families (provisional, bundled, OFL-licensed)

| Role | Family | Why |
|---|---|---|
| **Display / headline** | **Fraunces** (variable; use soft, low-contrast settings, `opsz` matched to size, weights 500–600) | Warm, editorial, human: gives the "personal, premium" voice and is unlike typical productivity apps |
| **UI / body** | **DM Sans** (or Manrope as alternative) | Clean, friendly geometric sans with good small-size legibility |
| **Numeric / data** | **DM Mono** (OFL, Regular + Medium; ADR-032), monospaced digits | Stable digits for timers, durations, tables, charts |

Fallback: platform default sans. Fonts are bundled assets; ship only the weights used. Validate the final choice for Latin glyph coverage, tabular figure support, and rendering at small sizes on Android during the token showcase review (ADR-016).

**Bundled files (Phase 1):** `assets/fonts/fraunces/Fraunces-Variable.ttf` (axes opsz, wght, SOFT, WONK) and `assets/fonts/dm_sans/DMSans-Variable.ttf` (axes opsz, wght), each with its `OFL.txt`. Flutter family names: `Fraunces`, `DMSans`. Weight and optical size are applied through `FontVariation`s. Display styles use `SOFT 50, WONK 0`.

**Validation finding (resolved by ADR-032):** neither bundled variable font has a `tnum` feature, so the numeric tokens use DM Mono, whose digits are all the same width.

### 3.2 Type scale

Size/line-height in logical px. Tokens are semantic; never use raw sizes in features.

| Token | Family | Size / LH | Weight | Tracking | Usage |
|---|---|---|---|---|---|
| `displayLarge` | Display | 40 / 46 | 560 | −0.5 | Onboarding statements, completion headlines |
| `displayMedium` | Display | 32 / 38 | 560 | −0.4 | Today greeting, tab titles (large-title style) |
| `headlineLarge` | Display | 26 / 32 | 560 | −0.2 | Screen titles, activity name on detail |
| `headlineSmall` | Display | 21 / 27 | 560 | 0 | Section titles in rich screens |
| `titleLarge` | UI | 18 / 24 | 600 | 0 | Card/list group titles, sheet titles |
| `titleMedium` | UI | 16 / 22 | 600 | 0 | List item primary text |
| `bodyLarge` | UI | 16 / 24 | 400 | 0 | Primary reading text, inputs |
| `bodyMedium` | UI | 14 / 20 | 400 | 0.1 | Secondary text, descriptions |
| `labelLarge` | UI | 15 / 20 | 600 | 0.1 | Buttons |
| `labelMedium` | UI | 13 / 18 | 600 | 0.2 | Chips, tabs, field labels |
| `labelSmall` | UI | 11 / 14 | 600 | 0.5, uppercase optional | Overlines, chart axes |
| `numericHero` | DM Mono | 72 / 76 | 400 | −2 | Focus timer |
| `numericLarge` | DM Mono | 34 / 40 | 500 | −0.5 | Insight headline numbers ("4h 32m") |
| `numericMedium` | DM Mono | 20 / 24 | 500 | 0 | Durations on timeline, set table cells, focus banner |

Rules: display family only at ≥ 21px; max two families per screen (display + UI); body text never below 14px; hierarchy via size/weight/color, never via ALL CAPS paragraphs. All styles scale with system text size (see accessibility).

---

## 4. Spacing

4-pt base. Tokens: `space.{name}`.

| Token | Value | Typical use |
|---|---|---|
| `xxs` | 2 | Icon–badge nudge |
| `xs` | 4 | Tight inline gaps |
| `sm` | 8 | Between related elements (icon ↔ label, chip gaps) |
| `md` | 12 | Inside compact components |
| `lg` | 16 | Default padding inside components; list item vertical rhythm |
| `xl` | 20 | Screen horizontal margin (compact) |
| `xxl` | 24 | Between groups; screen margin (medium) |
| `xxxl` | 32 | Between major sections; screen margin (expanded) |
| `huge` | 48 | Hero spacing, onboarding |
| `giant` | 64 | Top-of-screen breathing room on large layouts |

Screen margins per breakpoint: [responsive_design.md](responsive_design.md). Prefer whitespace and grouping over boxes/cards (avoid "excessive cards").

## 5. Corner radius

| Token | Value | Use |
|---|---|---|
| `radius.xs` | 6 | Small tags, chart tooltips |
| `radius.sm` | 10 | Inputs, set table cells, small chips |
| `radius.md` | 16 | List groups, cards, buttons (non-pill) |
| `radius.lg` | 24 | Sheets (top corners), large surfaces, onboarding cards |
| `radius.xl` | 32 | Hero surfaces, focus mode controls |
| `radius.pill` | 999 | Primary buttons, chips, segmented controls, FAB |

Nested radii: inner radius = outer radius − padding (never larger than the container's).

## 6. Borders, separators & component sizes

Component sizes (badges, touch target, strokes, chart line/height, day cell) are `AppSizes` tokens (`core/design/tokens/sizes.dart`); features never use size literals.


- `border.hairline` = 1dp `borderSubtle`: default outline for grouped surfaces in light mode (instead of shadows).
- `border.input` = 1dp `borderStrong`; focused = 2dp `brandPrimary`.
- `border.planned` = 1.5dp dashed (6 on / 4 off) in activity `solid` @ 70%.
- Separators inside lists: hairline inset to text start; omit when spacing alone separates items.

## 7. Elevation & shadows

Depth is restrained (§33.1). Three levels only:

| Level | Light | Dark | Use |
|---|---|---|---|
| `elevation.flat` | none (hairline border) | none (surface tone step) | Most content |
| `elevation.raised` | `0 1 2 rgba(31,29,43,0.06)`, `0 4 12 rgba(31,29,43,0.06)` | none; use `surfaceRaised` tone + hairline | Floating buttons, active drag item |
| `elevation.overlay` | `0 8 24 rgba(31,29,43,0.12)` | `0 8 24 rgba(0,0,0,0.5)` | Sheets, menus, dialogs |

Dark mode communicates depth with lighter surface tones, not shadows. Never stack shadows on cards in scrolling lists.

## 8. Iconography

- One icon family app-wide: **Phosphor** (ADR-024): regular weight for default, **fill** for selected states (navigation, rating stars).
- It is integrated by bundling the official MIT-licensed font files (`assets/fonts/phosphor/`, from `@phosphor-icons/web` 2.1.2) instead of the `phosphor_flutter` package, which doesn't compile on Flutter 3.47.
- Glyphs are referenced **only** inside `lib/core/design/`:
  - `AppIcons` names UI icons semantically (`AppIcons.add`, `AppIcons.delete`, …).
  - `ActivityIconRegistry` resolves stored `icon_id`s.
- `phosphor_glyphs.dart`, `activity_icon_registry.dart` and `keys/activity_icon_ids.dart` are **generated** by `tool/generate_phosphor_glyphs.py`. To add an icon, add its Phosphor name to the script and re-run it.
- Sizes: 16 (inline meta), 20 (dense UI), 24 (default), 32 (activity badges), 48+ (empty states, use illustration instead when possible).
- **Activity icons:** a curated catalog of 58 stable IDs (Phosphor names such as `barbell`, `book-open`, `briefcase`, `person-simple-walk`, `flower-lotus`, `translate`, …). The DB stores the ID (`activity_types.icon_id`), never a glyph or codepoint. IDs are permanent, and an unknown ID falls back to `sparkle`.
- Activity badge = icon in `solid` on a `soft` circle/squircle (`radius.md`). This badge is the activity's identity everywhere (timeline, quick log, insights legend).
- Icons never stand alone for unfamiliar actions; pair with labels or provide tooltips + semantics.

## 9. Motion

Motion communicates state and continuity; never decoration alone (setup §8A.6, §33.6).

| Token | Duration | Curve | Use |
|---|---|---|---|
| `motion.instant` | 90 ms | `easeOut` | Press feedback, toggles, checkbox fill start |
| `motion.fast` | 150 ms | `easeOutCubic` | Small state changes, fades, chip selection |
| `motion.standard` | 250 ms | `easeInOutCubicEmphasized` | Expand/collapse, sheet in, list insert/remove |
| `motion.emphasized` | 400 ms | `easeInOutCubicEmphasized` | Screen transitions, container transforms, chart transitions |
| `motion.celebrate` | 600–900 ms | spring (damping ~0.8) | Completion moments only (session complete, plan completed); never blocks input |

Patterns:
- **Navigation continuity:** shared-axis/fade-through between tabs (short), container transform from an item to its detail where it clarifies origin.
- **Reorder / drag:** lifted item scales to 1.02 with `elevation.raised`; neighbors slide with `standard`.
- **Timer:** pause/resume crossfades control state and dims/brightens the arc; no per-second bouncing.
- **Charts:** animate between ranges/metrics (morph line, `emphasized`); first load fades in, does not "draw" slowly every time.
- **Lists:** inserted items fade + size in; removed items size out with undo affordance.
- **Reduced motion:** when `MediaQuery.disableAnimations` (or platform "remove animations") is set, replace movement with ≤ 150ms crossfades and skip celebrations.
- No animation delays a common action (save, navigate, open sheet). Users can interact during exit animations.

## 10. Interaction feedback

| Event | Visual | Haptic (Android/iOS via wrapper) |
|---|---|---|
| Press | Surface tint/ripple in brand at low opacity, 90ms; custom ink, not default grey | none |
| Toggle / select | State change with `fast` | selection click |
| Reorder pick-up / drop | Lift / settle | light impact |
| Save log / finish session / complete plan | Success state or brief check animation | success notification (light) |
| Destructive action | Undo snackbar | none |
| Validation error | Inline message + field highlight | light warning (once per submit) |
| Timer start/pause | Control morph | light impact |

Haptics respect system settings; never on scroll or per-second ticks.

## 11. Component states

Every interactive component defines: `default`, `hovered` (tablets with pointer/stylus), `focused` (keyboard/switch access: 2dp `brandPrimary` ring with 2dp offset), `pressed`, `selected`, `disabled` (`textTertiary` + 38% surface contrast, no interaction), `loading` (inline progress replaces label, width preserved), `error` (danger border + message).
State layers: overlay of the content color at 8% (hover), 12% (focus/pressed), 16% (dragged).

## 12. Illustration

- **Original** illustrations only. Style: simple, soft geometric and organic shapes built on the Day Arc/horizon idea (sun/moon discs, horizon lines, layered hills, soft paper textures), using the brand and activity palettes, with flat fills and minimal line work. No characters/mascot unless decided later.
- Used in: onboarding, empty states, completion states, feature introductions, error/fatal screens. **Not** on Insights, History or forms.
- Delivered as vector (SVG rendered via a vector package, or `CustomPaint` for simple motifs). Must have light and dark variants or use theme tokens.
- Size: illustrations occupy ≤ 40% of the viewport height on compact screens; content and actions remain visible without scrolling.
- Asset production is an open task (no assets exist yet).

## 13. Data visualization tokens

- Series color = activity `solid`; comparison/previous period = same hue at 40% or `textTertiary` dashed.
- Body measurements use `brandPrimary` (or `slate`) since they have no activity color.
- Gridlines: `borderSubtle`, horizontal only, max 4; axis labels `labelSmall` `textSecondary`.
- Line width 2.5dp; points shown only for ≤ 31 points or on selection; selected point = 8dp dot with `surfaceBase` ring.
- Bars: `radius.xs` top corners; 60–70% band width.
- Tooltip/scrubber: `surfaceRaised`, `elevation.overlay`, `numericMedium` value + `labelSmall` date.
- Empty chart: neutral baseline + message, never a fake chart.

## 14. Accessibility (binding)

- Contrast: body text ≥ 4.5:1; large text (≥ 18.66px bold / 24px) and UI graphics ≥ 3:1. All semantic pairs above meet this except where marked "decorative/never text".
- Touch targets ≥ 48×48dp (visual element may be smaller; hit area may not).
- Text scales to 200% without clipping or loss of function (layouts reflow; numeric hero scales down gracefully with a min).
- Never rely on color alone: plan vs actual uses outline vs fill; status uses icon + label.
- Semantics for custom-painted elements (Day Arc, charts: provide a textual summary such as "Reading, last 7 days, total 4 hours 12 minutes, highest Thursday").
- Focus order follows visual order; all actions reachable by TalkBack/Switch Access.
- Respect reduced motion, bold text and system font scale.

---

## 15. Implementation (Flutter)

*Implemented in Phase 1.*

```text
lib/core/design/
├── tokens/
│   ├── color_tokens.dart       # raw palette (private) + semantic roles (light/dark)
│   ├── activity_palette.dart   # key → ActivityColors(solid, soft, …) per brightness
│   ├── typography.dart         # text style tokens
│   ├── spacing.dart            # const spacing values
│   ├── radius.dart
│   ├── elevation.dart
│   └── motion.dart             # durations + curves
├── app_theme.dart              # builds ThemeData (light/dark): ColorScheme, TextTheme, component themes from tokens
├── app_tokens.dart             # ThemeExtension<AppTokens> for roles Material doesn't model
├── context_ext.dart            # context.tokens, context.colors, context.textStyles
├── app_icons.dart              # semantic UI icon map (Phosphor, ADR-024)
├── icons/                      # generated: phosphor_glyphs.dart, activity_icon_registry.dart
├── keys/                       # pure Dart: activity_icon_ids.dart (generated), activity_color_key.dart
└── window_size_class.dart      # compact/medium/expanded + screen margins + content widths
```

Activity colors resolve with `context.tokens.activity(ActivityColorKey.sage)`. Numeric styles (no Material slot) are `AppTypography.numericHero/Large/Medium`. `AppTheme.light`/`AppTheme.dark` are built once. Not yet implemented: `inputDecorationTheme` (no inputs exist yet), page-transition customization (Flutter defaults), the planned-border token and the Day Arc (no screen uses them yet).

- `ThemeData` is fully derived from tokens so that remaining Material widgets inherit the identity (`ColorScheme`, `TextTheme`, `inputDecorationTheme`, `filledButtonTheme`, `bottomSheetTheme`, `navigationBarTheme`, `snackBarTheme`, page transitions, splash factory).
- Roles not covered by Material (surface steps, activity palette, planned border, motion) live in `AppTokens` (`ThemeExtension`) with `lerp` for smooth theme switching.
- Spacing/radius/motion are `const` (theme-independent); colors and text styles are theme-dependent and accessed via context.
- A **debug-only token showcase screen** (`lib/app/dev/`, route `/dev/tokens`, opened from Me → "Design tokens (debug)") renders colors, the activity palette, the type scale, spacing, radius, elevation and buttons, with a System/Light/Dark switch.
- `test/core/design/color_contrast_test.dart` enforces the contrast promises in §2 and §14 for both themes.
- Theme mode: System (default) / Light / Dark preference.
