import '../../../core/errors/app_exception.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_types/domain/activity_type.dart';
import 'plan.dart';

/// Pure validation of a plan draft (data_architecture.md §7). Issue targets:
/// `title`, `notes`, `activity`, `start`, `end`, `duration`.
abstract final class PlanValidator {
  /// [type] is the draft's activity type as loaded (null for a task, or when
  /// it doesn't exist). [activityLocked] means the plan already has records,
  /// so its activity can't change.
  static ValidationResult validate(
    PlanDraft draft, {
    ActivityType? type,
    bool activityLocked = false,
    Plan? existing,
  }) {
    final issues = <ValidationIssue>[];
    void add(ValidationCode code, String target) =>
        issues.add(ValidationIssue(code, target: target));

    final title = draft.title.trim();
    if (title.isEmpty && draft.activityTypeId == null) {
      add(ValidationCode.nameRequired, 'title');
    }
    if (title.length > Plan.maxTitleLength) {
      add(ValidationCode.nameTooLong, 'title');
    }
    if ((draft.notes?.length ?? 0) > ActivityLogDraft.maxNotesLength) {
      add(ValidationCode.textTooLong, 'notes');
    }

    // Only a newly chosen activity must be plannable; an existing plan keeps
    // its activity even if that was archived since.
    final typeId = draft.activityTypeId;
    final changed = existing != null && existing.activityTypeId != typeId;
    final chosenNow = typeId != null && (existing == null || changed);
    if (changed && activityLocked) {
      add(ValidationCode.planActivityLocked, 'activity');
    } else if (chosenNow &&
        (type == null || type.isDeleted || !type.supportsPlanning)) {
      add(ValidationCode.activityNotPlannable, 'activity');
    }

    final start = draft.plannedStartAt;
    final end = draft.plannedEndAt;
    final duration = draft.plannedDurationMs;
    if (end != null && start == null) add(ValidationCode.required, 'start');
    if (end != null && start != null && end.isBefore(start)) {
      add(ValidationCode.endBeforeStart, 'end');
    }
    if (duration != null && duration <= 0) {
      add(ValidationCode.negativeDuration, 'duration');
    }
    if (duration != null && end != null) {
      add(ValidationCode.plannedDurationConflict, 'duration');
    }
    return ValidationResult(issues);
  }
}
