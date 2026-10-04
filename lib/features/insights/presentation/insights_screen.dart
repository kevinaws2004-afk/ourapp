import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/insight.dart';
import '../domain/insight_repository.dart';
import 'chart_builder_sheet.dart';
import 'insight_chart_card.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';

/// Insights tab (§24–26; FR-AN-01…09): each activity's days, time and count
/// for the range against the previous one, opening its automatic progress
/// page (ADR-037), then the user's own charts (any activity, field, set
/// volume, body measurement or plan).
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key, required this.onOpenActivity});

  /// Opens an activity's automatic progress page (ADR-037).
  final ValueChanged<ActivityTypeId> onOpenActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final range = ref.watch(insightRangeProvider);
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.chart),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.giant,
            ),
            children: [
              Text(l10n.navInsights, style: context.textStyles.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final r in InsightRange.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(rangeLabel(l10n, r)),
                          selected: r == range,
                          onSelected: (_) =>
                              ref.read(insightRangeProvider.notifier).select(r),
                        ),
                      ),
                  ],
                ),
              ),
              SectionHeader(title: l10n.insightActivitySection),
              _ActivityTotals(onOpenActivity: onOpenActivity),
              SectionHeader(
                title: l10n.insightChartsSection,
                trailing: IconButton(
                  tooltip: l10n.insightAddChart,
                  icon: const Icon(AppIcons.add),
                  onPressed: () => showChartBuilder(context),
                ),
              ),
              const _Charts(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTotals extends ConsumerWidget {
  const _ActivityTotals({required this.onOpenActivity});

  final ValueChanged<ActivityTypeId> onOpenActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final types = ref.watch(activeActivityTypesProvider).value ?? const [];
    return AsyncValueView<
      (Map<ActivityTypeId, ActivityTotals>, Map<ActivityTypeId, ActivityTotals>)
    >(
      value: ref.watch(activityTotalsProvider),
      onRetry: () => ref.invalidate(activityTotalsProvider),
      data: (data) {
        final (current, previous) = data;
        final rows = [
          for (final type in types)
            if (current[type.id] case final totals?) (type, totals),
        ]..sort((a, b) => b.$2.durationMs.compareTo(a.$2.durationMs));
        if (rows.isEmpty) {
          return Text(
            l10n.insightNoActivity,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          );
        }
        return Column(
          children: [
            for (final (type, totals) in rows)
              _TotalsRow(
                type: type,
                totals: totals,
                previous: previous[type.id],
                onTap: () => onOpenActivity(type.id),
              ),
          ],
        );
      },
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.type,
    required this.totals,
    required this.onTap,
    this.previous,
  });

  final ActivityType type;
  final ActivityTotals totals;
  final ActivityTotals? previous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = previous?.durationMs ?? 0;
    final change = base == 0 || totals.durationMs == 0
        ? null
        : (totals.durationMs - base) / base;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
      title: Text(type.name),
      subtitle: Text(
        [
          l10n.insightDaysDone(totals.days),
          if (totals.durationMs > 0) formatDuration(l10n, totals.durationMs),
          l10n.insightTimesRecorded(totals.count),
        ].join(' · '),
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (change != null)
            Text(
              l10n.insightChange(formatChange(change)),
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          const Icon(AppIcons.chevron),
        ],
      ),
    );
  }
}

class _Charts extends ConsumerWidget {
  const _Charts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncValueView<List<InsightChartConfig>>(
      value: ref.watch(insightChartsProvider),
      onRetry: () => ref.invalidate(insightChartsProvider),
      data: (charts) => charts.isEmpty
          ? AppEmptyState(
              icon: AppIcons.insights.outline,
              title: l10n.insightChartsEmptyTitle,
              message: l10n.insightChartsEmptyMessage,
              action: AppButton(
                label: l10n.insightAddChart,
                icon: AppIcons.add,
                onPressed: () => showChartBuilder(context),
              ),
            )
          : Column(
              children: [
                for (final chart in charts)
                  InsightChartCard(
                    key: ValueKey(chart.id),
                    chart: chart,
                    onEdit: () => showChartBuilder(context, initial: chart),
                    onDelete: () async {
                      try {
                        await ref.read(deleteInsightChartProvider)(chart.id);
                      } catch (error) {
                        if (context.mounted) {
                          showMessageSnackBar(
                            context,
                            errorMessage(l10n, error),
                          );
                        }
                        return;
                      }
                      if (!context.mounted) return;
                      showUndoSnackBar(
                        context,
                        message: l10n.insightChartDeleted,
                        onUndo: () => unawaited(
                          ref.read(saveInsightChartProvider)(chart),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
