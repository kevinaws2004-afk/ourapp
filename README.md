# Personal Activity & Life Tracking App

> Working title. A customizable, local-first personal activity system that lets you plan your day, record what you actually do, capture the data that matters for each activity, and understand your progress over time.

**Plan → Do → Log → Measure → Understand**

Gym workouts, reading, focused work, meetings, walks, body measurements, or any custom activity you design all run on **one generic, configuration-driven engine**. Your data stays on your device: no account, no backend.

## Status

**Phase 2 (generic activity engine): complete**, plus the navigation clarification (ADR-028). Navigation is **Today | Plan | Insights | Me**, with a global **Record** action. You can:
- set up reusable activities under **Me → Activities** (builder or templates; ten generic field types, nine available now, with Repeating Group coming in Phase 3)
- **record** what you did from anywhere, including typed values, units, duration and notes
- use the **date-based Plan tab** to pick any date and see what was recorded that day (plans themselves arrive in Phase 4)

Today and Insights are still placeholders. See [`ai/tasks/current_task.md`](ai/tasks/current_task.md).

The visible app name **"OurApp"** is temporary. The product name is undecided, and `daylog` is only an internal technical identifier.

## Tech stack

Flutter · Dart · SQLite via drift (local) · Riverpod 3 · go_router · native animations · Phosphor icons · charts (CustomPaint-based recommended; pending ADR-P11). Android first, iOS-compatible. No backend in V1.

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
