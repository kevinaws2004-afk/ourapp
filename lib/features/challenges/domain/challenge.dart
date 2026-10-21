import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';

/// Stable identity of a challenge (UUIDv7 `public_id`, ADR-017).
extension type const ChallengeId(String value) {}

/// What a goal asks for (ADR-047).
enum GoalKind {
  /// Do the activity every day.
  daily('daily'),

  /// Do it on [Challenge.timesPerWeek] days of each week.
  weekly('weekly'),

  /// Do at least [Challenge.amount] of time or of a number field per day or
  /// week.
  amount('amount'),

  /// Reach [Challenge.amount] on a number field (down to 72 kg, up to
  /// 100 kg), from [Challenge.startValue], within [Challenge.targetDays]
  /// days. Recorded whenever you like: the latest value is where you are.
  target('target');

  const GoalKind(this.storageKey);

  final String storageKey;

  static GoalKind fromStorageKey(String? key) =>
      values.where((k) => k.storageKey == key).firstOrNull ?? daily;
}

/// The stretch a goal is counted over.
enum GoalPeriod {
  day('day'),
  week('week');

  const GoalPeriod(this.storageKey);

  final String storageKey;

  static GoalPeriod? fromStorageKey(String? key) =>
      values.where((p) => p.storageKey == key).firstOrNull;
}

/// A goal for one activity (ADR-044, ADR-047): "every day for 30 days",
/// "3 times a week for 8 weeks", "20 pages a day for 30 days", "10 h a week
/// for 12 weeks", "from 80 kg down to 72 kg in 12 weeks".
///
/// A challenge only points at an Activity Type; recording that activity is
/// what counts. Nothing about the days is stored here: progress and
/// streaks are worked out from the activity's logs (see
/// `ChallengeProgress`), so they can't go out of sync.
class Challenge {
  const Challenge({
    required this.id,
    required this.activityTypeId,
    required this.title,
    required this.startDate,
    required this.targetDays,
    required this.createdAt,
    required this.updatedAt,
    this.kind = GoalKind.daily,
    this.timesPerWeek,
    this.amount,
    this.amountFieldId,
    this.amountPeriod,
    this.restDays = 0,
    this.startValue,
  });

  static const maxTitleLength = 60;

  /// A goal lasts 1 to this many successful periods.
  static const maxTargetDays = 1000;

  /// Rest days a daily goal may allow per week.
  static const maxRestDays = 2;

  final ChallengeId id;
  final ActivityTypeId activityTypeId;
  final String title;

  /// The first day that counts; earlier records don't.
  final LocalDate startDate;

  /// How many successful periods complete the goal: days, or weeks when
  /// [period] is a week.
  final int targetDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  final GoalKind kind;

  /// Weekly goals: on how many days of each week.
  final int? timesPerWeek;

  /// Amount goals: the target per period, in milliseconds for time or in
  /// the field's canonical unit (ADR-020). Target goals: the value to
  /// reach.
  final double? amount;

  /// Amount goals: the number field summed; null for recorded time.
  /// Target goals: the number field followed.
  final ActivityFieldId? amountFieldId;

  /// Target goals: where it started, in the field's canonical unit.
  final double? startValue;

  /// Amount goals: per day or per week.
  final GoalPeriod? amountPeriod;

  /// Daily goals: missed days per week that don't break the streak.
  final int restDays;

  GoalPeriod get period => switch (kind) {
    GoalKind.daily => GoalPeriod.day,
    GoalKind.weekly => GoalPeriod.week,
    GoalKind.amount => amountPeriod ?? GoalPeriod.day,
    GoalKind.target => GoalPeriod.day,
  };

  Challenge copyWith({
    String? title,
    LocalDate? startDate,
    int? targetDays,
    DateTime? updatedAt,
    int? Function()? timesPerWeek,
    double? Function()? amount,
    int? restDays,
    double? Function()? startValue,
  }) => Challenge(
    id: id,
    activityTypeId: activityTypeId,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    targetDays: targetDays ?? this.targetDays,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    kind: kind,
    timesPerWeek: timesPerWeek != null ? timesPerWeek() : this.timesPerWeek,
    amount: amount != null ? amount() : this.amount,
    amountFieldId: amountFieldId,
    amountPeriod: amountPeriod,
    restDays: restDays ?? this.restDays,
    startValue: startValue != null ? startValue() : this.startValue,
  );
}

/// What the user enters to start a goal.
class ChallengeDraft {
  const ChallengeDraft({
    required this.activityTypeId,
    required this.title,
    required this.startDate,
    required this.targetDays,
    this.kind = GoalKind.daily,
    this.timesPerWeek,
    this.amount,
    this.amountFieldId,
    this.amountPeriod,
    this.restDays = 0,
    this.startValue,
  });

  final ActivityTypeId activityTypeId;
  final String title;
  final LocalDate startDate;
  final int targetDays;
  final GoalKind kind;
  final int? timesPerWeek;
  final double? amount;
  final ActivityFieldId? amountFieldId;
  final GoalPeriod? amountPeriod;
  final int restDays;
  final double? startValue;
}
