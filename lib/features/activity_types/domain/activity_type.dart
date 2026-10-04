import '../../../core/units/unit_registry.dart';
import 'activity_ids.dart';
import 'field_config.dart';
import 'field_type.dart';

/// One configurable input of an Activity Type (§10, ADR-026).
class ActivityField {
  const ActivityField({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.required,
    required this.measurable,
    required this.config,
    this.dimension,
    this.parentId,
    this.isRemoved = false,
  });

  final ActivityFieldId id;

  /// The Repeating Group this field belongs to; null for top-level fields
  /// (ADR-027). Immutable once created.
  final ActivityFieldId? parentId;
  final String name;
  final FieldType type;

  /// Only for Number fields; locked once values exist (ADR-020/026).
  final Dimension? dimension;
  final int position;
  final bool required;
  final bool measurable;
  final FieldConfig config;

  /// Soft-deleted: kept so historical values still render (ADR-022).
  final bool isRemoved;
}

/// A reusable activity definition (§3.1). Not an event.
class ActivityType {
  const ActivityType({
    required this.id,
    required this.name,
    required this.iconId,
    required this.colorKey,
    required this.supportsTimer,
    required this.supportsPlanning,
    required this.sortOrder,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isDeleted = false,
  });

  final ActivityTypeId id;
  final String name;

  /// Icon registry key (ADR-024).
  final String iconId;

  /// Activity palette key (design_system.md §2.4).
  final String colorKey;
  final String? description;
  final bool supportsTimer;
  final bool supportsPlanning;
  final int sortOrder;

  /// All fields, including removed ones (for history) and Repeating Group
  /// sub-fields (`parentId != null`), ordered by position within their parent.
  final List<ActivityField> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// Top-level fields offered in new logs, in order.
  List<ActivityField> get activeFields =>
      fields.where((f) => !f.isRemoved && f.parentId == null).toList();

  /// Sub-fields of a Repeating Group in order (removed ones only when
  /// [includeRemoved]).
  List<ActivityField> subFieldsOf(
    ActivityFieldId groupId, {
    bool includeRemoved = false,
  }) => fields
      .where((f) => f.parentId == groupId && (includeRemoved || !f.isRemoved))
      .toList();

  ActivityField? fieldById(ActivityFieldId id) {
    for (final field in fields) {
      if (field.id == id) return field;
    }
    return null;
  }
}
