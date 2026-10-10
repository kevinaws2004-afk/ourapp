import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/plans/domain/day_edges.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Thursday, Oct 8 2026 (UTC offset 0 in these tests).
final _day = LocalDate(2026, 10, 8);

Plan _plan(
  String id, {
  LocalDate? date,
  int? hour,
  int lengthMin = 30,
  String? type,
  PlanStatus status = PlanStatus.planned,
}) {
  final d = date ?? _day;
  final start = hour == null
      ? null
      : DateTime.utc(d.year, d.month, d.day, hour);
  return Plan(
    id: PlanId(id),
    planDate: d,
    activityTypeId: type == null ? null : ActivityTypeId(type),
    title: id,
    plannedStartAt: start,
    plannedEndAt: start?.add(Duration(minutes: lengthMin)),
    sortOrder: 0,
    status: status,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

PlannedItem _item(Plan plan, EffectivePlanStatus status) =>
    PlannedItem(plan: plan, type: null, records: const [], status: status);

DayOverview _overview(List<PlannedItem> planned) => DayOverview(
  date: _day,
  planned: planned,
  records: const [],
  unplanned: const [],
);

DateTime _at(int hour, [int minute = 0]) =>
    DateTime.utc(_day.year, _day.month, _day.day, hour, minute);

void main() {
  group('from yesterday (T2)', () {
    final yesterday = _overview([
      _item(_plan('open'), EffectivePlanStatus.planned),
      _item(_plan('done'), EffectivePlanStatus.completed),
      _item(_plan('skipped'), EffectivePlanStatus.skipped),
      _item(_plan('running'), EffectivePlanStatus.inProgress),
    ]);

    test('only things neither done, skipped nor running', () {
      expect(leftFromYesterday(yesterday, 8).map((i) => i.plan.title), [
        'open',
      ]);
    });

    test('only in the morning', () {
      expect(leftFromYesterday(yesterday, 11), hasLength(1));
      expect(leftFromYesterday(yesterday, 12), isEmpty);
    });
  });

  group('evening review (T7/T8)', () {
    test('not before 17:00, even with everything done', () {
      final day = _overview([
        _item(_plan('a', hour: 7), EffectivePlanStatus.completed),
      ]);
      expect(EveningReview.of(day, nowUtc: _at(16, 59), localHour: 16), isNull);
      expect(EveningReview.of(day, nowUtc: _at(17), localHour: 17), isNotNull);
    });

    test('not while the last planned thing is still ahead and some are '
        'open', () {
      final day = _overview([
        _item(_plan('a', hour: 7), EffectivePlanStatus.planned),
        _item(_plan('b', hour: 20), EffectivePlanStatus.planned),
      ]);
      expect(EveningReview.of(day, nowUtc: _at(18), localHour: 18), isNull);
      final late = EveningReview.of(day, nowUtc: _at(21), localHour: 21)!;
      expect(late.unfinished.map((i) => i.plan.title), ['a', 'b']);
      expect(late.closed, isFalse);
    });

    test('everything decided opens it early (from 17:00) and closes it', () {
      final day = _overview([
        _item(_plan('a', hour: 7), EffectivePlanStatus.completed),
        _item(_plan('b', hour: 21), EffectivePlanStatus.skipped),
      ]);
      final review = EveningReview.of(day, nowUtc: _at(17), localHour: 17)!;
      expect(review.closed, isTrue);
      expect((review.progress.done, review.progress.total), (1, 1));
    });

    test('only Anytime things open: no end to pass, so it waits', () {
      final day = _overview([_item(_plan('a'), EffectivePlanStatus.planned)]);
      expect(EveningReview.of(day, nowUtc: _at(22), localHour: 22), isNull);
    });

    test('nothing planned, or something running: none', () {
      expect(
        EveningReview.of(_overview(const []), nowUtc: _at(20), localHour: 20),
        isNull,
      );
      final running = _overview([
        _item(_plan('a', hour: 7), EffectivePlanStatus.inProgress),
      ]);
      expect(EveningReview.of(running, nowUtc: _at(20), localHour: 20), isNull);
    });
  });

  group('your usual weekday (T10)', () {
    int? minute(Plan p) => p.plannedStartAt == null
        ? null
        : p.plannedStartAt!.hour * 60 + p.plannedStartAt!.minute;

    test('the same weekday in the last four weeks, most frequent first, at '
        'its most frequent time', () {
      final plans = [
        for (final weeks in [1, 2, 3])
          _plan(
            'gym$weeks',
            date: _day.addDays(-7 * weeks),
            hour: weeks == 3 ? 6 : 7,
            type: 'gym',
          ),
        _plan('read', date: _day.addDays(-7), type: 'read'),
        _plan('read-wed', date: _day.addDays(-1), type: 'read'),
        _plan('old', date: _day.addDays(-35), type: 'old'),
        _plan(
          'skipped',
          date: _day.addDays(-14),
          type: 'swim',
          status: PlanStatus.skipped,
        ),
        _plan('today', date: _day, type: 'today'),
      ];
      final usual = usualForWeekday(plans, _day, minute);
      expect(usual.map((u) => u.activityTypeId.value), ['gym', 'read']);
      expect(usual.first.startMinute, 7 * 60);
      expect(usual.last.startMinute, isNull, reason: 'Anytime');
    });
  });
}
