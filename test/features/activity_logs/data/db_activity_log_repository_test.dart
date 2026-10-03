import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/domain/watch_records_for_day.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

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
    clock = FakeClock(
      DateTime.utc(2026, 10, 4, 22),
      offset: const Duration(hours: 5, minutes: 30),
    );
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    ids = SequentialIdGenerator();
    logActivity = LogActivity(types, logs, ids, clock);
    updateLog = UpdateActivityLog(types, logs, clock);
  });

  tearDown(() => db.close());

  Future<ActivityType> install(ActivityTypeDefinition definition) async {
    final id = await CreateActivityType(types, ids)(definition);
    return (await types.getType(id))!;
  }

  test('logging stores every Phase 2 value type and reads it back', () async {
    final type = await install(languageDefinition());
    final f = {for (final field in type.activeFields) field.name: field};
    final language = f['Language']!.config as SelectFieldConfig;
    final topics = f['Topics']!.config as SelectFieldConfig;
    final values = <ActivityFieldId, FieldValue>{
      f['Language']!.id: SingleSelectValue(language.options.first.id),
      f['Topics']!.id: MultiSelectValue([
        topics.options[1].id,
        topics.options[0].id,
      ]),
      f['Words learned']!.id: const NumberValue(25),
      f['Lesson']!.id: const TextValue('Past tense'),
      f['Difficulty']!.id: const RatingValue(3),
      f['Homework done']!.id: const BooleanValue(false),
      f['Class date']!.id: DateValue(LocalDate(2026, 10, 2)),
      f['Class time']!.id: TimeValue(LocalTime.hm(18, 30)),
      f['Speaking time']!.id: const DurationValue(600000),
    };

    final id = await logActivity(
      type.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 4, 13),
        durationMs: 2700000,
        notes: ' Good ',
        values: values,
      ),
    );

    final log = (await logs.getLog(id))!;
    expect(log.values, values);
    expect(log.durationMs, 2700000);
    expect(log.notes, 'Good');
  });

  test(
    'the local date comes from the start instant and device offset (ADR-013)',
    () async {
      final type = await install(walkingDefinition());

      // 20:00 UTC on Oct 3 is 01:30 on Oct 4 in UTC+05:30.
      final id = await logActivity(
        type.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 10, 3, 20),
          values: const {},
        ),
      );

      final log = (await logs.getLog(id))!;
      expect(log.localDate, LocalDate(2026, 10, 4));
      expect(log.tzOffsetMinutes, 330);
    },
  );

  test('numbers with units are normalized at write time (ADR-020)', () async {
    final type = await install(walkingDefinition());
    final distance = type.activeFields.single;

    await logActivity(
      type.id,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: {distance.id: const NumberValue(2.5, unitCode: 'mi')},
      ),
    );

    final row = await db.select(db.logValues).getSingle();
    expect(row.numberValue, 2.5);
    expect(row.unitCode, 'mi');
    expect(row.normalizedValue, closeTo(4023.36, 1e-9));
  });

  test('invalid drafts are rejected before anything is written', () async {
    final type = await install(readingDefinition());

    await expectLater(
      logActivity(
        type.id,
        ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}),
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(await db.select(db.activityLogs).get(), isEmpty);
  });

  test('editing diffs values: changed rows keep identity, cleared rows are removed', () async {
    final type = await install(readingDefinition());
    final [book, pages, rating] = type.activeFields;
    final id = await logActivity(
      type.id,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: {
          book.id: const TextValue('Antifragile'),
          pages.id: const NumberValue(10),
          rating.id: const RatingValue(4),
        },
      ),
    );
    final bookRowBefore = await (db.select(
      db.logValues,
    )..where((v) => v.textValue.equals('Antifragile'))).getSingle();

    clock.advance(const Duration(hours: 1));
    await updateLog(
      id,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: {
          book.id: const TextValue('Skin in the Game'),
          pages.id: const NumberValue(12),
        },
      ),
    );

    final log = (await logs.getLog(id))!;
    expect(log.values, {
      book.id: const TextValue('Skin in the Game'),
      pages.id: const NumberValue(12),
    });
    final bookRowAfter = await (db.select(
      db.logValues,
    )..where((v) => v.textValue.equals('Skin in the Game'))).getSingle();
    expect(bookRowAfter.internalId, bookRowBefore.internalId);
    expect(bookRowAfter.createdAt, bookRowBefore.createdAt);
    expect(await db.select(db.logValues).get(), hasLength(2));
  });

  test(
    'deleted logs disappear from history and come back on restore',
    () async {
      final type = await install(walkingDefinition());
      final id = await logActivity(
        type.id,
        ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}),
      );

      await DeleteActivityLog(logs)(id);
      expect(await logs.watchLogsForType(type.id).first, isEmpty);
      expect(await logs.getLog(id), isNull);

      await RestoreActivityLog(logs)(id);
      expect((await logs.watchLogsForType(type.id).first).single.id, id);
    },
  );

  test('history is newest first, with values loaded for every log', () async {
    final type = await install(readingDefinition());
    final book = type.activeFields.first;
    for (final (day, title) in [(1, 'A'), (3, 'C'), (2, 'B')]) {
      await logActivity(
        type.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 10, day, 12),
          values: {book.id: TextValue(title)},
        ),
      );
    }

    final history = await logs.watchLogsForType(type.id).first;
    expect(history.map((l) => (l.values[book.id]! as TextValue).text), [
      'C',
      'B',
      'A',
    ]);
  });

  test(
    'logs keep values of fields removed later (historical integrity)',
    () async {
      final type = await install(readingDefinition());
      final [book, pages, _] = type.activeFields;
      final id = await logActivity(
        type.id,
        ActivityLogDraft(
          startedAt: clock.nowUtc(),
          values: {
            book.id: const TextValue('B'),
            pages.id: const NumberValue(7),
          },
        ),
      );

      await UpdateActivityType(types, ids)(
        type.id,
        ActivityTypeDefinition(
          name: type.name,
          iconId: type.iconId,
          colorKey: type.colorKey,
          fields: [
            FieldDefinition(
              id: book.id,
              name: book.name,
              type: book.type,
              config: book.config,
              required: true,
            ),
          ],
        ),
      );

      final log = (await logs.getLog(id))!;
      expect(log.values[pages.id], const NumberValue(7));
      final reloaded = (await types.getType(type.id))!;
      expect(reloaded.fieldById(pages.id)!.isRemoved, isTrue);
    },
  );

  test('changing the type of a field with values is rejected by domain and database', () async {
    final type = await install(readingDefinition());
    final [book, pages, rating] = type.activeFields;
    await logActivity(
      type.id,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: {book.id: const TextValue('B'), pages.id: const NumberValue(7)},
      ),
    );

    final changePages = ActivityTypeDefinition(
      name: type.name,
      iconId: type.iconId,
      colorKey: type.colorKey,
      fields: [
        FieldDefinition(
          id: book.id,
          name: book.name,
          type: book.type,
          config: book.config,
          required: true,
        ),
        FieldDefinition(
          id: pages.id,
          name: pages.name,
          type: rating.type,
          config: rating.config,
        ),
      ],
    );
    await expectLater(
      UpdateActivityType(types, ids)(type.id, changePages),
      throwsA(isA<ValidationException>()),
    );
    // Bypassing the domain still fails, at the database (trigger → ValidationException).
    await expectLater(
      types.update(type.id, changePages),
      throwsA(isA<ValidationException>()),
    );
  });

  test('the history stream re-emits after a log is added', () async {
    final type = await install(walkingDefinition());
    final emitted = logs
        .watchLogsForType(type.id)
        .map((l) => l.length)
        .take(2)
        .toList();
    await pumpEventQueue();

    await logActivity(
      type.id,
      ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}),
    );

    expect(await emitted.timeout(const Duration(seconds: 2)), [0, 1]);
  });

  test('logs for a day: only that local day, active, in time order', () async {
    final type = await install(walkingDefinition());
    // Offset is UTC+05:30 in this suite.
    Future<ActivityLogId> at(DateTime utc) => logActivity(
      type.id,
      ActivityLogDraft(startedAt: utc, values: const {}),
    );
    final late = await at(DateTime.utc(2026, 10, 4, 12)); // Oct 4, 17:30 local
    final early = await at(DateTime.utc(2026, 10, 4, 2)); // Oct 4, 07:30 local
    await at(DateTime.utc(2026, 10, 4, 20)); // Oct 5, 01:30 local
    final deleted = await at(DateTime.utc(2026, 10, 4, 5));
    await DeleteActivityLog(logs)(deleted);

    final day = await logs.watchLogsForDay(LocalDate(2026, 10, 4)).first;

    expect(day.map((l) => l.id), [early, late]);
  });

  test(
    'records for a day pair each log with its type, including archived types',
    () async {
      final type = await install(walkingDefinition());
      await logActivity(
        type.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 10, 4, 6),
          values: const {},
        ),
      );
      await DeleteActivityType(types)(type.id);

      final records = await WatchRecordsForDay(logs, types)(
        LocalDate(2026, 10, 4),
      ).first;

      expect(records.single.type.name, 'Walking');
      expect(records.single.type.isDeleted, isTrue);
    },
  );
}
