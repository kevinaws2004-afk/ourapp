# Architecture Overview

> Entry point for all architecture documentation. Read this first, then the specific document you need.
> Decisions referenced as `ADR-0xx` (accepted) and `ADR-Pxx` (pending) are in [architecture_decisions.md](../decisions/architecture_decisions.md).
> **Status:** these documents describe the **target design**. Phases 1–2 (scaffold, design tokens, shell, preferences, and the generic activity engine: types, fields, logs, builder, form renderer) are implemented; [application_architecture.md](application_architecture.md) marks what exists. Anything that depends on an `ADR-Pxx` is a recommendation until approved.

| Document | Answers |
|---|---|
| **architecture.md** (this) | What are the principles, the big picture and the layers? |
| [application_architecture.md](application_architecture.md) | Where does code go? How do features, layers, routing and the generic form renderer work? |
| [data_architecture.md](data_architecture.md) | What is the domain model? How are field types, values, structured data and analytics series modeled? |
| [database.md](database.md) | What is the SQLite schema, with constraints, indexes, migrations and transactions? |
| [state_management.md](state_management.md) | How is Riverpod used? How does data flow to the UI? |
| [future_sync.md](future_sync.md) | How can this become local + cloud without a rewrite? |

---

## 1. System context (V1)

```text
┌──────────────────────────────────────────┐
│              Android device              │
│                                          │
│   Flutter app (Dart)                     │
│     Presentation  (widgets, routing)     │
│          │                               │
│     Domain        (entities, use cases,  │
│          │         field engine,         │
│          │         analytics engine)     │
│     Data          (repositories,         │
│          │         SQLite access)        │
│          ▼                               │
│   Local SQLite database  ◀── source of   │
│                              truth (V1)  │
└──────────────────────────────────────────┘
        No network. No backend. No account.
```

Infrastructure cost: ₹0/month (§7).

## 2. Architecture principles

These are binding. Violations need an ADR.

1. **Feature-first structure.** Code is grouped by feature, then by layer (ADR-005).
2. **Three layers with one-way dependencies:** Presentation → Domain ← Data. Domain depends on nothing Flutter- or SQLite-specific.
3. **Platform-independent logic.** Domain and data layers contain no Android-specific APIs. Platform specifics live behind interfaces in `core/` (ADR-009).
4. **No business logic in widgets.** Widgets render state and forward intents.
5. **No database code in UI.** Widgets and notifiers never touch SQL or DB classes; they call repositories or use cases.
6. **Repository abstraction** between domain and persistence (ADR-007). Repositories expose domain entities, never DB rows.
7. **SQLite is the V1 source of truth** (ADR-002). There is no in-memory "real" state that is not persisted.
8. **Local-first, offline-first** (ADR-003). Every feature works with no network.
9. **Sync-ready data:** two-level identity (INTEGER `internal_id` for joins, UUIDv7 `public_id` for identity, ADR-017), created/updated timestamps, soft deletion (ADR-022). No sync machinery in V1.
10. **One generic activity engine** (ADR-006). No per-activity tables, screens, or `if (type == gym)` branches. New activity types are data.
11. **Special components only for genuinely different data structures.** Set Table and Repeating Group are *field types*, not "the gym feature" (§46).
12. **Simplicity over cleverness.** Avoid premature abstraction. No interface without a second implementation *or* a test seam that needs it (repositories qualify: tests and future sync).
13. **No V1-excluded functionality** (§42): no backend, auth, sync, AI, social or subscriptions.
14. **Design system is infrastructure.** All visual values come from centralized tokens ([design_system.md](../ui/design_system.md)).

## 3. Layer responsibilities

| Layer | Contains | Must not contain |
|---|---|---|
| **Presentation** | Screens, widgets, Riverpod notifiers/controllers that hold UI state, route definitions, view models/formatters for display | SQL, DB classes, business rules (validation, aggregation, status transitions), direct `DateTime.now()` |
| **Domain** | Entities (pure Dart), value objects, field type catalog & validation, value encoding contracts, use cases, repository **interfaces**, analytics engine, timer math | Flutter imports (`package:flutter/*`), DB library imports, JSON-from-DB parsing tied to a driver |
| **Data** | Repository implementations, DB schema/tables/DAOs, row ↔ entity mappers, migrations, export writers | UI code, Riverpod UI state, business decisions beyond persistence |

`core/` holds cross-cutting infrastructure (database bootstrap, clock, ID generator, logging, errors, design tokens). `shared/` holds reusable presentation components. Details: [application_architecture.md](application_architecture.md).

## 4. The central abstraction

```text
Activity Type ─▶ Field Definitions ─▶ Generic Form Renderer ─▶ Activity Log + Log Values ─▶ Analytics (time, value, unit)
```

- **Field type catalog** (domain): a closed, code-defined set of field types. Each knows its config schema, value encoding, validation, and whether it is measurable.
- **Field editor registry** (presentation): maps each field type to an editor widget and a config-editor widget. The form renderer iterates field definitions and asks the registry for widgets. *This is the only place field-type branching happens*, and it is exhaustive via a sealed type/enum `switch`.
- **Analytics engine** (domain): turns a *metric source* (activity type + field path + optional filter) into points `(timestamp, value, unit)`, then aggregates by time bucket. It never branches on activity names.

Adding a new **activity type** = data only. Adding a new **field type** = code (domain catalog entry + editor + tests), still no schema change.

## 5. Data flow

**Read (reactive):**
```text
SQLite ──(watch query)──▶ Repository (Stream<Entity>) ──▶ Riverpod StreamProvider ──▶ Widget rebuild
```
**Write:**
```text
Widget intent ──▶ Notifier ──▶ Use case / Repository method (validates, transacts) ──▶ SQLite ──▶ watchers emit ──▶ UI updates
```
UI never updates optimistically from its own copy; the DB stream is the truth. Writes are local and fast, so optimistic UI is unnecessary in V1.

## 6. Key cross-cutting concerns

| Concern | Where documented |
|---|---|
| IDs, timestamps, soft delete | [database.md §2](database.md#2-conventions) |
| Time zones & "which day does this belong to" | [data_architecture.md §7](data_architecture.md#7-time-model) |
| Errors | [error_handling.md](../development/error_handling.md) |
| Performance budgets | [performance.md](../development/performance.md) |
| Testing | [testing_strategy.md](../development/testing_strategy.md) |
| Visual system | [design_system.md](../ui/design_system.md) |

## 7. Technology stack

| Concern | Choice | Status |
|---|---|---|
| UI framework / language | Flutter, Dart (null-safe, Dart 3) | Accepted (ADR-001) |
| Persistence | SQLite (local) | Accepted (ADR-002) |
| SQLite access library | drift (+ drift_flutter, drift_dev) | Accepted (ADR-011) |
| State management | Riverpod 3 (`flutter_riverpod`), hand-written providers | Accepted (ADR-004, ADR-014) |
| Navigation | go_router (18.x) | From spec; in use since Phase 1 |
| Animations | Native Flutter animation APIs first; `flutter_animate` only if it materially simplifies | Pending (ADR-P17) |
| Drag & drop | Flutter built-ins (`ReorderableListView`, `Draggable`) | Default |
| Charts | Custom `CustomPaint` chart components (recommended) vs charting package | **Pending** (ADR-P11) |
| Icons | Phosphor, bundled official MIT font + generated registry | Accepted (ADR-024) |
| Localization | `flutter_localizations` + gen-l10n | Accepted (ADR-015) |
| Backend | None | Accepted (ADR-008) |

Dependency rules: [coding_standards.md §Dependencies](../development/coding_standards.md#dependencies).
