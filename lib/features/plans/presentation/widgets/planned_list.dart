import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/domain/activity_log.dart';
import '../../../activity_logs/presentation/day_record_tile.dart';
import '../../domain/watch_day_overview.dart';
import '../plan_actions.dart';
import '../plan_providers.dart';
import 'plan_item_tile.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import 'plan_time_sheet.dart';
import '../plan_date_notifier.dart';
import '../../domain/plan.dart';
import '../../domain/drop_slot.dart';
import '../../../../core/time/local_date.dart';

/// A day's items (Today, Plan tab; ADR-035): plans and records made without
/// a plan as one list, in time order, then untimed plans in manual order.
/// With [reorderable], untimed plans can be dragged (FR-PL-08).
///
/// Tapping an item opens it to log into it ([onOpenItem], or [onOpenRecord]
/// for a record without a plan). A task's check ticks it off; plan options
/// sit behind More.
class PlannedList extends ConsumerWidget {
  const PlannedList({
    super.key,
    required this.entries,
    required this.onOpenItem,
    required this.onOpenRecord,
    this.reorderable = false,
    this.nowLine = false,
    this.dragToDays = false,
  });

  final List<DayEntry> entries;
  final ValueChanged<PlannedItem> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;
  final bool reorderable;

  /// Today: a "Now · 9:10" line between what's passed and what's next.
  final bool nowLine;

  /// Plan's week (P6): open plans can be held and dropped on another day of
  /// the week strip to move them there.
  final bool dragToDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = PlanActions(context, ref);
    Widget tile(DayEntry entry, {Widget? dragHandle}) => switch (entry) {
      PlanEntry(:final item) when dragToDays && item.isOpen => DayDraggable(
        key: ValueKey(item.plan.id),
        item: item,
        onHold: () => unawaited(actions.quickActions(item)),
        child: PlanItemTile(
          item: item,
          onTap: () => onOpenItem(item),
          onToggleDone: PlanActions.canToggleDone(item)
              ? () => actions.toggleDone(item)
              : null,
          dragHandle: dragHandle,
        ),
      ),
      PlanEntry(:final item) => PlanItemTile(
        key: ValueKey(item.plan.id),
        item: item,
        onTap: () => onOpenItem(item),
        onToggleDone: PlanActions.canToggleDone(item)
            ? () => actions.toggleDone(item)
            : null,
        onLongPress: () => unawaited(actions.quickActions(item)),
        dragHandle: dragHandle,
      ),
      RecordEntry(:final record) => DayRecordTile(
        key: ValueKey(record.log.id),
        record: record,
        onTap: () => onOpenRecord(record.log),
      ),
    };

    // Untimed plans sit at the end of [entries], under "Anytime".
    bool untimedPlan(DayEntry e) => _untimed(e);
    final timed = entries.where((e) => !untimedPlan(e)).toList();
    final untimed = entries.where(untimedPlan).cast<PlanEntry>().toList();
    final l10n = AppLocalizations.of(context);
    // Untimed items get their own heading under the timed ones (A19).
    final anytime = [
      if (timed.isNotEmpty && untimed.isNotEmpty) _AnytimeHeading(),
    ];
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider).nowUtc();
    DateTime timeOf(DayEntry e) => switch (e) {
      PlanEntry(:final item) =>
        item.plan.plannedStartAt ?? item.records.firstOrNull?.startedAt ?? now,
      RecordEntry(:final record) => record.log.startedAt,
    };
    // The now line sits before the first timed thing that's still ahead.
    final nowAt = !nowLine
        ? -1
        : switch (timed.indexWhere((e) => timeOf(e).isAfter(now))) {
            -1 => timed.length,
            final i => i,
          };
    final timedTiles = [
      for (final (i, entry) in timed.indexed) ...[
        if (i == nowAt) NowLine(now: now),
        tile(entry),
      ],
      if (nowAt == timed.length && timed.isNotEmpty) NowLine(now: now),
    ];
    // Something to drag: an open plan. Timed ones too: dropped between
    // two timed things they take the time that fits there (asked first).
    final draggable = [
      for (final e in [...timed, ...untimed])
        if (e is PlanEntry && e.item.isOpen) e,
    ];
    if (!reorderable || draggable.isEmpty || entries.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...timedTiles,
          ...anytime,
          for (final entry in untimed) tile(entry),
        ],
      );
    }
    final rows = <Object>[
      for (final (i, entry) in timed.indexed) ...[
        if (i == nowAt) const DropNowRow(),
        entry,
      ],
      if (nowAt == timed.length && timed.isNotEmpty) const DropNowRow(),
      if (anytime.isNotEmpty) const DropHeadingRow(),
      ...untimed,
    ];
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) => unawaited(
        handlePlanDrop(context, ref, rows, oldIndex, newIndex, timeOf),
      ),
      children: [
        for (final (index, row) in rows.indexed)
          switch (row) {
            DropHeadingRow() => KeyedSubtree(
              key: const ValueKey('anytime-heading'),
              child: _AnytimeHeading(),
            ),
            DropNowRow() => NowLine(key: const ValueKey('now-line'), now: now),
            final DayEntry entry => tile(
              entry,
              dragHandle: entry is PlanEntry && entry.item.isOpen
                  ? ReorderableDragStartListener(
                      index: index,
                      child: Semantics(
                        label: l10n.planReorderHandle,
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Icon(AppIcons.dragHandle),
                        ),
                      ),
                    )
                  : null,
            ),
            _ => const SizedBox.shrink(),
          },
      ],
    );
  }
}

