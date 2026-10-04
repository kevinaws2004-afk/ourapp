# UI Rules (AI)

> Rationale: [design_system.md](../../docs/ui/design_system.md), [ui_guidelines.md](../../docs/ui/ui_guidelines.md), [responsive_design.md](../../docs/ui/responsive_design.md).

1. Consume semantic tokens only (`context.tokens`, theme text styles, spacing/radius/motion constants). No `Color(0x…)`, literal font sizes, literal paddings, literal durations in features.
2. Use shared components from `lib/shared/` before Material defaults. If a needed pattern is missing, add it to `shared/` and document it in ui_guidelines.md.
3. Every data-bearing view implements loading, empty, error and success states with the shared state components.
4. Apply the Plan vs Reality grammar everywhere: planned = outline/dashed, actual = filled soft + solid accent. Never color-only meaning.
5. Activity identity = `ActivityBadge` (icon key + palette key). Text on activity `soft` uses text tokens, never `solid`.
6. One primary action per view; common actions ≤ 2 taps.
7. Reversible actions: immediate + Undo snackbar. Irreversible (discarding unsaved input): confirmation. No "Are you sure?" for reversible actions. Don't show a confirmation snackbar when the next screen already confirms the action (snackbars persist across navigation and can cover primary buttons).
8. Motion uses motion tokens, communicates state/continuity, never blocks input, and degrades to crossfades under reduced motion.
9. Responsive by window size class: compact = bottom nav, medium/expanded = rail and two-pane layouts where specified. Respect max content widths. Never stretch phone layouts.
10. Accessibility: ≥ 48dp targets, contrast per tokens, semantics labels for icon buttons and painted content, 200% text scale works, logical focus order.
11. Illustrations only in onboarding, empty, completion, intro and error screens, never on Insights/History/forms.
12. Copy: warm, concise, outcome-oriented where helpful, neutral about misses, sentence case, localizable.
13. Display font only at ≥ 21px; live and tabular numbers use the `numeric*` tokens (DM Mono, ADR-032).
14. Before calling UI work done, run the visual quality checklist (ui_guidelines.md §10) in light + dark, compact + expanded, text scale 1.0 + 2.0.
15. Never copy Flowfy or any other product's palette, fonts, illustrations, mascot, layouts or wording.
16. Icons are Phosphor through `AppIcons`/`ActivityIconRegistry` only (ADR-024): regular weight by default, fill for selected states.
17. Field editors go through `FieldEditorRegistry` and `FieldEditorShell` (visible label, `*` for required, inline error).
18. Primary navigation is Today | Plan | Insights | Me (ADR-028). No floating Record button: anything unplanned is added with the quick add's **Start now** and opened (ADR-035, ADR-039). Plan is Week | Month; a day opens via the shared `DayItems`, never a second day layout. Don't add tabs or a FAB. Activity setup lives under Me → Activities.
19. User-facing copy talks about items being **done** and logging into them; never "Log" as a noun. The activity page's button says "Record". Activity Log is internal only.
20. Color: only white shades, mist `#DDF0EF` and the six activity-palette colors sky, lilac, teal, rose, slate, coral; text/borders are slate shades (ADR-029, ADR-038). Use the semantic roles (`brandPrimary` = teal, `accentDawn` = coral, `success` = teal, `warning` = coral, `danger` = rose); never introduce another hue. Moss/apricot are never small text.
21. Tapping an item opens it to log into it (ADR-035); plan options (edit, Skip, Move, Delete) live behind its More button. Never add a Save button or a separate record form: items save as you type.
22. Never hard-code what an activity records, and never require setup before logging: any item takes notes straight away and gets its own activity on the first thing logged (ADR-035).
23. Charts only through `AppChart` (ADR-033); never use fl_chart widgets in features. Chart copy stays neutral ("+12 % vs previous period").
24. No size literals in features: use `AppSizes` (badges, touch target, strokes, charts), so the planned visual pass can retune them centrally.
