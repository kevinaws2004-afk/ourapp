import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/charts/app_chart.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/insight.dart';
import '../domain/insight_use_cases.dart';
import 'insight_formatting.dart';
import '../../../shared/widgets/panel_card.dart';
import '../../../shared/widgets/streak_badge.dart';
import 'insight_providers.dart';

/// Where your time went (H2): recorded time per bucket, a stacked bar per
/// activity in its own colour, with a legend of the biggest ones.
class TimeByActivityPanel extends ConsumerWidget {
  const TimeByActivityPanel({super.key});

  /// Activities named in the legend; the rest are counted.
  static const _legendSize = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(timeByActivityProvider).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();
    final range = ref.watch(insightRangeProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    final (from, to) = range.window(today);
    final types = {
      for (final t
          in ref.watch(activeActivityTypesProvider).value ??
              const <ActivityType>[])
        t.id: t,
    };
    final byType = <ActivityTypeId, List<DataPoint>>{};
    for (final r in rows) {
      byType
          .putIfAbsent(r.typeId, () => [])
          .add(
            DataPoint(r.date, r.durationMs / Duration.millisecondsPerMinute),
          );
    }
    final totals = {
      for (final MapEntry(:key, :value) in byType.entries)
        key: value.fold<double>(0, (t, p) => t + p.value),
    };
    final order = byType.keys.toList()
      ..sort((a, b) => totals[b]!.compareTo(totals[a]!));
    Color colorOf(ActivityTypeId id) => context.tokens
        .activity(
          ActivityColorKey.fromName(types[id]?.colorKey ?? '') ??
              ActivityColorKey.slate,
        )
        .solid;
    final serieses = {
      for (final id in order)
        id: buildSeries(
          byType[id]!,
          from: from,
          to: to,
          bucket: range.bucket,
          aggregation: Aggregation.sum,
        ),
    };
    final buckets = serieses.values.first.buckets;
    final display = InsightDisplay.of(
      l10n,
      const ActivityDurationSource(ActivityTypeId('')),
      null,
    );
    return PanelCard(
      title: l10n.insightTimeByActivitySection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppChart(
            kind: AppChartKind.stacked,
            labels: [
              for (final b in buckets)
                bucketLabel(context, b.start, range.bucket),
            ],
            formatValue: display.axis,
            wholeNumbers: true,
            series: [
              for (final id in order)
                ChartSeries(
                  values: [for (final b in serieses[id]!.buckets) b.value],
                  color: colorOf(id),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              for (final id in order.take(_legendSize))
                _LegendItem(
                  color: colorOf(id),
                  label:
                      '${types[id]?.name ?? ''} · '
                      '${formatDuration(l10n, (totals[id]! * Duration.millisecondsPerMinute).round())}',
                ),
              if (order.length > _legendSize)
                Text(
                  l10n.insightActivityLegendMore(order.length - _legendSize),
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSizes.monthDot * 2,
        height: AppSizes.monthDot * 2,
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.xsAll),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(label, style: context.textStyles.labelMedium),
    ],
  );
}

/// Plan vs reality (H3): the share of planned items done in the period,
/// against the period before, and per bucket.
class PlanAdherencePanel extends ConsumerWidget {
  const PlanAdherencePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final days = ref.watch(planAdherenceProvider).value;
    if (days == null) return const SizedBox.shrink();
    final range = ref.watch(insightRangeProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    final (from, to) = range.window(today);
    final (prevFrom, prevTo) = range.previous(today);
    ({int planned, int done}) sum(LocalDate a, LocalDate b) {
      var planned = 0;
      var done = 0;
      for (final d in days) {
        if (d.date.compareTo(a) < 0 || d.date.compareTo(b) > 0) continue;
        planned += d.planned;
        done += d.done;
      }
      return (planned: planned, done: done);
    }

    final now = sum(from, to);
    final before = sum(prevFrom, prevTo);
    if (now.planned == 0 && before.planned == 0) return const SizedBox.shrink();
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    if (now.planned == 0) {
      return PanelCard(
        title: l10n.insightPlanSection,
        child: Text(l10n.insightPlanEmpty, style: quiet),
      );
    }
    double share(({int planned, int done}) s) => s.done / s.planned;
    final change = before.planned == 0 ? null : share(now) - share(before);
    final bucketed = planShareBuckets(days, from, to, range.bucket);
    return PanelCard(
      title: l10n.insightPlanSection,
      subtitle: l10n.insightPlanDone(now.done, now.planned),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insightPercent(formatNumber(share(now) * 100, 0)),
            style: AppTypography.numericLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          if (change != null)
            Text(
              l10n.insightChange(
                l10n.insightPoints(formatSignedNumber((change * 100).round())),
              ),
              style: quiet,
            ),
          const SizedBox(height: AppSpacing.md),
          AppChart(
            kind: AppChartKind.bar,
            labels: [
              for (final (start, _) in bucketed)
                bucketLabel(context, start, range.bucket),
            ],
            formatValue: (v) => l10n.insightPercent(formatNumber(v, 0)),
            wholeNumbers: true,
            fixedMax: 100,
            series: [
              ChartSeries(
                values: [
                  for (final (_, value) in bucketed)
                    value == null ? null : value * 100,
                ],
                color: context.colors.brandPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A row of the activity list: its badge, name, numbers and streak.
class ActivityTotalsTile extends StatelessWidget {
  const ActivityTotalsTile({
    super.key,
    required this.type,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.muted = false,
    this.streak,
    this.action,
  });

  final ActivityType type;

  /// 🔥 days of a running challenge on it.
  final int? streak;

  /// A way to act on it ("Plan it").
  final Widget? action;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailing;

  /// Nothing in this period (B6): quieter, still openable.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final quiet = context.colors.textSecondary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Opacity(
        opacity: muted ? 0.6 : 1,
        child: ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
      ),
      title: Text(type.name, style: muted ? TextStyle(color: quiet) : null),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: trailing == null && streak == null && action == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (streak case final days?) StreakBadge(days: days),
                if (trailing case final t?) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    t,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: quiet,
                    ),
                  ),
                ],
                ?action,
              ],
            ),
    );
  }
}

/// The streak line of an activity, or null without any history.
String? streakText(
  AppLocalizations l10n,
  Set<LocalDate>? days,
  LocalDate today,
) {
  if (days == null || days.isEmpty) return null;
  final s = weekStreaks(days, today);
  return s.current > 0
      ? l10n.insightStreak(s.current, s.longest)
      : l10n.insightStreakEnded(s.longest);
}
