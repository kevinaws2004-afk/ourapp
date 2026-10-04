import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/plan.dart';
import '../domain/watch_day_overview.dart';
import 'plan_date_notifier.dart';
import 'plan_editor_sheet.dart';
import 'plan_providers.dart';
import 'widgets/planned_list.dart';

/// How the Plan tab shows the selected date (ADR-036, A1). A single day
/// opens on its own screen.
enum PlanView { week, month }

final planViewProvider = NotifierProvider<PlanViewNotifier, PlanView>(
  PlanViewNotifier.new,
);

class PlanViewNotifier extends Notifier<PlanView> {
  @override
  PlanView build() => PlanView.week;

  void show(PlanView view) => state = view;
}

/// The first day of [date]'s week, by the locale's first day of the week.
LocalDate weekStartOf(BuildContext context, LocalDate date) {
  // firstDayOfWeekIndex: 0 = Sunday; LocalDate.weekday: Monday = 1 … 7.
  final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return date.addDays(-((date.weekday % 7 - first) % 7));
}

/// Week | Month.
class PlanViewSwitch extends ConsumerWidget {
  const PlanViewSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<PlanView>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: PlanView.week, label: Text(l10n.planViewWeek)),
        ButtonSegment(value: PlanView.month, label: Text(l10n.planViewMonth)),
      ],
      selected: {ref.watch(planViewProvider)},
      onSelectionChanged: (s) =>
          ref.read(planViewProvider.notifier).show(s.single),
    );
  }
}

/// A row with previous / title / next, for the week and month views.
class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({
    required this.title,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    this.onToday,
  });

  final String title;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: previousTooltip,
          icon: const Icon(AppIcons.previous),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.titleLarge,
          ),
        ),
        IconButton(
          tooltip: nextTooltip,
          icon: const Icon(AppIcons.chevron),
          onPressed: onNext,
        ),
        if (onToday != null)
          TextButton(onPressed: onToday, child: Text(l10n.planToday)),
      ],
    );
  }
}

/// Seven days, each with its items (ADR-036). Tapping a day's heading opens
/// that day; "+" plans something on it.
class PlanWeekView extends ConsumerWidget {
  const PlanWeekView({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenDay,
  });

  final ValueChanged<PlanId> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;
  final ValueChanged<LocalDate> onOpenDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final selected = ref.watch(planSelectedDateProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    final notifier = ref.read(planSelectedDateProvider.notifier);
    final start = weekStartOf(context, selected);
    final end = start.addDays(6);
    DateTime d(LocalDate x) => DateTime(x.year, x.month, x.day);
    final containsToday =
        today.compareTo(start) >= 0 && today.compareTo(end) <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodHeader(
          title: l10n.planTimeRange(
            material.formatShortMonthDay(d(start)),
            material.formatShortMonthDay(d(end)),
          ),
          previousTooltip: l10n.planPreviousWeek,
          nextTooltip: l10n.planNextWeek,
          onPrevious: () => notifier.shiftDays(-7),
          onNext: () => notifier.shiftDays(7),
          onToday: containsToday ? null : notifier.goToToday,
        ),
        for (var i = 0; i < 7; i++)
          _WeekDay(
            date: start.addDays(i),
            isToday: start.addDays(i) == today,
            onOpenItem: onOpenItem,
            onOpenRecord: onOpenRecord,
            onOpenDay: onOpenDay,
          ),
      ],
    );
  }
}

class _WeekDay extends ConsumerWidget {
  const _WeekDay({
    required this.date,
    required this.isToday,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenDay,
  });

