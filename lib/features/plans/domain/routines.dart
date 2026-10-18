import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'plan.dart';
import 'plan_use_cases.dart';

/// One thing in a routine: what, and when on the day (local wall-clock
/// minute) for how long, if it had a time.
class RoutineItem {
  const RoutineItem({
    required this.title,
    this.activityTypeId,
    this.startMinute,
    this.durationMinutes,
    this.notes,
  });

  final String title;
  final ActivityTypeId? activityTypeId;
  final int? startMinute;
  final int? durationMinutes;
  final String? notes;

  Map<String, Object?> toJson() => {
    'title': title,
    'type': activityTypeId?.value,
    'start': startMinute,
    'minutes': durationMinutes,
    'notes': notes,
  };

  static RoutineItem? fromJson(Object? json) {
    if (json is! Map || json['title'] is! String) return null;
    int? minute(Object? v) => v is int && v >= 0 && v < 24 * 60 ? v : null;
    final minutes = json['minutes'];
    return RoutineItem(
      title: json['title'] as String,
      activityTypeId: switch (json['type']) {
        final String id => ActivityTypeId(id),
        _ => null,
      },
      startMinute: minute(json['start']),
      durationMinutes: minutes is int && minutes > 0 ? minutes : null,
      notes: json['notes'] is String ? json['notes'] as String : null,
    );
  }
}

/// A saved day ("Weekday study", "Gym day") to lay onto any date in one tap
/// (stored as JSON in `app_preferences`, no schema change).
class Routine {
  const Routine({required this.id, required this.name, required this.items});

  final String id;
  final String name;
  final List<RoutineItem> items;

  static const maxNameLength = 60;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'items': [for (final i in items) i.toJson()],
  };

  static Routine? fromJson(Object? json) {
    if (json is! Map || json['id'] is! String || json['name'] is! String) {
      return null;
    }
    final items = json['items'];
    return Routine(
      id: json['id'] as String,
      name: json['name'] as String,
      items: [
        if (items is List)
          for (final i in items) ?RoutineItem.fromJson(i),
      ],
    );
  }

  static List<Routine> listFromJson(Object? json) => [
    if (json is List)
      for (final r in json) ?Routine.fromJson(r),
  ];
}

/// [plans] of a day as routine items, in display order: their times as
/// local minutes. Skipped and cancelled plans are left out.
List<RoutineItem> routineItemsFrom(Iterable<Plan> plans, Clock clock) => [
  for (final plan in orderPlans(plans))
    if (plan.status != PlanStatus.skipped &&
        plan.status != PlanStatus.cancelled)
      RoutineItem(
        title: plan.title,
        activityTypeId: plan.activityTypeId,
        startMinute: switch (plan.plannedStartAt) {
          final start? => _localMinute(clock, start),
          null => null,
        },
        durationMinutes: switch (plan.plannedLengthMs) {
          final ms? when ms > 0 =>
            (ms / Duration.millisecondsPerMinute).round(),
          _ => null,
        },
        notes: plan.notes,
      ),
];

/// Puts [items] on [date] as new plans (each keeps its time and length);
/// returns them, for Undo. An activity that's gone becomes a task of the
/// same name, so nothing is lost.
class ApplyRoutineItems {
  const ApplyRoutineItems(this._create, this._clock, this._typeExists);

  final CreatePlan _create;
  final Clock _clock;

  /// Whether an activity can still be planned.
  final Future<bool> Function(ActivityTypeId id) _typeExists;

  Future<List<PlanId>> call(List<RoutineItem> items, LocalDate date) async {
    final created = <PlanId>[];
    for (final item in items) {
      final typeId = item.activityTypeId;
      final keepType = typeId != null && await _typeExists(typeId);
      final start = item.startMinute == null
          ? null
          : _localInstant(_clock, date, item.startMinute!);
      final lengthMs = item.durationMinutes == null
          ? null
          : item.durationMinutes! * Duration.millisecondsPerMinute;
      created.add(
        await _create(
          PlanDraft(
            planDate: date,
            title: item.title,
            activityTypeId: keepType ? typeId : null,
            notes: item.notes,
            plannedStartAt: start,
            plannedEndAt: start != null && lengthMs != null
                ? start.add(Duration(milliseconds: lengthMs))
                : null,
            plannedDurationMs: start == null ? lengthMs : null,
          ),
        ),
      );
    }
    return created;
  }
}

/// [minuteOfDay] local wall-clock time on [date], as a UTC instant.
DateTime _localInstant(Clock clock, LocalDate date, int minuteOfDay) {
  final naive = DateTime.utc(
    date.year,
    date.month,
    date.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );
  return naive.subtract(clock.offsetAt(naive));
}

int _localMinute(Clock clock, DateTime instantUtc) {
  final local = instantUtc.add(clock.offsetAt(instantUtc));
  return local.hour * 60 + local.minute;
}
