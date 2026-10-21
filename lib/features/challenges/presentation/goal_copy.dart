import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
import '../domain/challenge.dart';
import '../domain/challenge_progress.dart';

/// What an amount goal can sum for [type]: its number and duration fields
/// (list rows included), the ones shown in Progress first.
List<ActivityField> goalAmountFields(ActivityType type) => [
  for (final f in type.fields)
    if (!f.isRemoved &&
        (f.type == FieldType.number || f.type == FieldType.duration))
      f,
]..sort((a, b) => (b.measurable ? 1 : 0).compareTo(a.measurable ? 1 : 0));

/// What a target goal can follow for [type]: its number fields, not list
/// rows (a weight, a waist size; not one set's reps).
List<ActivityField> goalTargetFields(ActivityType type) => [
  for (final f in type.fields)
    if (!f.isRemoved && f.parentId == null && f.type == FieldType.number) f,
]..sort((a, b) => (b.measurable ? 1 : 0).compareTo(a.measurable ? 1 : 0));

/// The unit an amount goal on [field] is entered and shown in: the field's
/// default unit, or none for a plain number.
Unit? goalFieldUnit(ActivityField field) {
  final config = field.config;
  if (field.dimension case final dimension?) {
    final code = config is NumberFieldConfig ? config.defaultUnitCode : null;
    return (code == null ? null : UnitRegistry.byCode(code)) ??
        UnitRegistry.canonicalFor(dimension);
  }
  return null;
}

/// [value] of an amount goal as people say it: "45m", "20 Pages", "5 km".
/// [value] is ms for time and duration fields, or the field's canonical
/// unit.
String formatGoalAmount(
  AppLocalizations l10n,
  ActivityFieldId? fieldId,
  ActivityType? type,
  double value,
) {
  final field = fieldId == null ? null : type?.fieldById(fieldId);
  if (fieldId == null || field?.type == FieldType.duration) {
    return formatDuration(l10n, value.round());
  }
  if (field == null) return formatNumber(value, 1);
  final unit = goalFieldUnit(field);
  if (unit != null) {
    return '${formatNumber(unit.fromCanonical(value), 1)} ${unit.symbol}';
  }
  return '${formatNumber(value, 1)} ${field.name.toLowerCase()}';
}

/// "3 days", "3 weeks".
String goalPeriods(AppLocalizations l10n, int count, GoalPeriod period) =>
    switch (period) {
      GoalPeriod.day => l10n.insightDaysDone(count),
      GoalPeriod.week => l10n.goalWeeks(count),
    };

/// "21 / 75 days", "3 / 8 weeks". A target goal: "78.5 kg → 72 kg" with
/// [formatValue], else "40% of the way".
String goalProgressText(
  AppLocalizations l10n,
  ChallengeProgress progress, {
  String Function(double value)? formatValue,
}) {
  if (progress.isTarget) {
    if (progress.isCompleted) return l10n.goalTargetReached;
    final (now, target) = (progress.latestValue, progress.targetValue);
    if (formatValue != null && now != null && target != null) {
      return l10n.goalTargetProgress(formatValue(now), formatValue(target));
    }
    return l10n.goalTargetPercent((progress.fraction * 100).round());
  }
  return _periodProgressText(l10n, progress);
}

String _periodProgressText(AppLocalizations l10n, ChallengeProgress progress) =>
    switch (progress.period) {
      GoalPeriod.day => l10n.challengeProgressDays(
        progress.progress,
        progress.targetDays,
      ),
      GoalPeriod.week => l10n.goalProgressWeeks(
        progress.progress,
        progress.targetDays,
      ),
    };

/// The current period of a weekly or amount goal: "This week: 2 of 3
/// days", "Today: 30m of 45m". Null for a daily goal (its state line says
/// it).
String? goalPeriodLine(
  AppLocalizations l10n,
  Challenge challenge,
  ChallengeProgress progress,
  ActivityType? type,
) {
  switch (challenge.kind) {
    case GoalKind.daily:
      return null;
    case GoalKind.target:
      final toGo = progress.toGo;
      if (progress.isCompleted || toGo == null) return null;
      return l10n.goalTargetToGo(
        formatGoalAmount(l10n, challenge.amountFieldId, type, toGo),
      );
    case GoalKind.weekly:
      return l10n.goalThisWeekDays(
        progress.periodValue.round(),
        progress.periodTarget.round(),
      );
    case GoalKind.amount:
      final done = formatGoalAmount(
        l10n,
        challenge.amountFieldId,
        type,
        progress.periodValue,
      );
      final target = formatGoalAmount(
        l10n,
        challenge.amountFieldId,
        type,
        progress.periodTarget,
      );
      return progress.period == GoalPeriod.week
          ? l10n.goalThisWeekAmount(done, target)
          : l10n.goalTodayAmount(done, target);
  }
}

/// The automatic name of a goal: "30 days of Reading", "Gym 3× a week",
/// "45m of Reading a day".
String goalAutoTitle(
  AppLocalizations l10n, {
  required GoalKind kind,
  required int target,
  required String activity,
  int? timesPerWeek,
  String? amount,
  GoalPeriod period = GoalPeriod.day,
}) => switch (kind) {
  GoalKind.daily => l10n.challengeAutoTitle(target < 1 ? 1 : target, activity),
  GoalKind.weekly => l10n.goalAutoTitleWeekly(activity, timesPerWeek ?? 1),
  GoalKind.amount =>
    period == GoalPeriod.week
        ? l10n.goalAutoTitleAmountWeek(amount ?? '', activity)
        : l10n.goalAutoTitleAmountDay(amount ?? '', activity),
  GoalKind.target => l10n.goalAutoTitleTarget(activity, amount ?? ''),
};

/// Today's state in words for a goal counted per [period].
String goalStateText(
  AppLocalizations l10n,
  ChallengeToday state,
  GoalPeriod period, {
  bool target = false,
}) => target
    ? switch (state) {
        ChallengeToday.completed => l10n.goalTargetReached,
        ChallengeToday.done => l10n.goalTargetLoggedToday,
        _ => l10n.goalTargetLogHint,
      }
    : switch ((state, period)) {
        (ChallengeToday.completed, _) => l10n.challengeCompleted,
        (ChallengeToday.done, GoalPeriod.day) => l10n.challengeTodayDone,
        (ChallengeToday.atRisk, GoalPeriod.day) => l10n.challengeTodayAtRisk,
        (ChallengeToday.notYet, GoalPeriod.day) => l10n.challengeTodayNotYet,
        (ChallengeToday.done, GoalPeriod.week) => l10n.goalWeekDone,
        (ChallengeToday.atRisk, GoalPeriod.week) => l10n.goalWeekAtRisk,
        (ChallengeToday.notYet, GoalPeriod.week) => l10n.goalWeekNotYet,
      };
