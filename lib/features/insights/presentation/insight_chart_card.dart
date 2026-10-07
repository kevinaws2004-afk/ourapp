import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/charts/app_chart.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/insight.dart';
import '../domain/insight_use_cases.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';

ActivityTypeId? _typeOf(InsightSource source) => switch (source) {
  ActivityDurationSource(:final typeId) ||
  ActivityCountSource(:final typeId) ||
  FieldValueSource(:final typeId) ||
  VolumeSource(:final typeId) => typeId,
  PlannedVsActualSource(:final typeId) => typeId,
  MeasurementSource() => null,
};

/// One chart (saved, or worked out automatically): its headline value, change vs the previous period,
/// personal best, and the chart itself.
class InsightChartCard extends ConsumerWidget {
  const InsightChartCard({
    super.key,
    required this.chart,
    this.onEdit,
    this.onDelete,
    this.hideWhenEmpty = false,
  });

  final InsightChartConfig chart;

  /// Automatic charts with nothing in the period aren't shown (A23), e.g.
  /// "Time" for an activity that's never timed. Saved charts always show.
  final bool hideWhenEmpty;

  /// Edit/delete for a saved chart; automatic charts have neither.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final typeId = _typeOf(chart.source);
    final ActivityType? type = typeId == null
        ? null
        : ref.watch(activityTypeProvider(typeId)).value;
    final result = ref.watch(insightResultProvider(chart));
    if (hideWhenEmpty && (result.value?.isEmpty ?? false)) {
      return const SizedBox.shrink();
    }
    final accent = type == null
        ? context.colors.brandPrimary
        : context.tokens
              .activity(
                ActivityColorKey.fromName(type.colorKey) ??
                    ActivityColorKey.slate,
              )
              .solid;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceBase,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: context.colors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chart.title,
                      style: context.textStyles.titleMedium,
                    ),
                  ),
                  if (onEdit != null && onDelete != null)
                    PopupMenuButton<bool>(
                      tooltip: l10n.insightChartOptions,
                      icon: const Icon(AppIcons.more),
                      onSelected: (edit) => edit ? onEdit!() : onDelete!(),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: true,
                          child: Text(l10n.insightEdit),
                        ),
                        PopupMenuItem(
                          value: false,
                          child: Text(l10n.insightDelete),
                        ),
                      ],
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: AsyncValueView<InsightResult>(
                  value: result,
                  data: (result) => _Content(
                    chart: chart,
                    result: result,
                    display: InsightDisplay.of(
                      l10n,
                      chart.source,
                      type,
                      material: MaterialLocalizations.of(context),
                    ),
                    accent: accent,
                    itemLabel: _itemLabel(chart.source, type),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What one row of a volume's list is called ("Set"), for "Best Set".
String? _itemLabel(InsightSource source, ActivityType? type) =>
    switch ((source, type)) {
      (VolumeSource(:final groupFieldId), final type?) => switch (type
          .fieldById(groupFieldId)
          ?.config) {
        RepeatingGroupFieldConfig(:final itemLabel) => itemLabel,
        _ => null,
      },
      _ => null,
    };

class _Content extends StatelessWidget {
  const _Content({
    required this.chart,
    required this.result,
    required this.display,
    required this.accent,
    this.itemLabel,
  });

  final InsightChartConfig chart;
  final InsightResult result;
  final InsightDisplay display;
  final Color accent;
  final String? itemLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final series = result.series;
    final planned = result.plannedSeries;
    if (result.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          l10n.insightNoData,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    final current = result.currentValue;
    final change = result.change;
    String date(DataPoint p) => material.formatShortMonthDay(
      DateTime(p.date.year, p.date.month, p.date.day),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (planned != null)
          Text(
            l10n.insightPlannedVsActualSummary(
              display.format(current ?? 0),
              display.format(result.previousValue ?? 0),
            ),
            style: context.textStyles.titleSmall,
          )
        else if (current != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                display.format(current),
                style: AppTypography.numericLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  periodValueLabel(l10n, chart.aggregation),
                  style: quiet,
                ),
              ),
            ],
          ),
        if (planned == null && change != null)
          Text(l10n.insightChange(formatChange(change)), style: quiet),
        // All-time records, named for what they are (A21).
        if (result.bestDay case final day?)
          Text(
            l10n.insightBestDay(display.format(day.value), date(day)),
            style: quiet,
          ),
        if (result.personalBest case final best?)
          Text(switch ((chart.source, itemLabel)) {
            (VolumeSource(), final item?) => l10n.insightBestItem(
              item,
              display.format(best.value),
              date(best),
            ),
            _ => l10n.insightAllTimeBest(
              display.format(best.value),
              date(best),
            ),
          }, style: quiet),
        const SizedBox(height: AppSpacing.md),
        AppChart(
          kind: chart.kind == ChartKind.bar || planned != null
              ? AppChartKind.bar
              : AppChartKind.line,
          // Every bucket is whole (A2), labelled by its first day.
          labels: [
            for (final b in series.buckets)
              bucketLabel(context, b.start, result.bucket),
          ],
          formatValue: display.axis,
          wholeNumbers: display.wholeNumbers,
          fixedMax: display.fixedMax,
          series: [
            if (planned != null)
              ChartSeries(
                values: [
                  for (final b in planned.buckets)
                    b.value == null ? null : display.convert(b.value!),
                ],
                color: context.colors.borderStrong,
              ),
            ChartSeries(
              values: [
                for (final b in series.buckets)
                  b.value == null ? null : display.convert(b.value!),
              ],
              color: accent,
            ),
          ],
        ),
        if (planned != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(l10n.insightPlannedVsActualLegend, style: quiet),
          ),
      ],
    );
  }
}
