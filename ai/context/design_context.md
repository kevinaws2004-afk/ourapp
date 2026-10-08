# Design Context (AI quick-load)

> Compressed context. Canonical: [design_system.md](../../docs/ui/design_system.md), [ui_guidelines.md](../../docs/ui/ui_guidelines.md), [responsive_design.md](../../docs/ui/responsive_design.md), [visual_redesign_plan.md](../../docs/ui/visual_redesign_plan.md). Decision: ADR-045.

**Direction (owner, 2026-10-08):** take the functional app to a real consumer product using the owner's **Stitch** project as the visual/UX reference (exports in `design/`), with **three selectable light themes**. Stitch guides tokens *and* screen composition; its sample content (gym sets, kcal, budgets, sensors, AI) never sets the data model. Story: Plan → Do → Record → Measure → Understand → Improve.

**Status:** first slice built (tokens, shared components, Me → Appearance, Today, the item screen). Plan, Challenges, Insights and Me each get an explicit Stitch-based screen pass **after the owner reviews the slice on the phone**; until then they only use the new tokens/components.

**Feel:** calm, premium, personal, modern, distinctive, easy on the eyes, fast, uncluttered. One product, three personalities.

**Themes (`AppThemeId`):** Rose (blush canvas, rose signature, teal action, butter accent; borderless cards), **Lavender** (default; porcelain, electric lavender, mint action, sky accent; hairline edges, lavender→mint progress), Papaya (warm porcelain, papaya, aqua-mint action with dark text, periwinkle; rimmed cards, floating nav, coral→peach progress, facts as chips). The rose theme uses the app's own rose/teal, not Stitch's Flowfy-derived pink/teal. Light only; no dark mode for now.
- Roles: surfaces (canvas tinted, cards white, sunken wells), text ×3, `brandPrimary`(+soft/on), `action`(+soft/on), `accent`(+soft/on), `accentDawn` (stars), success/warning/danger. Activity keys (six, stored): sky, lilac, rose, teal, coral, slate; each theme has its own solid/soft. Text on soft = text roles.
- Type: **Plus Jakarta Sans** only: heavy tight headlines, bold labels, tabular `numeric*` styles.
- Shapes: cards 28, inputs/tiles 24, pills everywhere else. Soft tinted glows, not grey shadows.
- Plan vs Reality: item cards with a status chip (Planned / In progress / Done / Live; skipped faded) and the done check on the right.

**Tokens (use, never hardcode):** spacing 2/4/8/12/16/20/24/32/48/64 · radius 8/12/16/24/28/32/pill · shadows card/floating/glow · motion 90/150/250/400/600–900ms · component states default/hovered/focused/pressed/selected/disabled/loading/error.

**Shared components:** `AppCard`, `ItemCard`, `StatusChip`, `ProgressRing`, `AppProgressBar`, `FactPill`, `EmptyStateCard`, `AppButton` (primary/action/secondary/tertiary/destructive, `expand`), `ActivityBadge`, `DoneCheck`, `StatTile`, `PanelCard`. Only they read theme treatments.

**Must-haves per screen:** loading, empty (explain + next action), error (calm + retry), success. Responsive; 200% text; 48dp targets; reduced motion; contrast tested in all three themes.

**Interaction:** ≤ 2 taps for common actions; one big action per card; Undo snackbars; sheets for short tasks.

**Copy:** warm, concise, neutral about misses, sentence case. No developer words ("schema", "fields") in the UI.

**Icons:** Phosphor (bundled, ADR-024) through `AppIcons`/`ActivityIconRegistry`; activity icons on soft circles.

**Avoid:** copying Stitch's out-of-scope concepts (energy scores, calibration, sensors, AI, budgets, routines, XP, photos), the name "LifeOS", Flowfy's palette/name, a floating Quick Log button (ADR-028), per-theme screens, one-off values.
