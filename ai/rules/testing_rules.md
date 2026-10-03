# Testing Rules (AI)

> Rationale: [testing_strategy.md](../../docs/development/testing_strategy.md).

1. Test behavior and business rules, not implementation trivia. No tests written to inflate counts.
2. Domain logic → unit tests. If it can be a unit test, make it one.
3. Repositories → tests against a real in-memory SQLite database created through production migrations. Do not mock the database.
4. Widget tests for meaningful UI behavior: form renderer, field editors, set table, state switching, accessibility semantics.
5. Integration tests for critical journeys; the §43 success scenario must stay green once implemented.
6. Deterministic: override `clockProvider` and `idGeneratorProvider`; no real time, no randomness, no sleeps.
7. Prefer hand-written fakes over mocking frameworks; use `mocktail` only when a fake is impractical.
8. Every bug fix adds a regression test. Every migration adds a migration test. Every new field type adds round-trip + validation tests.
9. Test names describe behavior in plain language; one behavior per test; Arrange/Act/Assert.
10. Test files mirror source paths under `test/`; shared builders in `test/support/`.
11. Use the spec's reference activities (Gym, Reading, Meeting, Language Learning, Cooking) as fixtures to keep the engine generic.
12. Analytics and time tests must include DST/time zone and midnight-crossing cases.
13. All tests pass, `flutter analyze` is clean and `dart format` produces no diff before work is reported as done. Report failures honestly.
14. Widget tests that pump the app use `testAppWidgets` + `pumpTestApp` (test/support/test_app.dart), never bare `testWidgets` with a drift database. Pump the app once per test, and seed the DB to match any startup snapshot.
