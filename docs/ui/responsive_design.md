# Responsive Design

> Layout rules for Android phones and tablets now, iOS phones and tablets later (§33.7). "Do not simply stretch a phone layout to fill a tablet."

---

## 1. Breakpoints (window width classes)

Based on the **available window width** (not device type), so split-screen, foldables and rotation work naturally.

| Class | Width (dp) | Typical | Navigation | Screen margin | Columns |
|---|---|---|---|---|---|
| **Compact** | < 600 | Phones portrait | Bottom navigation bar | `space.xl` (20) | 1 |
| **Medium** | 600 – 839 | Large phones landscape, small tablets, unfolded foldables | Navigation rail (labels shown) | `space.xxl` (24) | 1–2 |
| **Expanded** | ≥ 840 | Tablets landscape/portrait 10" | Navigation rail (extended with labels, optional) | `space.xxxl` (32) | 2 (list–detail) or multi-column grids |

Height also matters: if height < 480dp (phone landscape), collapse large headers, hide decorative illustrations, and keep primary actions visible.

Implemented: `WindowSizeClass` in `lib/core/design/window_size_class.dart` (`of(context)`, `screenMargin`, `usesNavigationRail`) plus `AppContentWidth` constants; the shell in `lib/app/app_shell.dart` switches bottom bar ↔ rail. Features ask for the class; they never read raw widths with magic numbers. Height-based rules (< 480dp) and two-pane layouts arrive with the screens that need them.

## 2. Content width constraints

- Reading/form content max width: **600dp**, centered, on medium/expanded when shown single-column.
- Lists in a pane: max **720dp**.
- Charts may span wider, up to **960dp** per chart.
- Sheets on medium/expanded: max width **560dp**, centered (or side sheet for the log editor on expanded, see below).
- Dialogs: max width 480dp.

## 3. Screen adaptations

| Screen | Compact | Medium | Expanded |
|---|---|---|---|
| **Today** | Single column: header + Day Arc, plan, timeline | Single column, constrained width, larger Day Arc | Two panes: **Plan** (left) and **Actual timeline** (right), visually pairing planned vs actual; header spans both |
| **Plan** | Week strip + calendar button; selected date's Planned and Recorded sections stacked | Same, constrained width | Month calendar (left) + selected date (right) |
| **Me → Activities** | List of activity types | Constrained list | List of types (left) + activity detail (right) |
| **Log editor** | Full-screen route | Full-screen, constrained to 600dp | Side sheet/right pane over the current screen (keeps context), or constrained full-screen for structured logs |
| **Activity builder** | Single column, preview via toggle/tab | Single column + preview below | Two panes: builder (left) + live preview (right) |
| **Focus Mode** | Full-screen, vertical | Full-screen; controls side-by-side | Full-screen; timer centered; optional notes area beside timer in landscape |
| **Insights** | Vertical stack of cards; chart detail full-screen | 2-column card grid | Card grid (left/top) + chart detail pane (right) |
| **History** | List grouped by day | Constrained list | List + log detail pane |
| **Me** | List | Constrained list | Settings list (left) + detail (right) |
| **Onboarding** | Full-screen steps | Centered card (max 560dp) on illustrated background | Same; illustration and content side-by-side in landscape |

Two-pane rules: list selection drives the detail pane; with nothing selected, the detail pane shows a helpful empty state (not blank). On resize to compact, the selected detail becomes a pushed route.

## 4. Orientation & foldables

- All screens support portrait and landscape on tablets. On phones, landscape is supported (no forced portrait) with compact-height rules; Focus Mode works in both.
- Respect display cutouts and hinge areas (`MediaQuery.displayFeatures`): never place controls across a hinge; in book posture prefer two panes split at the hinge.

## 5. Safe areas, insets & keyboard

- Use `SafeArea`/padding from `MediaQuery` for system bars, gesture navigation and cutouts; edge-to-edge drawing with proper insets.
- Forms scroll the focused field into view above the keyboard; sticky save buttons sit above the keyboard.
- Sheets resize with the keyboard and remain dismissible.

## 6. Text scaling & density

- Layouts must work to **200% text scale**: rows wrap, numeric tiles grow vertically, nav labels may truncate with tooltips but never overlap.
- Do not fix heights for text containers; use min heights.
- Visual density stays comfortable on all sizes (no "compact density" for tablets; use space for layout, not smaller targets).

## 7. Input modalities

Tablets may have keyboards, mice or styluses: support hover states, focus traversal (Tab), keyboard shortcuts for primary actions where cheap (e.g. Enter to save in quick add), and right-click/long-press parity for context actions.

## 8. iOS readiness (future)

- No layout assumes Android system navigation; back navigation is provided in-app where needed (iOS swipe-back is supported by the router/page transitions).
- Respect iOS safe areas (Dynamic Island, home indicator) through the same inset handling.
- Platform-adaptive details (scroll physics, date pickers, haptics intensity) are isolated in shared components so iOS adaptation is a contained change.

## 9. Testing responsiveness

Widget tests at representative sizes: 360×780 (compact), 412×915 (large phone), 700×1000 (medium), 1280×800 (expanded landscape), 800×1280 (expanded portrait), each at text scale 1.0 and 2.0 for key screens (Today, Log editor, Insights). Manual check on a real tablet before each phase exit.
