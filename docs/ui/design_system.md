# Design System

> The canonical source for every visual value in the app. Feature code consumes **semantic tokens** from here and never hardcodes colors, type styles, spacing, radii, shadows, durations or curves.
> Interaction patterns, screens and states: [ui_guidelines.md](ui_guidelines.md). Layout adaptation: [responsive_design.md](responsive_design.md).
>
> **Status: three light themes on one token system (ADR-045, 2026-10-08).** The visual reference is the owner's Stitch project ("Personal Life OS", exports in `design/stitch_personal_life_os*/`), studied in [visual_redesign_plan.md](visual_redesign_plan.md). It replaced the provisional "Daylight" v0 values (ADR-016) and the six-color restriction (ADR-038). Built so far: the tokens and shared components, Me → Appearance, Today and the item screen (the first vertical slice). Plan, Challenges, Insights and Me get their own screen-level pass after the owner reviews the slice; until then they use the new tokens and components without a new layout.

---

## 1. Identity

**One product, three visual personalities.** The user picks a theme in Me → Appearance; everything about the product (screens, flows, data, components) is the same in each. Themes differ in token *values* and a few *treatments* read only by shared components (§7.1). Screens never branch on the theme.

| Theme (working name) | Canvas | Signature (`brandPrimary`) | Action (`action`) | Accent | Character |
|---|---|---|---|---|---|
| **Rose** (`rose`) | blush `#FBF4F5` | rose `#B04E62` | teal `#2F8180` | butter `#9A6A12` | soft, warm; borderless cards with a rose glow |
| **Lavender** (`lavender`, default) | porcelain `#F8F8FE` | electric lavender `#6847F0` | mint `#047857` | sky `#0369A1` | crisp, luminous; hairline lavender edges, lavender→mint progress |
| **Papaya** (`papaya`) | warm porcelain `#FBF9F7` | papaya `#C93A1B` | aqua mint `#2DD4BF` (dark text) | periwinkle `#4F46E5` | bright, tactile; rimmed cards, sand wells, floating nav, coral→peach progress, facts as chips |

The rose theme is built from the app's own rose and teal. It deliberately does not use the Stitch export's pink/teal values, which are another product's palette.

