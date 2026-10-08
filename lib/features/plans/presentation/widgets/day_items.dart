import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/domain/activity_log.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../activity_chooser.dart';
import '../plan_providers.dart';
import 'plan_quick_add.dart';
import 'planned_list.dart';

/// One day: quick add, how much is done, and the day's items (A1). Today
/// and the day screen show exactly this, so a day looks the same wherever
/// it's opened.
class DayItems extends ConsumerWidget {
  const DayItems({
    super.key,
    required this.date,
    required this.emptyMessage,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.chooser,
    this.onStartNow,
    this.emptyTitle,
    this.showSummary = true,
  });

  final LocalDate date;

  /// Shown when the day has no items.
  final String emptyMessage;

  /// With a title, the empty day is an empty-state card (Today, ADR-045).
  final String? emptyTitle;

  /// "3 done · 1 h 20 min" above the items; Today shows it in its hero.
  final bool showSummary;

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Picks an activity from the list, or makes a new one, for quick add.
  final ActivityChooser chooser;

  /// Offers "Start now" in quick add (today only).
  final ValueChanged<PlanId>? onStartNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlanQuickAdd(
          key: ValueKey(date),
          date: date,
          chooser: chooser,
          onStartNow: onStartNow,
        ),
        const SizedBox(height: AppSpacing.lg),
        AsyncValueView<DayOverview>(
          value: ref.watch(dayOverviewProvider(date)),
          onRetry: () => ref.invalidate(dayOverviewProvider(date)),
          data: (overview) => _Entries(
            overview: overview,
            emptyMessage: emptyMessage,
            emptyTitle: emptyTitle,
            showSummary: showSummary,
            onOpenItem: onOpenItem,
            onOpenRecord: onOpenRecord,
          ),
        ),
      ],
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({
    required this.overview,
    required this.emptyMessage,
    required this.emptyTitle,
    required this.showSummary,
    required this.onOpenItem,
    required this.onOpenRecord,
  });

  final DayOverview overview;
  final String emptyMessage;
  final String? emptyTitle;
  final bool showSummary;
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
      if (emptyTitle case final title?) {
        return EmptyStateCard(
          icon: AppIcons.today.outline,
          title: title,
          message: emptyMessage,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(emptyMessage, style: quiet),
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
        if (showSummary && done > 0)
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
          reorderable: true,
        ),
      ],
    );
  }
}
