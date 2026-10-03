# Performance

> "Fast" is a core product attribute (§33). These budgets are targets for a mid-range Android phone in **profile/release** mode.

---

## 1. Budgets

| Metric | Target |
|---|---|
| Cold start to interactive Today | < 1.5 s (mid-range), < 2.5 s (low-end) |
| Tab switch | next frame (state preserved by shell) |
| Open record form / Quick Record sheet | < 150 ms to first frame |
| Save log (incl. values) | < 50 ms DB time |
| Today screen query (plans + logs for a day) | < 20 ms |
| Insights chart for 6 months of data | < 200 ms compute; show skeleton if longer |
| History scroll | 60 fps (90/120 where supported), no jank with 10k+ logs |
| Focus timer | exactly one small widget rebuilds per second |
| Frame budget | no frames > 16 ms in common flows (verify with DevTools) |

Data scale assumption: ~10–50k logs, 100k–500k value rows (see [database.md §9](../architecture/database.md#9-size--performance-expectations)).

## 2. Database

- Index every query path used by screens ([database.md §6](../architecture/database.md#6-indexes-and-query-plans)). Implemented hot paths are verified with `EXPLAIN QUERY PLAN` in `schema_integrity_test.dart`.
- Integer joins (`internal_id`) on hot paths; no JSON predicates; units normalized at write time (ADR-017/019/020).
- Repositories load a list plus all its children in two queries (no N+1). Live queries re-run only after writes to their tables, and not while their screen is hidden (`reactiveQuery`).
- WAL mode; batch writes in transactions; never run writes in a loop without a transaction.
- Load **date-bounded** ranges; never "all logs" for screens.
- History uses **keyset pagination** (`started_at`, `id`) rather than large offsets.
- Watch queries should be as narrow as possible so unrelated writes don't trigger recomputation.
- Run DB work off the UI isolate if the chosen library supports it (drift does via background isolates; ADR-011).

## 3. Analytics

- Pure Dart computation over range-bounded data; memoize per (source, range, aggregation) via providers.
- Move to `Isolate.run` when a computation exceeds ~16 ms on the profiling device.
- Nested Repeating Group values (Phase 3) must stay queryable without hot-path JSON parsing; the storage choice is the ADR-019 sub-decision. Measure analytics queries with `EXPLAIN QUERY PLAN`.

## 4. UI

- `const` widgets; small rebuild scopes; `select` on providers.
- Builders/slivers for lists; avoid `shrinkWrap` lists inside scroll views for long content.
- `RepaintBoundary` around charts, the timer and animated decorations.
- Custom painters implement `shouldRepaint` correctly.
- Avoid expensive effects (blur/backdrop filters, large shadows, saveLayer opacity) in scrolling content; use pre-blended colors instead of `Opacity` widgets where possible.
- Images/illustrations: vector or appropriately sized raster; precache onboarding assets.
- Animations never block input; durations per [design_system.md §Motion](../ui/design_system.md#9-motion).

## 5. Startup

- Bootstrap only what's needed for the first screen (DB open + migrations + preferences).
- Defer analytics computation and history queries until their screens are visited.
- Bundle fonts (no runtime fetch); limit font weights/files shipped.

## 6. App size

Watch APK/AAB size per release. Every dependency is weighed for size (see [coding_standards.md §Dependencies](coding_standards.md#dependencies)). Ship only used font weights and icon subsets where tooling allows.

## 7. Measuring

- Profile mode on a real mid/low-end device before each phase exit.
- DevTools performance overlay and timeline for janky screens.
- Add a seeded "large dataset" dev option (debug builds only) to generate years of synthetic logs for performance testing.
