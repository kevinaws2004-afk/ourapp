import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/presentation/day_record_tile.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../focus/presentation/focus_banner.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../plans/presentation/widgets/planned_list.dart';

/// Today tab (ui_guidelines.md §4.1; FR-TD-01…05): a time-of-day greeting,
/// today's plan with Start / check actions, each plan paired with what was
/// recorded for it (planned vs actual), and what was recorded without a plan.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onOpenRecord,
    required this.onRecordPlan,
    required this.onTrackPlan,
    required this.onPlanDay,
    required this.onQuickRecord,
    required this.onOpenFocus,
  });

  /// Returns to the running focus session.
  final VoidCallback onOpenFocus;
  final ValueChanged<ActivityLog> onOpenRecord;
  final ValueChanged<PlannedItem> onRecordPlan;

  /// Sets up what to track for a task plan, then records it (ADR-030).
  final ValueChanged<PlannedItem> onTrackPlan;

  /// Opens the Plan tab on today.
  final VoidCallback onPlanDay;
  final VoidCallback onQuickRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
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
              Text(
                _greeting(l10n, clock),
                style: context.textStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(DateTime(today.year, today.month, today.day)),
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              FocusBanner(onOpen: onOpenFocus),
              AsyncValueView<DayOverview>(
                value: ref.watch(dayOverviewProvider(today)),
                onRetry: () => ref.invalidate(dayOverviewProvider(today)),
                data: (overview) => _TodayContent(
                  overview: overview,
                  onOpenRecord: onOpenRecord,
                  onRecordPlan: onRecordPlan,
                  onTrackPlan: onTrackPlan,
                  onPlanDay: onPlanDay,
                  onQuickRecord: onQuickRecord,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting(AppLocalizations l10n, Clock clock) {
    final now = clock.nowUtc();
    final hour = now.add(clock.offsetAt(now)).hour;
    return switch (hour) {
      < 5 => l10n.todayGreetingEvening,
      < 12 => l10n.todayGreetingMorning,
      < 18 => l10n.todayGreetingAfternoon,
      _ => l10n.todayGreetingEvening,
    };
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.overview,
    required this.onOpenRecord,
    required this.onRecordPlan,
    required this.onTrackPlan,
    required this.onPlanDay,
    required this.onQuickRecord,
  });

  final DayOverview overview;
  final ValueChanged<ActivityLog> onOpenRecord;
  final ValueChanged<PlannedItem> onRecordPlan;

  /// Sets up what to track for a task plan, then records it (ADR-030).
  final ValueChanged<PlannedItem> onTrackPlan;
  final VoidCallback onPlanDay;
  final VoidCallback onQuickRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (overview.planned.isEmpty && overview.records.isEmpty) {
      return AppEmptyState(
        icon: AppIcons.today.outline,
        title: l10n.todayEmptyTitle,
        message: l10n.todayEmptyMessage,
        action: AppButton(
          label: l10n.todayPlanYourDay,
          icon: AppIcons.plan.outline,
          onPressed: onPlanDay,
        ),
        secondaryAction: AppButton(
          label: l10n.todayRecordSomething,
          variant: AppButtonVariant.secondary,
          icon: AppIcons.record,
          onPressed: onQuickRecord,
        ),
      );
    }
    final quiet = context.textStyles.bodyLarge?.copyWith(
      color: context.colors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (overview.records.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            overview.recordedMs > 0
                ? l10n.todaySummary(
                    overview.records.length,
                    formatDuration(l10n, overview.recordedMs),
                  )
                : l10n.todaySummaryCount(overview.records.length),
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
        SectionHeader(
          title: l10n.todayPlanSection,
          trailing: TextButton(
            onPressed: onPlanDay,
            child: Text(l10n.todayEditPlan),
          ),
        ),
        if (overview.planned.isEmpty)
          Text(l10n.todayNothingPlanned, style: quiet)
        else
          PlannedList(
            items: overview.planned,
            onRecord: onRecordPlan,
            onOpenRecord: onOpenRecord,
            onTrack: onTrackPlan,
          ),
        SectionHeader(
          title: overview.planned.isEmpty
              ? l10n.planRecordedSection
              : l10n.planAlsoRecordedSection,
          // Unplanned activities are recorded here (Quick Record, FR-LG-06).
          trailing: TextButton.icon(
            icon: const Icon(AppIcons.record),
            label: Text(l10n.todayRecordSomething),
            onPressed: onQuickRecord,
          ),
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
    );
  }
}
