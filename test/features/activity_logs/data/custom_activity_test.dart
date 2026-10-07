import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/units/unit_registry.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// The product rule (ADR-042): built-in activities are only starting points;
/// any activity a user makes up is data, with the fields they choose. These
/// are the owner's examples, built only from generic field types, with no
/// built-in activity and no activity-specific code.
void main() {
  late AppDatabase db;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late SequentialIdGenerator ids;
  late LogActivity logActivity;

  setUp(() {
    db = newTestDatabase();
    final clock = FakeClock(DateTime.utc(2026, 10, 7, 9));
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
  });

  tearDown(() => db.close());

  FieldDefinition text(String name, {bool multiline = false}) =>
      FieldDefinition(
        name: name,
        type: FieldType.text,
        config: TextFieldConfig(multiline: multiline),
      );
  FieldDefinition number(
    String name, {
    Dimension? dimension,
    String? unit,
    int decimals = 0,
  }) => FieldDefinition(
    name: name,
    type: FieldType.number,
    dimension: dimension,
    config: NumberFieldConfig(decimals: decimals, defaultUnitCode: unit),
    measurable: true,
  );
  FieldDefinition duration(String name) => FieldDefinition(
    name: name,
    type: FieldType.duration,
    config: const DurationFieldConfig(),
    measurable: true,
  );
  FieldDefinition rating(String name) => FieldDefinition(
    name: name,
    type: FieldType.rating,
    config: const RatingFieldConfig(max: 10),
    measurable: true,
  );

  Future<ActivityType> create(ActivityTypeDefinition definition) async {
    final id = await CreateActivityType(types, ids)(definition);
    return (await types.getType(id))!;
  }

  /// Logs [byName] into [type] and returns what was stored.
  Future<ActivityLog> logInto(
    ActivityType type,
    Map<String, FieldValue> byName,
  ) async {
    final fields = {for (final f in type.activeFields) f.name: f.id};
    final id = await logActivity(
      type.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 7, 8),
        values: {
          for (final MapEntry(:key, :value) in byName.entries)
            fields[key]!: value,
        },
      ),
    );
    return (await logs.getLog(id))!;
  }

  test('"Build my company": hours, task, progress, notes, money spent, and '
      'a list of tasks done', () async {
    final type = await create(
      ActivityTypeDefinition(
        name: 'Build my company',
        iconId: 'briefcase',
        colorKey: 'teal',
        supportsTimer: true,
        fields: [
          duration('Hours'),
          text('Task'),
          rating('Progress'),
          text('Notes', multiline: true),
          number('Money spent', decimals: 2),
          const FieldDefinition(
            name: 'Tasks done',
            type: FieldType.repeatingGroup,
            config: RepeatingGroupFieldConfig(itemLabel: 'Task'),
            subFields: [
              FieldDefinition(
                name: 'What',
                type: FieldType.text,
                required: true,
                config: TextFieldConfig(),
              ),
              FieldDefinition(
                name: 'Shipped',
                type: FieldType.boolean,
                config: BooleanFieldConfig(),
              ),
            ],
          ),
        ],
      ),
    );
    final group = type.activeFields.last;
    final [what, shipped] = type.subFieldsOf(group.id);
    final tasks = RepeatingGroupValue([
      GroupItem(
        id: const GroupItemId('00000000-0000-7000-9000-000000000001'),
        values: {
          what.id: const TextValue('Landing page'),
          shipped.id: const BooleanValue(true),
        },
      ),
    ]);

    final values = {
      'Hours': const DurationValue(3 * 3600000),
      'Task': const TextValue('Pitch deck'),
      'Progress': const RatingValue(7),
      'Notes': const TextValue('Investor call on Friday'),
      'Money spent': const NumberValue(49.99),
      'Tasks done': tasks,
    };
    final log = await logInto(type, values);

    final fields = {for (final f in type.activeFields) f.name: f.id};
    expect(log.values, {
      for (final MapEntry(:key, :value) in values.entries) fields[key]!: value,
    });
  });

  test('"Car maintenance": kilometres, fuel, cost, issue, notes', () async {
    final type = await create(
      ActivityTypeDefinition(
        name: 'Car maintenance',
        iconId: 'car',
        colorKey: 'slate',
        fields: [
          number('Kilometres', dimension: Dimension.distance, unit: 'km'),
          number('Fuel', dimension: Dimension.volume, unit: 'l', decimals: 2),
          number('Cost', decimals: 2),
          text('Issue'),
          text('Notes', multiline: true),
        ],
      ),
    );

    final log = await logInto(type, {
      'Kilometres': const NumberValue(48210, unitCode: 'km'),
      'Fuel': const NumberValue(32.5, unitCode: 'l'),
      'Cost': const NumberValue(61.2),
      'Issue': const TextValue('Brake squeak'),
      'Notes': const TextValue('Pads at 30%'),
    });

    expect(log.values, hasLength(5));
    final km = type.activeFields.first.id;
    expect(log.values[km], const NumberValue(48210, unitCode: 'km'));
  });

  test('"Study": subject, duration, pages, score, notes; the activity is '
      'kept and reused for the next log', () async {
    final type = await create(
      ActivityTypeDefinition(
        name: 'Study',
        iconId: 'graduation-cap',
        colorKey: 'lilac',
        supportsTimer: true,
        fields: [
          text('Subject'),
          duration('Duration'),
          number('Pages'),
          number('Score', decimals: 1),
          text('Notes', multiline: true),
        ],
      ),
    );

    await logInto(type, {
      'Subject': const TextValue('Physics'),
      'Duration': const DurationValue(5400000),
      'Pages': const NumberValue(12),
      'Score': const NumberValue(8.5),
    });
    await logInto(type, {'Subject': const TextValue('Maths')});

    // Saved like any activity: it's offered again, and both logs are its.
    final active = await types.getActiveTypes();
    expect(active.map((t) => t.name), contains('Study'));
    final typeLogs = await logs.watchLogsForType(type.id).first;
    expect(typeLogs, hasLength(2));
  });
}
