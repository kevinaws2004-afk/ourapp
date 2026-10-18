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

    // Untimed plans sit at the end of [entries]; only they can be dragged.
    bool untimedPlan(DayEntry e) =>
        e is PlanEntry &&
        e.item.plan.plannedStartAt == null &&
        e.item.records.isEmpty;
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
    if (!reorderable || untimed.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...timedTiles,
          ...anytime,
          for (final entry in untimed) tile(entry),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...timedTiles,
        ...anytime,
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) async {
            final order = [for (final e in untimed) e.item.plan.id];
            order.insert(newIndex, order.removeAt(oldIndex));
            try {
              await ref.read(reorderPlansProvider)(order);
            } catch (error) {
              if (context.mounted) {
                showMessageSnackBar(context, errorMessage(l10n, error));
              }
            }
          },
          children: [
            for (final (index, entry) in untimed.indexed)
              tile(
                entry,
                dragHandle: ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: l10n.planReorderHandle,
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Icon(AppIcons.dragHandle),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
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
