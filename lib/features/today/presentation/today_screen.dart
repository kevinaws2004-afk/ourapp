import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../focus/presentation/focus_banner.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../plans/presentation/widgets/plan_quick_add.dart';
import '../../plans/presentation/widgets/planned_list.dart';

/// Today tab (ADR-035): a greeting, a quick way to add to the day (planned,
/// or "Now" to log it straight away), and the day's items in time order.
/// Opening an item is where you log into it.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenFocus,
  });

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Returns to the running timer's item.
  final VoidCallback onOpenFocus;

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
              const SizedBox(height: AppSpacing.lg),
              PlanQuickAdd(
                key: ValueKey(today),
                date: today,
                onStartNow: onOpenItem,
              ),
              const SizedBox(height: AppSpacing.md),
              AsyncValueView<DayOverview>(
                value: ref.watch(dayOverviewProvider(today)),
                onRetry: () => ref.invalidate(dayOverviewProvider(today)),
                data: (overview) => _TodayItems(
                  overview: overview,
                  today: today,
                  onOpenItem: onOpenItem,
                  onOpenRecord: onOpenRecord,
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

class _TodayItems extends StatelessWidget {
  const _TodayItems({
    required this.overview,
    required this.today,
    required this.onOpenItem,
    required this.onOpenRecord,
  });

  final DayOverview overview;
  final LocalDate today;
  final ValueChanged<PlanId> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    final entries = overview.entries;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Text(l10n.todayEmptyMessageItems, style: quiet),
      );
    }
    final done = entries
        .where(
          (e) => switch (e) {
            PlanEntry(:final item) =>
              item.status == EffectivePlanStatus.completed,
            RecordEntry() => true,
          },
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (done > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              overview.recordedMs > 0
                  ? l10n.todayDoneSummary(
                      done,
                      formatDuration(l10n, overview.recordedMs),
                    )
                  : l10n.todayDoneCount(done),
              style: quiet,
            ),
          ),
        PlannedList(
          entries: entries,
          onOpenItem: (item) => onOpenItem(item.plan.id),
          onOpenRecord: onOpenRecord,
        ),
      ],
    );
  }
}
