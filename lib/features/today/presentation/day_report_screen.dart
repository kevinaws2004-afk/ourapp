import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';

/// The waking day the report measures against: 7:00 to 23:00.
const _dayStartHour = 7;
const _wakingHours = 16;

/// What a day went into: what got done (and when), time per activity, and
/// the waking hours nothing was recorded for. Steps back and forth by day.
class DayReportScreen extends ConsumerStatefulWidget {
  const DayReportScreen({super.key, required this.date, this.onOpenItem});

  final LocalDate date;
  final ValueChanged<PlanId>? onOpenItem;

  @override
  ConsumerState<DayReportScreen> createState() => _DayReportScreenState();
}

class _DayReportScreenState extends ConsumerState<DayReportScreen> {
  late LocalDate _date = widget.date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
    final overview = ref.watch(dayOverviewProvider(_date)).value;
    final d = _date;
    final dateLabel = MaterialLocalizations.of(context)
        .formatFullDate(DateTime(d.year, d.month, d.day));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.dayReportPrevious,
            icon: const Icon(AppIcons.previous),
            onPressed: () => setState(() => _date = _date.addDays(-1)),
          ),
          IconButton(
            tooltip: l10n.dayReportNext,
            icon: const Icon(AppIcons.chevron),
            onPressed: _date == today
                ? null
                : () => setState(() => _date = _date.addDays(1)),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(margin, 0, margin, AppSpacing.xxxl),
            children: [
              ScreenHeader(
                showMark: false,
                overline: _date == today ? l10n.navToday : null,
                title: l10n.dayReportTitle,
                subtitle: dateLabel,
              ),
              if (overview == null)
                const SizedBox.shrink()
              else
                ..._report(context, l10n, overview, today, clock),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _report(
    BuildContext context,
    AppLocalizations l10n,
    DayOverview overview,
    LocalDate today,
    Clock clock,
  ) {
    final c = context.colors;
    final material = MaterialLocalizations.of(context);
    DateTime local(DateTime utc) =>
        utc.add(clock.offsetAt(utc)).copyWith(isUtc: false);
    String timeOf(DateTime utc) =>
        material.formatTimeOfDay(TimeOfDay.fromDateTime(local(utc)));

    // Time per activity, most first.
    final byType = <ActivityTypeId, (ActivityType, int)>{};
    for (final r in overview.records) {
      final ms = r.log.durationMs ?? 0;
      if (ms <= 0) continue;
      final prev = byType[r.type.id];
      byType[r.type.id] = (r.type, (prev?.$2 ?? 0) + ms);
    }
    final times = byType.values.toList()..sort((a, b) => b.$2 - a.$2);
    final tracked = times.fold(0, (sum, t) => sum + t.$2);

    // The waking hours so far (all of them for a past day).
    const fullDay = _wakingHours * Duration.millisecondsPerHour;
    var window = fullDay;
    if (_date == today) {
      final now = local(clock.nowUtc());
      final start = DateTime(now.year, now.month, now.day, _dayStartHour);
      window = now.difference(start).inMilliseconds.clamp(0, fullDay);
    }
    final untracked = (window - tracked).clamp(0, fullDay);

    // What got done, in the order it was done.
    final done = <(String, DateTime, ActivityType?, PlanId?)>[
      for (final item in overview.planned)
        if (item.status == EffectivePlanStatus.completed)
          (
            item.plan.title,
            item.records.lastOrNull?.endedAt ??
                item.records.lastOrNull?.startedAt ??
                item.plan.updatedAt,
            item.type,
            item.plan.id,
          ),
      for (final r in overview.unplanned)
        (r.type.name, r.log.endedAt ?? r.log.startedAt, r.type, null),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    final notDone = [
      for (final item in overview.planned)
        if (item.status != EffectivePlanStatus.completed) item,
    ];
    final planned = overview.planned.length;
    final plannedDone = planned - notDone.length;

    Color colorOf(ActivityType? type) => type == null
        ? c.textTertiary
        : context.tokens
              .activity(
                ActivityColorKey.fromName(type.colorKey) ??
                    ActivityColorKey.slate,
              )
              .solid;

    Widget stat(String label, String value, {Color? dot}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.numericMedium.copyWith(
              fontSize: 18,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xl,
        0,
        AppSpacing.sm,
      ),
      child: Text(text, style: context.textStyles.titleMedium),
    );

    final scale = (tracked + untracked) == 0 ? 1 : tracked + untracked;
    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.dayReportTrackedLabel,
              style: context.textStyles.labelLarge?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              tracked == 0
                  ? l10n.dayReportNothingTracked
                  : formatDuration(l10n, tracked),
              style: context.textStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            // The day as one bar: each activity's share, then untracked.
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: SizedBox(
                height: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (type, ms) in times)
                      Expanded(
                        flex: (ms * 1000 ~/ scale).clamp(1, 1000),
                        child: ColoredBox(color: colorOf(type)),
                      ),
                    if (untracked > 0 || times.isEmpty)
                      Expanded(
                        flex: times.isEmpty
                            ? 1
                            : (untracked * 1000 ~/ scale).clamp(1, 1000),
                        child: ColoredBox(color: c.borderStrong),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                stat(
                  l10n.dayReportDone,
                  planned == 0
                      ? '${done.length}'
                      : l10n.dayReportDoneOf(plannedDone, planned),
                  dot: c.success,
                ),
                stat(
                  l10n.dayReportUntracked,
                  formatDuration(l10n, untracked),
                  dot: c.borderStrong,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _date == today
                  ? l10n.dayReportUntrackedHintToday
                  : l10n.dayReportUntrackedHint(_wakingHours),
              style: context.textStyles.bodySmall?.copyWith(
                color: c.textTertiary,
              ),
            ),
          ],
        ),
      ),
      if (times.isNotEmpty) ...[
        sectionTitle(l10n.dayReportByActivity),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              for (final (type, ms) in times)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      ActivityBadge(
                        iconId: type.iconId,
                        colorKey: type.colorKey,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    type.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textStyles.titleSmall,
                                  ),
                                ),
                                Text(
                                  formatDuration(l10n, ms),
                                  style: context.textStyles.labelLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius: AppRadius.pillAll,
                              child: LinearProgressIndicator(
                                value: ms / times.first.$2,
                                minHeight: 6,
                                color: colorOf(type),
                                backgroundColor: c.surfaceSunken,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
      sectionTitle(l10n.dayReportDoneSection),
      if (done.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            l10n.dayReportNothingDone,
            style: context.textStyles.bodyMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
        )
      else
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (final (title, at, type, planId) in done)
                ListTile(
                  leading: Icon(AppIcons.check, color: colorOf(type)),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    timeOf(at),
                    style: context.textStyles.labelLarge?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  onTap: planId == null || widget.onOpenItem == null
                      ? null
                      : () => widget.onOpenItem!(planId),
                ),
            ],
          ),
        ),
      if (notDone.isNotEmpty) ...[
        sectionTitle(l10n.dayReportNotDoneSection),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (final item in notDone)
                ListTile(
                  leading: Icon(
                    item.status == EffectivePlanStatus.skipped
                        ? AppIcons.skip
                        : AppIcons.time,
                    color: c.textTertiary,
                  ),
                  title: Text(
                    item.plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    switch (item.status) {
                      EffectivePlanStatus.skipped => l10n.planStatusSkipped,
                      EffectivePlanStatus.cancelled => l10n.planStatusCancelled,
                      EffectivePlanStatus.inProgress =>
                        l10n.planStatusInProgress,
                      _ => l10n.dayReportOpen,
                    },
                    style: context.textStyles.labelLarge?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  onTap: widget.onOpenItem == null
                      ? null
                      : () => widget.onOpenItem!(item.plan.id),
                ),
            ],
          ),
        ),
      ],
    ];
  }
}
