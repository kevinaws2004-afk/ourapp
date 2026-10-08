import 'dart:math' as math;

import '../../../core/time/local_date.dart';

/// Where a challenge stands today (ADR-044).
enum ChallengeToday {
  /// Today's activity is recorded.
  done,

  /// Not recorded yet today, and a streak is running that today could
  /// extend: it would break if the day ends without it.
  atRisk,

  /// Not recorded yet today and no streak running (a fresh start, or after
  /// a missed day).
  notYet,

  /// The target is reached.
  completed,
}

/// Progress and streak of a daily challenge, worked out from the days its
/// activity was done (pure; ADR-044). They are two different things:
///
/// - **Progress** is the total number of successful days since the start,
///   out of [targetDays]. A missed day never lowers it.
/// - **Current streak** is the run of consecutive successful days ending
///   today (or yesterday while today is still open). A missed day resets
///   only this.
/// - **Best streak** is the longest such run.
///
/// 20 days done, one missed, the next day done: progress 21, current streak
/// 1, best streak 20.
class ChallengeProgress {
  const ChallengeProgress._({
    required this.targetDays,
    required this.daysDone,
    required this.currentStreak,
    required this.bestStreak,
    required this.doneToday,
    required this.completedOn,
    required this.doneDays,
  });

  /// Works out the progress from [doneDays] (the local days the activity was
  /// done; any may be outside the challenge, they are ignored) as of
  /// [today]. Only days from [startDate] to [today] count.
  factory ChallengeProgress.compute({
    required Iterable<LocalDate> doneDays,
    required LocalDate startDate,
    required LocalDate today,
    required int targetDays,
  }) {
    final days = {
      for (final d in doneDays)
        if (d.compareTo(startDate) >= 0 && d.compareTo(today) <= 0) d,
    };
    final sorted = days.toList()..sort();

    var best = 0;
    var run = 0;
    for (final (i, day) in sorted.indexed) {
      run = i > 0 && sorted[i - 1].addDays(1) == day ? run + 1 : 1;
      best = math.max(best, run);
    }

    final doneToday = days.contains(today);
    // Today still open doesn't break a streak that ran up to yesterday.
    var day = doneToday ? today : today.addDays(-1);
    var current = 0;
    while (days.contains(day)) {
      current++;
      day = day.addDays(-1);
    }

    return ChallengeProgress._(
      targetDays: targetDays,
      daysDone: sorted.length,
      currentStreak: current,
      bestStreak: best,
      doneToday: doneToday,
      completedOn: sorted.length >= targetDays ? sorted[targetDays - 1] : null,
      doneDays: Set.unmodifiable(days),
    );
  }

  final int targetDays;

  /// Every successful day since the start (not capped).
  final int daysDone;
  final int currentStreak;
  final int bestStreak;
  final bool doneToday;

  /// The day the target-th successful day happened, once reached.
  final LocalDate? completedOn;

  /// The successful days counted (from the start to today), for a calendar.
  final Set<LocalDate> doneDays;

  /// Successful days toward the target: "21 / 75" (capped at the target).
  int get progress => math.min(daysDone, targetDays);

  int get daysLeft => math.max(0, targetDays - daysDone);

  /// 0 to 1, for a progress bar.
  double get fraction => targetDays == 0 ? 0 : progress / targetDays;

  bool get isCompleted => daysDone >= targetDays;

  ChallengeToday get today {
    if (isCompleted) return ChallengeToday.completed;
    if (doneToday) return ChallengeToday.done;
    return currentStreak > 0 ? ChallengeToday.atRisk : ChallengeToday.notYet;
  }
}
