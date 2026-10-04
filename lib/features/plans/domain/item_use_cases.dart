import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/keys/activity_icon_ids.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/domain/activity_log_repository.dart';
import '../../activity_logs/domain/activity_log_use_cases.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type_definition.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import '../../activity_types/domain/activity_type_use_cases.dart';
import 'plan.dart';
import 'plan_repository.dart';
import 'plan_title_match.dart';
import 'plan_use_cases.dart';

// Use cases for items (ADR-035): a plan on your day is the place you log
// into. Its log is created on the first thing you log and saved as you go.

/// Gives an item an activity the first time something is logged into it: an
/// existing activity with the item's name, or a new one named after it with
/// no fields yet. Returns the item's activity.
class EnsureItemActivity {
  const EnsureItemActivity(
    this._plans,
    this._types,
    this._create,
    this._assign,
  );

  final PlanRepository _plans;
  final ActivityTypeRepository _types;
  final CreateActivityType _create;
  final AssignPlanActivity _assign;

  Future<ActivityTypeId> call(PlanId id) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'EnsureItemActivity ${id.value}');
    }
    if (plan.activityTypeId case final typeId?) return typeId;
    final active = await _types.getActiveTypes();
    final typeId =
        matchByName(plan.title, active, (t) => t.name)?.id ??
        await _create(newItemActivity(plan.title));
    await _assign(id, typeId);
    return typeId;
  }

  /// A plain activity for [title]: timer-capable, no fields, a palette color
  /// picked from the name so different items look different.
  static ActivityTypeDefinition newItemActivity(String title) {
    final name = title.trim();
    final colors = ActivityColorKey.values;
    return ActivityTypeDefinition(
      name: name.length > ActivityTypeDefinition.maxNameLength
          ? name.substring(0, ActivityTypeDefinition.maxNameLength)
          : name,
      iconId: ActivityIconIds.fallback,
      colorKey: colors[name.toLowerCase().hashCode.abs() % colors.length].name,
      supportsTimer: true,
      fields: const [],
    );
  }
}

/// Marks an item done (ADR-040). An activity item with nothing logged gets a
/// log at its planned time and length first; then the item is stored as
/// completed. Returns the log it created, if any (for Undo).
class MarkItemDone {
  const MarkItemDone(
    this._plans,
    this._logs,
    this._log,
    this._setStatus,
    this._clock,
  );

  final PlanRepository _plans;
  final ActivityLogRepository _logs;
  final LogActivity _log;
  final SetPlanStatus _setStatus;
  final Clock _clock;

  Future<ActivityLogId?> call(PlanId id) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'MarkItemDone ${id.value}');
    }
    final typeId = plan.activityTypeId;
    ActivityLogId? created;
    if (typeId != null && await _logs.getLogForPlan(id) == null) {
      created = await _log(
        typeId,
        ActivityLogDraft(
          startedAt: recordStartFor(plan, _clock),
          durationMs: plan.plannedLengthMs,
          values: const {},
          planId: id,
        ),
        partial: true,
      );
    }
    await _setStatus(id, PlanStatus.completed);
    return created;
  }
}

/// Deletes an item: the plan and what was logged into it (ADR-022 soft
/// delete). Returns the deleted logs, for [RestoreItem].
class DeleteItem {
  const DeleteItem(this._plans, this._logs);

  final PlanRepository _plans;
  final ActivityLogRepository _logs;

  Future<List<ActivityLogId>> call(PlanId id) async {
    final log = await _logs.getLogForPlan(id);
    if (log != null) await _logs.softDelete(log.id);
    await _plans.softDelete(id);
    return [?log?.id];
  }
}

/// Undo for [DeleteItem].
class RestoreItem {
  const RestoreItem(this._plans, this._logs);

  final PlanRepository _plans;
  final ActivityLogRepository _logs;

  Future<void> call(PlanId id, List<ActivityLogId> logs) async {
    await _plans.restore(id);
    for (final log in logs) {
      await _logs.restore(log);
    }
  }
}

/// Adds something new to log to an item, right where you're logging
/// (ADR-035): a field on the item's activity (created for it first if it has
/// none), at the end, or as a new detail inside the list [parentId]. Later
/// items of that activity have it too. Returns the item's activity.
class AddItemField {
  const AddItemField(this._types, this._ensure, this._update);

  final ActivityTypeRepository _types;
  final EnsureItemActivity _ensure;
  final UpdateActivityType _update;

  Future<ActivityTypeId> call(
    FieldDefinition field, {
    PlanId? planId,
    ActivityTypeId? typeId,
    ActivityFieldId? parentId,
  }) async {
    final id = typeId ?? await _ensure(planId!);
    final type = await _types.getType(id);
    if (type == null) {
      throw NotFoundException(debugContext: 'AddItemField ${id.value}');
    }
    final current = definitionOf(type);
    List<FieldDefinition> insert(List<FieldDefinition> fields) => [
      for (final f in fields)
        f.id == parentId
            ? f.copyWith(subFields: [...f.subFields, field])
            : f.copyWith(subFields: insert(f.subFields)),
    ];
    await _update(
      id,
      ActivityTypeDefinition(
        name: current.name,
        iconId: current.iconId,
        colorKey: current.colorKey,
        description: current.description,
        supportsTimer: current.supportsTimer,
        supportsPlanning: current.supportsPlanning,
        fields: parentId == null
            ? [...current.fields, field]
            : insert(current.fields),
      ),
    );
    return id;
  }
}
