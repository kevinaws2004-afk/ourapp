import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import '../domain/activity_type_definition.dart';

/// An unsaved activity built from definitions, for showing the real form
/// (the builder's live preview, a built-in activity's preview, B8). Each field gets
/// a stable preview ID from its key.
ActivityType previewType({
  required String name,
  required String iconId,
  required String colorKey,
  required bool supportsTimer,
  required bool supportsPlanning,
  required List<(FieldDefinition, String key)> fields,
}) {
  final all = <ActivityField>[];
  void add(
    FieldDefinition definition,
    String key,
    int position,
    ActivityFieldId? parentId,
  ) {
    final id = definition.id ?? ActivityFieldId('preview:$key');
    all.add(
      ActivityField(
        id: id,
        parentId: parentId,
        name: definition.name.isEmpty ? '—' : definition.name,
        type: definition.type,
        dimension: definition.dimension,
        position: position,
        required: definition.required,
        measurable: definition.measurable,
        config: definition.config,
      ),
    );
    for (final (index, sub) in definition.subFields.indexed) {
      add(sub, '$key.$index', index, id);
    }
  }

  for (final (index, (definition, key)) in fields.indexed) {
    add(definition, key, index, null);
  }
  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return ActivityType(
    id: const ActivityTypeId('preview'),
    name: name,
    iconId: iconId,
    colorKey: colorKey,
    supportsTimer: supportsTimer,
    supportsPlanning: supportsPlanning,
    sortOrder: 0,
    fields: all,
    createdAt: epoch,
    updatedAt: epoch,
  );
}

/// [definition] as a preview activity.
ActivityType previewOf(ActivityTypeDefinition definition) => previewType(
  name: definition.name,
  iconId: definition.iconId,
  colorKey: definition.colorKey,
  supportsTimer: definition.supportsTimer,
  supportsPlanning: definition.supportsPlanning,
  fields: [for (final (i, f) in definition.fields.indexed) (f, '$i')],
);
