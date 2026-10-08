import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/challenges/domain/challenge_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Progress and streak are two different things (ADR-044): progress is the
/// total of successful days; only the streak is broken by a missed day.
void main() {
  final start = LocalDate(2026, 9, 1);

  /// `count` consecutive days from [from].
  List<LocalDate> run(LocalDate from, int count) => [
    for (var i = 0; i < count; i++) from.addDays(i),
  ];

  ChallengeProgress compute(
    Iterable<LocalDate> days, {
    required LocalDate today,
    int target = 75,
    LocalDate? startDate,
  }) => ChallengeProgress.compute(
    doneDays: days,
    startDate: startDate ?? start,
    today: today,
    targetDays: target,
  );

  test('20 days done, one missed, the next day done: progress 21 / 75, '
      'current streak 1, best streak 20 (the owner\'s example)', () {
    final days = [...run(start, 20), start.addDays(21)]; // Sep 1–20, Sep 22
    final p = compute(days, today: start.addDays(21));

    expect(p.progress, 21, reason: 'a missed day never lowers progress');
    expect(p.daysDone, 21);
    expect(p.currentStreak, 1, reason: 'only the streak restarts');
    expect(p.bestStreak, 20);
    expect(p.daysLeft, 54);
    expect(p.today, ChallengeToday.done);
  });

  test('every day done: progress, current and best streak all agree', () {
    final p = compute(run(start, 12), today: start.addDays(11));

    expect((p.progress, p.currentStreak, p.bestStreak), (12, 12, 12));
    expect(p.fraction, closeTo(12 / 75, 1e-9));
  });

  group('today still open', () {
    test('doesn\'t break a streak that ran up to yesterday: it is at risk', () {
      final p = compute(run(start, 12), today: start.addDays(12));

      expect(p.currentStreak, 12);
      expect(p.doneToday, isFalse);
      expect(p.today, ChallengeToday.atRisk);
      expect(p.progress, 12);
    });

    test('with no streak running there is nothing at risk', () {
      final p = compute(run(start, 5), today: start.addDays(8)); // 2 missed

      expect(p.currentStreak, 0);
      expect(p.today, ChallengeToday.notYet);
      expect(p.bestStreak, 5);
      expect(p.progress, 5, reason: 'progress stays');
    });

    test('a brand new challenge starts at not-yet-today', () {
      final p = compute(const [], today: start, startDate: start);

      expect((p.progress, p.currentStreak, p.bestStreak), (0, 0, 0));
      expect(p.today, ChallengeToday.notYet);
    });
  });

  group('a missed day', () {
    test('once the day has ended, the streak is 0 but progress and the best '
        'streak stay', () {
      final days = run(start, 12); // Sep 1–12
      // Sep 13 missed; it is now Sep 14 and nothing is recorded yet.
      final p = compute(days, today: start.addDays(13));

      expect(p.currentStreak, 0);
      expect(p.bestStreak, 12);
      expect(p.progress, 12);
    });

    test('several misses build separate runs; best is the longest', () {
      final days = [
        ...run(start, 3), // Sep 1–3
        ...run(start.addDays(5), 7), // Sep 6–12
        ...run(start.addDays(14), 2), // Sep 15–16
      ];
      final p = compute(days, today: start.addDays(15));

      expect(p.bestStreak, 7);
      expect(p.currentStreak, 2);
      expect(p.progress, 12);
    });

    test('recording a forgotten day heals the streak (it is derived)', () {
      final broken = [...run(start, 5), ...run(start.addDays(6), 3)];
      expect(compute(broken, today: start.addDays(8)).currentStreak, 3);

      final healed = [...broken, start.addDays(5)];
      final p = compute(healed, today: start.addDays(8));
      expect((p.currentStreak, p.bestStreak, p.progress), (9, 9, 9));
    });
  });

  group('which days count', () {
    test('days before the start and after today are ignored', () {
      final startDate = LocalDate(2026, 9, 10);
      final days = [
        LocalDate(2026, 9, 8), // before the challenge
        LocalDate(2026, 9, 9),
        LocalDate(2026, 9, 10),
        LocalDate(2026, 9, 11),
        LocalDate(2026, 9, 20), // after "today"
      ];
      final p = compute(
        days,
        today: LocalDate(2026, 9, 11),
        startDate: startDate,
      );

      expect((p.progress, p.currentStreak, p.bestStreak), (2, 2, 2));
    });

    test('several records on one day are one day', () {
      final p = compute([start, start, start], today: start);

      expect(p.progress, 1);
    });

    test('streaks cross month and year ends', () {
      final startDate = LocalDate(2026, 12, 30);
      final days = run(startDate, 5); // Dec 30 – Jan 3
      final p = compute(
        days,
        today: LocalDate(2027, 1, 3),
        startDate: startDate,
      );

      expect((p.currentStreak, p.bestStreak), (5, 5));
    });
  });

  group('completed', () {
    test('reached when the total hits the target, even after misses', () {
      final days = [...run(start, 3), ...run(start.addDays(5), 4)]; // 7 days
      final p = compute(days, today: start.addDays(10), target: 7);

      expect(p.isCompleted, isTrue);
      expect(p.today, ChallengeToday.completed);
      expect(p.completedOn, start.addDays(8), reason: 'the 7th day done');
      expect(p.progress, 7);
    });

    test('progress is capped at the target; the streak keeps counting', () {
      final p = compute(run(start, 10), today: start.addDays(9), target: 7);

      expect(p.progress, 7);
      expect(p.daysDone, 10);
      expect(p.daysLeft, 0);
      expect(p.fraction, 1);
      expect(p.currentStreak, 10);
    });

    test('not completed one day short', () {
      final p = compute(run(start, 6), today: start.addDays(5), target: 7);

      expect(p.isCompleted, isFalse);
      expect(p.completedOn, isNull);
      expect(p.daysLeft, 1);
    });
  });
}
