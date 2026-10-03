You are the senior software architect for this project.
We are building a production-quality Flutter application called
"Personal Activity & Life Tracking App".
The existing product and technical specification is:
personal_activity_tracker_spec_updated.md
This document is the source of truth for the product requirements.
DO NOT start implementing the application yet.
Your current task is to convert the existing specification into a
professional engineering documentation structure that can be used by
Claude Code and future developers throughout the project.
The goal is to establish how a senior engineering team would structure,
document, architect, implement, test, and maintain this application.
==================================================
1. FIRST: READ AND UNDERSTAND THE EXISTING SPEC
==================================================
Read the complete:
personal_activity_tracker_spec_updated.md
Understand all of the following before creating documentation:
- Product philosophy
- Activity Type
- Activity Fields
- Activity Log
- Plans
- Measurements
- Generic activity system
- Generic database architecture
- Local-first architecture
- Custom activity builder
- Gym / repeating groups / sets
- Reading
- Focus sessions
- Daily timeline
- Planning
- Analytics
- Body measurements
- V1 scope
- Explicitly excluded features
- Future cloud/backend architecture
- Future synchronization requirements
- UI/UX requirements
Do not change the product requirements unless you identify an actual
architectural contradiction.
If something is ambiguous, document the ambiguity rather than inventing
requirements.
==================================================
2. CREATE THE ENGINEERING DOCUMENTATION
==================================================
Create this structure:
docs/
│
├── product/
│   ├── product_spec.md
│   ├── requirements.md
│   └── user_flows.md
│
├── architecture/
│   ├── architecture.md
│   ├── application_architecture.md
│   ├── data_architecture.md
│   ├── database.md
│   ├── state_management.md
│   └── future_sync.md
│
├── development/
│   ├── development_guide.md
│   ├── coding_standards.md
│   ├── testing_strategy.md
│   ├── error_handling.md
│   └── performance.md
│
├── ui/
│   ├── design_system.md
│   ├── ui_guidelines.md
│   └── responsive_design.md
│
└── decisions/
    └── architecture_decisions.md
ai/
│
├── context/
│   ├── product_context.md
│   ├── architecture_context.md
│   └── design_context.md
│
├── rules/
│   ├── coding_rules.md
│   ├── architecture_rules.md
│   ├── ui_rules.md
│   ├── database_rules.md
│   └── testing_rules.md
│
└── tasks/
    └── current_task.md
CLAUDE.md
Also update/create the root README.md if necessary so that it explains
the project and points developers/AI agents toward the relevant
documentation.
==================================================
3. CLAUDE.md
==================================================
Create a professional root-level CLAUDE.md.
This is the primary instruction file for Claude Code.
It must explain:
- What this project is
- The technology stack
- The architectural principles
- Where application code lives
- Where documentation lives
- Where AI-specific instructions live
- Which documents must be read before making architectural changes
- Coding standards
- Testing expectations
- Database rules
- UI/UX rules
- Dependency rules
- Git/code-quality expectations
- How Claude should approach implementation
- What Claude must NOT do
Claude must treat the product specification and architecture
documentation as the source of truth.
Claude must not make large architectural changes without first
understanding the existing architecture.
==================================================
4. TECHNOLOGY STACK
==================================================
The current application stack is:
Flutter
Dart
SQLite
Riverpod
Flutter Router / GoRouter
Flutter animations
Gesture handling / drag and drop
Charting / CustomPaint-based visualization
The exact packages may change during implementation.
Do not unnecessarily lock the project to a package if Flutter/Dart
provides an adequate native solution.
Dependency decisions should be documented when they materially affect
architecture.
==================================================
5. ARCHITECTURE PRINCIPLES
==================================================
Document and enforce these principles:
1. Feature-first architecture.
2. Clean separation between:
   - Presentation
   - Domain/business logic
   - Data/infrastructure
3. Platform-independent application logic.
4. Android is the initial target, but the architecture must remain
   compatible with future iOS support.
5. Do not put business logic inside widgets.
6. Do not put database logic directly inside UI code.
7. Use repository abstractions between business logic and persistence.
8. SQLite is the V1 source of truth.
9. The system must remain local-first.
10. Design the data model so cloud synchronization can be introduced
    later without rewriting the application.
11. Use stable IDs.
12. Include appropriate timestamps.
13. Consider soft deletion/versioning/synchronization metadata where
    appropriate for future sync.
