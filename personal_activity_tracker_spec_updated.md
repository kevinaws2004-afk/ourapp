# Personal Activity & Life Tracking App
## Product + Technical Specification — V1
---
## 1. Product Overview
### Working concept
A customizable personal activity system that lets users:
1. Plan what they intend to do.
2. Log what they actually did.
3. Attach different kinds of data to different activities.
4. Track measurable progress over time.
5. Use timers/focus sessions for time-based activities.
6. Review their entire day as a timeline.
7. Build their own activity templates instead of being forced into predefined categories.
The product is **not simply a habit tracker, to-do list, gym tracker, or calendar**.
The core concept is:
> **Plan → Do → Log → Measure → Understand**
The same underlying system should support:
- Gym workouts
- Reading
- Focused work
- Studying
- Walking
- Meditation
- Meetings
- Body measurements
- Personal routines
- Shopping/tasks
- Email/follow-ups
- Any custom activity the user wants to create
---
# 2. Product Philosophy
## 2.1 The app should be customizable
Users should not be forced to use a predefined model such as:
> "A workout always has sets, reps and weight."
Instead, users create an activity and decide what information matters.
Example:
### Gym
- Exercise
- Sets
- Reps
- Weight
- Duration
- Notes
### Reading
- Book
- Duration
- Pages
- Rating
- Notes
### Meeting
- People
- Duration
- Topics
- Decisions
- Action items
- Notes
### Walking
- Duration
- Distance
- Steps
- Calories
- Location
The application provides reusable field types and components that users combine.
---
# 3. Core Concepts
There are four major concepts.
## 3.1 Activity Type
An Activity Type is a reusable definition/template.
Examples:
- Gym
- Reading
- Focused Work
- Meeting
- Walking
- Study
It defines:
- Name
- Icon
- Appearance
- Fields
- Field order
- Which fields are measurable
- Whether the activity supports a timer
- Whether the activity can be planned
- Whether it supports repeating groups
An Activity Type is **not an actual event**.
---
## 3.2 Plan
A Plan represents what the user intends to do.
Example:
```text
Tomorrow
07:30  Gym
09:30  Focused Work
12:30  Read
14:00  Meeting
18:00  Walk
```
A plan can be very simple.
For example:
```text
Read
```
or more specific:
```text
Read Fooled by Randomness for 45 minutes
```
Plans represent **intention**.
---
## 3.3 Activity Log
An Activity Log represents what actually happened.
Example:
```text
Gym
07:42 - 08:51
Chest Press
50 kg × 12
55 kg × 10
60 kg × 8
Incline DB Press
20 kg × 12
20 kg × 10
```
Another example:
```text
Reading
21:10 - 21:55
Book:
Fooled by Randomness
Duration:
45 minutes
Pages:
18
```
Logs represent **reality**.
---
## 3.4 Measurement
A Measurement is a tracked value that can be analyzed over time.
Examples:
- Body weight
- Height
- Body fat
- Reading duration
- Work duration
- Walking distance
- Gym weight
- Reps
- Number of completed tasks
Measurements are what power analytics and graphs.
---
# 4. Fundamental Product Model
The architecture should follow:
```text
Activity Type
      |
      | defines
      v
Fields
      |
      | used when creating
      v
Activity Log
      |
      | contains
      v
Field Values
      |
      | analyzed by
      v
Analytics
```
Example:
```text
GYM
 |
 +-- Exercise
 +-- Sets
 +-- Weight
 +-- Reps
 +-- Duration
 +-- Notes
 |
 +-- Today's Log
       |
       +-- Chest Press
       |     +-- 50kg × 12
       |     +-- 55kg × 10
       |     +-- 60kg × 8
       |
       +-- Incline DB Press
             +-- 20kg × 12
             +-- 20kg × 10
```
Reading uses the exact same engine:
```text
READING
 |
 +-- Book
 +-- Duration
 +-- Pages
 +-- Rating
 +-- Notes
 |
 +-- Today's Log
       |
       +-- Fooled by Randomness
       +-- 45 minutes
       +-- 18 pages
```
---
# 5. Why the Database Must Be Generic
Do NOT create:
```text
gym_logs
reading_logs
work_logs
meeting_logs
walking_logs
```
That would make every new activity require new database tables and application code.
Instead, use a generic architecture:
```text
activity_types
activity_fields
activity_logs
log_values
```
The activity definition tells the application how to render the input form.
This allows a user to create new activity types without developers changing the database schema.
---
# 6. Local-First Architecture
## V1 requires no backend.
Everything should work locally.
### Technology
Suggested stack:
```text
Flutter
Dart
Flutter Router / GoRouter
SQLite
Riverpod
Flutter Animate / native Flutter animations
Gesture handling / drag & drop
Charting library / CustomPaint-based visualization
```
The exact libraries can change during implementation, but the architectural principle should remain:
> **Local-first, offline-first.**
---
# 7. Backend Requirements
## V1
No:
- API server
- PostgreSQL server
- Firebase
- Supabase
- AWS
- Authentication server
- Cloud database
Use:
```text
Android Device
      |
      v
Local SQLite
```
Infrastructure cost:
```text
₹0/month
```
for the application's backend infrastructure.
---
# 8. Why SQLite
The application will eventually contain:
- Thousands of activity logs
- Workout sets
- Reading sessions
- Focus sessions
- Plans
- Meetings
- Notes
- Body measurements
- Custom activity definitions
SQLite is appropriate because it provides:
- Structured storage
- Queries
- Indexing
- Transactions
- Offline operation
- Good performance
- No server
- No recurring infrastructure cost
---
# 9. Activity Field System
The most important feature is the customizable field system.
Users should be able to create:
```text
Activity
   |
   +-- Add Field
```
Available field types should initially include:
### Basic
- Text
- Long Text
- Number
- Boolean
- Date
- Time
- Date + Time
- Rating
- Dropdown
### Time
- Duration
- Timer
### Measurement
- Weight
- Distance
- Count
- Percentage
### People / Organization
- Person
- Multi-person
### Structured
- Checklist
- Repeating Group
- Set Table
---
# 10. Field Definition
Conceptually:
```text
Field
--------------------
id
activity_type_id
name
field_type
position
required
config
```
Example:
```text
Gym
Field:
Weight
Type:
Number
Unit:
kg
Required:
false
```
Another:
```text
Reading
Field:
Duration
Type:
Duration
Input:
Timer
```
---
# 11. Activity Builder
The user should be able to create an activity through a visual builder.
Example:
```text
Create Activity
Name:
[ Gym ]
Icon:
[ dumbbell ]
Fields:
[ Exercise       ]
[ Set Table      ]
[ Duration       ]
[ Notes          ]
+ Add Field
[ Save Activity ]
```
The user can reorder fields.
Example:
```text
1. Exercise
2. Set Table
3. Duration
4. Notes
```
---
# 12. Gym Activity
Gym requires a special structured component.
## Gym Activity
```text
Gym
```
Possible fields:
```text
Workout duration
Exercise list
Notes
```
Each exercise contains a repeating set structure.
Example:
```text
Chest Press
Set    Weight    Reps
------------------------
1      50 kg     12
2      55 kg     10
3      60 kg      8
+ Add Set
```
Then:
```text
+ Add Exercise
```
Example full workout:
```text
GYM
Duration: 1h 12m
Chest Press
50kg × 12
55kg × 10
60kg × 8
Incline DB Press
20kg × 12
20kg × 10
22.5kg × 8
Cable Fly
15kg × 15
15kg × 12
Notes:
Good workout.
```
---
# 13. Gym Analytics
The application should be able to derive:
- Maximum weight
- Maximum reps
- Total sets
- Total workout duration
- Exercise frequency
- Estimated volume
- Weight progression
- Rep progression
- Workout frequency
- Personal records
Example:
```text
Chest Press
Oct 1   50 kg
Oct 4   52.5 kg
Oct 8   55 kg
Oct 12  57.5 kg
Oct 17  60 kg
```
The user can select:
```text
Weight
Reps
Volume
Frequency
```
and see the appropriate graph.
---
# 14. Reading Activity
Example fields:
```text
Book
Duration
Pages
Rating
Notes
```
The timer can automatically populate Duration.
Example:
```text
READING
Book:
Fooled by Randomness
Started:
21:10
Finished:
21:55
Duration:
45 minutes
Pages:
18
Notes:
Chapter 4
```
---
# 15. Reading Analytics
Possible measurements:
- Minutes per day
- Minutes per week
- Pages per day
- Pages per week
- Reading sessions
- Average session duration
- Book completion
- Reading consistency
Example:
```text
Reading Time
Monday       40m
Tuesday      55m
Wednesday    20m
Thursday     75m
Friday       45m
```
Graph:
```text
Time
 |
 |            *
 |      *     |
 |  *   |     *
 |  |   |     |
 +----------------
    M T W T F
```
---
# 16. Focus Mode
Any activity with a Duration/Timer field can optionally support Focus Mode.
Example:
```text
READING
Fooled by Randomness
        42:17
      [ Pause ]
      [ Finish ]
```
When finished:
```text
Reading session complete
42 minutes
```
The duration is automatically stored in the activity log.
The same timer can be used for:
- Reading
- Focused work
- Studying
- Coding
- Meditation
- Writing
- Exercise
- Any user-created activity
---
# 17. Focus Mode and Distraction Control
V1 should support:
- Full-screen focus timer
- Start/pause/resume
- Finish session
- Automatic duration logging
- Optional notes after session
Actual blocking of other Android applications should be treated as a later Android-specific feature.
Do not make the core product dependent on app blocking.
---
# 18. Daily Timeline
The Today screen is one of the most important screens.
Example:
```text
TODAY
07:32
GYM
1h 04m
Chest / Shoulders
09:41
FOCUSED WORK
2h 13m
Project: My App
12:32
LUNCH
14:10
MEETING
47m
Product roadmap
17:25
READING
38m
Fooled by Randomness
19:10
WALK
31m
```
This should answer:
> "What did I actually do today?"
---
# 19. Planning
The user can create plans for:
- Today
- Tomorrow
- Future dates
Example:
```text
TOMORROW
07:30  Gym
09:30  Work
12:30  Reading
14:00  Meeting
18:00  Walk
23:00  Sleep
```
A planned item can optionally link to an Activity Type.
Example:
```text
Plan:
Read
Linked Activity:
Reading
```
When the user completes the plan, they can create the corresponding activity log.
---
# 20. Plan vs Log
This distinction is fundamental.
### Plan
What the user intended to do.
```text
Read for 1 hour.
```
### Log
What actually happened.
```text
Read for 37 minutes.
```
The application should preserve both.
This allows future analytics such as:
```text
Planned:
60 min
Actual:
37 min
Difference:
-23 min
```
---
# 21. Tasks Without Detailed Logging
Not everything needs a detailed Activity Log.
Examples:
```text
Brush teeth
Buy groceries
Email John
Call Mom
Pay bill
```
These can simply be tasks.
The user should not have to configure five fields just to remember:
> "Buy milk."
Therefore the app needs a lightweight task/plan mode.
---
# 22. Meetings
Meetings can use a custom Activity Type.
Example:
```text
MEETING
People:
Kevin
John
Sarah
Duration:
48 min
Topics:
- Product roadmap
- Pricing
- Launch
Decisions:
- Launch V1 first
Action Items:
[ ] Kevin → Build analytics
[ ] John → Prepare design
Notes:
...
```
The same meeting can be stored as an Activity Log.
---
# 23. Body Measurements
Body tracking should be separate from Activity Types conceptually, while using the same analytics principles.
Possible measurements:
```text
Weight
Height
Body Fat %
Chest
Waist
Arms
Legs
```
Example:
```text
BODY WEIGHT
Oct 1    85.0 kg
Oct 8    84.2 kg
Oct 15   83.6 kg
Oct 22   83.1 kg
```
This naturally becomes a time-series graph.
---
# 24. Analytics Engine
The analytics engine should not know what an activity means.
It should understand:
```text
Time
+
Measurement
+
Unit
```
Example:
```text
Reading
Duration
```
becomes:
```text
Date → Minutes
```
Gym:
```text
Chest Press
Weight
```
becomes:
```text
Date → Weight
```
Body:
```text
Weight
```
becomes:
```text
Date → Body Weight
```
This makes the graph system reusable.
---
# 25. Analytics Types
V1 analytics should include:
### Time Series
Examples:
- Reading minutes
- Work hours
- Body weight
- Exercise weight
### Totals
Examples:
- Total reading time this week
- Total focused work
- Total workouts
- Total walking distance
### Counts
Examples:
- Workouts
- Reading sessions
- Meetings
- Completed tasks
### Averages
Examples:
- Average reading session
- Average workout duration
- Average meeting duration
### Comparison
Examples:
```text
This week vs last week
This month vs last month
```
---
# 26. Graph System
The user should not have to create a new graph implementation for every activity.
A generic graph configuration can specify:
```text
Activity
Field
Metric
Time range
Aggregation
Chart type
```
Example:
```text
Activity:
Reading
Field:
Duration
Metric:
Total per day
Range:
Last 30 days
Chart:
Line
```
Another:
```text
Activity:
Gym
Exercise:
Chest Press
Metric:
Maximum Weight
Range:
Last 6 months
Chart:
Line
```
---
# 27. Local Data Model
Initial SQLite schema:
## activity_types
```text
id
name
icon
color
description
supports_timer
created_at
updated_at
```
## activity_fields
```text
id
activity_type_id
name
field_type
position
required
config_json
created_at
updated_at
```
## activity_logs
```text
id
activity_type_id
started_at
ended_at
created_at
updated_at
notes
```
## log_values
```text
id
log_id
field_id
value_text
value_number
value_json
```
Only the appropriate value representation should be populated.
For complex structures such as gym sets, `value_json` can store structured data initially.
---
# 28. Plans
## plans
```text
id
title
description
scheduled_start
scheduled_end
activity_type_id
status
created_at
updated_at
```
Possible status:
```text
planned
in_progress
completed
skipped
cancelled
```
---
# 29. Body Measurements
## measurements
```text
id
measurement_type
value
unit
recorded_at
notes
```
Examples:
```text
weight | 85.0 | kg | 2026-10-03
height | 180  | cm | 2026-10-03
```
---
# 30. Focus Sessions
Focus sessions can either be represented as normal Activity Logs or have a lightweight session table.
Initial approach:
```text
focus_session
```
can contain:
```text
id
activity_log_id
started_at
paused_duration
ended_at
duration
```
This keeps timer behavior separate from general activity data while still linking the result to the Activity Log.
---
# 31. Custom Activity Example
Suppose the user creates:
```text
Language Learning
```
Fields:
```text
Language       → Dropdown
Duration       → Timer
Words learned  → Number
Lesson         → Text
Difficulty     → Rating
Notes          → Long Text
```
No developer code should be required.
The app should render the activity form from the field definitions.
---
# 32. Another Custom Example
User creates:
```text
Cooking
```
Fields:
```text
Recipe         → Text
Duration       → Timer
Servings       → Number
Calories       → Number
Rating         → Rating
Ingredients    → Checklist
Notes          → Long Text
```
Again, no database migration should be required.
---
# 33. UI/UX Direction
The application should feel:
- Calm
- Premium
- Personal
- Modern
- Visually rich
- Visually distinctive
- Easy on the eyes
- Fast
- Non-cluttered
- Designed as a coherent product rather than a collection of screens
The interface should have a clear visual identity. The goal is not simply
to make individual screens attractive; the entire product should feel like
one recognizable visual system.
33.1 Design principles observed from reference products
The supplied Flowfy screenshots are being used as a reference for design
principles only. They demonstrate several useful principles that should
inform our design without copying their visual identity.
The reference demonstrates:
- a cohesive visual world across screens and promotional surfaces
- soft pastel backgrounds and surfaces rather than generic white screens
- large, confident typography with a strong display style
- rounded, touch-friendly components
- subtle borders and depth rather than heavy shadows
- a restrained palette with a few memorable accent colors
- illustrations and decorative objects used to create personality
- onboarding that feels conversational and human
- progressive disclosure: one meaningful question or decision at a time
- personalization before the main product experience
- outcome-oriented copy rather than purely functional labels
- a strong distinction between ordinary functionality and how that
  functionality is packaged and presented to the user
