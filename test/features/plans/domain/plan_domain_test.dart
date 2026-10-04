import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/time/clock.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_title_match.dart';
import 'package:daylog/features/plans/domain/plan_validator.dart';
import 'package:flutter_test/flutter_test.dart';

final _date = LocalDate(2026, 10, 5);

Plan plan({
  String id = 'p',
  ActivityTypeId? typeId,
  DateTime? start,
  DateTime? end,
  int? durationMs,
  int sortOrder = 0,
  PlanStatus status = PlanStatus.planned,
}) => Plan(
  id: PlanId(id),
  planDate: _date,
  activityTypeId: typeId,
  title: id,
  plannedStartAt: start,
  plannedEndAt: end,
  plannedDurationMs: durationMs,
  sortOrder: sortOrder,
  status: status,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

ActivityType type({bool plannable = true, bool deleted = false}) =>
    ActivityType(
      id: const ActivityTypeId('reading'),
      name: 'Reading',
      iconId: 'book-open',
      colorKey: 'sky',
      supportsTimer: true,
      supportsPlanning: plannable,
      sortOrder: 0,
      fields: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      isDeleted: deleted,
    );

/// A clock whose offset changes at [switchAt] (a DST transition).
class _DstClock implements Clock {
  _DstClock(this.switchAt, this.before, this.after);

  final DateTime switchAt;
  final Duration before;
  final Duration after;

  @override
  DateTime nowUtc() => switchAt;

  @override
  Duration offsetAt(DateTime instantUtc) =>
      instantUtc.isBefore(switchAt) ? before : after;
}

void main() {
  group('effective status (ADR-018, ADR-040)', () {
    const reading = ActivityTypeId('reading');
    final today = _date;
    final tomorrow = _date.addDays(1);

    test(
      'logging into an activity item today makes it in progress, not done',
      () {
        expect(
          plan(typeId: reading).effectiveStatus(hasRecord: true, today: today),
          EffectivePlanStatus.inProgress,
        );
        expect(
          plan(typeId: reading).effectiveStatus(hasRecord: false, today: today),
          EffectivePlanStatus.planned,
        );
      },
    );

    test('once its day has passed, what was logged counts as done', () {
      expect(
        plan(typeId: reading).effectiveStatus(hasRecord: true, today: tomorrow),
        EffectivePlanStatus.completed,
      );
    });

    test('marked done is done, logged or not', () {
      for (final hasRecord in [true, false]) {
        expect(
          plan(
            typeId: reading,
            status: PlanStatus.completed,
          ).effectiveStatus(hasRecord: hasRecord, today: today),
          EffectivePlanStatus.completed,
        );
      }
    });

    test('something logged wins over skipped', () {
      expect(
        plan(
          typeId: reading,
          status: PlanStatus.skipped,
        ).effectiveStatus(hasRecord: true, today: tomorrow),
        EffectivePlanStatus.completed,
      );
    });

    test('a running timer shows in progress, even when marked done', () {
      expect(
        plan(
          typeId: reading,
          status: PlanStatus.completed,
        ).effectiveStatus(hasRecord: true, today: today, inFocus: true),
        EffectivePlanStatus.inProgress,
      );
    });

    test('a task is completed only by its stored status', () {
      expect(
        plan(status: PlanStatus.completed)
            .effectiveStatus(hasRecord: false, today: today),
        EffectivePlanStatus.completed,
      );
      expect(
        plan().effectiveStatus(hasRecord: false, today: today),
        EffectivePlanStatus.planned,
      );
    });
  });

  test('planned length comes from the time range or the duration', () {
    final start = DateTime.utc(2026, 10, 5, 9);
    expect(
      plan(
        start: start,
        end: start.add(const Duration(hours: 1)),
      ).plannedLengthMs,
      3600000,
    );
    expect(plan(durationMs: 2700000).plannedLengthMs, 2700000);
    expect(plan(start: start).plannedLengthMs, isNull);
  });

  test('timed plans come first by time, then untimed by manual order', () {
    final ordered = orderPlans([
      plan(id: 'untimed-2', sortOrder: 2),
      plan(id: 'late', start: DateTime.utc(2026, 10, 5, 18)),
      plan(id: 'untimed-1', sortOrder: 1),
      plan(id: 'early', start: DateTime.utc(2026, 10, 5, 7)),
    ]);
    expect(ordered.map((p) => p.id.value), [
      'early',
      'late',
      'untimed-1',
      'untimed-2',
    ]);
  });

  group('validator', () {
    List<(ValidationCode, String?)> issues(
      PlanDraft draft, {
      ActivityType? withType,
      Plan? existing,
      bool locked = false,
    }) => [
      for (final i in PlanValidator.validate(
        draft,
        type: withType,
        existing: existing,
        activityLocked: locked,
      ).issues)
        (i.code, i.target),
    ];

    test('a task needs a title; an activity plan may borrow its name', () {
      expect(issues(PlanDraft(planDate: _date, title: ' ')), [
        (ValidationCode.nameRequired, 'title'),
      ]);
      expect(
        issues(
          PlanDraft(
            planDate: _date,
            title: '',
            activityTypeId: const ActivityTypeId('reading'),
          ),
          withType: type(),
        ),
        isEmpty,
      );
    });

    test('a new activity must exist and be plannable', () {
      final draft = PlanDraft(
        planDate: _date,
        title: 'Read',
        activityTypeId: const ActivityTypeId('reading'),
      );
      for (final t in [null, type(plannable: false), type(deleted: true)]) {
        expect(issues(draft, withType: t), [
          (ValidationCode.activityNotPlannable, 'activity'),
        ]);
      }
      // An existing plan keeps its archived activity.
      expect(
        issues(
          draft,
          withType: type(deleted: true),
          existing: plan(typeId: const ActivityTypeId('reading')),
        ),
        isEmpty,
      );
    });

    test('a recorded plan can\'t change its activity', () {
      expect(
        issues(
          PlanDraft(planDate: _date, title: 'Read'),
          existing: plan(typeId: const ActivityTypeId('reading')),
          locked: true,
        ),
        [(ValidationCode.planActivityLocked, 'activity')],
      );
    });

    test('times: end needs a start, follows it, and excludes a length', () {
      final nine = DateTime.utc(2026, 10, 5, 9);
      final eight = DateTime.utc(2026, 10, 5, 8);
      expect(
        issues(PlanDraft(planDate: _date, title: 'x', plannedEndAt: nine)),
        [(ValidationCode.required, 'start')],
      );
      expect(
        issues(
          PlanDraft(
            planDate: _date,
            title: 'x',
            plannedStartAt: nine,
            plannedEndAt: eight,
          ),
        ),
        [(ValidationCode.endBeforeStart, 'end')],
      );
      expect(
        issues(
          PlanDraft(
            planDate: _date,
            title: 'x',
            plannedStartAt: eight,
            plannedEndAt: nine,
            plannedDurationMs: 60000,
          ),
        ),
        [(ValidationCode.plannedDurationConflict, 'duration')],
      );
      expect(
        issues(PlanDraft(planDate: _date, title: 'x', plannedDurationMs: 0)),
        [(ValidationCode.negativeDuration, 'duration')],
      );
    });
  });

  test('shifting days keeps the local wall-clock time across DST', () {
    // Offset goes from +1h to +2h at 2026-03-29 01:00 UTC.
    final clock = _DstClock(
      DateTime.utc(2026, 3, 29, 1),
      const Duration(hours: 1),
      const Duration(hours: 2),
    );
    // 09:00 local on Mar 28 (+1h) = 08:00 UTC.
    final shifted = clock.shiftDays(DateTime.utc(2026, 3, 28, 8), 1);
    // 09:00 local on Mar 29 (+2h) = 07:00 UTC.
    expect(shifted, DateTime.utc(2026, 3, 29, 7));
  });

  test('daysUntil counts calendar days', () {
    expect(LocalDate(2026, 10, 30).daysUntil(LocalDate(2026, 11, 2)), 3);
    expect(LocalDate(2026, 11, 2).daysUntil(LocalDate(2026, 10, 30)), -3);
  });

  group('record start for a plan (ADR-030)', () {
    final now = DateTime.utc(2026, 10, 5, 12, 30);
    final clock = _DstClock(
      now,
      const Duration(hours: 2),
      const Duration(hours: 2),
    );

    test('today\'s plan starts now', () {
      expect(recordStartFor(plan(), clock), now);
    });

    test('another day\'s plan starts at its planned time, or that date at '
        'the current local time', () {
      final yesterday = Plan(
        id: const PlanId('y'),
        planDate: LocalDate(2026, 10, 4),
        title: 'y',
        sortOrder: 0,
        status: PlanStatus.planned,
        createdAt: now,
        updatedAt: now,
      );
      // 14:30 local on Oct 4 at +2h = 12:30 UTC.
      expect(
        recordStartFor(yesterday, clock),
        DateTime.utc(2026, 10, 4, 12, 30),
      );
      final timed = Plan(
        id: const PlanId('t'),
        planDate: LocalDate(2026, 10, 4),
        title: 't',
        plannedStartAt: DateTime.utc(2026, 10, 4, 5),
        sortOrder: 0,
        status: PlanStatus.planned,
        createdAt: now,
        updatedAt: now,
      );
      expect(recordStartFor(timed, clock), DateTime.utc(2026, 10, 4, 5));
    });
  });

  test('a timed plan records from its planned start, even today', () {
    final clock = _DstClock(
      DateTime.utc(2026, 10, 5, 12),
      Duration.zero,
      Duration.zero,
    );
    final slot = DateTime.utc(2026, 10, 5, 21, 10);
    expect(recordStartFor(plan(start: slot), clock), slot);
  });

  test(
    'a typed title matches an activity by name, ignoring case and spaces',
    () {
      final names = ['Gym', 'Reading'];
      expect(matchByName(' gym ', names, (n) => n), 'Gym');
      expect(matchByName('Bath', names, (n) => n), isNull);
      expect(matchByName('', names, (n) => n), isNull);
    },
  );
}
