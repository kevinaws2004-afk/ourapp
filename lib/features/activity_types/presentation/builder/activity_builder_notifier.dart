import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/keys/activity_color_key.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/activity_ids.dart';
import '../../domain/activity_type.dart';
import '../../domain/activity_type_definition.dart';
import '../../domain/activity_type_validator.dart';
import '../activity_type_providers.dart';

/// One field in the builder draft. [key] is stable for list identity even
/// before the field has an ID; [locked] means its type/dimension can't change.
class BuilderField {
  const BuilderField({
    required this.key,
    required this.definition,
    this.locked = false,
  });

  final String key;
  final FieldDefinition definition;
  final bool locked;

  BuilderField withDefinition(FieldDefinition definition) =>
      BuilderField(key: key, definition: definition, locked: locked);
}

class ActivityBuilderState {
  const ActivityBuilderState({
    required this.name,
    required this.iconId,
    required this.colorKey,
    required this.fields,
    this.typeId,
    this.description = '',
    this.supportsTimer = false,
    this.supportsPlanning = true,
    this.issues = const [],
    this.isSaving = false,
    this.isDirty = false,
    this.lockedFieldIds = const {},
  });

  final ActivityTypeId? typeId;
  final String name;
  final String iconId;
  final String colorKey;
  final String description;
  final bool supportsTimer;
  final bool supportsPlanning;
  final List<BuilderField> fields;
  final List<ValidationIssue> issues;
  final bool isSaving;
  final bool isDirty;

  /// Fields (at any depth) that already have entries: their type and unit
  /// dimension are locked (ADR-026).
  final Set<ActivityFieldId> lockedFieldIds;

  bool get isNew => typeId == null;

  ActivityTypeDefinition toDefinition() => ActivityTypeDefinition(
    name: name,
    iconId: iconId,
    colorKey: colorKey,
    description: description,
    supportsTimer: supportsTimer,
    supportsPlanning: supportsPlanning,
    fields: [for (final f in fields) f.definition],
  );

  /// Issues for a builder field and its sub-fields, matched by the
  /// validator's field keys.
  List<ValidationIssue> issuesForField(int index) {
    final keys = <String>{};
    void collect(FieldDefinition field, String path) {
      keys.add(ActivityTypeValidator.fieldKey(field, path));
      for (final (i, sub) in field.subFields.indexed) {
        collect(sub, '$path.$i');
      }
    }

    collect(fields[index].definition, '$index');
    return issues.where((i) => keys.contains(i.target)).toList();
  }

  ActivityBuilderState copyWith({
    String? name,
    String? iconId,
    String? colorKey,
    String? description,
    bool? supportsTimer,
    bool? supportsPlanning,
    List<BuilderField>? fields,
    List<ValidationIssue>? issues,
    bool? isSaving,
    bool? isDirty,
  }) => ActivityBuilderState(
    typeId: typeId,
    name: name ?? this.name,
    iconId: iconId ?? this.iconId,
    colorKey: colorKey ?? this.colorKey,
    description: description ?? this.description,
    supportsTimer: supportsTimer ?? this.supportsTimer,
    supportsPlanning: supportsPlanning ?? this.supportsPlanning,
    fields: fields ?? this.fields,
    issues: issues ?? this.issues,
    isSaving: isSaving ?? this.isSaving,
    isDirty: isDirty ?? this.isDirty,
    lockedFieldIds: lockedFieldIds,
  );
}

/// What the builder edits: an existing type, or a new one optionally named
/// up front (e.g. from a plan: "Food" → set up what to track, ADR-030).
class ActivityBuilderArgs {
  const ActivityBuilderArgs({this.typeId, this.initialName = ''});

  final ActivityTypeId? typeId;
  final String initialName;

  @override
  bool operator ==(Object other) =>
      other is ActivityBuilderArgs &&
      other.typeId == typeId &&
      other.initialName == initialName;

  @override
  int get hashCode => Object.hash(typeId, initialName);
}

/// Builder for a new type or an existing one.
final activityBuilderProvider = AsyncNotifierProvider.autoDispose
    .family<ActivityBuilderNotifier, ActivityBuilderState, ActivityBuilderArgs>(
      ActivityBuilderNotifier.new,
    );

