# Design Context (AI quick-load)

> Compressed context. Canonical: [design_system.md](../../docs/ui/design_system.md), [ui_guidelines.md](../../docs/ui/ui_guidelines.md), [responsive_design.md](../../docs/ui/responsive_design.md). Status of concrete values: accepted as provisional v0 (ADR-016), pending the owner's on-device showcase review. "Daylight" is not the product name.

**Upcoming (owner, 2026-10-04):** a dedicated visual pass after core functionality. The target is colorful, alive and premium (not cream-heavy, not all dark, not plain white). Story: Plan → Do → Record → Measure → Understand → Improve. Until then: no redesign or new features; keep everything token-driven (incl. `AppSizes`) so the look can change without domain/DB changes. See design_system.md (top note).

**Feel:** calm, premium, personal, modern, visually distinctive, easy on the eyes, fast, uncluttered, intentionally designed. One recognizable visual world, not a set of screens.

**Identity "Daylight":** the shape and light of a day.
- Light: white-shade canvas (`#F7FBFB`), white cards, mist `#DDF0EF` sunken surfaces, slate-ink text. Dark: deep slate surfaces (`#13171E`), white-shade text. Never pure black.
- **Only white shades, mist `#DDF0EF` and six palette colors are used (ADR-029, ADR-038).** Brand = **teal**, accent = **coral** (rating stars), success = **teal**, warning = **coral**, danger = **rose**. Neutrals are white and slate shades. Coral and teal are graphics-only for small text in light mode.
- Activity palette keys (six): sky, lilac, rose, teal, coral, slate. Sand, sage, apricot, moss were removed (stored sage/moss → teal, apricot → coral). Each has `solid` (icons/charts) and `soft` (surfaces). Text on soft = textPrimary.
- Type: **Fraunces** for display/headlines (≥ 21px), **DM Sans** for UI/body, tabular figures for numbers.
- Motifs: **Day Arc** (Today header, onboarding progress, focus ring, completion) and **Plan vs Reality grammar**: planned = outline/dashed; actual = filled soft + solid accent. Skipped ≠ error.

**Tokens (use, never hardcode):** spacing 2/4/8/12/16/20/24/32/48/64 · radius 6/10/16/24/32/pill · elevation flat/raised/overlay (dark uses tone, not shadow) · motion 90/150/250/400/600–900ms with defined curves · component states default/hovered/focused/pressed/selected/disabled/loading/error.

**Must-haves per screen:** loading (skeleton after ~150ms), empty (explain + next action), error (calm + retry, keep input), success (brief, meaningful). Responsive: compact (<600) bottom nav; medium/expanded rail + two panes; max content widths; 200% text scale; 48dp targets; reduced motion.

**Interaction:** ≤ 2 taps for common actions; Undo snackbars instead of confirm dialogs for reversible actions; purposeful micro-interactions only; sheets for short tasks; one primary action per view.

**Onboarding:** understand → one question → personalize → show value → begin; ≤ 5 skippable screens; privacy promise; no account.

**Copy:** warm, concise, outcome-oriented where helpful, neutral about misses, sentence case.

**Icons:** Phosphor (bundled official font, ADR-024): regular by default, fill when selected, through `AppIcons`/`ActivityIconRegistry`. Activities store an `icon_id` such as `barbell`.

**Avoid:** generic white CRUD, black productivity dashboards, excessive gradients/cards/buttons, spreadsheet layouts, unadapted Material defaults, one-off values, copying Flowfy (principles only, no palette/fonts/illustrations/mascot/layouts/wording).
