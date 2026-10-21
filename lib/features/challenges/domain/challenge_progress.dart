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
    this.kind = GoalKind.daily,
    this.startValue,
    this.latestValue,
    this.targetValue,
    this.values = const {},
    this.daysToDeadline,
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
    double? startValue,
  }) {
    if (kind == GoalKind.target) {
      return ChallengeProgress._target(
        values: amounts,
        startDate: startDate,
        today: today,
        targetDays: targetDays,
        target: amount ?? 0,
        startValue: startValue,
      );
    }
    final period = switch (kind) {
      GoalKind.daily => GoalPeriod.day,
      GoalKind.weekly => GoalPeriod.week,
      GoalKind.amount => amountPeriod ?? GoalPeriod.day,
      GoalKind.target => GoalPeriod.day,
    };
    // A weekly goal counts its whole first week: started on a Tuesday after
    // a Monday session, that session still counts toward the week.
    final countFrom = period == GoalPeriod.week
        ? weekStartOf(startDate)
        : startDate;
    bool inRange(LocalDate d) =>
        d.compareTo(countFrom) >= 0 && d.compareTo(today) <= 0;
    final days = {
      for (final d in doneDays)
        if (inRange(d)) d,
    };
    final threshold = switch (kind) {
      GoalKind.daily => 1.0,
      GoalKind.weekly => (timesPerWeek ?? 1).toDouble(),
      GoalKind.amount || GoalKind.target => amount ?? 1,
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
    // The start day is free: a goal set up in the evening, after the day's
    // chance has gone, doesn't begin with a miss (or use up a rest day).
    final free = <LocalDate>{
      if (period == GoalPeriod.day &&
          periods.isNotEmpty &&
          !periods.first.success)
        periods.first.start,
    };
    final rested = <LocalDate>{};
    if (kind == GoalKind.daily && restDays > 0) {
      final usedByWeek = <LocalDate, int>{};
      for (final p in periods) {
        if (p.success || p.start == today || free.contains(p.start)) continue;
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
      } else if (rested.contains(p.start) || free.contains(p.start) || open) {
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
          free.contains(p.start) ||
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

  /// A target goal (from 80 kg down to 72 kg): no periods or streaks, just
  /// the latest value against the start and the target. [values] are the
  /// value recorded each day (the day's last), any date.
  factory ChallengeProgress._target({
    required Map<LocalDate, double> values,
    required LocalDate startDate,
    required LocalDate today,
    required int targetDays,
    required double target,
    double? startValue,
  }) {
    final dates = values.keys.where((d) => d.compareTo(today) <= 0).toList()
      ..sort();
    final before = dates.where((d) => d.compareTo(startDate) <= 0).lastOrNull;
    final since = [
      for (final d in dates)
        if (d.compareTo(startDate) >= 0) d,
    ];
    final start =
        startValue ??
        (before != null ? values[before] : null) ??
        (since.isEmpty ? null : values[since.first]);
    final latest = since.isEmpty ? start : values[since.last];
    final down = start != null && target < start;
    bool reached(double v) => down ? v <= target : v >= target;
    final completedOn = since.where((d) => reached(values[d]!)).firstOrNull;
    final deadline = startDate.addDays(targetDays - 1);
    return ChallengeProgress._(
      targetDays: targetDays,
      daysDone: since.length,
      currentStreak: 0,
      bestStreak: 0,
      doneToday: values.containsKey(today),
      completedOn: completedOn,
      doneDays: Set.unmodifiable(since),
      period: GoalPeriod.day,
      periodValue: latest ?? 0,
      periodTarget: target,
      restedDays: const {},
      kind: GoalKind.target,
      startValue: start,
      latestValue: latest,
      targetValue: target,
      values: Map.unmodifiable({for (final d in since) d: values[d]!}),
      daysToDeadline: math.max(0, today.daysUntil(deadline) + 1),
    );
  }

  final GoalKind kind;

  /// Target goals: where it started, where it is now and where it's going
  /// (the field's canonical unit). Null until anything is known.
  final double? startValue;
  final double? latestValue;
  final double? targetValue;

  /// Target goals: the value recorded each day since the start.
  final Map<LocalDate, double> values;

  /// Target goals: days left until the date it's meant to be reached by,
  /// today included.
  final int? daysToDeadline;

  bool get isTarget => kind == GoalKind.target;

  /// Target goals: how far from the target still (always positive).
  double? get toGo => switch ((latestValue, targetValue)) {
    (final now?, final target?) => (now - target).abs(),
    _ => null,
  };

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

  int get daysLeft => daysToDeadline ?? math.max(0, targetDays - daysDone);

  /// 0 to 1, for a progress bar. A target goal: how much of the way from
  /// the start to the target.
  double get fraction {
    if (isTarget) {
      final (start, now, target) = (startValue, latestValue, targetValue);
      if (completedOn != null) return 1;
      if (start == null || now == null || target == null) return 0;
      if (start == target) return 1;
      return ((start - now) / (start - target)).clamp(0, 1).toDouble();
    }
    return targetDays == 0 ? 0 : progress / targetDays;
  }

  /// 0 to 1: how far the current period is.
  double get periodFraction =>
      periodTarget <= 0 ? 0 : math.min(1, periodValue / periodTarget);

  bool get isCompleted =>
      isTarget ? completedOn != null : daysDone >= targetDays;

  ChallengeToday get today {
    if (isCompleted) return ChallengeToday.completed;
    if (doneToday) return ChallengeToday.done;
    // A target goal is checked in on now and then, never "at risk".
    if (isTarget) return ChallengeToday.notYet;
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
