import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/plans/domain/activity_usage.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_time_suggestions.dart';
import 'package:daylog/features/plans/domain/plan_title_match.dart';
import 'package:flutter_test/flutter_test.dart';

Plan _plan(String typeId, LocalDate date) => Plan(
  id: PlanId('$typeId-${date.toIso()}'),
  planDate: date,
  activityTypeId: ActivityTypeId(typeId),
  title: '',
  sortOrder: 0,
  status: PlanStatus.planned,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  group('time sheet suggestions (A5)', () {
    test('today offers the next half hours after now, the first being the '
        'default', () {
      expect(
        PlanTimeSuggestions.starts(isToday: true, now: LocalTime.hm(21, 8)),
        [
          LocalTime.hm(21, 30),
          LocalTime.hm(22, 0),
          LocalTime.hm(22, 30),
          LocalTime.hm(23, 0),
          LocalTime.hm(23, 30),
        ],
      );
      expect(
        PlanTimeSuggestions.starts(
          isToday: true,
          now: LocalTime.hm(9, 30),
        ).first,
        LocalTime.hm(10, 0),
        reason: 'strictly after now',
      );
    });

    test('nothing is offered past midnight', () {
      expect(
        PlanTimeSuggestions.starts(isToday: true, now: LocalTime.hm(23, 40)),
        isEmpty,
      );
    });

    test('other days offer typical times, not 9 AM only', () {
      expect(
        PlanTimeSuggestions.starts(isToday: false, now: LocalTime.hm(21, 8)),
        PlanTimeSuggestions.otherDayStarts,
      );
    });

    test('a length that would run past midnight has no end', () {
      expect(
        PlanTimeSuggestions.endAfter(LocalTime.hm(22, 0), 60),
        LocalTime.hm(23, 0),
      );
      expect(PlanTimeSuggestions.endAfter(LocalTime.hm(23, 30), 60), isNull);
    });
  });

  group('suggestions while typing (A6)', () {
    const names = ['Reading', 'Gym', 'Spanish reading club', 'Walking'];

    test(
      'names starting with the text come first, then names containing it',
      () {
        expect(suggestByName('read', names, (n) => n), [
          'Reading',
          'Spanish reading club',
        ]);
      },
    );

    test('empty text suggests nothing; the limit applies', () {
      expect(suggestByName('  ', names, (n) => n), isEmpty);
      expect(suggestByName('i', names, (n) => n, limit: 2), hasLength(2));
    });
  });

  group('recent activities (A7)', () {
    final today = LocalDate(2026, 10, 4);

    test('most used first, ties by the latest date, unused ones keep their '
        'order', () {
      final ranked = rankByUse(
        ['a', 'b', 'c', 'd'],
        [
          _plan('c', today),
          _plan('c', today.addDays(-1)),
          _plan('b', today.addDays(-3)),
          _plan('d', today),
        ],
        ActivityTypeId.new,
      );
      expect(ranked, ['c', 'd', 'b', 'a']);
    });
  });
}
