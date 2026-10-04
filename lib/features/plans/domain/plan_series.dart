import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';

extension type const PlanSeriesId(String value) {}

/// When a repeating plan happens (ADR-036): on [weekdays] (1 = Monday …
/// 7 = Sunday) of every [intervalWeeks]th week, counted from the week of its
/// start, until [endDate] if set.
class RepeatRule {
  const RepeatRule({
    required this.weekdays,
    this.intervalWeeks = 1,
    this.endDate,
  });

  static const maxIntervalWeeks = 52;

  final Set<int> weekdays;
  final int intervalWeeks;
  final LocalDate? endDate;

  bool get isValid =>
      weekdays.isNotEmpty &&
      weekdays.every((d) => d >= 1 && d <= 7) &&
      intervalWeeks >= 1 &&
      intervalWeeks <= maxIntervalWeeks;

  /// Bit 0 = Monday … bit 6 = Sunday (storage).
  int get weekdaysMask =>
      weekdays.fold(0, (mask, day) => mask | (1 << (day - 1)));

  static Set<int> weekdaysFromMask(int mask) => {
    for (var day = 1; day <= 7; day++)
      if (mask & (1 << (day - 1)) != 0) day,
  };

  /// Whether a series starting on [start] has an occurrence on [date].
  bool occursOn(LocalDate date, LocalDate start) {
    if (date.compareTo(start) < 0) return false;
    if (endDate case final end? when date.compareTo(end) > 0) return false;
    if (!weekdays.contains(date.weekday)) return false;
    final weeks = mondayOf(start).daysUntil(mondayOf(date)) ~/ 7;
    return weeks % intervalWeeks == 0;
  }

  RepeatRule withEnd(LocalDate? end) => RepeatRule(
    weekdays: weekdays,
    intervalWeeks: intervalWeeks,
    endDate: end,
  );
}

/// The Monday of [date]'s week.
LocalDate mondayOf(LocalDate date) => date.addDays(1 - date.weekday);

/// A repeating plan (ADR-036): what each occurrence looks like, and when it
/// happens. Occurrences are ordinary plans linked to it.
class PlanSeries {
  const PlanSeries({
    required this.id,
    required this.title,
    required this.rule,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.activityTypeId,
    this.notes,
    this.startMinute,
    this.durationMs,
  });

  final PlanSeriesId id;
  final String title;
  final ActivityTypeId? activityTypeId;
  final String? notes;

  /// Local wall-clock start, as minutes after midnight; null if untimed.
  final int? startMinute;
  final int? durationMs;
  final RepeatRule rule;
  final LocalDate startDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool occursOn(LocalDate date) => rule.occursOn(date, startDate);
}