/// A plan dropped at [newIndex] of a day's draggable [rows] (entries, with
/// a [DropNowRow] and a [DropHeadingRow] where they show; [newIndex] as
/// after it was taken out).
/// Among the Anytime ones it just takes its place (a timed one asks to
/// lose its time first). Among the timed ones it gets the time that fits
/// between its new neighbours, asked first, or is told it doesn't fit.
Future<void> handlePlanDrop(
  BuildContext context,
  WidgetRef ref,
  List<Object> rows,
  int oldIndex,
  int newIndex,
  DateTime Function(DayEntry) timeOf,
) async {
  final l10n = AppLocalizations.of(context);
  final order = [...rows];
  final moved = order.removeAt(oldIndex);
  order.insert(newIndex, moved);
  if (moved is! PlanEntry || oldIndex == newIndex) return;
  order.removeWhere((r) => r is DropNowRow);
  newIndex = order.indexOf(moved);
  final plan = moved.item.plan;
  final heading = order.indexWhere((r) => r is DropHeadingRow);
  final hasTimed = rows.any((r) => r is DayEntry && !_untimed(r));
  final toAnytime = heading == -1 ? !hasTimed : newIndex > heading;
  final clock = ref.read(clockProvider);
  final material = MaterialLocalizations.of(context);
  String timeText(DateTime utc) => material.formatTimeOfDay(
    TimeOfDay.fromDateTime(utc.add(clock.offsetAt(utc)).copyWith(isUtc: false)),
  );
  String nameOf(DayEntry e) => switch (e) {
    PlanEntry(:final item) => item.plan.title,
    RecordEntry(:final record) => record.type.name,
  };
  Future<void> update(PlanDraft draft) =>
      ref.read(updatePlanProvider)(plan.id, draft);

  try {
    if (toAnytime) {
      if (plan.plannedStartAt case final start?) {
        final ok = await _confirm(
          context,
          title: l10n.planDropAnytimeTitle(plan.title),
          body: l10n.planDropAnytimeBody(timeText(start)),
          action: l10n.planDropAnytime,
        );
        if (ok != true) return;
        final length = plan.plannedLengthMs;
        await update(
          plan.toDraft().copyWithTime(start: null, end: null, duration: length),
        );
      }
      final ids = [
        for (final r in order.skip(heading + 1))
          if (r is PlanEntry) r.item.plan.id,
      ];
      await ref.read(reorderPlansProvider)(ids);
      return;
    }

    // Among the timed ones: its neighbours where it was dropped.
    DayEntry? before;
    DayEntry? after;
    for (var i = newIndex - 1; i >= 0; i--) {
      if (order[i] case final DayEntry e) {
        before = e;
        break;
      }
    }
    for (var i = newIndex + 1; i < order.length; i++) {
      final r = order[i];
      if (r is DropHeadingRow) break;
      if (r case final DayEntry e) {
        after = e;
        break;
      }
    }
    DateTime endOf(DayEntry e) => switch (e) {
      PlanEntry(:final item) => timeOf(e).add(
        Duration(milliseconds: item.plan.plannedLengthMs ?? _defaultLength),
      ),
      RecordEntry(:final record) =>
        record.log.endedAt ??
            record.log.startedAt.add(
              Duration(milliseconds: record.log.durationMs ?? 0),
            ),
    };
    final length = Duration(
      milliseconds: plan.plannedLengthMs ?? _defaultLength,
    );
    final date = plan.planDate;
    final dayStart = DateTime(date.year, date.month, date.day).toUtc();
    final slot = DropSlot.between(
      previousEnd: before == null ? null : endOf(before),
      nextStart: after == null ? null : timeOf(after),
      length: length,
      dayStart: dayStart,
      dayEnd: DateTime(date.year, date.month, date.day + 1).toUtc(),
    );
    // Already where it belongs: nothing to ask.
    if (plan.plannedStartAt case final current?
        when slot.fits &&
            (before == null || !current.isBefore(endOf(before))) &&
            (after == null || !current.add(length).isAfter(timeOf(after)))) {
      return;
    }
    if (!context.mounted) return;
    String neighbor(DayEntry e) =>
        l10n.planDropNeighbor(nameOf(e), timeText(timeOf(e)));
    final where = switch ((before, after)) {
      (final b?, final a?) => l10n.planDropBetween(neighbor(b), neighbor(a)),
      (final b?, null) => l10n.planDropAfter(neighbor(b)),
      (null, final a?) => l10n.planDropBefore(neighbor(a)),
      _ => '',
    };
    final choice = await showDialog<_DropChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          slot.fits
              ? l10n.planDropMoveTitle(plan.title, timeText(slot.start))
              : l10n.planDropNoFitTitle(plan.title),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.fits
                  ? where
                  : '$where ${slot.free < const Duration(minutes: 1) ? l10n.planDropNoFitNone(formatDuration(l10n, length.inMilliseconds)) : l10n.planDropNoFitBody(formatDuration(l10n, slot.free.inMilliseconds), formatDuration(l10n, length.inMilliseconds))}',
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(AppIcons.time, size: 18),
              label: Text(l10n.planDropPickTime),
              onPressed: () => Navigator.pop(context, _DropChoice.pick),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          if (slot.fits)
            FilledButton(
              onPressed: () => Navigator.pop(context, _DropChoice.move),
              child: Text(l10n.planDropMove),
            ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    DateTime? start = slot.start;
    DateTime? end;
    if (choice == _DropChoice.pick) {
      final nowUtc = clock.nowUtc();
      LocalTime local(DateTime utc) {
        final t = utc.add(clock.offsetAt(utc));
        return LocalTime.hm(t.hour, t.minute);
      }

      final picked = await showPlanTimeSheet(
        context,
        isToday: date == currentLocalDate(clock),
        now: local(nowUtc),
        start: local(slot.start),
        end: plan.plannedEndAt == null ? null : local(slot.start.add(length)),
      );
      if (picked == null) return;
      DateTime? instant(LocalTime? t) => t == null
          ? null
          : DateTime(date.year, date.month, date.day, t.hour, t.minute).toUtc();
      start = instant(picked.start);
      end = instant(picked.end);
    } else if (plan.plannedEndAt != null) {
      end = slot.start.add(length);
    }
    await update(
      plan.toDraft().copyWithTime(
        start: start,
        end: end,
        duration: end == null ? plan.plannedLengthMs : null,
      ),
    );
    if (start != null && context.mounted) {
      showMessageSnackBar(
        context,
        l10n.planDropMoved(plan.title, timeText(start)),
      );
    }
  } catch (error) {
    if (context.mounted) {
      showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }
}

/// A plan's length when it has none, for fitting it in.
const _defaultLength = 30 * Duration.millisecondsPerMinute;

bool _untimed(DayEntry e) =>
    e is PlanEntry &&
    e.item.plan.plannedStartAt == null &&
    e.item.records.isEmpty;

Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: Text(body),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(action),
      ),
    ],
  ),
);

