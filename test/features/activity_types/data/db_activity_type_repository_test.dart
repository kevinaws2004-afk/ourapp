import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository repository;
  late SequentialIdGenerator ids;
  late CreateActivityType create;
  late UpdateActivityType update;

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 4, 8));
    repository = DbActivityTypeRepository(db, clock);
    ids = SequentialIdGenerator();
    create = CreateActivityType(repository, ids);
    update = UpdateActivityType(repository, ids);
  });

  tearDown(() => db.close());

  test(
    'creating a type persists it with ordered fields and public IDs',
    () async {
      final id = await create(readingDefinition());

      final type = (await repository.getType(id))!;
      expect(type.name, 'Reading');
      expect(type.supportsTimer, isTrue);
      expect(type.activeFields.map((f) => f.name), ['Book', 'Pages', 'Rating']);
      expect(type.activeFields.map((f) => f.position), [0, 1, 2]);
      expect(type.fields.every((f) => f.id.value.length == 36), isTrue);
      expect(type.createdAt, clock.nowUtc());
    },
  );

  test('new types are appended to the display order', () async {
    await create(readingDefinition());
    await create(walkingDefinition());

    final types = await repository.watchActiveTypes().first;
    expect(types.map((t) => t.name), ['Reading', 'Walking']);
    expect(types.map((t) => t.sortOrder), [0, 1]);
  });

  test('invalid definitions are rejected with a ValidationException', () async {
    const invalid = ActivityTypeDefinition(
      name: '',
      iconId: 'sparkle',
      colorKey: 'teal',
      fields: [],
    );
    expect(() => create(invalid), throwsA(isA<ValidationException>()));
  });

  group('activity names are unique (A8)', () {
    Matcher duplicateName() => throwsA(
      isA<ValidationException>().having(
        (e) => e.issues.single,
        'issue',
        const ValidationIssue(
          ValidationCode.duplicateActivityName,
          target: 'name',
        ),
      ),
    );

    test('creating a second activity with the same name is rejected, '
        'ignoring case and spaces', () async {
      await create(readingDefinition());
      final again = readingDefinition();
      expect(
        () => create(
          ActivityTypeDefinition(
            name: '  reading ',
            iconId: again.iconId,
            colorKey: again.colorKey,
            fields: const [],
          ),
        ),
        duplicateName(),
      );
    });

    test('renaming to another activity\'s name is rejected; keeping its own '
        'name is fine', () async {
      final reading = await create(readingDefinition());
      final walking = await create(walkingDefinition());
      final type = (await repository.getType(walking))!;

      expect(
        () => update(walking, _renamed(definitionOf(type), 'Reading')),
        duplicateName(),
      );
      await update(reading, definitionOf((await repository.getType(reading))!));
    });

    test('an archived activity\'s name can be used again', () async {
      final id = await create(readingDefinition());
      await DeleteActivityType(repository)(id);

      expect(await create(readingDefinition()), isNot(id));
    });
  });

  test('updating reorders, renames, adds and soft-deletes fields', () async {
    final id = await create(readingDefinition());
    final before = (await repository.getType(id))!;
    final book = before.activeFields[0];
    final rating = before.activeFields[2];

    clock.advance(const Duration(minutes: 1));
    await update(
      id,
      ActivityTypeDefinition(
        name: 'Reading',
        iconId: 'book-open',
        colorKey: 'sky',
        fields: [
          FieldDefinition(
            id: rating.id,
            name: 'Stars',
            type: FieldType.rating,
            config: rating.config,
          ),
          FieldDefinition(
            id: book.id,
            name: 'Book',
            type: FieldType.text,
            config: book.config,
          ),
          const FieldDefinition(
            name: 'Notes to self',
            type: FieldType.text,
            config: TextFieldConfig(),
          ),
        ],
      ),
    );

    final after = (await repository.getType(id))!;
    expect(after.activeFields.map((f) => f.name), [
      'Stars',
      'Book',
      'Notes to self',
    ]);
    expect(
      after.activeFields.first.id,
      rating.id,
      reason: 'renaming keeps the field identity',
    );
    expect(after.fields.where((f) => f.isRemoved).map((f) => f.name), [
      'Pages',
    ]);
    expect(after.updatedAt, clock.nowUtc());
  });

  test(
    'deleting hides the type from the active list; restoring brings it back',
    () async {
      final id = await create(readingDefinition());

      await DeleteActivityType(repository)(id);
      expect(await repository.watchActiveTypes().first, isEmpty);
      expect(
        (await repository.getType(id))!.isDeleted,
        isTrue,
        reason: 'still readable for history',
      );

      await RestoreActivityType(repository)(id);
      expect((await repository.watchActiveTypes().first).single.id, id);
    },
  );

  test('updating an unknown type is NotFound', () async {
    expect(
      () => update(
        const ActivityTypeId('00000000-0000-7000-8000-000000000999'),
        readingDefinition(),
      ),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('using a built-in activity assigns fresh option IDs', () async {
    final installer = AddBuiltInActivity(create, ids);
    final first = await installer(languageDefinition());
    // Names are unique among active activities: archive before reinstalling.
    await DeleteActivityType(repository)(first);
    final second = await installer(languageDefinition());
    final a =
        (await repository.getType(first))!.activeFields.first.config
            as SelectFieldConfig;
    final b =
        (await repository.getType(second))!.activeFields.first.config
            as SelectFieldConfig;
    expect(a.options.map((o) => o.label), ['Spanish', 'French']);
    expect(a.options.first.id, isNot(b.options.first.id));
    expect(
      a.options.first.id.value,
      isNot('opt-es'),
      reason: 'placeholder option IDs replaced',
    );
  });

  test('the active-types stream updates after writes', () async {
    final emitted = repository
        .watchActiveTypes()
        .map((types) => types.length)
        .take(2)
        .toList();
    await pumpEventQueue();
    await create(readingDefinition());

    expect(await emitted, [0, 1]);
  });
}

ActivityTypeDefinition _renamed(ActivityTypeDefinition d, String name) =>
    ActivityTypeDefinition(
      name: name,
      iconId: d.iconId,
      colorKey: d.colorKey,
      description: d.description,
      supportsTimer: d.supportsTimer,
      supportsPlanning: d.supportsPlanning,
      fields: d.fields,
    );