14. Do not create separate hardcoded systems for Gym, Reading,
    Walking, Meetings, etc.
15. The activity engine must remain generic.
16. New activity types should primarily be configuration/data rather
    than requiring new database tables.
17. Avoid premature abstraction.
18. Prefer simple, maintainable solutions over clever solutions.
19. Do not introduce backend infrastructure in V1.
20. Do not introduce authentication, cloud sync, AI coaching,
    social features, or other explicitly excluded V1 features unless
    the product specification is changed.
==================================================
6. FLUTTER PROJECT STRUCTURE
==================================================
Document the intended project structure.
The application code should live under:
lib/
with a structure along these lines:
lib/
├── main.dart
├── app/
├── core/
├── features/
└── shared/
The feature structure should follow:
features/
└── feature_name/
    ├── data/
    ├── domain/
    └── presentation/
Document what belongs in each layer.
Do not blindly create empty folders unless they are actually needed.
==================================================
7. DATABASE ARCHITECTURE
==================================================
Document the generic activity data model.
The architecture must support concepts such as:
activity_types
activity_fields
activity_logs
log_values
plans
measurements
focus_sessions
The exact SQLite implementation can be decided during implementation,
but the conceptual model from the existing specification must remain.
Document:
- relationships
- ownership
- IDs
- timestamps
- field types
- repeating groups
- structured values
- migrations
- indexes
- constraints
- future synchronization considerations
Do not create separate tables such as:
gym_logs
reading_logs
walking_logs
meeting_logs
unless there is a demonstrated architectural reason.
==================================================
8. UI/UX ENGINEERING
==================================================
Document the visual direction from the existing specification and the
reference UI observations supplied for this project.
The application should feel:
- premium
- calm
- personal
- modern
- visually distinctive
- easy on the eyes
- fast
- uncluttered
- intentionally designed rather than template-driven
The UI should communicate a clear product identity. Visual design is not
an afterthought; it is part of the product experience and perceived quality.
Reference design principles
The supplied Flowfy screenshots are a design reference, not a template to copy.
Use them to understand principles such as:
- strong and recognizable visual identity
- cohesive use of a small family of colors
- soft pastel surfaces instead of sterile default screens
- large, confident typography and clear hierarchy
- rounded, touch-friendly components
- restrained depth and subtle shadows/borders
- decorative illustrations or visual motifs where they improve the experience
- emotional, human onboarding rather than purely functional forms
- progressive disclosure rather than showing every option at once
- personalization that makes the user feel the product is adapting to them
- benefit-oriented copy instead of technical labels where appropriate
- polished presentation of screenshots/marketing surfaces as part of product packaging
Do not copy Flowfy's exact palette, typography, illustrations, mascot,
layouts, wording, or component designs. The goal is to derive design
principles and create a distinct identity for this product.
Design system requirements
Document and centralize:
- color tokens and semantic color roles
- light/dark theme behavior
- typography families and type scale
- spacing scale
- corner-radius scale
- borders and separators
- elevation/shadows
- iconography rules
- component states
- motion/animation rules
- interaction feedback
- accessibility requirements
Avoid arbitrary one-off values scattered through feature code.
Product experience requirements
The UX documentation should explicitly cover:
- first-run onboarding
- personalization questions, where useful
- empty states
- loading states
- error states
- success/completion states
- quick logging
- confirmation and feedback interactions
- transitions between major screens
- micro-interactions
- responsive phone layouts
- responsive tablet layouts
Onboarding should have a narrative and should help the user understand
why the product is useful. Do not turn onboarding into a long settings form.
Visual quality bar
Do not accept a screen merely because it is functional.
Before considering a UI implementation complete, evaluate:
- hierarchy
- spacing
- alignment
- readability
- touch targets
- visual consistency
- motion quality
- empty/loading/error states
- responsiveness
- whether the screen feels like the same product as the rest of the app
Avoid:
- generic white CRUD screens
- generic black productivity dashboards
- excessive gradients
- excessive cards
- too many buttons
- spreadsheet-like layouts
- default Material styling where a custom product component is more appropriate
- inconsistent colors, typography, spacing, or corner radii
The design system should be centralized rather than having random colors,
spacing values, and typography throughout the application.
Design documentation
The resulting engineering documentation should make the visual system
implementable by another developer without guessing. In particular,
docs/ui/design_system.md, docs/ui/ui_guidelines.md, and
ai/context/design_context.md should contain enough information to guide
future screens consistently.
8A. DESIGN IMPLEMENTATION PRINCIPLES
==================================================
Treat the design system as shared infrastructure, not feature-local styling.
1. Create semantic design tokens before building a large number of screens.
2. Components should consume semantic tokens rather than hardcoded colors,
spacing values, typography values, or radii.
3. Product identity should be visible across onboarding, core navigation,
activity logging, analytics, and empty states.
4. Prefer composition and reusable components over copying screen-specific UI.
5. Preserve interaction patterns across features. A timer, field editor,
confirmation, sheet, or chart should not behave differently on every screen
without a documented reason.
6. Animations must communicate state or improve continuity; do not add
motion only for decoration.
7. Use illustrations/decorative assets selectively. They must support the
product's identity and hierarchy rather than overwhelm the data.
8. The implementation must remain responsive on common Android phones and
larger tablet layouts.
9. Marketing/store presentation is separate from the application UI, but
screens should still be polished enough that the product can be presented
cohesively in future store materials.
10. Never reproduce another product's branded assets or distinctive design
verbatim. Use references to understand principles and create original work.
9. TESTING
==================================================
Define a serious testing strategy.
Document when to use:
- unit tests
- widget tests
- integration tests
Important areas requiring strong testing include:
- Activity Type creation
- Custom fields
- Activity Logs
- Plans
- Database operations
- Repeating groups
- Timers
- Measurements
- Analytics calculations
- Repository behavior
Do not require meaningless tests simply to increase test count.
Focus on behavior and important business rules.
==================================================
10. CODE QUALITY
==================================================
Define senior-engineering coding standards.
Include:
- meaningful naming
- small cohesive classes/functions
- single responsibility
- explicit dependencies
- avoiding unnecessary duplication
- avoiding giant widgets
- avoiding giant provider files
- avoiding global mutable state
- null-safety
- error handling
- logging
- documentation where useful
- linting
- formatting
- dependency discipline
Do not over-engineer.
The goal is maintainable production code, not architecture for
architecture's sake.
==================================================
11. FUTURE BACKEND/SYNC
==================================================
The V1 application has NO backend.
However, the documentation must explain how the architecture can
eventually evolve into:
Flutter App
    ↓
