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
13. Display font only at ≥ 21px; numbers request tabular figures (not effective until ADR-P21 is decided).
14. Before calling UI work done, run the visual quality checklist (ui_guidelines.md §10) in light + dark, compact + expanded, text scale 1.0 + 2.0.
15. Never copy Flowfy or any other product's palette, fonts, illustrations, mascot, layouts or wording.
16. Icons are Phosphor through `AppIcons`/`ActivityIconRegistry` only (ADR-024): regular weight by default, fill for selected states.
17. Field editors go through `FieldEditorRegistry` and `FieldEditorShell` (visible label, `*` for required, inline error).
18. Primary navigation is Today | Plan | Insights | Me, plus the global Record action (ADR-028). Don't add tabs. Activity setup lives under Me → Activities.
19. User-facing copy says **Record** ("Record", "Record Reading", "Record deleted"), never "Log". Activity Log is internal only.
20. Color: only the nine activity-palette colors plus neutrals (ADR-029; sand was removed). Use the semantic roles (`brandPrimary` = teal, `accentDawn` = apricot, `success` = moss, `warning` = apricot, `danger` = rose); never introduce another hue. Moss/apricot are never small text.
