import '../../../core/units/unit_registry.dart';
import 'activity_ids.dart';
import 'field_config.dart';
import 'field_type.dart';

/// What the user defines in the builder (or a template provides). Input to
/// `CreateActivityType` / `UpdateActivityType`. Field order is list order.
class ActivityTypeDefinition {
  const ActivityTypeDefinition({
    required this.name,
    required this.iconId,
    required this.colorKey,
    required this.fields,
    this.description,
    this.supportsTimer = false,
    this.supportsPlanning = true,
  });

  static const maxNameLength = 60;

  final String name;
  final String iconId;
  final String colorKey;
  final String? description;
  final bool supportsTimer;
  final bool supportsPlanning;
  final List<FieldDefinition> fields;
}

/// One field in a definition. [id] is null for a field that doesn't exist
/// yet; use cases assign UUIDv7 IDs before persisting.
class FieldDefinition {
  const FieldDefinition({
    required this.name,
    required this.type,
    required this.config,
    this.id,
    this.dimension,
    this.required = false,
    this.measurable = false,
  });

  static const maxNameLength = 40;

  final ActivityFieldId? id;
  final String name;
  final FieldType type;
  final Dimension? dimension;
  final bool required;
  final bool measurable;
  final FieldConfig config;

  FieldDefinition withId(ActivityFieldId id) => FieldDefinition(
    id: id,
    name: name,
    type: type,
    dimension: dimension,
    required: required,
    measurable: measurable,
    config: config,
  );

  FieldDefinition withConfig(FieldConfig config) => FieldDefinition(
    id: id,
    name: name,
    type: type,
    dimension: dimension,
    required: required,
    measurable: measurable,
    config: config,
  );
}
