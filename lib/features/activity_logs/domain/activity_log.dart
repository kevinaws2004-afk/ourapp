import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'field_value.dart';

extension type const ActivityLogId(String value) {}

/// What actually happened (§3.3). Reality, as opposed to a Plan.
class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.activityTypeId,
    required this.startedAt,
    required this.tzOffsetMinutes,
    required this.localDate,
    required this.values,
    required this.createdAt,
    required this.updatedAt,
    this.endedAt,
    this.durationMs,
    this.notes,
  });

  final ActivityLogId id;
  final ActivityTypeId activityTypeId;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Actual elapsed duration (ADR-021).
  final int? durationMs;
  final int tzOffsetMinutes;

  /// Local calendar day of [startedAt] at recording time (ADR-013).
  final LocalDate localDate;
  final String? notes;
  final Map<ActivityFieldId, FieldValue> values;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// User input for logging or editing an activity. Values with no entry are
/// simply absent.
class ActivityLogDraft {
  const ActivityLogDraft({
    required this.startedAt,
    required this.values,
    this.durationMs,
    this.notes,
  });

  static const maxNotesLength = 10000;

  final DateTime startedAt;
  final int? durationMs;
  final String? notes;
  final Map<ActivityFieldId, FieldValue> values;
}