  final LocalDate date;
  final bool isToday;
  final ValueChanged<PlanId> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;
  final ValueChanged<LocalDate> onOpenDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final heading = context.textStyles.titleMedium?.copyWith(
      color: isToday ? context.colors.brandPrimary : null,
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: () => onOpenDay(date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      material.formatFullDate(
                        DateTime(date.year, date.month, date.day),
                      ),
                      style: heading,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.planNewTitle,
                icon: const Icon(AppIcons.add),
                onPressed: () => unawaited(showPlanEditor(context, date: date)),
              ),
            ],
          ),
          AsyncValueView<DayOverview>(
            value: ref.watch(dayOverviewProvider(date)),
            onRetry: () => ref.invalidate(dayOverviewProvider(date)),
            data: (overview) {
              final entries = overview.entries;
              if (entries.isEmpty) {
                return Text(
                  l10n.planWeekEmptyDay,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                );
              }
              return PlannedList(
                entries: entries,
                onOpenItem: (item) => onOpenItem(item.plan.id),
                onOpenRecord: onOpenRecord,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A month calendar with a dot per planned item (ADR-036). Tapping a day
/// opens it.
class PlanMonthView extends ConsumerWidget {
  const PlanMonthView({super.key, required this.onOpenDay});

  final ValueChanged<LocalDate> onOpenDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final selected = ref.watch(planSelectedDateProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    final notifier = ref.read(planSelectedDateProvider.notifier);
    final first = LocalDate(selected.year, selected.month, 1);
    final gridStart = weekStartOf(context, first);
    final nextMonth = DateTime(selected.year, selected.month + 1);
    final last = LocalDate(nextMonth.year, nextMonth.month, 1).addDays(-1);
    final weeks = (gridStart.daysUntil(last) ~/ 7) + 1;
    final gridEnd = gridStart.addDays(weeks * 7 - 1);
    final plans = ref.watch(plansInRangeProvider((gridStart, gridEnd)));
    final types = {
      for (final t
          in ref.watch(activeActivityTypesProvider).value ??
              const <ActivityType>[])
        t.id: t,
    };
    final byDate = <LocalDate, List<Plan>>{};
    for (final plan in plans.value ?? const <Plan>[]) {
      byDate.putIfAbsent(plan.planDate, () => []).add(plan);
    }

    void moveMonths(int months) {
      final target = DateTime(selected.year, selected.month + months);
      notifier.select(LocalDate(target.year, target.month, 1));
    }

    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        material.narrowWeekdays[gridStart.addDays(i).weekday % 7],
    ];
    final thisMonth =
        today.year == selected.year && today.month == selected.month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodHeader(
          title: material.formatMonthYear(
            DateTime(selected.year, selected.month),
          ),
          previousTooltip: l10n.planPreviousWeek,
          nextTooltip: l10n.planNextWeek,
          onPrevious: () => moveMonths(-1),
          onNext: () => moveMonths(1),
          onToday: thisMonth ? null : notifier.goToToday,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        for (var w = 0; w < weeks; w++)
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _MonthDay(
                    date: gridStart.addDays(w * 7 + i),
                    inMonth:
                        gridStart.addDays(w * 7 + i).month == selected.month,
                    isToday: gridStart.addDays(w * 7 + i) == today,
                    dotColors: [
                      for (final plan
                          in byDate[gridStart.addDays(w * 7 + i)] ??
                              const <Plan>[])
                        _dotColor(
                          context,
                          types[plan.activityTypeId]?.colorKey,
                        ),
                    ],
                    onTap: () => onOpenDay(gridStart.addDays(w * 7 + i)),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static Color _dotColor(BuildContext context, String? colorKey) =>
      colorKey == null
      ? context.colors.textTertiary
      : context.tokens
            .activity(
              ActivityColorKey.fromName(colorKey) ?? ActivityColorKey.slate,
            )
            .solid;
}

class _MonthDay extends StatelessWidget {
  const _MonthDay({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.dotColors,
    required this.onTap,
  });

  static const _maxDots = 4;

  final LocalDate date;
  final bool inMonth;
  final bool isToday;
  final List<Color> dotColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context)
          .formatFullDate(DateTime(date.year, date.month, date.day)),
      value: '${dotColors.length}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: SizedBox(
          height: AppSizes.dayCell,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: isToday
                      ? colors.brandPrimary
                      : inMonth
                      ? colors.textPrimary
                      : colors.textTertiary,
                  fontWeight: isToday ? FontWeight.w700 : null,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final color in dotColors.take(_maxDots))
                    Container(
                      width: AppSizes.monthDot,
                      height: AppSizes.monthDot,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
