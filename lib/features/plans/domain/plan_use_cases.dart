import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import 'plan.dart';
import 'plan_repository.dart';
import 'plan_validator.dart';

// Use cases for plans (ADR-023: verb + domain object; `call`).

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// An activity plan with no title takes its activity's name.
String _titleFor(PlanDraft draft, ActivityType? type) {
  final title = draft.title.trim();
  return title.isEmpty && type != null ? type.name : title;
}

class CreatePlan {
  const CreatePlan(this._plans, this._types, this._ids, this._clock);

  final PlanRepository _plans;
  final ActivityTypeRepository _types;
  final IdGenerator _ids;
  final Clock _clock;

  Future<PlanId> call(PlanDraft draft) async {
    final type = draft.activityTypeId == null
        ? null
        : await _types.getType(draft.activityTypeId!);
    PlanValidator.validate(
      draft,
      type: type,
    ).throwIfInvalid(debugContext: 'CreatePlan');
    final now = _clock.nowUtc();
    final id = PlanId(_ids.newId());
    await _plans.create(
      Plan(
        id: id,
        planDate: draft.planDate,
        activityTypeId: draft.activityTypeId,
        title: _titleFor(draft, type),
        notes: _trimToNull(draft.notes),
        plannedStartAt: draft.plannedStartAt?.toUtc(),
        plannedEndAt: draft.plannedEndAt?.toUtc(),
        plannedDurationMs: draft.plannedDurationMs,
        sortOrder: await _plans.nextSortOrder(draft.planDate),
        status: PlanStatus.planned,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

class UpdatePlan {
  const UpdatePlan(this._plans, this._types, this._clock);

  final PlanRepository _plans;
  final ActivityTypeRepository _types;
  final Clock _clock;

  Future<void> call(PlanId id, PlanDraft draft) async {
    final existing = await _plans.getPlan(id);
    if (existing == null) {
      throw NotFoundException(debugContext: 'UpdatePlan ${id.value}');
    }
    final type = draft.activityTypeId == null
        ? null
        : await _types.getType(draft.activityTypeId!);
    final changed = existing.activityTypeId != draft.activityTypeId;
    PlanValidator.validate(
      draft,
      type: type,
      existing: existing,
      activityLocked: changed && await _plans.hasRecords(id),
    ).throwIfInvalid(debugContext: 'UpdatePlan');
    final moved = draft.planDate != existing.planDate;
    await _plans.update(
      Plan(
        id: id,
        planDate: draft.planDate,
        activityTypeId: draft.activityTypeId,
        title: _titleFor(draft, type),
        notes: _trimToNull(draft.notes),
        plannedStartAt: draft.plannedStartAt?.toUtc(),
        plannedEndAt: draft.plannedEndAt?.toUtc(),
        plannedDurationMs: draft.plannedDurationMs,
        sortOrder: moved
            ? await _plans.nextSortOrder(draft.planDate)
            : existing.sortOrder,
        // A task can't stay completed as an activity plan (CHECK).
        status:
            draft.activityTypeId != null &&
                existing.status == PlanStatus.completed
            ? PlanStatus.planned
            : existing.status,
        createdAt: existing.createdAt,
        updatedAt: _clock.nowUtc(),
      ),
    );
  }
}

/// Gives a task an activity, so it can be recorded with that activity's own
/// fields ("Food" → set up what to track → record it, ADR-030). Everything
/// else about the plan stays.
class AssignPlanActivity {
  const AssignPlanActivity(this._update, this._plans);

  final UpdatePlan _update;
  final PlanRepository _plans;

  Future<void> call(PlanId id, ActivityTypeId typeId) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'AssignPlanActivity ${id.value}');
    }
    await _update(
      id,
      PlanDraft(
        planDate: plan.planDate,
        title: plan.title,
        activityTypeId: typeId,
        notes: plan.notes,
        plannedStartAt: plan.plannedStartAt,
        plannedEndAt: plan.plannedEndAt,
        plannedDurationMs: plan.plannedDurationMs,
      ),
    );
  }
}

/// Completes/uncompletes a task, or skips/cancels/reopens any plan. Activity
/// plans are completed by recording them, never by a stored status (ADR-018).
class SetPlanStatus {
  const SetPlanStatus(this._plans, this._clock);

  final PlanRepository _plans;
  final Clock _clock;

  Future<void> call(PlanId id, PlanStatus status) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'SetPlanStatus ${id.value}');
    }
    if (status == PlanStatus.completed && !plan.isTask) {
      throw const ValidationException([
        ValidationIssue(ValidationCode.onlyTasksCanBeCompleted),
      ], debugContext: 'SetPlanStatus');
    }
    await _plans.update(
      plan.copyWith(status: status, updatedAt: _clock.nowUtc()),
    );
  }
}

/// Moves a plan to another date ("Move to tomorrow", F11): planned times keep
/// their local wall-clock time, the plan reopens, and it goes to the end of
/// the target date's manual order.
class MovePlan {
  const MovePlan(this._plans, this._clock);

  final PlanRepository _plans;
  final Clock _clock;

  Future<void> call(PlanId id, LocalDate to) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'MovePlan ${id.value}');
    }
    final days = plan.planDate.daysUntil(to);
    DateTime? shift(DateTime? instant) =>
        instant == null ? null : _clock.shiftDays(instant, days);
    await _plans.update(
      plan.copyWith(
        planDate: to,
        plannedStartAt: () => shift(plan.plannedStartAt),
        plannedEndAt: () => shift(plan.plannedEndAt),
        sortOrder: await _plans.nextSortOrder(to),
        status: PlanStatus.planned,
        updatedAt: _clock.nowUtc(),
      ),
    );
  }
}

/// New manual order of a date's untimed plans (drag and drop, FR-PL-08).
class ReorderPlans {
  const ReorderPlans(this._plans, this._clock);

  final PlanRepository _plans;
  final Clock _clock;

  Future<void> call(List<PlanId> order) =>
      _plans.reorder(order, _clock.nowUtc());
}

class DeletePlan {
  const DeletePlan(this._plans);

  final PlanRepository _plans;

  Future<void> call(PlanId id) => _plans.softDelete(id);
}

/// Undo for [DeletePlan].
class RestorePlan {
  const RestorePlan(this._plans);

  final PlanRepository _plans;

  Future<void> call(PlanId id) => _plans.restore(id);
}
