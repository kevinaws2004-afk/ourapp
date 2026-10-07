import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/insight.dart';
import '../domain/insight_repository.dart';
import '../domain/insight_use_cases.dart';
import 'chart_builder_sheet.dart';
import 'insight_chart_card.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';
import 'activity_insights_screen.dart';
import 'insight_overview.dart';
import 'insight_range_picker.dart';

/// Insights tab (§24–26; FR-AN-01…09): the period at a glance against the
/// one before, the calendar of days something was done, where the time went,
/// plan vs reality, then each activity (days, time, count, change and
/// streak; those not done this period below) opening its automatic progress
/// page (ADR-037), and the user's own charts (any activity, field, set
/// volume, body measurement or plan).
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key, required this.onOpenActivity});

  /// Opens an activity's automatic progress page (ADR-037).
  final ValueChanged<ActivityTypeId> onOpenActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
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
              const InsightRangePicker(),
              SectionHeader(title: l10n.insightSummarySection),
              const InsightSummaryTiles(),
              const SizedBox(height: AppSpacing.lg),
              ConsistencyPanel(
                typeId: null,
                color: context.colors.brandPrimary,
              ),
              const TimeByActivityPanel(),
              const PlanAdherencePanel(),
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
    final history = ref.watch(activeDaysProvider).value ?? const {};
    final today = currentLocalDate(ref.watch(clockProvider));
    return AsyncValueView<
      (Map<ActivityTypeId, ActivityTotals>, Map<ActivityTypeId, ActivityTotals>)
    >(
      value: ref.watch(activityTotalsProvider),
      onRetry: () => ref.invalidate(activityTotalsProvider),
      data: (data) {
        final (current, previous) = data;
        final rows =
            [
              for (final type in types)
                if (current[type.id] case final totals?) (type, totals),
            ]..sort((a, b) {
              // Time first, then how often, so untimed activities rank too.
              final byTime = b.$2.durationMs.compareTo(a.$2.durationMs);
              return byTime != 0 ? byTime : b.$2.count.compareTo(a.$2.count);
            });
        // Activities with history but nothing this period stay reachable
        // (B6).
        final quiet = [
          for (final type in types)
            if (current[type.id] == null && history.containsKey(type.id)) type,
        ];
        // Names used by more than one activity (A24).
        final names = <String, int>{};
        for (final (type, _) in rows) {
          final key = type.name.trim().toLowerCase();
          names[key] = (names[key] ?? 0) + 1;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rows.isEmpty)
              Text(
                l10n.insightNoActivity,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            for (final (type, totals) in rows)
              ActivityTotalsTile(
                type: type,
                subtitle: [
                  [
                    l10n.insightDaysDone(totals.days),
                    if (totals.durationMs > 0)
                      formatDuration(l10n, totals.durationMs),
                    l10n.insightTimesRecorded(totals.count),
                  ].join(' · '),
                  ?streakText(l10n, history[type.id], today),
                  if (names[type.name.trim().toLowerCase()]! > 1)
                    l10n.insightDuplicateName,
                ].join('\n'),
                trailing: switch (activityChange(totals, previous[type.id])) {
                  final c? => formatChange(c),
                  null => null,
                },
                onTap: () => onOpenActivity(type.id),
              ),
            if (quiet.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.insightNotThisPeriod,
                style: context.textStyles.labelLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              for (final type in quiet)
                ActivityTotalsTile(
                  type: type,
                  muted: true,
                  subtitle: streakText(l10n, history[type.id], today) ?? '',
                  onTap: () => onOpenActivity(type.id),
                ),
            ],
          ],
        );
      },
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