These are principles, not requirements to reproduce Flowfy's exact
colors, fonts, illustrations, mascot, wording, layouts, or branding.
Our application must develop its own visual identity appropriate to the
idea of understanding and improving how a person spends their time and lives
their day.
33.2 Visual identity
The design system should define:
- primary and secondary color families
- semantic colors
- light and dark themes
- typography families
- display/headline typography
- body typography
- numeric/data typography where useful
- spacing scale
- corner-radius scale
- border styles
- elevation and shadow rules
- iconography
- illustration style
- component states
- motion rules
Do not hardcode arbitrary visual values inside individual screens.
The visual system should be centralized and reusable across the application.
33.3 Product packaging
Product packaging is part of the overall product experience.
The application should be designed so that its value can eventually be
communicated through the same visual language in:
- onboarding
- empty states
- core screens
- feature introductions
- completion states
- screenshots
- future app-store presentation
The product should not rely on functional descriptions alone such as:
"Create Activity", "Add Log", or "View Analytics".
Where appropriate, copy should communicate the user's goal or outcome while
remaining clear and concise.
33.4 Onboarding philosophy
The first-run experience should feel like the product is helping the user
set up their own system, not filling out a configuration form.
Prefer:
Understand the user
        ↓
Ask one meaningful question
        ↓
