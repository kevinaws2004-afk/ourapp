# Coding Rules (AI)

> Enforceable rules. Rationale: [coding_standards.md](../../docs/development/coding_standards.md).

1. Use the spec's vocabulary: ActivityType, ActivityField, ActivityLog, LogValue, Plan, Measurement, FocusSession. No synonyms.
2. Domain code imports no `package:flutter/*` and no DB library.
3. No business logic in widgets; no SQL/DB classes outside `data/`.
4. Never branch on activity identity (`name == 'Gym'`, template keys). Branch only on field types (registry) or config/roles.
5. Never call `DateTime.now()`; use the injected `Clock`. Never generate IDs except via the ID generator.
6. No `dynamic` outside JSON boundary code; decode to typed objects immediately.
7. Use `sealed` classes + exhaustive `switch` for closed sets (field types, metric sources, failures, states).
8. Immutable domain entities with value equality.
9. No hardcoded colors, text styles, spacing, radii, shadows, durations or curves in feature code; use design tokens.
10. Extract widget classes, not widget-returning helper methods; keep `build` methods small.
11. No giant files: split around ~300 lines; no `utils.dart` dumping grounds.
12. No global mutable state or singletons; inject via Riverpod providers.
13. Never swallow exceptions. Raw errors become sealed `AppException`s in the data layer (`guardStorage`). Domain validation returns `ValidationResult`; use cases throw `ValidationException`. UI shows copy from `shared/errors/error_copy.dart`, never raw errors (ADR-025).
14. No `print`; use `AppLogger`. Never log user content at info level or above.
15. User-visible strings come from ARB files via `AppLocalizations` (ADR-015); no inline user-facing literals in widgets. Never show the codename `daylog` or the design name "Daylight" as the product name (ADR-010).
16. `dart format` clean and `flutter analyze` zero issues before considering work done.
17. Do not add a dependency without meeting the dependency rules ([coding_standards.md §Dependencies](../../docs/development/coding_standards.md#dependencies)); architecture-shaping packages need an ADR.
18. No dead code, commented-out code, or speculative parameters "for later".
19. Comment *why*, not *what*.
20. Prefer the simplest solution that satisfies the documented requirement. No premature abstraction.
21. Use cases are named Verb + domain object (`CreateActivityType`, `LogActivity`), with one `call()` method (ADR-023). No Manager/Handler/Processor/Service names.
22. Icons: use `AppIcons` (UI) or `ActivityIconRegistry` (activity `icon_id`). Never reference glyphs or codepoints elsewhere, and never store them in SQLite (ADR-024). Regenerate glyph files with `tool/generate_phosphor_glyphs.py`.
23. Domain IDs are `extension type` wrappers around public UUIDv7 strings (`ActivityTypeId`, `ActivityFieldId`, `ActivityLogId`, `SelectOptionId`).
