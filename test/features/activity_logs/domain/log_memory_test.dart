import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/domain/log_memory.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

const _exercises = ActivityFieldId('exercises');
const _exercise = ActivityFieldId('exercise');
const _sets = ActivityFieldId('sets');
const _weight = ActivityFieldId('weight');

GroupItem _row(String id, Map<ActivityFieldId, FieldValue> values) =>
    GroupItem(id: GroupItemId(id), values: values);

ActivityLog _log(String id, Map<ActivityFieldId, FieldValue> values) =>
    ActivityLog(
      id: ActivityLogId(id),
      activityTypeId: const ActivityTypeId('gym'),
      startedAt: DateTime.utc(2026, 10, 1),
      tzOffsetMinutes: 0,
      localDate: LocalDate(2026, 10, 1),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      values: values,
    );

Map<ActivityFieldId, FieldValue> _workout(String exercise, double kg) => {
  _exercises: RepeatingGroupValue([
    _row('$exercise-row', {
      _exercise: TextValue(exercise),
      _sets: RepeatingGroupValue([
        _row('$exercise-set', {_weight: NumberValue(kg, unitCode: 'kg')}),
      ]),
    }),
  ]),
};

/// Logging from memory (B1, B2; ADR-041).
void main() {
  test('copied values keep everything but give every row a new identity', () {
    final copy = copyValues(_workout('Squat', 80), SequentialIdGenerator());
    final rows = (copy[_exercises]! as RepeatingGroupValue).items;
    final sets = (rows.single.values[_sets]! as RepeatingGroupValue).items;

    expect(rows.single.values[_exercise], const TextValue('Squat'));
    expect(sets.single.values[_weight], const NumberValue(80, unitCode: 'kg'));
    expect(rows.single.id, isNot(const GroupItemId('Squat-row')));
    expect(sets.single.id, isNot(const GroupItemId('Squat-set')));
    expect(rows.single.id, isNot(sets.single.id));
  });

  test('the last row with a name is found newest first, ignoring case', () {
    final logs = [
      _log('new', _workout('Squat', 85)),
      _log('old', _workout('Squat', 80)),
    ];
    final row = findLastRow(
      logs,
      groupFieldId: _exercises,
      nameFieldId: _exercise,
      name: ' squat ',
    );
    final sets = (row!.values[_sets]! as RepeatingGroupValue).items;
    expect(sets.single.values[_weight], const NumberValue(85, unitCode: 'kg'));
  });

  test('a name never logged, or an empty one, finds nothing', () {
    final logs = [_log('a', _workout('Squat', 80))];
    for (final name in ['Bench press', '  ']) {
      expect(
        findLastRow(
          logs,
          groupFieldId: _exercises,
          nameFieldId: _exercise,
          name: name,
        ),
        isNull,
      );
    }
  });
}
