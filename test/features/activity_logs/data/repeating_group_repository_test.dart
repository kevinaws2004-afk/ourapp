import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/domain/log_validator.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// Repeating Groups stored as rows (ADR-027): log_group_items + scoped
/// log_values, against a real in-memory database.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late SequentialIdGenerator ids;
  late LogActivity logActivity;
  late UpdateActivityLog updateLog;

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 4, 12));
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    ids = SequentialIdGenerator();
    logActivity = LogActivity(
      types,
      logs,
      DbPlanRepository(db, clock),
      ids,
      clock,
    );
    updateLog = UpdateActivityLog(types, logs, clock);
  });

  tearDown(() => db.close());

  Future<ActivityType> installGym() async {
    final id = await CreateActivityType(types, ids)(gymDefinition());
    return (await types.getType(id))!;
  }

  /// Gym field IDs by name.
  ({
    ActivityFieldId exercises,
    ActivityFieldId exercise,
    ActivityFieldId sets,
    ActivityFieldId weight,
    ActivityFieldId reps,
  })
  fieldsOf(ActivityType gym) {
    ActivityFieldId byName(String name) =>
        gym.fields.firstWhere((f) => f.name == name).id;
    return (
      exercises: byName('Exercises'),
      exercise: byName('Exercise'),
      sets: byName('Sets'),
      weight: byName('Weight'),
      reps: byName('Reps'),
    );
  }

  // UUID-shaped like real item IDs (public_id is CHECKed to 36 chars).
  var nextItem = 0;
  GroupItemId itemId() => GroupItemId(
    '00000000-0000-7000-9000-${(nextItem++).toString().padLeft(12, '0')}',
  );

  GroupItem set(
    ({
      ActivityFieldId exercises,
      ActivityFieldId exercise,
      ActivityFieldId sets,
      ActivityFieldId weight,
      ActivityFieldId reps,
    })
    f,
    double kg,
    int reps, {
    GroupItemId? id,
  }) => GroupItem(
    id: id ?? itemId(),
    values: {
      f.weight: NumberValue(kg, unitCode: 'kg'),
      f.reps: NumberValue(reps.toDouble()),
    },
  );

  test('a type stores sub-fields under their group, in order', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);

    expect(gym.activeFields.map((x) => x.name), ['Exercises']);
    expect(gym.subFieldsOf(f.exercises).map((x) => x.name), [
      'Exercise',
      'Sets',
    ]);
    expect(gym.subFieldsOf(f.sets).map((x) => x.name), ['Weight', 'Reps']);
    expect(gym.fieldById(f.reps)!.parentId, f.sets);
    final exerciseConfig = gym.fieldById(f.exercise)!.config as TextFieldConfig;
    expect(exerciseConfig.suggestFromHistory, isTrue);
    expect(
      (gym.fieldById(f.sets)!.config as RepeatingGroupFieldConfig).itemLabel,
      'Set',
    );
  });

  test('the §43 workout round-trips with nested items in order', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);
    final workout = RepeatingGroupValue([
      GroupItem(
        id: itemId(),
        values: {
          f.exercise: const TextValue('Chest Press'),
          f.sets: RepeatingGroupValue([
            set(f, 50, 12),
            set(f, 55, 10),
            set(f, 60, 8),
          ]),
        },
      ),
      GroupItem(
        id: itemId(),
        values: {
          f.exercise: const TextValue('Squat'),
          f.sets: RepeatingGroupValue([set(f, 80, 5)]),
        },
      ),
    ]);

    final id = await logActivity(
      gym.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 4, 7),
        values: {f.exercises: workout},
      ),
    );
    final stored = await logs.getLog(id);

    expect(stored!.values[f.exercises], workout);
    final rows = await db.customSelect('SELECT * FROM log_group_items').get();
    expect(rows, hasLength(6)); // 2 exercises + 4 sets
    final groupRows = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM log_values v JOIN activity_fields f '
          "ON f.internal_id = v.field_id WHERE f.field_type = 'repeating_group'",
        )
        .getSingle();
    expect(groupRows.read<int>('c'), 0, reason: 'groups have no value row');
  });

  test('empty items are dropped before saving', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);

    final id = await logActivity(
      gym.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 4, 7),
        values: {
          f.exercises: RepeatingGroupValue([
            GroupItem(id: itemId(), values: const {}),
          ]),
        },
      ),
    );

    expect((await logs.getLog(id))!.values, isEmpty);
  });

  test('a required sub-field is reported against its item', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);
    final exercise = itemId();

    await expectLater(
      logActivity(
        gym.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 10, 4, 7),
          values: {
            f.exercises: RepeatingGroupValue([
              GroupItem(
                id: exercise,
                values: {
                  f.sets: RepeatingGroupValue([set(f, 50, 12)]),
                },
              ),
            ]),
          },
        ),
      ),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.map((i) => i.target),
          'targets',
          [LogValidator.itemTarget(exercise, f.exercise)],
        ),
      ),
    );
  });

  test('editing keeps item identity, reorders, and removes items '
      'with their values', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);
    final exercise = itemId();
    final first = set(f, 50, 12);
    final second = set(f, 55, 10);
    final third = set(f, 60, 8);
    final id = await logActivity(
      gym.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 4, 7),
        values: {
          f.exercises: RepeatingGroupValue([
            GroupItem(
              id: exercise,
              values: {
                f.exercise: const TextValue('Chest Press'),
                f.sets: RepeatingGroupValue([first, second, third]),
              },
            ),
          ]),
        },
      ),
    );
    Future<Map<String, int>> internalIds() async => {
      for (final r
          in await db
              .customSelect(
                'SELECT public_id, internal_id FROM log_group_items',
              )
              .get())
        r.read<String>('public_id'): r.read<int>('internal_id'),
    };
    final before = await internalIds();

    // Drop the first set, swap the others, change one weight.
    final edited = RepeatingGroupValue([
      GroupItem(
        id: exercise,
        values: {
          f.exercise: const TextValue('Chest Press'),
          f.sets: RepeatingGroupValue([third, set(f, 57.5, 10, id: second.id)]),
        },
      ),
    ]);
    clock.advance(const Duration(minutes: 5));
    await updateLog(
      id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 4, 7),
        values: {f.exercises: edited},
      ),
    );

    expect((await logs.getLog(id))!.values[f.exercises], edited);
    final after = await internalIds();
    expect(after.keys.toSet(), {
      exercise.value,
      second.id.value,
      third.id.value,
    });
    for (final key in after.keys) {
      expect(after[key], before[key], reason: 'identity of $key kept');
    }
    final orphanValues = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM log_values WHERE group_item_id IS NOT NULL '
          'AND group_item_id NOT IN (SELECT internal_id FROM log_group_items)',
        )
        .getSingle();
    expect(orphanValues.read<int>('c'), 0);
  });

  test(
    'a group with items locks its semantics like a field with values',
    () async {
      final gym = await installGym();
      final f = fieldsOf(gym);
      await logActivity(
        gym.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 10, 4, 7),
          values: {
            f.exercises: RepeatingGroupValue([
              GroupItem(
                id: itemId(),
                values: {f.exercise: const TextValue('Row')},
              ),
            ]),
          },
        ),
      );

      expect(await types.fieldsWithValues(gym.id), {f.exercises, f.exercise});
    },
  );

  test('updating a type adds and removes sub-fields in place', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);
    final definition = ActivityTypeDefinition(
      name: gym.name,
      iconId: gym.iconId,
      colorKey: gym.colorKey,
      fields: [
        FieldDefinition(
          id: f.exercises,
          name: 'Exercises',
          type: FieldType.repeatingGroup,
          config: const RepeatingGroupFieldConfig(itemLabel: 'Exercise'),
          subFields: [
            FieldDefinition(
              id: f.exercise,
              name: 'Exercise',
              type: FieldType.text,
              required: true,
              config: const TextFieldConfig(suggestFromHistory: true),
            ),
            const FieldDefinition(
              name: 'Rest',
              type: FieldType.duration,
              config: DurationFieldConfig(),
            ),
          ],
        ),
      ],
    );

    await UpdateActivityType(types, ids)(gym.id, definition);
    final updated = (await types.getType(gym.id))!;

    expect(updated.subFieldsOf(f.exercises).map((x) => x.name), [
      'Exercise',
      'Rest',
    ]);
    expect(
      updated.fieldById(f.sets)!.isRemoved,
      isTrue,
      reason: 'removed groups are soft-deleted',
    );
    expect(updated.fieldById(f.reps)!.isRemoved, isTrue);
  });

  test('text suggestions are distinct, newest first, and skip deleted '
      'logs', () async {
    final gym = await installGym();
    final f = fieldsOf(gym);
    Future<ActivityLogId> record(List<String> names) => logActivity(
      gym.id,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: {
          f.exercises: RepeatingGroupValue([
            for (final name in names)
              GroupItem(id: itemId(), values: {f.exercise: TextValue(name)}),
          ]),
        },
      ),
    );

    await record(['Squat', 'Chest Press']);
    clock.advance(const Duration(days: 1));
    await record(['squat']);
    clock.advance(const Duration(days: 1));
    final deleted = await record(['Deadlift']);
    await DeleteActivityLog(logs)(deleted);

    final suggestions = await logs.textSuggestions(f.exercise);
    expect(suggestions, hasLength(2));
    expect(suggestions.first.toLowerCase(), 'squat');
    expect(suggestions.last, 'Chest Press');
  });
}
