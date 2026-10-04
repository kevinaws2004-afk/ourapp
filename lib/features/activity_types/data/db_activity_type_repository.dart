import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/units/unit_registry.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import '../domain/activity_type_definition.dart';
import '../domain/activity_type_repository.dart';
import '../domain/field_type.dart';
import 'field_config_codec.dart';

/// drift implementation of [ActivityTypeRepository].
///
/// Types and their fields load in two queries (types, then all their fields
/// by `activity_type_id IN (…)`): no N+1. Internal integer IDs stay here.
class DbActivityTypeRepository implements ActivityTypeRepository {
  DbActivityTypeRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  int _now() => _clock.nowUtc().millisecondsSinceEpoch;

  /// Re-runs [load] after any write to the tables it reads (no polling query).
  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.activityTypes, _db.activityFields]),
    ),
    load,
  );

  @override
  Stream<List<ActivityType>> watchActiveTypes() => guardStorageStream(
    'watchActiveTypes',
    _watch(() async {
      final rows =
          await (_db.select(_db.activityTypes)
                ..where((t) => isActive(t.deletedAt))
                ..orderBy([
                  (t) => OrderingTerm.asc(t.sortOrder),
                  (t) => OrderingTerm.asc(t.name),
                ]))
              .get();
      return _withFields(rows);
    }),
  );

  @override
  Stream<List<ActivityType>> watchAllTypes() => guardStorageStream(
    'watchAllTypes',
    _watch(() async => _withFields(await _db.select(_db.activityTypes).get())),
  );

  @override
  Stream<ActivityType?> watchType(ActivityTypeId id) =>
      guardStorageStream('watchType', _watch(() => _load(id)));

  @override
  Future<ActivityType?> getType(ActivityTypeId id) =>
      guardStorage('getType', () => _load(id));

  Future<ActivityType?> _load(ActivityTypeId id) async {
    final row = await (_db.select(
      _db.activityTypes,
    )..where((t) => t.publicId.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return (await _withFields([row])).single;
  }

  Future<List<ActivityType>> _withFields(List<ActivityTypeRow> types) async {
    if (types.isEmpty) return const [];
    final fieldRows =
        await (_db.select(_db.activityFields)
              ..where(
                (f) => f.activityTypeId.isIn(types.map((t) => t.internalId)),
              )
              ..orderBy([(f) => OrderingTerm.asc(f.position)]))
            .get();
    final byType = <int, List<ActivityFieldRow>>{};
    for (final f in fieldRows) {
      byType.putIfAbsent(f.activityTypeId, () => []).add(f);
    }
    return [
      for (final t in types) _toDomain(t, byType[t.internalId] ?? const []),
    ];
  }

  ActivityType _toDomain(ActivityTypeRow row, List<ActivityFieldRow> fields) {
    // Active fields first (by position), then removed ones, for stable display.
    final active = fields.where((f) => f.deletedAt == null);
    final removed = fields.where((f) => f.deletedAt != null);
    final publicIds = {for (final f in fields) f.internalId: f.publicId};
    return ActivityType(
      id: ActivityTypeId(row.publicId),
      name: row.name,
      iconId: row.iconId,
      colorKey: row.colorKey,
      description: row.description,
      supportsTimer: row.supportsTimer == 1,
      supportsPlanning: row.supportsPlanning == 1,
      sortOrder: row.sortOrder,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      isDeleted: row.deletedAt != null,
      fields: [
        for (final f in [...active, ...removed])
          fieldToDomain(f, parentPublicId: publicIds[f.parentFieldId]),
      ],
    );
  }

  /// Shared with the log repository, which renders fields of historical logs.
  /// [parentPublicId] is the public ID of the row's `parent_field_id`.
  static ActivityField fieldToDomain(
    ActivityFieldRow f, {
    String? parentPublicId,
  }) {
    final type = FieldType.fromStorageKey(f.fieldType);
    return ActivityField(
      id: ActivityFieldId(f.publicId),
      parentId: parentPublicId == null ? null : ActivityFieldId(parentPublicId),
      name: f.name,
      type: type,
      dimension: Dimension.fromCode(f.dimension),
      position: f.position,
      required: f.required == 1,
      measurable: f.measurable == 1,
      config: FieldConfigCodec.decode(type, f.configJson),
      isRemoved: f.deletedAt != null,
    );
  }

  @override
  Future<Set<ActivityFieldId>> fieldsWithValues(ActivityTypeId id) =>
      guardStorage('fieldsWithValues', () async {
        final rows = await _db
            .customSelect(
              'SELECT f.public_id FROM activity_fields f '
              'JOIN activity_types t ON t.internal_id = f.activity_type_id '
              'WHERE t.public_id = ? AND (EXISTS '
              '(SELECT 1 FROM log_values v WHERE v.field_id = f.internal_id) '
              'OR EXISTS (SELECT 1 FROM log_group_items i '
              'WHERE i.field_id = f.internal_id))',
              variables: [Variable(id.value)],
              readsFrom: {_db.activityFields, _db.logValues, _db.logGroupItems},
            )
            .get();
        return {
          for (final r in rows) ActivityFieldId(r.read<String>('public_id')),
        };
      });

  @override
  Future<void> create(ActivityTypeId id, ActivityTypeDefinition definition) =>
      guardStorage('createActivityType', () {
        return _db.transaction(() async {
          final now = _now();
          final maxOrder = await _db
              .customSelect(
                'SELECT COALESCE(MAX(sort_order), -1) AS m FROM activity_types',
              )
              .getSingle();
          final typeId = await _db
              .into(_db.activityTypes)
              .insert(
                ActivityTypesCompanion.insert(
                  publicId: id.value,
                  name: definition.name,
                  iconId: definition.iconId,
                  colorKey: definition.colorKey,
                  description: Value(definition.description),
                  supportsTimer: Value(definition.supportsTimer ? 1 : 0),
                  supportsPlanning: Value(definition.supportsPlanning ? 1 : 0),
                  sortOrder: Value(maxOrder.read<int>('m') + 1),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          await _insertFields(typeId, definition.fields, null, now);
        });
      });

  @override
  Future<void> update(ActivityTypeId id, ActivityTypeDefinition definition) =>
      guardStorage('updateActivityType', () {
        return _db.transaction(() async {
          final now = _now();
          final type = await (_db.select(
            _db.activityTypes,
          )..where((t) => t.publicId.equals(id.value))).getSingleOrNull();
          if (type == null) {
            throw const NotFoundException(debugContext: 'updateActivityType');
          }
          await (_db.update(
            _db.activityTypes,
          )..where((t) => t.internalId.equals(type.internalId))).write(
            ActivityTypesCompanion(
              name: Value(definition.name),
              iconId: Value(definition.iconId),
              colorKey: Value(definition.colorKey),
              description: Value(definition.description),
              supportsTimer: Value(definition.supportsTimer ? 1 : 0),
              supportsPlanning: Value(definition.supportsPlanning ? 1 : 0),
              updatedAt: Value(now),
            ),
          );

          final existing = await (_db.select(
            _db.activityFields,
          )..where((f) => f.activityTypeId.equals(type.internalId))).get();
          final byPublicId = {for (final f in existing) f.publicId: f};
          final kept = <String>{};

          Future<void> upsert(List<FieldDefinition> fields, int? parent) async {
            for (final (position, field) in fields.indexed) {
              final publicId = field.id!.value;
              kept.add(publicId);
              final current = byPublicId[publicId];
              if (current == null) {
                final inserted = await _insertField(
                  type.internalId,
                  field,
                  position,
                  parent,
                  now,
                );
                await _insertFields(
                  type.internalId,
                  field.subFields,
                  inserted,
                  now,
                );
                continue;
              }
              await (_db.update(
                _db.activityFields,
              )..where((f) => f.internalId.equals(current.internalId))).write(
                ActivityFieldsCompanion(
                  name: Value(field.name),
                  fieldType: Value(field.type.storageKey),
                  dimension: Value(field.dimension?.code),
                  position: Value(position),
                  required: Value(field.required ? 1 : 0),
                  measurable: Value(field.measurable ? 1 : 0),
                  configJson: Value(FieldConfigCodec.encode(field.config)),
                  updatedAt: Value(now),
                  // Re-adding a removed field restores it.
                  deletedAt: const Value(null),
                ),
              );
              await upsert(field.subFields, current.internalId);
            }
          }

          await upsert(definition.fields, null);
          for (final field in existing) {
            if (!kept.contains(field.publicId) && field.deletedAt == null) {
              await (_db.update(
                _db.activityFields,
              )..where((f) => f.internalId.equals(field.internalId))).write(
                ActivityFieldsCompanion(
                  deletedAt: Value(now),
                  updatedAt: Value(now),
                ),
              );
            }
          }
        });
      });

  /// Inserts [fields] (and their sub-fields, parents first) under [parent].
  Future<void> _insertFields(
    int typeId,
    List<FieldDefinition> fields,
    int? parent,
    int now,
  ) async {
    for (final (position, field) in fields.indexed) {
      final id = await _insertField(typeId, field, position, parent, now);
      await _insertFields(typeId, field.subFields, id, now);
    }
  }

  Future<int> _insertField(
    int typeId,
    FieldDefinition field,
    int position,
    int? parent,
    int now,
  ) => _db
      .into(_db.activityFields)
      .insert(
        ActivityFieldsCompanion.insert(
          publicId: field.id!.value,
          activityTypeId: typeId,
          parentFieldId: Value(parent),
          name: field.name,
          fieldType: field.type.storageKey,
          dimension: Value(field.dimension?.code),
          position: position,
          required: Value(field.required ? 1 : 0),
          measurable: Value(field.measurable ? 1 : 0),
          configJson: Value(FieldConfigCodec.encode(field.config)),
          createdAt: now,
          updatedAt: now,
        ),
      );

  @override
  Future<void> softDelete(ActivityTypeId id) => _setDeleted(id, deleted: true);

  @override
  Future<void> restore(ActivityTypeId id) => _setDeleted(id, deleted: false);

  Future<void> _setDeleted(ActivityTypeId id, {required bool deleted}) =>
      guardStorage(
        deleted ? 'deleteActivityType' : 'restoreActivityType',
        () async {
          final now = _now();
          final count =
              await (_db.update(
                _db.activityTypes,
              )..where((t) => t.publicId.equals(id.value))).write(
                ActivityTypesCompanion(
                  deletedAt: Value(deleted ? now : null),
                  updatedAt: Value(now),
                ),
              );
          if (count == 0) {
            throw NotFoundException(debugContext: 'setDeleted ${id.value}');
          }
        },
      );
}
