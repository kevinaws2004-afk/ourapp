import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/ids/id_generator.dart';
import 'package:daylog/features/measurements/data/db_measurement_repository.dart';
import 'package:daylog/features/measurements/domain/measurement.dart';
import 'package:daylog/features/measurements/domain/measurement_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show scrollAndTap;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
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
      find.text('84.2 kg'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Weight'), findsWidgets);
    expect(find.text('84.2 kg'), findsOneWidget);
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
}
