import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../focus/domain/focus_session.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/icons/activity_icon_registry.dart';
import '../../../core/design/keys/activity_icon_ids.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../../shared/widgets/done_check.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/domain/watch_records_for_day.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../focus/presentation/focus_screen.dart';
import '../../notifications/data/reminder_store.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_actions.dart';
import '../../plans/presentation/plan_formatting.dart';
import '../../plans/presentation/widgets/planned_list.dart';

/// Today's day as a timeline: the time on the left, each thing as a colored
/// node on one line (filled once done), its name, a detail line and a
/// status chip; a NOW marker where the present falls. Things without a
/// time follow as a checklist ("Anytime").
///
/// Hold an open thing and drag it to move it: between timed things it
/// takes the time that fits (asked first), into Anytime it loses its time
/// (asked first), among Anytime ones it just takes its place
/// ([handlePlanDrop]). Held and let go without moving, it shows the quick
/// actions.
class TodayTimeline extends ConsumerStatefulWidget {
  const TodayTimeline({
    super.key,
    required this.overview,
    required this.onOpenItem,
    required this.onOpenRecord,
  });

  final DayOverview overview;
  final ValueChanged<PlanId> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;

  @override
  ConsumerState<TodayTimeline> createState() => _TodayTimelineState();
}

class _TodayTimelineState extends ConsumerState<TodayTimeline> {
  /// The plan picked up, and where from.
  PlannedItem? _held;
  int _heldAt = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider).nowUtc();
    final entries = widget.overview.entries;
    bool untimed(DayEntry e) =>
        e is PlanEntry &&
        e.item.plan.plannedStartAt == null &&
        e.item.records.isEmpty;
    final timed = entries.where((e) => !untimed(e)).toList();
    final anytime = entries.where(untimed).cast<PlanEntry>().toList();

    DateTime timeOf(DayEntry e) => switch (e) {
      PlanEntry(:final item) =>
        item.plan.plannedStartAt ?? item.records.firstOrNull?.startedAt ?? now,
      RecordEntry(:final record) => record.log.startedAt,
    };
    final nowAt = switch (timed.indexWhere((e) => timeOf(e).isAfter(now))) {
      -1 => timed.length,
      final i => i,
    };

    final rows = <Object>[
      for (final (i, entry) in timed.indexed) ...[
        if (i == nowAt) const DropNowRow(),
        entry,
      ],
      if (nowAt == timed.length && timed.isNotEmpty) const DropNowRow(),
      if (anytime.isNotEmpty) const DropHeadingRow(),
      ...anytime,
    ];

    Widget draggable(int index, PlannedItem item, Widget child) => item.isOpen
        ? ReorderableDelayedDragStartListener(index: index, child: child)
        : child;

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderStart: (index) {
        final row = rows[index];
        _held = row is PlanEntry ? row.item : null;
        _heldAt = index;
      },
      onReorderEnd: (index) {
        final held = _held;
        // Held and let go where it was: the quick actions, as a long-press
        // does everywhere else. (Dropped next to itself counts as there.)
        if (held != null && (index == _heldAt || index == _heldAt + 1)) {
          unawaited(PlanActions(context, ref).quickActions(held));
        }
        _held = null;
      },
      onReorderItem: (oldIndex, newIndex) {
        if (oldIndex == newIndex) return;
        unawaited(
          handlePlanDrop(context, ref, rows, oldIndex, newIndex, timeOf),
        );
      },
      proxyDecorator: (child, _, _) => Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: AppRadius.mdAll,
        child: child,
      ),
      children: [
        for (final (index, row) in rows.indexed)
          switch (row) {
            DropNowRow() => _NowMarker(key: const ValueKey('now'), now: now),
            DropHeadingRow() => Padding(
              key: const ValueKey('anytime'),
              padding: EdgeInsets.only(
                top: timed.isEmpty ? 0 : AppSpacing.lg,
                bottom: AppSpacing.sm,
                left: AppSpacing.xs,
              ),
              child: Text(
                l10n.planAnytime.toUpperCase(),
                style: context.textStyles.labelSmall?.copyWith(
                  color: context.colors.textTertiary,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            final PlanEntry e when untimed(e) => Padding(
              key: ValueKey(e.item.plan.id),
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Material(
                color: context.colors.surfaceBase,
                borderRadius: AppRadius.mdAll,
                clipBehavior: Clip.antiAlias,
                child: draggable(
                  index,
                  e.item,
                  _AnytimeRow(item: e.item, onOpen: widget.onOpenItem),
                ),
              ),
            ),
            final DayEntry e => KeyedSubtree(
              key: switch (e) {
                PlanEntry(:final item) => ValueKey(item.plan.id),
                RecordEntry(:final record) => ValueKey(record.log.id),
              },
              child: switch (e) {
                PlanEntry(:final item) => draggable(
                  index,
                  item,
                  _TimelineRow(
                    entry: e,
                    first: e == timed.first,
                    last: e == timed.last,
                    onOpenItem: widget.onOpenItem,
                    onOpenRecord: widget.onOpenRecord,
                    dragging: item.isOpen,
                  ),
                ),
                RecordEntry() => _TimelineRow(
                  entry: e,
                  first: e == timed.first,
                  last: e == timed.last,
                  onOpenItem: widget.onOpenItem,
                  onOpenRecord: widget.onOpenRecord,
                ),
              },
            ),
            _ => SizedBox.shrink(key: ValueKey('row$index')),
          },
      ],
    );
  }
}