Qualities (§33) the system delivers: calm (tinted canvases, never pure white or black), premium (heavy display type, generous rounded cards, soft tinted glows), personal (each activity keeps its color; the theme is the user's choice), distinctive (status chips and the done check, the day ring, Up next), fast (one big action per card; cards, not forms).

### 1.1 Plan vs Reality visual language (product-wide)
Every item on a day is an **item card** (`ItemCard`): activity badge, time, a **status chip**, title, what was logged, and the **done check** on the right.
- **Planned** = `scheduled` chip ("Planned"), open ring in the activity color.
- **In progress** = `active` chip ("In progress"; "Live" while its timer runs).
- **Done** = `done` chip with ✓ and the filled check circle in `success`; the summary shows what was logged and, for a planned length, "45 min of 1 h".
- **Skipped / cancelled** = neutral chip, the card fades to 55% (never red; skipping is not an error).
- Text always says the state; color and the check only reinforce it (accessibility).

### 1.2 References
- **Stitch "Personal Life OS"** (owner's own design work): visual and UX reference for tokens *and* screen composition (ADR-045). Its example content (gym sets, kcal, budgets, sensors, AI) never dictates the data model; screens are built from the generic engine.
- **Flowfy**: principles only (§33.1). Not its palette, fonts, illustrations, layouts or wording. No product name, file or token may contain "Flowfy".

---

## 2. Color

### 2.1 Token architecture
```text
Theme values (lib/core/design/themes/*_theme.dart)  →  AppColors roles (public)  →  shared components / screens
```
- Feature code uses **semantic roles only** (`context.colors.surfaceCanvas`, `context.colors.textSecondary`, `context.tokens.activity(key).soft`).
- Hex values live only in the three theme files.
- Every role has a value in every theme. All themes are light (ADR-045); there is no dark mode for now.

### 2.2 Roles

| Role | Rose | Lavender | Papaya | Usage |
|---|---|---|---|---|
| `surfaceCanvas` | `#FBF4F5` | `#F8F8FE` | `#FBF9F7` | Screen background |
| `surfaceBase` / `surfaceRaised` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` | Cards, sheets, menus |
| `surfaceSunken` | `#F7E8EB` | `#F1EEFD` | `#F4EFEA` | Inputs, tracks, wells, folded rows |
| `borderSubtle` | `#F1DEE3` | `#E8E4FA` | `#EEE6E0` | Hairlines, card edges (decorative) |
| `borderStrong` | `#8F6F79` | `#837E9E` | `#8A746D` | Meaningful outlines (≥ 3:1) |
| `textPrimary` | `#2B2330` | `#1E1B4B` | `#1E232F` | Headings, body |
| `textSecondary` | `#5C5262` | `#4B4868` | `#4F5563` | Metadata, descriptions |
| `textTertiary` | `#8C8291` | `#7D7A96` | `#828795` | Placeholders, disabled (never small essential text) |
| `brandPrimary` / `onBrandPrimary` | `#B04E62` / white | `#6847F0` / white | `#C93A1B` / white | Selection, primary buttons, links, focus |
| `brandPrimarySoft` / `onBrandPrimarySoft` | `#F9E1E7` / `#7A2C3D` | `#ECE8FE` / `#4A2BC2` | `#FFE9E2` / `#9A2A10` | Active chips, nav indicator, steppers |
| `action` / `onAction` | `#2F8180` / white | `#047857` / white | `#2DD4BF` / `#1E232F` | Big "go" actions: Start, Mark done |
| `actionSoft` / `onActionSoft` | `#DDF0EF` / `#1D5655` | `#D9F7E8` / `#065F46` | `#DDF8F4` / `#0F6B62` | Done chips |
| `accent` / `accentSoft` / `onAccentSoft` | `#9A6A12` / `#FBF0D5` / `#6B4A0C` | `#0369A1` / `#E0F2FE` / `#075985` | `#4F46E5` / `#EEF0FF` / `#3730A3` | Scheduled chips, info |
| `accentDawn` | `#D9822B` | `#F59E0B` | `#FF6B4A` | Rating stars (graphics only) |
| `success` / `successContainer` | `#2F8180` / `#DDF0EF` | `#059669` / `#D9F7E8` | `#0D9488` / `#DDF8F4` | Done check, saved (icons/fills) |
| `warning` / `warningContainer` | `#B4582A` / `#FBE8DC` | `#C2410C` / `#FFEDE0` | `#C2410C` / `#FFEDE0` | At risk (icons/fills) |
| `danger` / `dangerContainer` | `#B4233F` / `#FBE3E8` | `#BE123C` / `#FFE4E8` | `#BE123C` / `#FFE4E8` | Errors; may be text |
| `scrim` | ink @ 40% | ink @ 40% | ink @ 40% | Behind sheets |

**Contrast (enforced by `test/core/design/color_contrast_test.dart` for every theme):** text roles ≥ 4.5:1 on canvas, cards, wells and every soft container; every `on*` role ≥ 4.5:1 on its fill; graphic roles ≥ 3:1 on canvas and cards; brand and danger ≥ 4.5:1 (usable as text). Stitch's bright fills fail with white text (mint 2.5:1, papaya 2.8:1), so bright fills carry dark text (Papaya's action) or a deeper tone is used.

Status colors never judge the user (a skipped plan is neutral, not `danger`).

### 2.3 Activity palette
The DB stores one of six keys (`sky`, `lilac`, `rose`, `teal`, `coral`, `slate`); each theme resolves them to its own `solid` + `soft`, so an activity's color sits in the theme:

| Key | Rose (solid / soft) | Lavender | Papaya |
|---|---|---|---|
| `sky` | `#4A78A8` / `#E1ECF7` | `#0284C7` / `#E0F2FE` | `#0284C7` / `#E0F2FE` |
| `lilac` | `#7A62B5` / `#ECE6F8` | `#7C5CFC` / `#EDE9FE` | `#5B5BD6` / `#EEF0FF` |
| `rose` | `#B04E62` / `#F8E3E7` | `#DB2777` / `#FCE7F3` | `#E11D48` / `#FFE4E9` |
| `teal` | `#2F8180` / `#DDF0EF` | `#059669` / `#D9F7E8` | `#0D9488` / `#D9F7F3` |
| `coral` | `#C0503E` / `#FBE4DF` | `#EA580C` / `#FFEDE0` | `#E8512F` / `#FFEAE3` |
| `slate` | `#5D6A80` / `#E6E9EF` | `#64748B` / `#EEF1F6` | `#5B6170` / `#EEF0F3` |

Rules: `solid` for icons, bars, chart marks (≥ 3:1 on cards and on its `soft`); `soft` for tinted surfaces; text on `soft` is always a text role. Keys are permanent: `sand` was removed (ADR-029); stored `sage`/`moss` show as teal and `apricot` as coral (`ActivityColorKey.fromName`); any other unknown key falls back to `slate`.

### 2.4 Gradients
Allowed for: progress fills in themes whose treatment says so (§7.1), the hero card's corner wash, the empty-state orb. Never on text or as card fills.

---

## 3. Typography

### 3.1 Family (ADR-045)
**Plus Jakarta Sans** (OFL, v2.071 Google Fonts build), bundled as static weights 400/500/600/700/800 in `assets/fonts/plus_jakarta_sans/` with `OFL.txt`. Flutter family `PlusJakartaSans`. One family for every theme and every role.

Why (owner asked for a deliberate choice, not a copy): it is the family of all three Stitch directions, and its heavy 700–800 headlines with tight tracking are what give those screens their confident, friendly hierarchy. Fraunces' editorial serif fought the pill-and-card composition. It has **tabular figures** (`tnum`), so numbers and running timers no longer need DM Mono (whose monospace look read as technical; ADR-032 superseded). It covers ₹ € ° × –, and one family is lighter to ship than three. Previously bundled: Fraunces, DM Sans, DM Mono (removed).

### 3.2 Type scale

| Token | Size / LH | Weight | Tracking | Usage |
|---|---|---|---|---|
| `displayLarge` | 36 / 44 | 800 | −0.9 | Big statements |
| `displayMedium` | 30 / 38 | 800 | −0.6 | Today's greeting, tab titles |
| `headlineLarge` | 26 / 34 | 700 | −0.4 | Screen titles |
| `headlineSmall` | 22 / 28 | 700 | −0.2 | Card titles (Up next) |
| `titleLarge` | 18 / 24 | 700 | −0.1 | Section headers, sheet titles |
| `titleMedium` | 16 / 22 | 600 | 0 | Item titles, field card labels |
| `bodyLarge` | 16 / 24 | 400 | 0 | Reading text, inputs |
| `bodyMedium` | 14 / 20 | 400 | 0 | Secondary text |
| `bodySmall` | 12 / 16 | 500 | 0 | Small meta |
| `labelLarge` | 15 / 20 | 700 | 0.1 | Buttons |
| `labelMedium` | 13 / 18 | 600 | 0.2 | Times, field labels, nav |
| `labelSmall` | 11 / 14 | 700 | 0.5 | Chips, overlines (often upper case) |
| `numericHero` | 56 / 64 | 800 | −1.5 | Running timer (tabular) |
| `numericLarge` | 32 / 40 | 800 | −0.6 | Headline numbers (tabular) |
| `numericMedium` | 20 / 26 | 700 | −0.2 | Ring counts, stepper values, stats (tabular) |

Rules: body text never below 14px except `bodySmall` meta; hierarchy via size/weight/color; all styles scale with system text size.

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

Screen margins per breakpoint: [responsive_design.md](responsive_design.md). Content sits in cards on the tinted canvas (§7); inside a card, whitespace groups things, not more boxes.

## 5. Corner radius (shared by every theme)

| Token | Value | Use |
|---|---|---|
| `xs` | 8 | Small tags, tooltips |
| `sm` | 12 | Small surfaces |
| `md` | 16 | Inner wells |
| `lg` | 24 | Inputs, steppers, tiles, menus, snack bars |
| `card` | 28 | Cards (`AppCard`, item cards, hero) |
| `xl` | 32 | Sheet tops, floating nav |
| `pill` | 999 | Buttons, chips, segmented controls, folded rows |

Nested radii: inner radius = outer radius − padding.

## 6. Borders, separators & component sizes

Component sizes (badges, touch target, strokes, chart sizes, duration boxes) are `AppSizes` tokens; features never use size literals.
- Cards are edged by the theme (§7.1), never a heavy outline.
- Inputs are borderless sunken wells; focused = 2dp `brandPrimary`; error = `danger`.
- Separators inside lists: avoid; spacing and cards separate items.

## 7. Elevation & shadows

Shadows are soft glows tinted with the theme's own hue plus a faint contact shadow (`AppShadows`):

| Token | Use |
|---|---|
| `card` | Cards resting on the canvas |
| `floating` | Floating nav, menus, popovers |
| `glow(color)` | Under a full-width primary/action button, in its own color |

Never stack shadows inside cards (`AppCard(flat: true)` for nested cards).

### 7.1 Treatments (per theme, read only by shared components)

| Treatment | Rose | Lavender | Papaya | Read by |
|---|---|---|---|---|
| `cardEdge` | none | hairline (`borderSubtle`) | rim (ink @ 5%, 1.5dp) | `AppCard`, `cardDecoration` |
| `navStyle` | bar | bar | floating pill | `AppShell` |
| `progressGradient` | teal (solid) | lavender → mint | papaya → peach | `AppProgressBar`, `ProgressRing` |
| `heroWash` | mist | mint | aqua | `DayHero` |
| `factsAsChips` | tiles | tiles | chips | `FactPill` |

## 8. Iconography

- One icon family app-wide: **Phosphor** (ADR-024): regular weight for default, **fill** for selected states (navigation, rating stars).
- It is integrated by bundling the official MIT-licensed font files (`assets/fonts/phosphor/`, from `@phosphor-icons/web` 2.1.2) instead of the `phosphor_flutter` package, which doesn't compile on Flutter 3.47.
- Glyphs are referenced **only** inside `lib/core/design/`:
  - `AppIcons` names UI icons semantically (`AppIcons.add`, `AppIcons.delete`, …).
  - `ActivityIconRegistry` resolves stored `icon_id`s.
- `phosphor_glyphs.dart`, `activity_icon_registry.dart` and `keys/activity_icon_ids.dart` are **generated** by `tool/generate_phosphor_glyphs.py`. To add an icon, add its Phosphor name to the script and re-run it.
- Sizes: 16 (inline meta), 20 (dense UI), 24 (default), 32 (activity badges), 48+ (empty states, use illustration instead when possible).
- **Activity icons:** a curated catalog of 58 stable IDs (Phosphor names such as `barbell`, `book-open`, `briefcase`, `person-simple-walk`, `flower-lotus`, `translate`, …). The DB stores the ID (`activity_types.icon_id`), never a glyph or codepoint. IDs are permanent, and an unknown ID falls back to `sparkle`.
- Activity badge = icon in `solid` on a `soft` **circle** (ADR-045). This badge is the activity's identity everywhere (item cards, quick add, insights legend).
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
- **Timer:** pause/resume crossfades the control and dims the time; no per-second bouncing.
- **Theme switch:** the whole app cross-fades its colors (`AppTokens.lerp`); shapes and treatments switch halfway.
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

- **Original** illustrations only. Style: simple, soft geometric and organic shapes in the current theme's palette (soft orbs and pastel washes, as in the empty-state card), with flat fills and minimal line work. No characters/mascot unless decided later.
- Used in: onboarding, empty states, completion states, feature introductions, error/fatal screens. **Not** on Insights, History or forms.
- Delivered as vector (SVG rendered via a vector package, or `CustomPaint` for simple motifs). Must use theme tokens so it fits all three themes.
- Size: illustrations occupy ≤ 40% of the viewport height on compact screens; content and actions remain visible without scrolling.
- Asset production is an open task; empty states use the shared `EmptyStateCard` orb meanwhile.

## 13. Data visualization tokens

- Series color = activity `solid`; comparison/previous period = same hue at 40% or `textTertiary` dashed.
- Body measurements use `brandPrimary` (or `slate`) since they have no activity color.
- Gridlines: `borderSubtle`, horizontal only, max 4; axis labels `labelSmall` `textSecondary`.
- Line width 2.5dp; points shown only for ≤ 31 points or on selection; selected point = 8dp dot with `surfaceBase` ring.
- Bars: `radius.xs` top corners; 60–70% band width.
- Progress (bars, rings): pill tracks on `surfaceSunken`, filled with the theme's progress fill (solid or gradient, §7.1).
- Tooltip/scrubber: `surfaceRaised`, `elevation.overlay`, `numericMedium` value + `labelSmall` date.
- Empty chart: neutral baseline + message, never a fake chart.

## 14. Accessibility (binding)

- Contrast: body text ≥ 4.5:1; large text (≥ 18.66px bold / 24px) and UI graphics ≥ 3:1. All semantic pairs above meet this except where marked "decorative/never text".
- Touch targets ≥ 48×48dp (visual element may be smaller; hit area may not).
- Text scales to 200% without clipping or loss of function (layouts reflow; numeric hero scales down gracefully with a min).
- Never rely on color alone: status is a text chip ("Planned", "Done"), done adds the ✓.
- Semantics for custom-painted elements (rings, charts: provide a textual summary such as "Reading, last 7 days, total 4 hours 12 minutes, highest Thursday").
- Focus order follows visual order; all actions reachable by TalkBack/Switch Access.
- Respect reduced motion, bold text and system font scale.

---

## 15. Implementation (Flutter)

```text
lib/core/design/
├── themes/
│   ├── app_theme_id.dart       # AppThemeId { rose, lavender, papaya }, fallback lavender
│   ├── rose_theme.dart         # const AppTokens values
│   ├── lavender_theme.dart
│   └── papaya_theme.dart
├── tokens/
│   ├── color_tokens.dart       # AppColors roles
│   ├── activity_palette.dart   # ActivityPalette (per theme), ActivityColors(solid, soft)
│   ├── elevation.dart          # AppShadows: card, floating, glow(color)
│   ├── treatments.dart         # AppTreatments: cardEdge, navStyle, progressGradient, heroWash, factsAsChips
│   ├── typography.dart         # Plus Jakarta Sans scale
│   ├── spacing.dart, radius.dart, sizes.dart, motion.dart
├── app_theme.dart              # AppTheme.of(id): ThemeData from tokens (cached)
├── app_tokens.dart             # ThemeExtension<AppTokens>: colors, shadows, treatments, palette; AppTokens.of(id)
├── context_ext.dart            # context.tokens, context.colors, context.textStyles
├── app_icons.dart, icons/, keys/, window_size_class.dart
```

- The chosen theme is the `theme` row of `app_preferences` (`AppThemeId.name`); unknown or missing → Lavender. The old `theme_mode` value is ignored. `App` uses `AppTheme.of(effectiveThemeProvider)` with `ThemeMode.light`.
- `ThemeData` is derived from tokens: `ColorScheme` (primary = brand, secondary = action, tertiary = accent), `TextTheme`, inputs (sunken pill wells), chips, buttons (pills), navigation bar/rail, sheets, dialogs, snack bars (inverse), pickers, popup menus.
- Shared components (`lib/shared/widgets/`): `AppCard`/`cardDecoration`, `AppButton` (primary, action, secondary, tertiary, destructive; `expand` = full width + glow), `StatusChip`, `ItemCard`, `ProgressRing`, `AppProgressBar`, `FactPill`, `EmptyStateCard`, `ActivityBadge`, `DoneCheck`, `StatTile`, `PanelCard`, `SectionHeader`, state views, charts. The number stepper is the `stepper` mode of the form renderer's `NumberValueEditor`.
- The debug token showcase (`/dev/tokens`) switches between the three themes.
- Tests: `color_contrast_test.dart` (every theme), `palette_consistency_test.dart` (three distinct themes, six keys), `picker_theme_test.dart`, app/slice tests switching themes.
