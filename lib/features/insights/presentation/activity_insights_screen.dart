import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/charts/breakdown_bars.dart';
import '../../../shared/widgets/charts/day_grid.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/auto_insights.dart';
import '../domain/insight.dart';
import '../domain/insight_use_cases.dart';
import 'insight_chart_card.dart';
import 'insight_formatting.dart';
import '../../../shared/widgets/panel_card.dart';
import 'insight_providers.dart';
import 'insight_range_picker.dart';
import 'progress_sentences.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../challenges/presentation/challenge_providers.dart';

/// One activity's progress, worked out automatically (ADR-037, ADR-043):
/// days done, time and how often against the previous period and its
/// streak; a calendar of the days it was done; when in the day it's done;
/// then a chart for its time and each of its fields by type, each row of its
/// lists (e.g. each exercise's best weight, estimated maximum, volume and
/// reps), and how often each option of its choices was picked. Nobody builds
/// these.
class ActivityInsightsScreen extends ConsumerStatefulWidget {
  const ActivityInsightsScreen({super.key, required this.typeId});

  final ActivityTypeId typeId;

  @override
  ConsumerState<ActivityInsightsScreen> createState() =>
      _ActivityInsightsScreenState();
}

class _ActivityInsightsScreenState
    extends ConsumerState<ActivityInsightsScreen> {
  /// Every list row instead of the six most used (C3).
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final typeId = widget.typeId;
    final type = ref.watch(activityTypeProvider(typeId)).value;
    final range = ref.watch(insightRangeProvider);
    final accent = type == null
        ? context.colors.brandPrimary
        : context.tokens
              .activity(
                ActivityColorKey.fromName(type.colorKey) ??
                    ActivityColorKey.slate,
              )
              .solid;
    final auto = ref.watch(
      autoChartsProvider((typeId: typeId, showAll: _showAll)),
    );
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
              if (type != null) _Sentence(type: type),
              _Summary(typeId: typeId),
              const SizedBox(height: AppSpacing.lg),
              _Consistency(typeId: typeId, color: accent),
              _WhenYouDoIt(typeId: typeId, color: accent),
              SectionHeader(title: l10n.insightProgressSection),
              AsyncValueView(
                value: auto,
                onRetry: () => ref.invalidate(autoChartsProvider),
                data: (auto) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final chart in auto.charts)
                      InsightChartCard(
                        chart: _titled(l10n, chart, range),
                        hideWhenEmpty: true,
                      ),
                    for (final breakdown in auto.breakdowns)
                      _ChoiceBreakdown(field: breakdown.field, color: accent),
                    if (auto.hasMore && !_showAll)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          label: l10n.insightShowAllRows,
                          variant: AppButtonVariant.tertiary,
                          onPressed: () => setState(() => _showAll = true),
                        ),
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
      AutoChartKind.rowValue =>
        row == null ? field : l10n.insightAutoRowValue(row, field),
      AutoChartKind.volume =>
        row == null ? l10n.insightAutoVolume : l10n.insightAutoRowVolume(row),
      AutoChartKind.estimatedMax =>
        row == null
            ? l10n.insightAutoEstimatedMax
            : l10n.insightAutoRowEstimatedMax(row),
      AutoChartKind.rowTotal =>
        row == null
            ? l10n.insightAutoTotal(field)
            : l10n.insightAutoRowTotal(row, field),
      AutoChartKind.yesShare => l10n.insightAutoYesShare(field),
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

/// "4 days · 3h 20m · 5 times · +12 %" for the range, and the streak.
class _Summary extends ConsumerWidget {
  const _Summary({required this.typeId});

  final ActivityTypeId typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(activityTypeProvider(typeId)).value;
    final totals = ref.watch(activityTotalsProvider);
    final days = ref.watch(activeDaysProvider).value?[typeId] ?? const {};
    final today = currentLocalDate(ref.watch(clockProvider));
    final streak = weekStreaks(days, today);
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    return AsyncValueView(
      value: totals,
      onRetry: () => ref.invalidate(activityTotalsProvider),
      data: (data) {
        final (current, previous) = data;
        final now = current[typeId];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (now == null)
              Text(
                l10n.insightActivityEmpty(type?.name ?? ''),
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              )
            else
              Text(
                [
                  l10n.insightDaysDone(now.days),
                  if (now.durationMs > 0) formatDuration(l10n, now.durationMs),
                  l10n.insightTimesRecorded(now.count),
                  if (activityChange(now, previous[typeId]) case final c?)
                    l10n.insightChange(formatChange(c)),
                ].join(' · '),
                style: context.textStyles.titleMedium,
              ),
            if (streak.longest > 0)
              Text(
                streak.current > 0
                    ? l10n.insightStreak(streak.current, streak.longest)
                    : l10n.insightStreakEnded(streak.longest),
                style: quiet,
              ),
          ],
        );
      },
    );
  }
}