Personalize the starting experience
        ↓
Show what the user will get
        ↓
Let the user begin
Onboarding should remain short enough that the user can reach the core
product without unnecessary friction.
Where useful, it may ask about:
- what the user wants to track
- which activities matter to them
- whether they want planning, logging, focus sessions, or analytics
- initial preferences
Do not force the user to configure the entire system before using it.
33.5 Components
Use a coherent component language:
- rounded surfaces where appropriate
- comfortable touch targets
- clear hierarchy
- restrained borders/shadows
- consistent controls
- consistent sheets/dialogs
- consistent input fields
- consistent buttons
- consistent chips/tags
- consistent charts
- consistent empty/loading/error states
Avoid:
- Generic white CRUD screens
- Generic black productivity dashboards
- Excessive gradients
- Excessive cards
- Too many buttons
- Spreadsheet-like interfaces
- Default Material components used without adaptation when they conflict
  with the product's design language
- Random one-off colors or spacing
33.6 Motion and interaction
Motion should be subtle, fast, and meaningful.
Use animation for:
- navigation continuity
- expanding/collapsing content
- progress changes
- timer state changes
- success/completion feedback
- reordering or drag-and-drop
- chart transitions where useful
Avoid animation that delays common actions or makes the interface feel busy.
33.7 Responsive design
The UI must be designed for:
- Android phones
- Android tablets
- future iOS phone support
- future iOS tablet support
Do not simply stretch a phone layout to fill a tablet.
Use responsive layout rules, adaptive spacing, and appropriate content
constraints from the beginning.
# 34. Primary Navigation
Recommended V1 navigation:
```text
Today
Plan
Track
Insights
Me
```
## Today
Today's plan + actual timeline.
## Plan
Future planning.
## Track
Activity types and logging.
## Insights
Graphs and historical analytics.
## Me
Body measurements, preferences, settings, export.
---
# 35. Today Screen
The Today screen should combine:
### Morning
```text
Good morning
Today's plan
07:30 Gym
09:30 Work
12:30 Reading
14:00 Meeting
```
### During the day
Users can start activities.
### Evening
The timeline becomes:
```text
What you planned
vs
What actually happened
```
---
# 36. Activity Logging UX
The user should have multiple ways to start a log.
### From Today
Tap:
```text
Gym
```
### From Track
Tap:
```text
Gym → Log
```
### From a Plan
Tap:
```text
Gym → Start
```
### From Focus
Tap:
```text
Reading → Start Focus
```
---
# 37. Quick Logging
The application should support extremely fast logging.
Example:
```text
+ Log
Gym
Reading
Work
Meeting
Task
```
The user should not have to navigate through multiple screens for common activities.
---
# 38. Search and History
Users should be able to search their logs.
Examples:
```text
Chest Press
Fooled by Randomness
Meeting with John
Work
```
History should be filterable by:
- Activity
- Date
- Measurement
- Tag
- Person
- Project
---
# 39. Data Privacy
V1 should be local-first.
Potential product positioning:
> Your personal activity data stays on your device.
No account is required.
No data needs to leave the device for the core application.
Future cloud functionality should be opt-in.
---
# 40. Backup / Export
Even without a backend, users need a way to protect their data.
V1 should eventually support:
```text
Export data
```
Possible formats:
```text
JSON
CSV
```
A backup can be saved to the user's device.
Cloud sync is not required for the initial release.
---
# 41. V1 Scope
The first shippable version should contain:
## Core
- Local SQLite
- Activity Types
- Custom Fields
- Activity Logs
- Plans
- Basic Tasks
- Daily Timeline
## Tracking
- Timer
- Focus sessions
- Number fields
- Duration fields
- Text fields
- Rating
- Checklist
- Set Table
## Gym
- Exercises
- Sets
- Reps
- Weight
- Workout duration
## Reading
- Book
- Duration
- Pages
- Notes
## Analytics
- Basic history
- Line graphs
- Totals
- Counts
- Time-based measurements
## Body
- Weight
- Height
- Basic body measurements
## UX
- Premium visual design
- Distinct visual identity
- Centralized design system
- Light/dark themes
- Smooth navigation
- Short first-run onboarding
- Empty, loading, error, and success states
- Meaningful micro-interactions
- Responsive phone/tablet layouts
- Fast logging
---
# 42. Explicitly Out of V1
Do not build these initially:
- User accounts
- Cloud sync
- Social network
- Public profiles
- Leaderboards
- Multiplayer
- AI assistant
- AI coaching
- Subscription system
- Complex recommendation engine
- Web application
- Desktop application
- Cross-device synchronization
- Advanced app blocking
- Wearable integrations
- Complex automation engine
These can be considered only after the core product works.
---
# 43. V1 Success Criterion
The first version is successful if a user can do this:
### Night
Create tomorrow's plan:
```text
Gym
Work
Read
Meeting
Walk
```
### Morning
See the plan.
### Gym
Start Gym.
Log:
```text
Chest Press
50 × 12
55 × 10
60 × 8
```
### Work
Start Focus Mode.
Work for:
```text
1h 42m
```
### Reading
Start Reading timer.
Read for:
```text
43m
```
### Meeting
Log:
```text
48m
Topics
Decisions
Action items
```
### Night
Open Today.
See:
```text
Planned:
Gym
Work
Reading
Meeting
Walk
Actual:
Gym       1h 04m
Work      1h 42m
Reading   43m
Meeting   48m
Walk      31m
```
Then open Insights and see progress over time.
If this works smoothly, the core product is real.
---
# 44. Future Product Expansion
Once the foundation is stable, possible additions include:
## Cloud
- Account
- Backup
- Multi-device sync
## AI
- Daily summaries
- Weekly summaries
- Natural-language logging
- Automatic categorization
- Pattern discovery
- Personal insights
Example:
> "You planned 6 hours of focused work this week and completed 4h 32m."
## Integrations
- Google Calendar
- Apple/Android health data
- Wearables
- Email
- Calendar
- Fitness platforms
## Advanced Focus
- Android app blocking
- Website blocking
- Scheduled focus sessions
- Automatic Do Not Disturb integration
## Advanced Analytics
- Correlations
- Goal tracking
- Personal records
- Trends
- Planned vs actual
- Consistency
- Time allocation
---
# 45. Long-Term Product Model
The eventual product can become:
```text
                    YOUR LIFE
                       |
        ┌──────────────┼──────────────┐
        |              |              |
       PLAN           DO             MEASURE
        |              |              |
      Tasks        Activities       Metrics
        |              |              |
        └──────────────┼──────────────┘
                       |
                    INSIGHTS
                       |
                "Understand yourself"
```
The core advantage is that users aren't restricted to one domain.
The same system can understand:
```text
Gym
Reading
Work
Study
Meetings
Walking
Meditation
Sleep
Body
Money
Learning
Projects
Routines
Tasks
```
without requiring a separate application for every part of life.
---
# 46. Most Important Architectural Principle
The application should be **configuration-driven**.
Do not write:
```text
if activity == gym:
    show gym screen
if activity == reading:
    show reading screen
if activity == meeting:
    show meeting screen
```
Instead:
```text
Activity Type
      |
      v
Field Definitions
      |
      v
Generic Form Renderer
      |
      v
Activity Log
```
Special components such as the Gym Set Table can exist where the data structure genuinely requires them.
This keeps the application extensible.
---
# 46A. Product Experience Principle
The product should follow this principle:
The underlying functionality can be simple; the experience should feel intentional, coherent, and distinctly valuable.

The application should compete on clarity, personalization, visual identity,
interaction quality, and the usefulness of the information it helps the user
understand.
Reference products may inform design principles, but the final interface,
copy, visual language, illustrations, and interaction patterns must be
original to this product.
# 47. Final Product Definition
The product can be summarized in one sentence:
> **A customizable local-first personal activity system that lets users plan their day, record what they actually do, capture the data that matters for each activity, and understand their progress over time.**
The central abstraction is:
```text
Activity Type
      ↓
Custom Fields
      ↓
Plan
      ↓
Activity Log
      ↓
Measurements
      ↓
Analytics
```
Gym, Reading, Work, Meetings, Body Weight and every future category are different expressions of the same underlying system.
That is the foundation on which the entire application should be built.
