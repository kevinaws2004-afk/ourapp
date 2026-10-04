import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import 'plan.dart';
import 'plan_repository.dart';
import 'plan_series.dart';
import 'plan_use_cases.dart';

// Repeating plans and planning ahead (ADR-036).

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

/// Local minute of day of [instantUtc].
int _localMinute(Clock clock, DateTime instantUtc) {
  final local = instantUtc.add(clock.offsetAt(instantUtc));
  return local.hour * 60 + local.minute;
}

/// Makes sure every repeating plan has its occurrences between [from] and
/// [to] (inclusive) as ordinary plans you can open and log into. Safe to
/// call repeatedly: one occurrence per series and date, and one the user
/// deleted stays deleted.
class EnsureSeriesOccurrences {
  const EnsureSeriesOccurrences(this._plans, this._ids, this._clock);

  final PlanRepository _plans;
  final IdGenerator _ids;
  final Clock _clock;

  Future<void> call(LocalDate from, LocalDate to) async {
    final series = await _plans.seriesBetween(from, to);
    if (series.isEmpty) return;
    final now = _clock.nowUtc();
    for (var date = from; date.compareTo(to) <= 0; date = date.addDays(1)) {
      for (final s in series) {
        if (!s.occursOn(date)) continue;
        await _plans.createOccurrence(
          Plan(
            id: PlanId(_ids.newId()),
            planDate: date,
            activityTypeId: s.activityTypeId,
            title: s.title,
            notes: s.notes,
            plannedStartAt: s.startMinute == null
                ? null
                : _localInstant(_clock, date, s.startMinute!),
            plannedDurationMs: s.durationMs,
            sortOrder: await _plans.nextSortOrder(date),
            status: PlanStatus.planned,
            createdAt: now,
            updatedAt: now,
            seriesId: s.id,
          ),
        );
      }
    }
  }
}

/// Makes a plan repeat (ADR-036): it becomes the first occurrence of a new
/// series with its title, activity, time and length. A plan that already
/// repeats switches to the new rule from its date on: the old series ends
/// the day before and its later open occurrences are removed.
class RepeatPlan {
  const RepeatPlan(this._plans, this._ids, this._clock);

  final PlanRepository _plans;
  final IdGenerator _ids;
  final Clock _clock;

  Future<PlanSeriesId> call(PlanId id, RepeatRule rule) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'RepeatPlan ${id.value}');
    }
    if (!rule.isValid ||
        (rule.endDate != null && rule.endDate!.compareTo(plan.planDate) < 0)) {
      throw const ValidationException([
        ValidationIssue(ValidationCode.invalidRepeat),
      ], debugContext: 'RepeatPlan');
    }
    final now = _clock.nowUtc();
    if (plan.seriesId case final old?) {
      await _end(_plans, old, plan.planDate.addDays(-1), now);
      await _plans.deleteOpenOccurrences(old, plan.planDate.addDays(1), now);
    }
    final seriesId = PlanSeriesId(_ids.newId());
    await _plans.createSeries(
      PlanSeries(
        id: seriesId,
        title: plan.title,
        activityTypeId: plan.activityTypeId,
        notes: plan.notes,
        startMinute: plan.plannedStartAt == null
            ? null
            : _localMinute(_clock, plan.plannedStartAt!),
        durationMs: plan.plannedLengthMs,
        rule: rule,
        startDate: plan.planDate,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _plans.linkToSeries(id, seriesId);
    return seriesId;
  }
}

/// Ends a series after [lastDate]; a series ending before it starts is
/// deleted.
Future<void> _end(
  PlanRepository plans,
  PlanSeriesId id,
  LocalDate lastDate,
  DateTime now,
) async {
  final series = await plans.getSeries(id);
  if (series == null) return;
  if (lastDate.compareTo(series.startDate) < 0) {
    await plans.deleteSeries(id, now);
  } else {
    await plans.setSeriesEnd(id, lastDate, now);
  }
}

/// "Stop repeating" on an occurrence: it stays, nothing repeats after it, and
/// later open occurrences are removed (logged ones are kept).
class StopRepeating {
  const StopRepeating(this._plans, this._clock);

  final PlanRepository _plans;
  final Clock _clock;

  Future<void> call(PlanId id) async {
    final plan = await _plans.getPlan(id);
    final seriesId = plan?.seriesId;
    if (plan == null || seriesId == null) return;
    final now = _clock.nowUtc();
    await _end(_plans, seriesId, plan.planDate, now);
    await _plans.deleteOpenOccurrences(seriesId, plan.planDate.addDays(1), now);
  }
}

/// "Plan next" (ADR-036): the same thing on another date (next appointment,
/// next session), with the same activity, so it has the same things to log.
/// Optionally at [startAt]; it keeps the planned length.
class PlanNext {
  const PlanNext(this._create, this._plans);

  final CreatePlan _create;
  final PlanRepository _plans;

  Future<PlanId> call(PlanId id, LocalDate date, {DateTime? startAt}) async {
    final plan = await _plans.getPlan(id);
    if (plan == null) {
      throw NotFoundException(debugContext: 'PlanNext ${id.value}');
    }
    return _create(
      PlanDraft(
        planDate: date,
        title: plan.title,
        activityTypeId: plan.activityTypeId,
        plannedStartAt: startAt,
        plannedDurationMs: plan.plannedLengthMs,
      ),
    );
  }
}