/// The days this activity was done in the range (H1).
class _Consistency extends ConsumerWidget {
  const _Consistency({required this.typeId, required this.color});

  final ActivityTypeId typeId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ConsistencyPanel(typeId: typeId, color: color);
}

/// The calendar of days something was done in the range, for one activity
/// or all (H1).
class ConsistencyPanel extends ConsumerWidget {
  const ConsistencyPanel({
    super.key,
    required this.typeId,
    required this.color,
  });

  final ActivityTypeId? typeId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(insightRangeProvider);
    final (from, to) = range.window(currentLocalDate(ref.watch(clockProvider)));
    final counts = ref.watch(dayCountsProvider(typeId)).value;
    if (counts == null) return const SizedBox.shrink();
    final caption = l10n.insightDaysOfPeriod(counts.length, range.days);
    return PanelCard(
      title: l10n.insightConsistencySection,
      subtitle: caption,
      child: DayGrid(
        from: from,
        to: to,
        counts: counts,
        color: color,
        semanticLabel: caption,
      ),
    );
  }
}

/// When in the day this activity is usually done (morning…night).
class _WhenYouDoIt extends ConsumerWidget {
  const _WhenYouDoIt({required this.typeId, required this.color});

  final ActivityTypeId typeId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final minutes = ref.watch(startMinutesProvider(typeId)).value;
    if (minutes == null || minutes.isEmpty) return const SizedBox.shrink();
    final counts = <PartOfDay, int>{};
    for (final m in minutes) {
      final part = partOfDay(m);
      counts[part] = (counts[part] ?? 0) + 1;
    }
    String label(PartOfDay p) => switch (p) {
      PartOfDay.morning => l10n.insightMorning,
      PartOfDay.afternoon => l10n.insightAfternoon,
      PartOfDay.evening => l10n.insightEvening,
      PartOfDay.night => l10n.insightNight,
    };
    return PanelCard(
      title: l10n.insightWhenSection,
      child: BreakdownBars(
        color: color,
        entries: [
          for (final p in PartOfDay.values)
            if (counts[p] case final n?) BreakdownEntry(label(p), n),
        ],
      ),
    );
  }
}

/// How often each option of a choice field was picked in the range (B3).
class _ChoiceBreakdown extends ConsumerWidget {
  const _ChoiceBreakdown({required this.field, required this.color});

  final ActivityField field;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final picks = ref.watch(choicePicksProvider(field.id)).value;
    final options = switch (field.config) {
      SelectFieldConfig(:final options) => options,
      _ => const <SelectOption>[],
    };
    if (picks == null || picks.isEmpty || options.isEmpty) {
      return const SizedBox.shrink();
    }
    final labels = {for (final o in options) o.id.value: o.label};
    final counts = optionCounts(picks, [for (final o in options) o.id.value]);
    return PanelCard(
      title: field.name,
      subtitle: l10n.insightChoiceTimes,
      child: BreakdownBars(
        color: color,
        entries: [
          for (final (id, n) in counts)
            if (labels[id] case final label?) BreakdownEntry(label, n),
        ],
      ),
    );
  }
}

/// The activity's period in one sentence, first (PR5, ADR-046), with its 🔥
/// when it's in a running challenge.
class _Sentence extends ConsumerWidget {
  const _Sentence({required this.type});

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(activityTotalsProvider).value;
    if (data == null) return const SizedBox.shrink();
    final period = progressPeriod(l10n, ref.watch(insightRangeProvider));
    final totals = data.$1[type.id];
    final streak = ref.watch(activityStreaksProvider)[type.id];
    final sentence = totals == null
        ? l10n.progressActivityNone(type.name, period)
        : l10n.progressActivitySentence(
            type.name,
            totals.days,
            period,
            totals.count,
          );
    return Stack(
      children: [
        SentenceCard(sentence: sentence),
        if (streak != null)
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: StreakBadge(days: streak.days),
          ),
      ],
    );
  }
}
