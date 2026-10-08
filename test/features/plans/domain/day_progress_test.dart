import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/plans/domain/day_progress.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = LocalDate(2026, 10, 3);
  final created = DateTime.utc(2026, 10, 1);
  var next = 0;

  PlannedItem item(
    EffectivePlanStatus status, {
    DateTime? start,
    int? lengthMs,
    String title = 'Gym',
  }) => PlannedItem(
    plan: Plan(
      id: PlanId('plan-${next++}'),
      planDate: day,
      activityTypeId: const ActivityTypeId('type'),
      title: title,
      plannedStartAt: start,
      plannedDurationMs: lengthMs,
      sortOrder: next,
      status: PlanStatus.planned,
      createdAt: created,
      updatedAt: created,
    ),
    type: null,
    records: const [],
    status: status,
  );

  DayOverview overview(List<PlannedItem> planned) => DayOverview(
    date: day,
    planned: planned,
    records: const [],
    unplanned: const [],
  );

  group('DayProgress', () {
    test('counts done of the items that count; skipped and cancelled '
        "don't", () {
      final progress = DayProgress.of(
        overview([
          item(EffectivePlanStatus.completed),
          item(EffectivePlanStatus.inProgress),
          item(EffectivePlanStatus.planned),
          item(EffectivePlanStatus.skipped),
          item(EffectivePlanStatus.cancelled),
        ]),
      );
      expect(progress.done, 1);
      expect(progress.total, 3);
      expect(progress.fraction, closeTo(1 / 3, 1e-9));
      expect(progress.allDone, isFalse);
    });

    test('an empty day is empty, not done', () {
      final progress = DayProgress.of(overview(const []));
      expect(progress.isEmpty, isTrue);
      expect(progress.allDone, isFalse);
      expect(progress.fraction, 0);
    });
  });

  group('upNext', () {
    final now = DateTime.utc(2026, 10, 3, 12);

    test('the item in progress comes first', () {
      final doing = item(EffectivePlanStatus.inProgress, title: 'Reading');
      final later = item(
        EffectivePlanStatus.planned,
        start: DateTime.utc(2026, 10, 3, 13),
      );
      expect(upNext(overview([later, doing]), now), doing);
    });

    test('then the earliest timed item that has not ended', () {
      final missed = item(
        EffectivePlanStatus.planned,
        start: DateTime.utc(2026, 10, 3, 9),
        lengthMs: 3600000,
      );
      final running = item(
        EffectivePlanStatus.planned,
        start: DateTime.utc(2026, 10, 3, 11, 30),
        lengthMs: 3600000,
      );
      final evening = item(
        EffectivePlanStatus.planned,
        start: DateTime.utc(2026, 10, 3, 18),
      );
      expect(upNext(overview([missed, evening, running]), now), running);
    });

    test('then the first untimed item', () {
      final missed = item(
        EffectivePlanStatus.planned,
        start: DateTime.utc(2026, 10, 3, 9),
      );
      final anytime = item(EffectivePlanStatus.planned);
      expect(upNext(overview([missed, anytime]), now), anytime);
    });

    test('nothing when everything is done, skipped or past', () {
      expect(
        upNext(
          overview([
            item(EffectivePlanStatus.completed),
            item(EffectivePlanStatus.skipped),
            item(
              EffectivePlanStatus.planned,
              start: DateTime.utc(2026, 10, 3, 8),
            ),
          ]),
          now,
        ),
        isNull,
      );
    });
  });
}
