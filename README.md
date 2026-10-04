# Personal Activity & Life Tracking App

> Working title. A customizable, local-first personal activity system that lets you plan your day, record what you actually do, capture the data that matters for each activity, and understand your progress over time.

**Plan → Do → Log → Measure → Understand**

Gym workouts, reading, focused work, meetings, walks, body measurements, or any custom activity you design all run on **one generic, configuration-driven engine**. Your data stays on your device: no account, no backend.

## Status

**Flow rework done (ADR-035–037):** items you log into (saved as you type, with Add to log), a Day/Week/Month planner with repeating plans and Plan next, and automatic progress per activity in Insights. Phases 5 (focus) and 6 (insights + body measurements) are complete. Phases 1–4 (scaffold, generic engine, structured fields, plans & Today) and the navigation clarification (ADR-028) are done. Navigation is **Today | Plan | Insights | Me**. Everything on a day is an item: add it (or **Now** for what you're doing), open it, and log into it; it saves as you type (ADR-035). You can:
- set up reusable activities under **Me → Activities** (builder or templates; ten generic field types, including **Repeating Groups**, e.g. exercises with nested sets; templates include Gym, Meeting and Cooking)
- **log** into any item: typed values, units, duration, notes and lists of items (with suggestions from earlier records, e.g. exercise names); leave and come back to add more
- **plan** any date on the Plan tab: activity plans and simple tasks, with optional times or a length, quick add, drag to reorder, skip or move to tomorrow
- **open a planned item to log into it** (e.g. a Gym session, set by set); it then shows ✓ with a summary, and **Today** lists the day's items with what actually happened ("Done · 45 min of 1 h")

- **timer**: start it inside an item and keep logging while it runs; pause/resume; it survives the app being closed; finishing fills the item's time
- **understand progress** on Insights: time and counts per activity vs the previous period, and your own charts of anything (time, any number such as the weight of your bench-press sets, volume, personal bests, body measurements, planned vs actual)
- track **body measurements** under Me See [`ai/tasks/current_task.md`](ai/tasks/current_task.md).

The visible app name **"OurApp"** is temporary. The product name is undecided, and `daylog` is only an internal technical identifier.

## Tech stack

Flutter · Dart · SQLite via drift (local) · Riverpod 3 · go_router · native animations · Phosphor icons · charts via fl_chart (ADR-033). Android first, iOS-compatible. No backend in V1.

## Documentation map

| Start here | |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Instructions for Claude Code / AI agents (also a good engineering summary) |
| [`personal_activity_tracker_spec_updated.md`](personal_activity_tracker_spec_updated.md) | Original product spec (source of truth) |
| [`claude_setup.md`](claude_setup.md) | Engineering process brief |

| Area | Documents |
|---|---|
| **Product** | [Product spec](docs/product/product_spec.md) · [Requirements & open questions](docs/product/requirements.md) · [User flows](docs/product/user_flows.md) |
| **Architecture** | [Overview](docs/architecture/architecture.md) · [Application structure](docs/architecture/application_architecture.md) · [Data model](docs/architecture/data_architecture.md) · [SQLite schema](docs/architecture/database.md) · [State management](docs/architecture/state_management.md) · [Future sync](docs/architecture/future_sync.md) |
| **Development** | [Dev guide & phases](docs/development/development_guide.md) · [Coding standards](docs/development/coding_standards.md) · [Testing](docs/development/testing_strategy.md) · [Error handling](docs/development/error_handling.md) · [Performance](docs/development/performance.md) |
| **UI** | [Design system](docs/ui/design_system.md) · [UI guidelines](docs/ui/ui_guidelines.md) · [Responsive design](docs/ui/responsive_design.md) |
| **Decisions** | [Architecture decision records](docs/decisions/architecture_decisions.md) |
| **AI agents** | [`ai/context/`](ai/context/) · [`ai/rules/`](ai/rules/) · [`ai/tasks/current_task.md`](ai/tasks/current_task.md) |

## Getting started

Requires Flutter stable (scaffolded with **Flutter 3.47.6 / Dart 3.13.5**) and the Android SDK. iOS builds need Xcode.

```bash
flutter pub get
flutter test                                  # unit, widget and repository tests
flutter emulators --launch Medium_Phone_API_37.0
flutter run -d emulator-5554                  # or any device from `flutter devices`
```

More commands (code generation, migrations, integration tests): [development_guide.md §3](docs/development/development_guide.md#3-daily-commands).

## Privacy

V1 stores everything locally in SQLite. Nothing leaves the device for core functionality. Any future cloud features will be opt-in.
