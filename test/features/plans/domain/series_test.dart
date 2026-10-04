import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_series.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/domain/series_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// Repeating plans and Plan next (ADR-036).
void main() {
  group('RepeatRule', () {
    final start = LocalDate(2026, 10, 5); // a Monday

    test('repeats on its weekdays from its start', () {
      const rule = RepeatRule(weekdays: {1, 3, 5}); // Mon, Wed, Fri
      expect(rule.occursOn(LocalDate(2026, 10, 5), start), isTrue);
      expect(rule.occursOn(LocalDate(2026, 10, 6), start), isFalse);
      expect(rule.occursOn(LocalDate(2026, 10, 7), start), isTrue);
      expect(rule.occursOn(LocalDate(2026, 10, 4), start), isFalse);
    });

    test('every other week, counted from the start week', () {
      const rule = RepeatRule(weekdays: {3}, intervalWeeks: 2);
      expect(rule.occursOn(LocalDate(2026, 10, 7), start), isTrue);
      expect(rule.occursOn(LocalDate(2026, 10, 14), start), isFalse);
      expect(rule.occursOn(LocalDate(2026, 10, 21), start), isTrue);
    });

    test('stops after its end date; weekday mask round-trips', () {
      final rule = RepeatRule(
        weekdays: const {1, 7},
        endDate: LocalDate(2026, 10, 12),
      );
      expect(rule.occursOn(LocalDate(2026, 10, 12), start), isTrue);
      expect(rule.occursOn(LocalDate(2026, 10, 19), start), isFalse);
      expect(rule.weekdaysMask, 0x41);
      expect(RepeatRule.weekdaysFromMask(0x41), {1, 7});
    });
  });

  group('with a database', () {
    late AppDatabase db;
    late FakeClock clock;
    late SequentialIdGenerator ids;
    late DbActivityTypeRepository types;
    late DbPlanRepository plans;
    late DbActivityLogRepository logs;
    late EnsureSeriesOccurrences ensure;
    late RepeatPlan repeat;
    final monday = LocalDate(2026, 10, 5);

    setUp(() {
      db = newTestDatabase();
      // 2 h ahead of UTC, so local wall-clock times are checked.
      clock = FakeClock(
        DateTime.utc(2026, 10, 5, 6),
        offset: const Duration(hours: 2),
      );
      ids = SequentialIdGenerator();
      types = DbActivityTypeRepository(db, clock);
      plans = DbPlanRepository(db, clock);
      logs = DbActivityLogRepository(db, clock, const AppLogger());
      ensure = EnsureSeriesOccurrences(plans, ids, clock);
      repeat = RepeatPlan(plans, ids, clock);
    });

    tearDown(() => db.close());

    /// Gym at 18:00 local for an hour, on [date].
    Future<PlanId> gymPlan(LocalDate date) async {
      final gym = await CreateActivityType(types, ids)(gymDefinition());
      return CreatePlan(plans, types, ids, clock)(
        PlanDraft(
          planDate: date,
          title: '',
          activityTypeId: gym,
          plannedStartAt: DateTime.utc(2026, 10, 5, 16), // 18:00 local
          plannedDurationMs: 3600000,
        ),
      );
    }

    Future<List<Plan>> week(LocalDate from) =>
        plans.watchPlansForRange(from, from.addDays(6)).first;

    test('repeating Gym Mon/Wed/Fri fills the week with occurrences at '
        '18:00 local, once', () async {
      final id = await gymPlan(monday);
      await repeat(id, const RepeatRule(weekdays: {1, 3, 5}));

      await ensure(monday, monday.addDays(6));
      await ensure(monday, monday.addDays(6)); // idempotent

      final occurrences = await week(monday);
      expect([for (final p in occurrences) p.planDate.day], [5, 7, 9]);
      expect(occurrences.first.id, id, reason: 'the plan is the first one');
      for (final p in occurrences) {
        expect(p.isRepeating, isTrue);
        expect(p.title, 'Gym');
        final local = p.plannedStartAt!.add(const Duration(hours: 2));
        expect((local.hour, local.minute), (18, 0));
        expect(p.plannedLengthMs, 3600000);
      }
    });

    test('a deleted occurrence is not generated again', () async {
      await repeat(await gymPlan(monday), const RepeatRule(weekdays: {1, 3}));
      await ensure(monday, monday.addDays(6));
      final wednesday = (await week(monday)).last;

      await plans.softDelete(wednesday.id);
      await ensure(monday, monday.addDays(6));

      expect([for (final p in await week(monday)) p.planDate.day], [5]);
    });

    test('changing the rule from a date ends the old series there and '
        'keeps what was logged', () async {
      final first = await gymPlan(monday);
      await repeat(first, const RepeatRule(weekdays: {1, 3, 5}));
      await ensure(monday, monday.addDays(13));
      final all = await plans
          .watchPlansForRange(monday, monday.addDays(13))
          .first;
      // Something was logged into the next Monday's occurrence.
      final nextMonday = all.firstWhere((p) => p.planDate.day == 12);
      final gym = nextMonday.activityTypeId!;
      await LogActivity(types, logs, plans, ids, clock)(
        gym,
        ActivityLogDraft(
          startedAt: clock.nowUtc(),
          values: const {},
          planId: nextMonday.id,
        ),
        partial: true,
      );
      final wednesday = all.firstWhere((p) => p.planDate.day == 7);

      await repeat(wednesday.id, const RepeatRule(weekdays: {2})); // Tuesdays
      await ensure(monday, monday.addDays(13));

      final days = [
        for (final p
            in await plans.watchPlansForRange(monday, monday.addDays(13)).first)
          p.planDate.day,
      ];
      // Mon 5 (old), Wed 7 (now the new series' first), Mon 12 (logged,
      // kept), Tue 13 (new).
      expect(days, [5, 7, 12, 13]);
    });

    test(
      'stop repeating keeps this one and removes the open ones after',
      () async {
        final first = await gymPlan(monday);
        await repeat(first, const RepeatRule(weekdays: {1, 3, 5}));
        await ensure(monday, monday.addDays(13));

        await StopRepeating(plans, clock)(first);
        await ensure(monday, monday.addDays(13));

        expect([for (final p in await week(monday)) p.planDate.day], [5]);
      },
    );

    test('an end date before the plan is rejected', () async {
      final id = await gymPlan(monday);
      await expectLater(
        repeat(
          id,
          RepeatRule(weekdays: const {1}, endDate: monday.addDays(-1)),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        repeat(id, const RepeatRule(weekdays: {})),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'moving an occurrence moves a one-off copy; its date stays free',
      () async {
        await repeat(await gymPlan(monday), const RepeatRule(weekdays: {1, 3}));
        await ensure(monday, monday.addDays(6));
        final wednesday = (await week(monday)).last;

        final moved = await MovePlan(plans, ids, clock)(
          wednesday.id,
          monday.addDays(3),
        );
        await ensure(monday, monday.addDays(6));

        final now = await week(monday);
        expect([for (final p in now) p.planDate.day], [5, 8]);
        final copy = now.last;
        expect(copy.id, moved);
        expect(copy.isRepeating, isFalse);
      },
    );

    test('plan next: the same thing on another date, same length', () async {
      final id = await gymPlan(monday);
      final next = await PlanNext(CreatePlan(plans, types, ids, clock), plans)(
        id,
        monday.addDays(14),
      );

      final plan = (await plans.getPlan(next))!;
      final original = (await plans.getPlan(id))!;
      expect(plan.planDate, monday.addDays(14));
      expect(plan.title, 'Gym');
      expect(plan.activityTypeId, original.activityTypeId);
      expect(plan.plannedDurationMs, 3600000);
      expect(plan.isRepeating, isFalse);
    });
  });
}
