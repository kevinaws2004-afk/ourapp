import 'activity_ids.dart';
import 'activity_type.dart';
import 'activity_type_definition.dart';

/// Persistence for activity types and their fields (one aggregate).
///
/// Default reads exclude deleted types (ADR-022). Fields of a type are always
/// returned including removed ones, marked `isRemoved`, so history renders.
/// All methods throw only `AppException`s (ADR-025).
abstract interface class ActivityTypeRepository {
  /// Active types, ordered for display.
  Stream<List<ActivityType>> watchActiveTypes();

  /// Active types once, ordered for display.
  Future<List<ActivityType>> getActiveTypes();

  /// Every type including deleted ones, for rendering historical records.
  Stream<List<ActivityType>> watchAllTypes();

  /// A type by ID, including a deleted one (for historical logs).
  Stream<ActivityType?> watchType(ActivityTypeId id);

  Future<ActivityType?> getType(ActivityTypeId id);

  /// Fields of [id] that have at least one stored value (semantics locked).
  Future<Set<ActivityFieldId>> fieldsWithValues(ActivityTypeId id);

  /// Persists a new type. Every field in [definition] must already have an ID.
  Future<void> create(ActivityTypeId id, ActivityTypeDefinition definition);

  /// Replaces the type's definition. Fields missing from [definition] are
  /// soft-deleted; new fields must already have IDs.
  Future<void> update(ActivityTypeId id, ActivityTypeDefinition definition);

  Future<void> softDelete(ActivityTypeId id);

  Future<void> restore(ActivityTypeId id);
}
