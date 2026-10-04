import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/presentation/value_formatting.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// Row summaries show what was logged, numbers included (A18).
void main() {
  testWidgets('a nested list summarizes as names with their rows, repeats '
      'folded', (tester) async {
    final type = (await tester.runAsync(() async {
      final db = newTestDatabase();
      final clock = FakeClock(DateTime.utc(2026, 10, 5, 8));
      final types = DbActivityTypeRepository(db, clock);
      final id = await CreateActivityType(types, SequentialIdGenerator())(
        gymDefinition(),
      );
      final type = await types.getType(id);
      await db.close();
      return type;
    }))!;
    final [exercises] = _children(type, null);
    final [exercise, sets] = _children(type, exercises);
    final [weight, reps] = _children(type, sets);
    var n = 0;
    GroupItem item(Map<ActivityFieldId, FieldValue> values) =>
        GroupItem(id: GroupItemId('item-${n++}'), values: values);
    GroupItem set(double kg, double r) =>
        item({weight: NumberValue(kg, unitCode: 'kg'), reps: NumberValue(r)});
    final log = ActivityLog(
      id: const ActivityLogId('log'),
      activityTypeId: type.id,
      startedAt: DateTime.utc(2026, 10, 5, 8),
      tzOffsetMinutes: 0,
      localDate: LocalDate(2026, 10, 5),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      values: {
        exercises: RepeatingGroupValue([
          item({
            exercise: const TextValue('Bench press'),
            sets: RepeatingGroupValue([set(60, 8), set(60, 8), set(65, 6)]),
          }),
          item({
            exercise: const TextValue('Squat'),
            sets: RepeatingGroupValue([set(80, 5)]),
          }),
        ]),
      },
    );

    late String summary;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            summary = summarizeLog(context, type, log);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(summary, 'Bench press 60 kg × 8 (×2), 65 kg × 6; Squat 80 kg × 5');
  });
}

List<ActivityFieldId> _children(ActivityType type, ActivityFieldId? parent) => [
  for (final f in type.fields)
    if (f.parentId == parent) f,
].map((f) => f.id).toList();