Repository
    ↓
Local SQLite
    +
Remote API
    ↓
Cloud Database
Document the principles needed to make this possible without forcing
cloud complexity into V1.
Do not implement the backend.
==================================================
12. ARCHITECTURE DECISION RECORDS
==================================================
Create an architecture decision document.
Record important decisions such as:
- Flutter instead of separate Kotlin/Swift applications
- SQLite for V1
- Local-first architecture
- Riverpod for state management
- Feature-first structure
- Generic activity engine
- Repository abstraction
- No backend in V1
- Android-first development with future iOS support
For each decision explain:
- Decision
- Context
- Reason
- Consequences
Do not invent decisions that have not actually been made.
==================================================
13. IMPORTANT: DO NOT IMPLEMENT YET
==================================================
At this stage:
DO NOT:
- create application screens
- create database code
- create providers
- create widgets
- install random packages
- implement features
- create backend code
- create authentication
- create cloud infrastructure
Only create/update the Markdown documentation and project-level
configuration/documentation files required for the documentation system.
==================================================
14. SENIOR ENGINEER STANDARD
==================================================
Approach this as if another senior engineer will join the project
six months from now.
A developer should be able to understand:
- what the product does
- why the architecture exists
- where code belongs
- how data flows
- how the database works
- how state is managed
- how UI is structured
- how features should be implemented
- how code should be tested
- what is intentionally NOT part of V1
Documentation should be concise enough to remain maintainable.
Do not duplicate the same information across ten files.
If information belongs in one canonical document, reference that
document instead of copying the entire explanation elsewhere.
==================================================
15. FINAL STEP
==================================================
After creating all documentation:
1. Show the final directory tree.
2. Explain the purpose of every Markdown file.
3. Identify any contradictions or ambiguities found in the existing
   specification.
4. Identify any architectural decisions that still require a decision.
5. Do NOT start implementing the Flutter application.
Wait for further instructions after the documentation phase is complete.