import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/ids/id_generator.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:daylog/features/insights/presentation/activity_insights_screen.dart';
import 'package:daylog/features/measurements/data/db_measurement_repository.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/measurements/domain/measurement.dart';
import 'package:daylog/features/measurements/domain/measurement_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show scrollAndTap;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

Future<void> seedWeights(AppDatabase db, FakeClock clock) async {
  final IdGenerator ids = SequentialIdGenerator();
  final record = RecordMeasurement(
    DbMeasurementRepository(db, clock),
    ids,
    clock,
  );
  for (final (day, kg) in [(24, 85.0), (1, 84.2)]) {
    await record(
      MeasurementDraft(
        type: MeasurementType.weight,
        value: kg,
        unitCode: 'kg',
        recordedAt: day == 1
            ? DateTime.utc(2026, 10, 1, 7)
            : DateTime.utc(2026, 9, day, 7),
      ),
    );
  }
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

/// Scrolls the Insights tab down to its list of activities.
Future<void> scrollToActivities(WidgetTester tester) =>
    tester.scrollUntilVisible(
      find.text('Activities'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );

void main() {
  testAppWidgets('an empty Insights tab invites building a chart', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openTab(tester, 'Insights');

    expect(find.text('Nothing recorded in this period.'), findsOneWidget);
    expect(find.text('Build your first chart'), findsOneWidget);
  });

  testAppWidgets('building a body-weight chart shows the latest value and a '
      'line', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedWeights);
    await openTab(tester, 'Insights');

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Add chart'));
    await tester.tap(find.text('Body measurement'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    await tester.scrollUntilVisible(
      find.byType(LineChart),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Weight'), findsWidgets);
    // The headline (the axis now fits 84–85 kg and may repeat it, D1).
    expect(find.text('84.2 kg'), findsWidgets);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testAppWidgets('recording a body measurement from Me', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openTab(tester, 'Me');
    await tester.tap(find.text('Body measurements'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add measurement'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Value'), '84.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('84.5 kg'), findsOneWidget);
  });

  testAppWidgets('an activity in Insights opens its progress, worked out '
      'automatically (ADR-037)', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async {
        final ids = SequentialIdGenerator();
        final types = DbActivityTypeRepository(db, clock);
        final logs = DbActivityLogRepository(db, clock, const AppLogger());
        final gymId = await CreateActivityType(types, ids)(gymDefinition());
        final gym = (await types.getType(gymId))!;
        ActivityFieldId f(String name) =>
            gym.fields.firstWhere((x) => x.name == name).id;
        await LogActivity(types, logs, DbPlanRepository(db, clock), ids, clock)(
          gymId,
          ActivityLogDraft(
            startedAt: DateTime.utc(2026, 10, 2, 18),
            durationMs: 3600000,
            values: {
              f('Exercises'): RepeatingGroupValue([
                GroupItem(
                  id: GroupItemId(ids.newId()),
                  values: {
                    f('Exercise'): const TextValue('Chest Press'),
                    f('Sets'): RepeatingGroupValue([
                      GroupItem(
                        id: GroupItemId(ids.newId()),
                        values: {
                          f('Weight'): const NumberValue(60, unitCode: 'kg'),
                          f('Reps'): const NumberValue(8),
                        },
                      ),
                    ]),
                  },
                ),
              ]),
            },
          ),
        );
      },
    );
    await openTab(tester, 'Insights');

    // The activities come after the period's overview.
    await scrollToActivities(tester);
    expect(find.textContaining('1 day ·'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Gym'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityInsightsScreen), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chest Press · best Weight'),
      200,
      // The page's list, not the range chips scrolling sideways in it.
      scrollable: find
          .descendant(
            of: find.byType(ActivityInsightsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Chest Press · best Weight'), findsOneWidget);
    expect(find.byTooltip('Chart options'), findsNothing, reason: 'automatic');
    // One period for every number (A20), records named for what they are.
    expect(find.text('Sep 4 – Oct 3'), findsOneWidget);
    expect(find.text('best this period'), findsWidgets);
    expect(find.text('All-time best 60 kg · Oct 2'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Best day 480 kg · Oct 2'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ActivityInsightsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Best Set 480 kg · Oct 2'), findsOneWidget, reason: 'A21');
  });

  group('one period, live and clear (A20–A24)', () {
    // One generator for the group, so IDs never repeat within a database.
    final ids = SequentialIdGenerator();
    Future<ActivityTypeId> logReading(
      AppDatabase db,
      FakeClock clock, {
      ActivityTypeId? typeId,
      String name = 'Reading',
      int? durationMs,
    }) async {
      final types = DbActivityTypeRepository(db, clock);
      final logs = DbActivityLogRepository(db, clock, const AppLogger());
      // Straight through the repository: two activities may share a name
      // when they were made before names were unique (A24).
      final id = typeId ?? ActivityTypeId(ids.newId());
      if (typeId == null) {
        await types.create(
          id,
          ActivityTypeDefinition(
            name: name,
            iconId: 'book-open',
            colorKey: 'sky',
            fields: const [],
          ),
        );
      }
      await LogActivity(types, logs, DbPlanRepository(db, clock), ids, clock)(
        id,
        ActivityLogDraft(
          startedAt: clock.nowUtc(),
          durationMs: durationMs,
          // Something in it, so it counts as done (A8).
          notes: 'A chapter',
          values: const {},
        ),
      );
      return id;
    }

    testAppWidgets('the activity list updates as soon as something is '
        'logged', (tester) async {
      late ActivityTypeId reading;
      final db = await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) async => reading = await logReading(db, clock),
      );
      await openTab(tester, 'Insights');
      await scrollToActivities(tester);
      expect(find.textContaining('1 day · once'), findsOneWidget);

      await tester.runAsync(
        () => logReading(
          db,
          FakeClock(DateTime.utc(2026, 10, 3, 9)),
          typeId: reading,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('2 times'), findsOneWidget);
    });

    testAppWidgets('two activities with one name are told apart', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) async {
          await logReading(db, clock);
          await logReading(db, clock);
        },
      );
      await openTab(tester, 'Insights');
      await scrollToActivities(tester);

      expect(
        find.textContaining('Another activity has this name'),
        findsNWidgets(2),
      );
    });

    testAppWidgets('an automatic chart with nothing in the period is left out '
        '(A23)', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) => logReading(db, clock),
      );
      await openTab(tester, 'Insights');
      await scrollToActivities(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Reading'));
      await tester.pumpAndSettle();

      expect(find.text('Times done'), findsOneWidget);
      expect(find.text('Time'), findsNothing, reason: 'never timed');
      expect(find.text('No data in this period yet.'), findsNothing);
    });
  });

  testAppWidgets('the Insights home shows the period at a glance, the '
      'calendar, and activities not done this period stay reachable (H1, '
      'H5, B6)', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async {
        final ids = SequentialIdGenerator();
        final types = DbActivityTypeRepository(db, clock);
        final logs = DbActivityLogRepository(db, clock, const AppLogger());
        final log = LogActivity(
          types,
          logs,
          DbPlanRepository(db, clock),
          ids,
          clock,
        );
        Future<ActivityTypeId> make(String name) => types
            .create(
              ActivityTypeId(ids.newId()),
              ActivityTypeDefinition(
                name: name,
                iconId: 'book-open',
                colorKey: 'sky',
                fields: const [],
              ),
            )
            .then((_) async => (await types.getActiveTypes()).last.id);
        final recent = await make('Journal');
        final old = await make('Painting');
        await log(
          recent,
          ActivityLogDraft(
            startedAt: clock.nowUtc(),
            durationMs: 1800000,
            notes: 'Good day',
            values: const {},
          ),
        );
        await log(
          old,
          ActivityLogDraft(
            startedAt: DateTime.utc(2026, 3, 1, 10),
            notes: 'Sky study',
            values: const {},
          ),
        );
      },
    );
    await openTab(tester, 'Insights');

    expect(find.text('At a glance'), findsOneWidget);
    expect(find.text('Days active'), findsOneWidget);
    expect(find.text('Consistency'), findsOneWidget);
    expect(find.text('1 of 30 days'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Not done this period'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.widgetWithText(ListTile, 'Painting'), findsOneWidget);
    expect(find.textContaining('Best run 1 week'), findsOneWidget);
    await scrollAndTap(tester, find.widgetWithText(ListTile, 'Painting'));
    expect(find.byType(ActivityInsightsScreen), findsOneWidget);
    expect(
      find.textContaining('Pick a longer period above'),
      findsOneWidget,
      reason: 'C4',
    );
  });

  testAppWidgets('an activity\'s page charts yes/no as a share, choices as '
      'how often each, and when in the day it\'s done (B2, B3)', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async {
        final ids = SequentialIdGenerator();
        final types = DbActivityTypeRepository(db, clock);
        final logs = DbActivityLogRepository(db, clock, const AppLogger());
        final id = await CreateActivityType(types, ids)(
          const ActivityTypeDefinition(
            name: 'Meds',
            iconId: 'pill',
            colorKey: 'rose',
            fields: [
              FieldDefinition(
                name: 'Taken',
                type: FieldType.boolean,
                config: BooleanFieldConfig(),
              ),
              FieldDefinition(
                name: 'Dose time',
                type: FieldType.singleSelect,
                config: SelectFieldConfig(
                  options: [
                    SelectOption(
                      id: SelectOptionId('am'),
                      label: 'With breakfast',
                    ),
                    SelectOption(
                      id: SelectOptionId('pm'),
                      label: 'With dinner',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        final type = (await types.getType(id))!;
        ActivityFieldId f(String name) =>
            type.fields.firstWhere((x) => x.name == name).id;
        final pm =
            (type.fields.firstWhere((x) => x.name == 'Dose time').config
                    as SelectFieldConfig)
                .options[1]
                .id;
        await LogActivity(types, logs, DbPlanRepository(db, clock), ids, clock)(
          id,
          ActivityLogDraft(
            // 08:00 local: the test clock's morning.
            startedAt: clock.nowUtc(),
            values: {
              f('Taken'): const BooleanValue(true),
              f('Dose time'): SingleSelectValue(pm),
            },
          ),
        );
      },
    );
    await openTab(tester, 'Insights');
    await scrollToActivities(tester);
    await scrollAndTap(tester, find.widgetWithText(ListTile, 'Meds'));

    final page = find
        .descendant(
          of: find.byType(ActivityInsightsScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(find.text('When you do it'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Taken · how often yes'),
      200,
      scrollable: page,
    );
    expect(find.text('100 %'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('How often each'),
      200,
      scrollable: page,
    );
    expect(find.text('With dinner'), findsOneWidget);
    expect(find.text('With breakfast'), findsNothing, reason: 'never picked');
  });
}