enum _DropChoice { move, pick }

/// The Anytime heading's place in a draggable day ([handlePlanDrop]).
class DropHeadingRow {
  const DropHeadingRow();
}

/// The now line's place in a draggable day ([handlePlanDrop]).
class DropNowRow {
  const DropNowRow();
}

/// A plan that can be held and dropped on a day of the week strip (P6).
/// Held and let go without moving, it opens the quick actions instead, as
/// a long-press does everywhere else.
class DayDraggable extends StatefulWidget {
  const DayDraggable({
    super.key,
    required this.item,
    required this.onHold,
    required this.child,
  });

  final PlannedItem item;

  /// Held without dragging: the quick actions.
  final VoidCallback onHold;
  final Widget child;

  @override
  State<DayDraggable> createState() => _DayDraggableState();
}

class _DayDraggableState extends State<DayDraggable> {
  double _moved = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      onLongPressHint: l10n.planQuickActionsHint,
      onLongPress: widget.onHold,
      child: LayoutBuilder(
        builder: (context, constraints) => LongPressDraggable<PlannedItem>(
          data: widget.item,
          hapticFeedbackOnStart: true,
          onDragStarted: () => _moved = 0,
          onDragUpdate: (d) => _moved += d.delta.distance,
          onDraggableCanceled: (_, _) {
            if (_moved < 12) widget.onHold();
          },
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: c.brandPrimary,
                borderRadius: AppRadius.pillAll,
                boxShadow: context.tokens.shadows.glow(c.brandPrimary),
              ),
              child: Text(
                widget.item.plan.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleSmall?.copyWith(
                  color: c.onBrandPrimary,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: widget.child),
          child: widget.child,
        ),
      ),
    );
  }
}

/// "Anytime": the heading above a day's untimed items (A19).
class _AnytimeHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(
        AppLocalizations.of(context).planAnytime.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(
          color: context.colors.textTertiary,
          letterSpacing: 1.1,
        ),
      ),
    ),
  );
}

/// "● NOW · 9:10" on Today's timeline (ADR-046): a chip between two lines.
class NowLine extends StatelessWidget {
  const NowLine({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(now.toLocal()));
    final line = Expanded(
      child: Container(
        height: 1.5,
        color: c.brandPrimary.withValues(alpha: 0.3),
      ),
    );
    return Semantics(
      label: AppLocalizations.of(context).nowLine(time),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.md,
        ),
        // The pill never takes more than the row minus the two lines.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              line,
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (constraints.maxWidth - 48).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.brandPrimarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs + 1),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)
                              .nowLine(time)
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: c.onBrandPrimarySoft,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              line,
            ],
          ),
        ),
      ),
    );
  }
}
