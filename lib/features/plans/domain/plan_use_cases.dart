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

/// Completes, skips, cancels or reopens any plan (ADR-040: activity items
/// are marked done too; see [MarkItemDone] for logging them first).
class SetPlanStatus {
  const SetPlanStatus(this._plans, this._clock);

  final PlanRepository _plans;
  final Clock _clock;

  Future<void> call(PlanId id, PlanStatus status) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'SetPlanStatus ${id.value}');
    }
    await _plans.update(
      plan.copyWith(status: status, updatedAt: _clock.nowUtc()),
    );
  }
}

/// Moves a plan to another date ("Move to tomorrow", F11): planned times keep
/// their local wall-clock time, the plan reopens, and it goes to the end of
/// the target date's manual order. Returns the moved plan.
///
/// An occurrence of a repeating plan (ADR-036) moves as a one-off copy: the
/// occurrence is deleted on its date (so it isn't generated again there) and
/// the copy, no longer repeating, goes to [to].
class MovePlan {
  const MovePlan(this._plans, this._ids, this._clock);

  final PlanRepository _plans;
  final IdGenerator _ids;
  final Clock _clock;

  /// Moves the plan to [to], keeping its time of day. With
  /// [anytimeIfPassed] (bringing yesterday's thing to today, T2), a time
  /// that has already passed on [to] is dropped: it becomes Anytime and
  /// keeps its length.
  Future<PlanId> call(
    PlanId id,
    LocalDate to, {
    bool anytimeIfPassed = false,
  }) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'MovePlan ${id.value}');
    }
    final days = plan.planDate.daysUntil(to);
    DateTime? shift(DateTime? instant) =>
        instant == null ? null : _clock.shiftDays(instant, days);
    final now = _clock.nowUtc();
    final start = shift(plan.plannedStartAt);
    final passed = anytimeIfPassed && start != null && start.isBefore(now);
    final moved = plan.copyWith(
      planDate: to,
      plannedStartAt: () => passed ? null : start,
      plannedEndAt: () => passed ? null : shift(plan.plannedEndAt),
      plannedDurationMs: passed ? () => plan.plannedLengthMs : null,
      sortOrder: await _plans.nextSortOrder(to),
      status: PlanStatus.planned,
      updatedAt: now,
    );
    if (!plan.isRepeating) {
      await _plans.update(moved);
      return id;
    }
    final copy = Plan(
      id: PlanId(_ids.newId()),
      planDate: moved.planDate,
      activityTypeId: plan.activityTypeId,
      title: plan.title,
      notes: plan.notes,
      plannedStartAt: moved.plannedStartAt,
      plannedEndAt: moved.plannedEndAt,
      plannedDurationMs: moved.plannedDurationMs,
      sortOrder: moved.sortOrder,
      status: PlanStatus.planned,
      createdAt: now,
      updatedAt: now,
    );
    await _plans.create(copy);
    await _plans.softDelete(id);
    return copy.id;
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

/// A copy of a plan on the same day (B7): same title, activity, time and
/// notes; a one-off (not repeating), planned, nothing logged. Returns it.
class DuplicatePlan {
  const DuplicatePlan(this._plans, this._create);

  final PlanRepository _plans;
  final CreatePlan _create;

  Future<PlanId> call(PlanId id) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'DuplicatePlan ${id.value}');
    }
    return _create(
      PlanDraft(
        planDate: plan.planDate,
        title: plan.title,
        activityTypeId: plan.activityTypeId,
        notes: plan.notes,
        plannedStartAt: plan.plannedStartAt,
        plannedEndAt: plan.plannedEndAt,
        plannedDurationMs: plan.plannedDurationMs,
      ),
    );
  }
}
