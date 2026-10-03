# Architecture Rules (AI)

> Rationale: [architecture.md](../../docs/architecture/architecture.md), [application_architecture.md](../../docs/architecture/application_architecture.md).

1. Before any architectural or cross-feature change, read `CLAUDE.md`, `docs/architecture/architecture.md`, and the specific architecture doc involved.
2. Feature-first: `lib/features/<feature>/{data,domain,presentation}`. Create a layer folder only when it gets its first file.
3. Dependency direction: presentation → domain ← data. `core/` and `shared/` never import features.
4. Cross-feature imports only into another feature's `domain/`. Never import another feature's `data/` or `presentation/` (the app router is the only exception, for screens).
5. No cyclic feature dependencies. Shared concepts move to the lower-level feature's domain.
6. Repository interfaces live in domain; implementations in data; bindings in providers. Repositories return domain entities only and hide soft-deleted rows by default.
7. Every write goes through a use case (ADR-023). Composite reads are use cases; simple single-repository reads are watched through repository providers.
8. The generic engine is sacred: new activity types are data; new field types are code (catalog + editor + tests) without per-activity tables.
9. One form renderer for create/edit/plan→log/post-focus/builder preview.
10. SQLite is the source of truth; Riverpod holds no authoritative long-lived state.
11. Timer state derives from persisted timestamps.
12. No backend, network calls, auth, sync, AI, social, subscriptions or telemetry (V1 exclusions).
13. Keep sync-readiness: UUIDv7 `public_id`s (internal integer keys stay in the data layer), timestamps, soft delete, stable IDs inside JSON. Do not add sync machinery.
14. Do not resolve a pending ADR or open question silently. Follow the documented recommendation/interim assumption and say so, or ask.
15. Any new architectural decision → update `docs/decisions/architecture_decisions.md` in the same change. More generally, every change keeps docs in sync with code per [development_guide.md §4.1](../../docs/development/development_guide.md#41-documentation-maintenance-binding); docs must never describe architecture or behavior the code no longer follows.
16. Routing is centralized in `app/router.dart`; route params are public IDs. Full-screen editors use the root navigator.
17. No Android-only APIs in domain/data; platform services go behind interfaces in `core/platform/`.
18. Riverpod 3 pauses hidden providers. Repository streams must be built with `reactiveQuery` so hidden screens refresh correctly when revealed.
