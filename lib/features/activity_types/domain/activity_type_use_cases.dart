import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import 'activity_ids.dart';
import 'activity_type_definition.dart';
import 'activity_type_repository.dart';
import 'activity_type_validator.dart';
import 'field_config.dart';

// Use cases for activity types (ADR-023: verb + domain object; `call`).

/// Assigns UUIDv7 IDs to new fields and to select options that lack one.
ActivityTypeDefinition _withIds(
  ActivityTypeDefinition definition,
  IdGenerator ids,
) {
  return ActivityTypeDefinition(
    name: definition.name.trim(),
    iconId: definition.iconId,
    colorKey: definition.colorKey,
    description: _trimToNull(definition.description),
    supportsTimer: definition.supportsTimer,
    supportsPlanning: definition.supportsPlanning,
    fields: [
      for (final field in definition.fields)
        FieldDefinition(
          id: field.id ?? ActivityFieldId(ids.newId()),
          name: field.name.trim(),
          type: field.type,
          dimension: field.dimension,
          required: field.required,
          measurable: field.type.canBeMeasurable && field.measurable,
          config: field.config,
        ),
    ],
  );
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

/// A starter template is plain data (data_architecture.md §9). Installing it
/// creates an ordinary type with fresh IDs (including select option IDs).
class InstallActivityTemplate {
  const InstallActivityTemplate(this._create, this._ids);

  final CreateActivityType _create;
  final IdGenerator _ids;

  Future<ActivityTypeId> call(ActivityTypeDefinition template) => _create(
    ActivityTypeDefinition(
      name: template.name,
      iconId: template.iconId,
      colorKey: template.colorKey,
      description: template.description,
      supportsTimer: template.supportsTimer,
      supportsPlanning: template.supportsPlanning,
      fields: [
        for (final field in template.fields)
          switch (field.config) {
            SelectFieldConfig(:final options) => field.withConfig(
              SelectFieldConfig(
                options: [
                  for (final option in options)
                    SelectOption(
                      id: SelectOptionId(_ids.newId()),
                      label: option.label,
                    ),
                ],
              ),
            ),
            _ => field,
          },
      ],
    ),
  );
}