class ActivityBuilderNotifier extends AsyncNotifier<ActivityBuilderState> {
  ActivityBuilderNotifier(this.args);

  final ActivityBuilderArgs args;

  ActivityTypeId? get typeId => args.typeId;
  int _nextKey = 0;

  ActivityBuilderState get _state => state.requireValue;

  String _key() => 'f${_nextKey++}';

  @override
  Future<ActivityBuilderState> build() async {
    final id = typeId;
    if (id == null) {
      return ActivityBuilderState(
        name: args.initialName.trim(),
        iconId: 'sparkle',
        colorKey: ActivityColorKey.teal.name,
        fields: const [],
      );
    }
    final repository = ref.read(activityTypeRepositoryProvider);
    final type = await repository.getType(id);
    if (type == null) {
      throw NotFoundException(debugContext: 'builder ${id.value}');
    }
    final locked = await repository.fieldsWithValues(id);
    return ActivityBuilderState(
      typeId: id,
      name: type.name,
      iconId: type.iconId,
      colorKey:
          (ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate)
              .name,
      description: type.description ?? '',
      supportsTimer: type.supportsTimer,
      supportsPlanning: type.supportsPlanning,
      lockedFieldIds: locked,
      fields: [
        for (final field in type.activeFields)
          BuilderField(
            key: _key(),
            definition: _definitionOf(type, field),
            locked: locked.contains(field.id),
          ),
      ],
    );
  }

  static FieldDefinition _definitionOf(
    ActivityType type,
    ActivityField field,
  ) => FieldDefinition(
    id: field.id,
    name: field.name,
    type: field.type,
    dimension: field.dimension,
    required: field.required,
    measurable: field.measurable,
    config: field.config,
    subFields: [
      for (final sub in type.subFieldsOf(field.id)) _definitionOf(type, sub),
    ],
  );

  void _update(ActivityBuilderState next) =>
      state = AsyncData(next.copyWith(isDirty: true, issues: const []));

  void setName(String value) => _update(_state.copyWith(name: value));

  void setDescription(String value) =>
      _update(_state.copyWith(description: value));

  void setIcon(String iconId) => _update(_state.copyWith(iconId: iconId));

  void setColor(String colorKey) =>
      _update(_state.copyWith(colorKey: colorKey));

  void setSupportsTimer(bool value) =>
      _update(_state.copyWith(supportsTimer: value));

  void setSupportsPlanning(bool value) =>
      _update(_state.copyWith(supportsPlanning: value));

  void addField(FieldDefinition definition) => _update(
    _state.copyWith(
      fields: [
        ..._state.fields,
        BuilderField(key: _key(), definition: definition),
      ],
    ),
  );

  void replaceField(String key, FieldDefinition definition) => _update(
    _state.copyWith(
      fields: [
        for (final f in _state.fields)
          f.key == key ? f.withDefinition(definition) : f,
      ],
    ),
  );

  void removeField(String key) => _update(
    _state.copyWith(fields: _state.fields.where((f) => f.key != key).toList()),
  );

  /// [newIndex] is already adjusted for the removed item (onReorderItem).
  void reorderField(int oldIndex, int newIndex) {
    final fields = [..._state.fields];
    fields.insert(newIndex, fields.removeAt(oldIndex));
    _update(_state.copyWith(fields: fields));
  }

  /// Returns the saved type's ID, or null with inline issues on validation
  /// failure. Other `AppException`s propagate.
  Future<ActivityTypeId?> save() async {
    final current = _state;
    state = AsyncData(current.copyWith(isSaving: true, issues: const []));
    try {
      final definition = current.toDefinition();
      final ActivityTypeId id;
      if (current.typeId case final existing?) {
        await ref.read(updateActivityTypeProvider)(existing, definition);
        id = existing;
      } else {
        id = await ref.read(createActivityTypeProvider)(definition);
      }
      state = AsyncData(current.copyWith(isSaving: false, isDirty: false));
      return id;
    } on ValidationException catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, issues: e.issues));
      return null;
    } catch (_) {
      state = AsyncData(current.copyWith(isSaving: false));
      rethrow;
    }
  }
}
