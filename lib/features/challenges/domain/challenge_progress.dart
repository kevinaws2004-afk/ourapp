import 'dart:math' as math;

import '../../../core/time/local_date.dart';
import 'challenge.dart';

/// Where a challenge stands today (ADR-044).
enum ChallengeToday {
  /// The current period (today, or this week) already counts.
  done,

  /// The current period doesn't count yet, and a streak is running that it
  /// could extend: it would break if the period ends without it.
  atRisk,

  /// The current period doesn't count yet and no streak is running (a
  /// fresh start, or after a missed period).
  notYet,

  /// The target is reached.
  completed,
}

/// The Monday of [date]'s week (weeks run Monday to Sunday).
LocalDate weekStartOf(LocalDate date) => date.addDays(-(date.weekday - 1));

/// Progress and streak of a goal, worked out from the days its activity was
/// done and, for amount goals, how much was done each day (pure; ADR-044,
/// ADR-047). They are different things:
///
/// - **Progress** is the number of successful periods (days, or weeks)
///   since the start, out of [targetDays]. A missed period never lowers it.
/// - **Current streak** is the run of consecutive successful periods
///   ending now (or with the previous period while the current one is still
///   open). A missed period resets only this; a daily goal's rest days
///   (up to `restDays` misses a week) don't.
/// - **Best streak** is the longest such run.
///
/// 20 days done, one missed, the next day done: progress 21, current streak
/// 1, best streak 20 (or 22 with a rest day a week).
class ChallengeProgress {
  const ChallengeProgress._({
    required this.targetDays,
    required this.daysDone,
    required this.currentStreak,
    required this.bestStreak,
    required this.doneToday,
    required this.completedOn,
    required this.doneDays,
    required this.period,
    required this.periodValue,
    required this.periodTarget,
    required this.restedDays,
  });

  /// Works out the progress as of [today]. [doneDays] are the local days
  /// the activity was done (any outside the goal are ignored); [amounts]
  /// how much was done per day, for amount goals (milliseconds of time, or
  /// a field's canonical total). Only days from [startDate] to [today]
  /// count.
  factory ChallengeProgress.compute({
    required Iterable<LocalDate> doneDays,
    required LocalDate startDate,
    required LocalDate today,
    required int targetDays,
    GoalKind kind = GoalKind.daily,
    int? timesPerWeek,
    double? amount,
    GoalPeriod? amountPeriod,
    Map<LocalDate, double> amounts = const {},
    int restDays = 0,
  }) {
    bool inRange(LocalDate d) =>
        d.compareTo(startDate) >= 0 && d.compareTo(today) <= 0;
    final days = {
      for (final d in doneDays)
        if (inRange(d)) d,
    };
    final period = switch (kind) {
      GoalKind.daily => GoalPeriod.day,
      GoalKind.weekly => GoalPeriod.week,
      GoalKind.amount => amountPeriod ?? GoalPeriod.day,
    };
    final threshold = switch (kind) {
      GoalKind.daily => 1.0,
      GoalKind.weekly => (timesPerWeek ?? 1).toDouble(),
      GoalKind.amount => amount ?? 1,
    };
    double valueOn(LocalDate d) => switch (kind) {
      GoalKind.amount => amounts[d] ?? 0,
      _ => days.contains(d) ? 1 : 0,
    };

    // Every period from the start to today, oldest first: its value and,
    // once reached, the day it was.
    final periods = <_Period>[];
    if (startDate.compareTo(today) <= 0) {
      var first = period == GoalPeriod.day ? startDate : weekStartOf(startDate);
      while (first.compareTo(today) <= 0) {
        final length = period == GoalPeriod.day ? 1 : 7;
        var value = 0.0;
        LocalDate? reachedOn;
        for (var i = 0; i < length; i++) {
          final d = first.addDays(i);
          if (!inRange(d)) continue;
          value += valueOn(d);
          if (reachedOn == null && value >= threshold) reachedOn = d;
        }
        periods.add(_Period(first, value, reachedOn));
        first = first.addDays(length);
      }
    }

    // Rest days: a daily goal's first misses each week, up to restDays, keep
    // the streak (today is still open, so it's never one).
    final rested = <LocalDate>{};
    if (kind == GoalKind.daily && restDays > 0) {
      final usedByWeek = <LocalDate, int>{};
      for (final p in periods) {
        if (p.success || p.start == today) continue;
        final week = weekStartOf(p.start);
        final used = usedByWeek[week] ?? 0;
        if (used < restDays) {
          usedByWeek[week] = used + 1;
          rested.add(p.start);
        }
      }
    }

    var best = 0;
    var run = 0;
    for (final (i, p) in periods.indexed) {
      final open = i == periods.length - 1;
      if (p.success) {
        run++;
      } else if (rested.contains(p.start) || open) {
        // Neither counts nor breaks.
      } else {
        run = 0;
      }
      best = math.max(best, run);
    }

    var current = 0;
    for (var i = periods.length - 1; i >= 0; i--) {
      final p = periods[i];
      if (p.success) {
        current++;
      } else if (rested.contains(p.start) ||
          i == periods.length - 1 && !p.success) {
        continue;
      } else {
        break;
      }
    }

    final successes = [
      for (final p in periods)
        if (p.success) p,
    ];
    final last = periods.lastOrNull;
    return ChallengeProgress._(
      targetDays: targetDays,
      daysDone: successes.length,
      currentStreak: current,
      bestStreak: best,
      doneToday: last?.success ?? false,
      completedOn: successes.length >= targetDays
          ? successes[targetDays - 1].reachedOn
          : null,
      doneDays: Set.unmodifiable(days),
      period: period,
      periodValue: last?.value ?? 0,
      periodTarget: threshold,
      restedDays: Set.unmodifiable(rested),
    );
  }

  /// Successful periods (days or weeks) that complete the goal.
  final int targetDays;

  /// Every successful period since the start (not capped).
  final int daysDone;
  final int currentStreak;
  final int bestStreak;

  /// Whether the current period (today, or this week) already counts.
  final bool doneToday;

  /// The day the target-th successful period was reached.
  final LocalDate? completedOn;

  /// The days the activity was done (from the start to today), for a
  /// calendar.
  final Set<LocalDate> doneDays;

  /// What one step of progress is: a day or a week.
  final GoalPeriod period;

  /// How far the current period is: days done this week, or the amount so
  /// far today or this week (ms of time, or a field's canonical total).
  final double periodValue;

  /// What the current period needs to count.
  final double periodTarget;

  /// Missed days a daily goal's rest days covered.
  final Set<LocalDate> restedDays;

  /// Successful periods toward the target: "21 / 75" (capped).
  int get progress => math.min(daysDone, targetDays);

  int get daysLeft => math.max(0, targetDays - daysDone);

  /// 0 to 1, for a progress bar.
  double get fraction => targetDays == 0 ? 0 : progress / targetDays;

  /// 0 to 1: how far the current period is.
  double get periodFraction =>
      periodTarget <= 0 ? 0 : math.min(1, periodValue / periodTarget);

  bool get isCompleted => daysDone >= targetDays;

  ChallengeToday get today {
    if (isCompleted) return ChallengeToday.completed;
    if (doneToday) return ChallengeToday.done;
    return currentStreak > 0 ? ChallengeToday.atRisk : ChallengeToday.notYet;
  }
}

class _Period {
  _Period(this.start, this.value, this.reachedOn);

  final LocalDate start;
  final double value;
  final LocalDate? reachedOn;

  bool get success => reachedOn != null;
}
