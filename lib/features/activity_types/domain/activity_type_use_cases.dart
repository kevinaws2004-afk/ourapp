import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import 'activity_ids.dart';
import 'activity_type.dart';
import 'activity_type_definition.dart';
import 'activity_type_repository.dart';
import 'activity_type_validator.dart';
import 'field_config.dart';

// Use cases for activity types (ADR-023: verb + domain object; `call`).

/// Assigns UUIDv7 IDs to new fields (recursively, for Repeating Group
/// sub-fields) and normalizes names.
ActivityTypeDefinition _withIds(
  ActivityTypeDefinition definition,
  IdGenerator ids,
) {
  FieldDefinition assign(FieldDefinition field) => FieldDefinition(
    id: field.id ?? ActivityFieldId(ids.newId()),
    name: field.name.trim(),
    type: field.type,
    dimension: field.dimension,
    required: field.required,
    measurable: field.type.canBeMeasurable && field.measurable,
    config: field.config,
    subFields: [for (final sub in field.subFields) assign(sub)],
  );

  return ActivityTypeDefinition(
    name: definition.name.trim(),
    iconId: definition.iconId,
    colorKey: definition.colorKey,
    description: _trimToNull(definition.description),
    supportsTimer: definition.supportsTimer,
    supportsPlanning: definition.supportsPlanning,
    fields: [for (final field in definition.fields) assign(field)],
  );
}

/// The editable definition of an existing [type]: its active fields (with
/// their IDs, so saving keeps them) and their sub-fields, in order.
ActivityTypeDefinition definitionOf(ActivityType type) {
  FieldDefinition field(ActivityField f) => FieldDefinition(
    id: f.id,
    name: f.name,
    type: f.type,
    dimension: f.dimension,
    required: f.required,
    measurable: f.measurable,
    config: f.config,
    subFields: [for (final sub in type.subFieldsOf(f.id)) field(sub)],
  );
  return ActivityTypeDefinition(
    name: type.name,
    iconId: type.iconId,
    colorKey: type.colorKey,
    description: type.description,
    supportsTimer: type.supportsTimer,
    supportsPlanning: type.supportsPlanning,
    fields: [for (final f in type.activeFields) field(f)],
  );
}

/// Whether [a] and [b] name the same activity: trimmed, case-insensitive.
bool sameActivityName(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();

/// Rejects a name another active activity already uses, so typing "Gym"
/// always means one activity. Archived activities don't count.
Future<void> _ensureNameFree(
  ActivityTypeRepository repository,
  String name, {
  ActivityTypeId? except,
  required String debugContext,
}) async {
  final taken = (await repository.getActiveTypes()).any(
    (t) => t.id != except && sameActivityName(t.name, name),
  );
  if (taken) {
    throw ValidationException(const [
      ValidationIssue(ValidationCode.duplicateActivityName, target: 'name'),
    ], debugContext: debugContext);
  }
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

class CreateActivityType {
  const CreateActivityType(this._repository, this._ids);

  final ActivityTypeRepository _repository;
  final IdGenerator _ids;

  Future<ActivityTypeId> call(ActivityTypeDefinition definition) async {
    ActivityTypeValidator.validate(definition)
        .throwIfInvalid(debugContext: 'CreateActivityType');
    await _ensureNameFree(
      _repository,
      definition.name,
      debugContext: 'CreateActivityType',
    );
    final id = ActivityTypeId(_ids.newId());
    await _repository.create(id, _withIds(definition, _ids));
    return id;
  }
}

class UpdateActivityType {
  const UpdateActivityType(this._repository, this._ids);

  final ActivityTypeRepository _repository;
  final IdGenerator _ids;

  Future<void> call(
    ActivityTypeId id,
    ActivityTypeDefinition definition,
  ) async {
    final existing = await _repository.getType(id);
    if (existing == null) {
      throw NotFoundException(debugContext: 'UpdateActivityType ${id.value}');
    }
    ActivityTypeValidator.validate(
      definition,
      existing: existing,
      fieldsWithValues: await _repository.fieldsWithValues(id),
    ).throwIfInvalid(debugContext: 'UpdateActivityType');
    await _ensureNameFree(
      _repository,
      definition.name,
      except: id,
      debugContext: 'UpdateActivityType',
    );
    await _repository.update(id, _withIds(definition, _ids));
  }
}

/// Soft-deletes (archives) a type; its logs stay in history (ADR-022).
class DeleteActivityType {
  const DeleteActivityType(this._repository);

  final ActivityTypeRepository _repository;

  Future<void> call(ActivityTypeId id) => _repository.softDelete(id);
}

/// Undo for [DeleteActivityType].
class RestoreActivityType {
  const RestoreActivityType(this._repository);

  final ActivityTypeRepository _repository;

  Future<void> call(ActivityTypeId id) => _repository.restore(id);
}

/// A built-in activity is plain data (data_architecture.md §9). Installing it
/// creates an ordinary type with fresh IDs (including select option IDs).
class AddBuiltInActivity {
  const AddBuiltInActivity(this._create, this._ids);

  final CreateActivityType _create;
  final IdGenerator _ids;

  Future<ActivityTypeId> call(ActivityTypeDefinition builtIn) => _create(
    ActivityTypeDefinition(
      name: builtIn.name,
      iconId: builtIn.iconId,
      colorKey: builtIn.colorKey,
      description: builtIn.description,
      supportsTimer: builtIn.supportsTimer,
      supportsPlanning: builtIn.supportsPlanning,
      fields: [for (final field in builtIn.fields) _freshOptionIds(field)],
    ),
  );

  FieldDefinition _freshOptionIds(FieldDefinition field) => field.copyWith(
    config: switch (field.config) {
      SelectFieldConfig(:final options) => SelectFieldConfig(
        options: [
          for (final option in options)
            SelectOption(id: SelectOptionId(_ids.newId()), label: option.label),
        ],
      ),
      final other => other,
    },
    subFields: [for (final sub in field.subFields) _freshOptionIds(sub)],
  );
}
