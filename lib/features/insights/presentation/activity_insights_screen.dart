import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/auto_insights.dart';
import '../domain/insight.dart';
import 'insight_chart_card.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';
import 'insight_range_picker.dart';

/// One activity's progress, worked out automatically (ADR-037): days done,
/// time and how often in the range against the previous one, then a chart
/// for its time, its numbers, and each row of its lists (e.g. each
/// exercise's best weight and volume). Nobody builds these charts.
class ActivityInsightsScreen extends ConsumerWidget {
  const ActivityInsightsScreen({super.key, required this.typeId});

  final ActivityTypeId typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final type = ref.watch(activityTypeProvider(typeId)).value;
    final range = ref.watch(insightRangeProvider);
    return Scaffold(
      appBar: AppBar(
        title: type == null
            ? null
            : Row(
                children: [
                  ActivityBadge(
                    iconId: type.iconId,
                    colorKey: type.colorKey,
                    size: AppSizes.badgeSmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(type.name, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.chart),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.md,
              margin,
              AppSpacing.giant,
            ),
            children: [
              const InsightRangePicker(),
              const SizedBox(height: AppSpacing.lg),
              _Summary(typeId: typeId),
              SectionHeader(title: l10n.insightProgressSection),
              AsyncValueView<List<AutoChart>>(
                value: ref.watch(autoChartsProvider(typeId)),
                onRetry: () => ref.invalidate(autoChartsProvider(typeId)),
                data: (charts) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final chart in charts)
                      InsightChartCard(
                        chart: _titled(l10n, chart, range),
                        hideWhenEmpty: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The chart with its title, in buckets that fit [range] (A20).
  static InsightChartConfig _titled(
    AppLocalizations l10n,
    AutoChart chart,
    InsightRange range,
  ) {
    final field = chart.fieldName ?? '';
    final row = chart.rowName;
    final title = switch (chart.kind) {
      AutoChartKind.time => l10n.insightAutoTime,
      AutoChartKind.count => l10n.insightAutoCount,
      AutoChartKind.value => field,
      AutoChartKind.best =>
        row == null
            ? l10n.insightAutoBest(field)
            : l10n.insightAutoRowBest(field, row),
      AutoChartKind.volume =>
        row == null ? l10n.insightAutoVolume : l10n.insightAutoRowVolume(row),
    };
    final c = chart.config;
    return InsightChartConfig(
      id: c.id,
      title: title,
      source: c.source,
      aggregation: c.aggregation,
      bucket: range.bucket,
      kind: c.kind,
    );
  }
}

/// "4 days · 3h 20m · 5 times · +12 %" for the range.
class _Summary extends ConsumerWidget {
  const _Summary({required this.typeId});

  final ActivityTypeId typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(activityTypeProvider(typeId)).value;
    final totals = ref.watch(activityTotalsProvider);
    return AsyncValueView(
      value: totals,
      onRetry: () => ref.invalidate(activityTotalsProvider),
      data: (data) {
        final (current, previous) = data;
        final now = current[typeId];
        if (now == null) {
          return Text(
            l10n.insightActivityEmpty(type?.name ?? ''),
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          );
        }
        final before = previous[typeId]?.durationMs ?? 0;
        final change = before == 0 || now.durationMs == 0
            ? null
            : (now.durationMs - before) / before;
        return Text(
          [
            l10n.insightDaysDone(now.days),
            if (now.durationMs > 0) formatDuration(l10n, now.durationMs),
            l10n.insightTimesRecorded(now.count),
            if (change != null) l10n.insightChange(formatChange(change)),
          ].join(' · '),
          style: context.textStyles.titleMedium,
        );
      },
    );
  }
}
