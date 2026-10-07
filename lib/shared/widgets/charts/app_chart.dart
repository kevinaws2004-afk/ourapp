import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import 'chart_axis.dart';

/// One series for [AppChart]: a value (or a gap) per bucket.
class ChartSeries {
  const ChartSeries({required this.values, required this.color});

  final List<double?> values;
  final Color color;
}

enum AppChartKind { line, bar, stacked }

/// The app's chart (ADR-033): fl_chart behind one shared component, styled
/// only with design tokens (no default chart look). Line charts leave gaps
/// for empty buckets and fit their axis to the values (D1); bar charts
/// group several series per bucket; stacked bars pile them up. Touching a
/// point or bar shows its bucket and value (D2).
class AppChart extends StatelessWidget {
  const AppChart({
    super.key,
    required this.kind,
    required this.series,
    required this.labels,
    required this.formatValue,
    this.wholeNumbers = false,
    this.fixedMax,
    this.height = AppSizes.chartHeight,
  });

  /// A fixed top for an axis from 0 (a rating's scale, 100 %; D5).
  final double? fixedMax;

  /// Values are counts: the axis uses whole steps (A22).
  final bool wholeNumbers;

  final AppChartKind kind;
  final List<ChartSeries> series;

  /// One label per bucket (shown sparsely on the x axis).
  final List<String> labels;
  final String Function(double value) formatValue;
  final double height;

  ChartAxis get _axis {
    if (fixedMax case final top?) {
      final fitted = ChartAxis.fit(top, wholeNumbers: wholeNumbers);
      return ChartAxis(interval: fitted.interval, max: top);
    }
    double? min;
    double? max;
    if (kind == AppChartKind.stacked) {
      for (var i = 0; i < labels.length; i++) {
        final total = series.fold<double>(0, (t, s) => t + (s.values[i] ?? 0));
        if (max == null || total > max) max = total;
      }
      return ChartAxis.fit(max ?? 0, wholeNumbers: wholeNumbers);
    }
    for (final s in series) {
      for (final v in s.values) {
        if (v == null) continue;
        if (min == null || v < min) min = v;
        if (max == null || v > max) max = v;
      }
    }
    if (kind == AppChartKind.line && min != null && max != null) {
      return ChartAxis.fitRange(min, max, wholeNumbers: wholeNumbers);
    }
    return ChartAxis.fitRange(
      math.min(0, min ?? 0),
      max ?? 0,
      wholeNumbers: wholeNumbers,
    );
  }

  String _tooltip(int index, double value) =>
      index >= 0 && index < labels.length
      ? '${labels[index]}\n${formatValue(value)}'
      : formatValue(value);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.textStyles.labelSmall?.copyWith(
      color: colors.textSecondary,
    );
    final step = (labels.length / 5).ceil().clamp(1, labels.length);
    final axis = _axis;
    final titles = FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: AppSpacing.giant - AppSpacing.md,
          interval: axis.interval,
          getTitlesWidget: (value, meta) =>
              Text(formatValue(value), style: labelStyle),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: AppSpacing.xxl,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (i < 0 || i >= labels.length || i % step != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(labels[i], style: labelStyle),
            );
          },
        ),
      ),
    );
    final grid = FlGridData(
      drawVerticalLine: false,
      horizontalInterval: axis.interval,
      getDrawingHorizontalLine: (_) =>
          FlLine(color: colors.borderSubtle, strokeWidth: AppSizes.hairline),
    );
    final border = FlBorderData(show: false);

    return SizedBox(
      height: height,
      child: switch (kind) {
        AppChartKind.line => LineChart(
          LineChartData(
            minY: axis.min,
            maxY: axis.max,
            // Half a bucket either side, so a lone point still shows (D4).
            minX: -0.5,
            maxX: labels.length - 0.5,
            gridData: grid,
            borderData: border,
            titlesData: titles,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.surfaceRaised,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      _tooltip(s.x.round(), s.y),
                      context.textStyles.labelMedium!.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            lineBarsData: [
              for (final s in series)
                LineChartBarData(
                  spots: [
                    for (final (i, v) in s.values.indexed)
                      v == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), v),
                  ],
                  color: s.color,
                  barWidth: AppSizes.chartLine,
                  isCurved: false,
                  dotData: FlDotData(
                    getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                      radius: AppSizes.chartDot,
                      color: s.color,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: series.length == 1,
                    color: s.color.withValues(alpha: 0.12),
                  ),
                ),
            ],
          ),
        ),
        AppChartKind.bar || AppChartKind.stacked => BarChart(
          BarChartData(
            minY: axis.min,
            maxY: axis.max,
            gridData: grid,
            borderData: border,
            titlesData: titles,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => colors.surfaceRaised,
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  _tooltip(group.x, rod.toY),
                  context.textStyles.labelMedium!.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < labels.length; i++)
                BarChartGroupData(
                  x: i,
                  barsSpace: AppSpacing.xxs,
                  barRods: kind == AppChartKind.stacked
                      ? [_stack(i)]
                      : [
                          for (final s in series)
                            BarChartRodData(
                              toY: s.values[i] ?? 0,
                              color: s.color,
                              width: series.length == 1
                                  ? AppSpacing.md
                                  : AppSpacing.sm,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSpacing.xs),
                              ),
                            ),
                        ],
                ),
            ],
          ),
        ),
      },
    );
  }

  /// One bar with every series piled up, in order, for bucket [i].
  BarChartRodData _stack(int i) {
    final items = <BarChartRodStackItem>[];
    var top = 0.0;
    for (final s in series) {
      final v = s.values[i] ?? 0;
      if (v <= 0) continue;
      items.add(BarChartRodStackItem(top, top + v, s.color));
      top += v;
    }
    return BarChartRodData(
      toY: top,
      // Covered by the stack items; the last series colours any gap.
      color: series.isEmpty ? null : series.last.color,
      rodStackItems: items,
      width: AppSpacing.md,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.xs),
      ),
    );
  }
}