/// What one timeline row shows, from a plan or a record.
class _RowData {
  const _RowData({
    required this.title,
    required this.type,
    required this.time,
    required this.endTime,
    required this.detail,
    required this.status,
    required this.tone,
    required this.done,
    required this.faded,
    required this.onTap,
    this.onToggle,
    this.onLongPress,
    this.streak,
    this.reminder = false,
  });

  final String title;
  final ActivityType? type;
  final String? time;
  final String? endTime;
  final String? detail;
  final String? status;
  final StatusTone tone;
  final bool done;
  final bool faded;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onLongPress;
  final int? streak;

  /// It has a reminder set.
  final bool reminder;
}

class _TimelineRow extends ConsumerWidget {
  const _TimelineRow({
    required this.entry,
    required this.first,
    required this.last,
    required this.onOpenItem,
    required this.onOpenRecord,
    this.dragging = false,
  });

  /// Held to drag: the hold no longer opens the quick actions itself.
  final bool dragging;

  final DayEntry entry;
  final bool first;
  final bool last;
  final ValueChanged<PlanId> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;

  _RowData _data(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final streaks = ref.watch(activityStreaksProvider);
    switch (entry) {
      case RecordEntry(:final record):
        final DayRecord(:log, :type) = record;
        final logged = summarizeLog(context, type, log);
        return _RowData(
          title: type.name,
          type: type,
          time: material.formatTimeOfDay(
            TimeOfDay.fromDateTime(log.startedAt.toLocal()),
          ),
          endTime: null,
          detail: logged.isNotEmpty
              ? logged
              : log.durationMs == null
              ? null
              : formatDuration(l10n, log.durationMs!),
          status: l10n.statusRecorded,
          tone: StatusTone.done,
          done: true,
          faded: false,
          streak: streaks[type.id]?.days,
          onTap: () => onOpenRecord(log),
        );
      case PlanEntry(:final item):
        final plan = item.plan;
        final actions = PlanActions(context, ref);
        final status = item.status;
        final done = status == EffectivePlanStatus.completed;
        final running = status == EffectivePlanStatus.inProgress;
        final inactive =
            status == EffectivePlanStatus.skipped ||
            status == EffectivePlanStatus.cancelled;
        final doneTime = material.formatTimeOfDay(
          TimeOfDay.fromDateTime(plan.updatedAt.toLocal()),
        );
        String? detail;
        if (running) {
          ref.watch(focusTickProvider);
          final session = ref.watch(activeFocusSessionProvider).value;
          ref.watch(minuteTickProvider);
          final now = ref.watch(clockProvider).nowUtc();
          detail = session == null
              ? null
              : sessionLine(l10n, session, now, short: true);
        } else if (done) {
          final result = formatItemResult(context, item);
          // When it was ticked off; without a planned time it goes in the
          // time column instead.
          final at = l10n.doneAtTime(doneTime);
          detail = plan.plannedStartAt == null
              ? (result == l10n.planStatusDone ? null : result)
              : (result == l10n.planStatusDone ? at : '$result · $at');
        } else if (!inactive) {
          detail = switch (plan.plannedLengthMs) {
            final ms? => formatDuration(l10n, ms),
            null => null,
          };
        }
        final (String?, StatusTone) chip = switch (status) {
          EffectivePlanStatus.completed => (
            l10n.planStatusDone,
            StatusTone.done,
          ),
          EffectivePlanStatus.inProgress => (
            _paused(ref) ? l10n.focusPaused : l10n.planStatusInProgress,
            StatusTone.active,
          ),
          EffectivePlanStatus.skipped => (
            l10n.planStatusSkipped,
            StatusTone.neutral,
          ),
          EffectivePlanStatus.cancelled => (
            l10n.planStatusCancelled,
            StatusTone.neutral,
          ),
          _ => (null, StatusTone.neutral),
        };
        return _RowData(
          title: plan.title,
          type: item.type,
          // Done without a planned time: when it was done.
          time: formatPlanStart(context, plan) ?? (done ? doneTime : null),
          endTime: formatPlanEnd(context, plan),
          detail: detail,
          status: chip.$1,
          tone: chip.$2,
          done: done,
          faded: inactive,
          streak: item.type == null ? null : streaks[item.type!.id]?.days,
          reminder:
              item.isOpen &&
              reminderFor(
                    plan,
                    ref.watch(remindersProvider).value ?? const {},
                  ) !=
                  null,
          onTap: () => onOpenItem(plan.id),
          onToggle: PlanActions.canToggleDone(item)
              ? () => unawaited(actions.toggleDone(item))
              : null,
          onLongPress: () => unawaited(actions.quickActions(item)),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final d = _data(context, ref);
    final activity = context.tokens.activity(
      ActivityColorKey.fromName(d.type?.colorKey ?? '') ??
          ActivityColorKey.slate,
    );
    final lineColor = c.textTertiary.withValues(alpha: 0.22);
    const node = 40.0;

    return Opacity(
      opacity: d.faded ? 0.5 : 1,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: d.onTap,
        onLongPress: dragging ? null : d.onLongPress,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time.
              SizedBox(
                width: 58,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.time case final t?)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            t,
                            maxLines: 1,
                            style: context.textStyles.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: d.done ? c.textTertiary : c.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      if (d.endTime case final e?)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            e,
                            maxLines: 1,
                            style: context.textStyles.labelSmall?.copyWith(
                              color: c.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Rail and node.
              SizedBox(
                width: node,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (!(first && last))
                      Positioned(
                        top: first ? AppSpacing.sm + node / 2 : 0,
                        bottom: last ? null : 0,
                        height: last ? AppSpacing.sm + node / 2 : null,
                        child: Container(width: 2, color: lineColor),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Container(
                        width: node,
                        height: node,
                        decoration: BoxDecoration(
                          color: d.done ? activity.solid : activity.soft,
                          borderRadius: BorderRadius.circular(node * 0.34),
                          border: Border.all(color: c.surfaceCanvas, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          d.done
                              ? AppIcons.check
                              : d.type == null
                              ? AppIcons.browse
                              : ActivityIconRegistry.resolve(
                                  d.type?.iconId ?? ActivityIconIds.fallback,
                                ),
                          size: 18,
                          color: d.done ? c.surfaceBase : activity.solid,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Content.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm + 2,
                    bottom: AppSpacing.lg + 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              d.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: d.done ? c.textSecondary : null,
                              ),
                            ),
                          ),
                          if (d.reminder) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              AppIcons.bellOn,
                              size: 13,
                              color: c.brandPrimary,
                            ),
                          ],
                          if (d.streak case final s?) ...[
                            const SizedBox(width: AppSpacing.xs),
                            StreakBadge(days: s, compact: true),
                          ],
                        ],
                      ),
                      if (d.detail != null || d.status != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          // The detail moves under the chip on a narrow
                          // row (large text).
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xxs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (d.status case final s?)
                                StatusChip(label: s, tone: d.tone),
                              if (d.detail case final t?)
                                Text(
                                  t,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (d.onToggle != null || d.done)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DoneCheck(
                      done: d.done,
                      color: activity.solid,
                      onPressed: d.onToggle,
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

/// A task with no time: a checklist row.
class _AnytimeRow extends ConsumerWidget {
  const _AnytimeRow({required this.item, required this.onOpen});

  final PlannedItem item;
  final ValueChanged<PlanId> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final done = item.status == EffectivePlanStatus.completed;
    final actions = PlanActions(context, ref);
    final type = item.type;
    final activity = context.tokens.activity(
      ActivityColorKey.fromName(type?.colorKey ?? '') ?? ActivityColorKey.slate,
    );
    return InkWell(
      onTap: () => onOpen(item.plan.id),
      // Open ones are held to drag (the quick actions show when let go).
      onLongPress: item.isOpen
          ? null
          : () => unawaited(actions.quickActions(item)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xxs,
          AppSpacing.lg,
          AppSpacing.xxs,
        ),
        child: Row(
          children: [
            DoneCheck(
              done: done,
              color: type == null ? c.textSecondary : activity.solid,
              onPressed: PlanActions.canToggleDone(item)
                  ? () => unawaited(actions.toggleDone(item))
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                item.plan.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: done ? c.textTertiary : null,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: c.textTertiary,
                ),
              ),
            ),
            if (!done &&
                reminderFor(
                      item.plan,
                      ref.watch(remindersProvider).value ?? const {},
                    ) !=
                    null) ...[
              Icon(AppIcons.bellOn, size: 13, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (item.status == EffectivePlanStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _RunningLabel(color: c.brandPrimary),
              ),
            if (done)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(item.plan.updatedAt.toLocal()),
                  ),
                  style: context.textStyles.labelSmall?.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ),
            if (type != null)
              Icon(
                ActivityIconRegistry.resolve(type.iconId),
                size: 16,
                color: activity.solid,
              ),
          ],
        ),
      ),
    );
  }
}

/// "NOW 5:00 PM": a line across the timeline at the present.
class _NowMarker extends StatelessWidget {
  const _NowMarker({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(now.toLocal()));
    return Semantics(
      label: l10n.nowLine(time),
      excludeSemantics: true,
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                l10n.nowNextNow.toUpperCase(),
                style: context.textStyles.labelSmall?.copyWith(
                  color: c.brandPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: c.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surfaceCanvas, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(child: Container(height: 2, color: c.brandPrimary)),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                time,
                style: context.textStyles.labelSmall?.copyWith(
                  color: c.brandPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Running · 12:04" for the item whose timer is on, ticking.
class _RunningLabel extends ConsumerWidget {
  const _RunningLabel({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(focusTickProvider);
    final session = ref.watch(activeFocusSessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider).nowUtc();
    return Text(
      sessionLine(AppLocalizations.of(context), session, now),
      style: context.textStyles.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Whether the running thing's timer is paused (on a break).
bool _paused(WidgetRef ref) =>
    ref.watch(activeFocusSessionProvider).value?.state == FocusState.paused;
