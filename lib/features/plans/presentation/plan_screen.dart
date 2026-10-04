import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/presentation/day_record_tile.dart';
import '../domain/watch_day_overview.dart';
import 'plan_date_notifier.dart';
import 'plan_editor_sheet.dart';
import 'plan_providers.dart';
import 'widgets/plan_quick_add.dart';
import 'widgets/planned_list.dart';

/// Plan tab (ADR-028, ui_guidelines.md §4.2): the date-based planning system.
/// Select any date → its plans, paired with what was actually recorded, plus
/// records that weren't planned (F3, F3a).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({
    super.key,
    required this.onOpenRecord,
    required this.onRecordPlan,
    required this.onTrackPlan,
  });

  final ValueChanged<ActivityLog> onOpenRecord;

  /// Opens the record form for an activity plan (F5).
  final ValueChanged<PlannedItem> onRecordPlan;

  /// Sets up what to track for a task plan, then records it (ADR-030).
  final ValueChanged<PlannedItem> onTrackPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final selected = ref.watch(planSelectedDateProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.giant,
            ),
            children: [
              Text(l10n.navPlan, style: context.textStyles.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              _DateHeading(selected: selected, today: today),
              const SizedBox(height: AppSpacing.md),
              _WeekStrip(selected: selected, today: today),
              SectionHeader(
                title: l10n.planPlannedSection,
                trailing: IconButton(
                  tooltip: l10n.planNewTitle,
                  icon: const Icon(AppIcons.add),
                  onPressed: () => showPlanEditor(context, date: selected),
                ),
              ),
              PlanQuickAdd(key: ValueKey(selected), date: selected),
              const SizedBox(height: AppSpacing.md),
              AsyncValueView<DayOverview>(
                value: ref.watch(dayOverviewProvider(selected)),
                onRetry: () => ref.invalidate(dayOverviewProvider(selected)),
                data: (overview) => _DayContent(
                  overview: overview,
                  showRecorded: selected.compareTo(today) <= 0,
                  onOpenRecord: onOpenRecord,
                  onRecordPlan: onRecordPlan,
                  onTrackPlan: onTrackPlan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.overview,
    required this.showRecorded,
    required this.onOpenRecord,
    required this.onRecordPlan,
    required this.onTrackPlan,
  });

  final DayOverview overview;
  final bool showRecorded;
  final ValueChanged<ActivityLog> onOpenRecord;
  final ValueChanged<PlannedItem> onRecordPlan;

  /// Sets up what to track for a task plan, then records it (ADR-030).
  final ValueChanged<PlannedItem> onTrackPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quiet = context.textStyles.bodyLarge?.copyWith(
      color: context.colors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (overview.planned.isEmpty)
          Text(l10n.planPlannedEmpty, style: quiet)
        else
          PlannedList(
            items: overview.planned,
            onRecord: onRecordPlan,
            onOpenRecord: onOpenRecord,
            onTrack: onTrackPlan,
            reorderable: true,
          ),
        if (showRecorded) ...[
          SectionHeader(
            title: overview.planned.isEmpty
                ? l10n.planRecordedSection
                : l10n.planAlsoRecordedSection,
          ),
          if (overview.unplanned.isEmpty)
            Text(
              overview.records.isEmpty
                  ? l10n.planRecordedEmpty
                  : l10n.planNothingUnplanned,
              style: quiet,
            )
          else
            for (final record in overview.unplanned)
              DayRecordTile(
                record: record,
                onTap: () => onOpenRecord(record.log),
              ),
        ],
      ],
    );
  }
}

class _DateHeading extends ConsumerWidget {
  const _DateHeading({required this.selected, required this.today});

  final LocalDate selected;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final notifier = ref.read(planSelectedDateProvider.notifier);
    final relative = switch (selected) {
      _ when selected == today => l10n.planToday,
      _ when selected == today.addDays(1) => l10n.planTomorrow,
      _ when selected == today.addDays(-1) => l10n.planYesterday,
      _ => null,
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (relative != null)
                Text(
                  relative,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.brandPrimary,
                  ),
                ),
              Text(
                material.formatFullDate(
                  DateTime(selected.year, selected.month, selected.day),
                ),
                style: context.textStyles.headlineSmall,
              ),
            ],
          ),
        ),
        if (selected != today)
          TextButton(
            onPressed: notifier.goToToday,
            child: Text(l10n.planToday),
          ),
        IconButton(
          tooltip: l10n.planChooseDate,
          icon: const Icon(AppIcons.date),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(
                selected.year,
                selected.month,
                selected.day,
              ),
              currentDate: DateTime(today.year, today.month, today.day),
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
            );
            if (picked != null) {
              notifier.select(LocalDate(picked.year, picked.month, picked.day));
            }
          },
        ),
      ],
    );
  }
}

/// Seven days around the selected date, starting on the locale's first day of
/// the week, with previous/next week controls.
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.selected, required this.today});

  final LocalDate selected;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final notifier = ref.read(planSelectedDateProvider.notifier);
    // firstDayOfWeekIndex: 0 = Sunday; LocalDate.weekday: Monday = 1 … Sunday = 7.
    final offset = (selected.weekday % 7 - material.firstDayOfWeekIndex) % 7;
    final start = selected.addDays(-offset);
    return Row(
      children: [
        IconButton(
          tooltip: l10n.planPreviousWeek,
          icon: const Icon(AppIcons.previous),
          onPressed: () => notifier.shiftDays(-7),
        ),
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              date: start.addDays(i),
              weekdayLabel:
                  material.narrowWeekdays[start.addDays(i).weekday % 7],
              isSelected: start.addDays(i) == selected,
              isToday: start.addDays(i) == today,
              onTap: () => notifier.select(start.addDays(i)),
            ),
          ),
        IconButton(
          tooltip: l10n.planNextWeek,
          icon: const Icon(AppIcons.chevron),
          onPressed: () => notifier.shiftDays(7),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.weekdayLabel,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final LocalDate date;
  final String weekdayLabel;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isSelected
        ? colors.onBrandPrimarySoft
        : colors.textPrimary;
    return Semantics(
      selected: isSelected,
      button: true,
      label: MaterialLocalizations.of(context)
          .formatFullDate(DateTime(date.year, date.month, date.day)),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.dayCell),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: isSelected ? colors.brandPrimarySoft : null,
            borderRadius: AppRadius.mdAll,
            border: isToday && !isSelected
                ? Border.all(color: colors.borderStrong)
                : null,
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekdayLabel,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
