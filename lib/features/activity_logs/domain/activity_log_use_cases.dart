import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import '../../plans/domain/plan_repository.dart';
import 'activity_log.dart';
import 'activity_log_repository.dart';
import 'field_value.dart';
import 'log_validator.dart';

// Use cases for activity logs (ADR-023: verb + domain object; `call`).

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Trims text, and drops empty Repeating Group items and empty groups, so an
/// untouched "Add set" row never becomes a stored item.
Map<ActivityFieldId, FieldValue> _normalizeValues(
  Map<ActivityFieldId, FieldValue> values,
) {
  final result = <ActivityFieldId, FieldValue>{};
  for (final MapEntry(:key, :value) in values.entries) {
    switch (value) {
      case TextValue(:final text):
        result[key] = TextValue(text.trim());
      case RepeatingGroupValue(:final items):
        final kept = [
          for (final item in items)
            if (_normalizeValues(item.values) case final itemValues
                when itemValues.isNotEmpty)
              item.withValues(itemValues),
        ];
        if (kept.isNotEmpty) result[key] = RepeatingGroupValue(kept);
      default:
        result[key] = value;
    }
  }
  return result;
}

ActivityLogDraft _normalized(ActivityLogDraft draft) => ActivityLogDraft(
  startedAt: draft.startedAt,
  durationMs: draft.durationMs,
  notes: draft.notes,
  values: _normalizeValues(draft.values),
  planId: draft.planId,
  endedAt: draft.endedAt,
);

/// Records what actually happened for an activity type, optionally
/// fulfilling a plan of that type (ADR-018).
class LogActivity {
  const LogActivity(
    this._types,
    this._logs,
    this._plans,
    this._ids,
    this._clock,
  );

  final ActivityTypeRepository _types;
  final ActivityLogRepository _logs;
  final PlanRepository _plans;
  final IdGenerator _ids;
  final Clock _clock;

  Future<ActivityLogId> call(
    ActivityTypeId typeId,
    ActivityLogDraft draft,
  ) async {
    final type = await _types.getType(typeId);
    if (type == null || type.isDeleted) {
      throw NotFoundException(debugContext: 'LogActivity ${typeId.value}');
    }
    final input = _normalized(draft);
    LogValidator.validate(
      type,
      input,
    ).throwIfInvalid(debugContext: 'LogActivity');
    if (draft.planId case final planId?) {
      final plan = await _plans.getPlan(planId);
      if (plan == null || plan.activityTypeId != typeId) {
        throw const ValidationException([
          ValidationIssue(ValidationCode.planRecordMismatch),
        ], debugContext: 'LogActivity plan');
      }
    }
    final now = _clock.nowUtc();
    final startedAt = draft.startedAt.toUtc();
    final offset = _clock.offsetAt(startedAt);
    final id = ActivityLogId(_ids.newId());
    await _logs.create(
      ActivityLog(
        id: id,
        activityTypeId: typeId,
        startedAt: startedAt,
        endedAt: draft.endedAt?.toUtc(),
        durationMs: draft.durationMs,
        tzOffsetMinutes: offset.inMinutes,
        localDate: LocalDate.ofInstant(startedAt, offset),
        notes: _trimToNull(draft.notes),
        values: input.values,
        planId: draft.planId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

class UpdateActivityLog {
  const UpdateActivityLog(this._types, this._logs, this._clock);

  final ActivityTypeRepository _types;
  final ActivityLogRepository _logs;
  final Clock _clock;

  Future<void> call(ActivityLogId id, ActivityLogDraft draft) async {
    final existing = await _logs.getLog(id);
    if (existing == null) {
      throw NotFoundException(debugContext: 'UpdateActivityLog ${id.value}');
    }
    final type = await _types.getType(existing.activityTypeId);
    if (type == null) {
      throw const NotFoundException(debugContext: 'UpdateActivityLog type');
    }
    final input = _normalized(draft);
    LogValidator.validate(
      type,
      input,
      existing: existing.values,
    ).throwIfInvalid(debugContext: 'UpdateActivityLog');
    final startedAt = draft.startedAt.toUtc();
    final offset = _clock.offsetAt(startedAt);
    await _logs.update(
      ActivityLog(
        id: id,
        activityTypeId: existing.activityTypeId,
        startedAt: startedAt,
        endedAt: existing.endedAt,
        durationMs: draft.durationMs,
        tzOffsetMinutes: offset.inMinutes,
        localDate: LocalDate.ofInstant(startedAt, offset),
        notes: _trimToNull(draft.notes),
        values: input.values,
        planId: existing.planId,
        createdAt: existing.createdAt,
        updatedAt: _clock.nowUtc(),
      ),
    );
  }
}

class DeleteActivityLog {
  const DeleteActivityLog(this._logs);

  final ActivityLogRepository _logs;

  Future<void> call(ActivityLogId id) => _logs.softDelete(id);
}

/// Undo for [DeleteActivityLog].
class RestoreActivityLog {
  const RestoreActivityLog(this._logs);

  final ActivityLogRepository _logs;

  Future<void> call(ActivityLogId id) => _logs.restore(id);
}
