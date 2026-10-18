import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/challenges/domain/challenge.dart';
import 'package:daylog/features/challenges/domain/challenge_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Weekly and amount goals, and rest days (ADR-047). 2026-09-07 is a Monday.
void main() {
  final monday = LocalDate(2026, 9, 7);

  group('weekly goals', () {
    ChallengeProgress weekly(
      Iterable<LocalDate> days, {
      required LocalDate today,
      int times = 3,
      int weeks = 8,
    }) => ChallengeProgress.compute(
      doneDays: days,
      startDate: monday,
      today: today,
      targetDays: weeks,
      kind: GoalKind.weekly,
      timesPerWeek: times,
    );

    test('a week counts once it has the days; progress is in weeks', () {
      final days = [monday, monday.addDays(2), monday.addDays(4)];
      final p = weekly(days, today: monday.addDays(5));
      expect(p.period, GoalPeriod.week);
      expect(p.daysDone, 1);
      expect(p.doneToday, isTrue, reason: 'this week already counts');
      expect(p.periodValue, 3);
      expect(p.periodTarget, 3);
      expect(p.currentStreak, 1);
    });

    test('the current week still open keeps last week\'s streak', () {
      final days = [
        for (var i = 0; i < 3; i++) monday.addDays(i), // week 1 done
        monday.addDays(7), // week 2: one day so far
      ];
      final p = weekly(days, today: monday.addDays(8));
      expect(p.daysDone, 1);
      expect(p.currentStreak, 1);
      expect(p.today, ChallengeToday.atRisk);
      expect(p.periodValue, 1);
    });

    test('a missed week breaks the streak but not the progress', () {
      final days = [
        for (var i = 0; i < 3; i++) monday.addDays(i), // week 1
        monday.addDays(7), // week 2: only one day
        for (var i = 14; i < 17; i++) monday.addDays(i), // week 3
      ];
      final p = weekly(days, today: monday.addDays(20));
      expect(p.daysDone, 2);
      expect(p.currentStreak, 1);
      expect(p.bestStreak, 1);
    });

    test('completedOn is the day the last needed week was reached', () {
      final days = [
        for (var i = 0; i < 3; i++) monday.addDays(i),
        for (var i = 7; i < 10; i++) monday.addDays(i),
      ];
      final p = weekly(days, today: monday.addDays(13), weeks: 2);
      expect(p.isCompleted, isTrue);
      expect(p.completedOn, monday.addDays(9));
    });
  });

  group('amount goals', () {
    test('a day counts once its amount reaches the target', () {
      final p = ChallengeProgress.compute(
        doneDays: [monday, monday.addDays(1)],
        startDate: monday,
        today: monday.addDays(2),
        targetDays: 30,
        kind: GoalKind.amount,
        amount: 20, // pages
        amountPeriod: GoalPeriod.day,
        amounts: {
          monday: 25,
          monday.addDays(1): 12,
          monday.addDays(2): 8,
        },
      );
      expect(p.daysDone, 1, reason: '12 pages is short of 20');
      expect(p.periodValue, 8, reason: 'today so far');
      expect(p.doneToday, isFalse);
      expect(p.currentStreak, 0, reason: 'yesterday fell short');
    });

    test('a weekly amount adds up the days of the week', () {
      const hour = 3600000.0;
      final p = ChallengeProgress.compute(
        doneDays: const [],
        startDate: monday,
        today: monday.addDays(3),
        targetDays: 12,
        kind: GoalKind.amount,
        amount: 10 * hour,
        amountPeriod: GoalPeriod.week,
        amounts: {
          monday: 4 * hour,
          monday.addDays(1): 3 * hour,
          monday.addDays(3): 3.5 * hour,
        },
      );
      expect(p.period, GoalPeriod.week);
      expect(p.daysDone, 1);
      expect(p.periodValue, 10.5 * hour);
      expect(p.periodFraction, 1);
    });
  });

  group('rest days', () {
    test('one missed day a week keeps a daily streak going', () {
      // Mon–Wed done, Thu missed, Fri–Sun done.
      final days = [
        for (var i = 0; i < 3; i++) monday.addDays(i),
        for (var i = 4; i < 7; i++) monday.addDays(i),
      ];
      final with1 = ChallengeProgress.compute(
        doneDays: days,
        startDate: monday,
        today: monday.addDays(6),
        targetDays: 30,
        restDays: 1,
      );
      expect(with1.currentStreak, 6);
      expect(with1.bestStreak, 6);
      expect(with1.daysDone, 6, reason: 'a rest day isn\'t a done day');
      expect(with1.restedDays, {monday.addDays(3)});

      final without = ChallengeProgress.compute(
        doneDays: days,
        startDate: monday,
        today: monday.addDays(6),
        targetDays: 30,
      );
      expect(without.currentStreak, 3);
    });

    test('a second miss in the same week still breaks it', () {
      // Mon done, Tue missed, Wed done, Thu missed, Fri done.
      final days = [monday, monday.addDays(2), monday.addDays(4)];
      final p = ChallengeProgress.compute(
        doneDays: days,
        startDate: monday,
        today: monday.addDays(4),
        targetDays: 30,
        restDays: 1,
      );
      expect(p.currentStreak, 1);
      expect(p.bestStreak, 2);
    });
  });
}
