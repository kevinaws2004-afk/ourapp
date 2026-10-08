import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/status_chip.dart';
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
  });

  final List<DayEntry> entries;
  final ValueChanged<PlannedItem> onOpenItem;
  final ValueChanged<ActivityLog> onOpenRecord;
  final bool reorderable;

  /// Today: a "Now · 9:10" line between what's passed and what's next.
  final bool nowLine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = PlanActions(context, ref);
    Widget tile(DayEntry entry, {Widget? dragHandle}) => switch (entry) {
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

/// "Anytime": the heading above a day's untimed items (A19).
class _AnytimeHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(
        AppLocalizations.of(context).planAnytime,
        style: context.textStyles.labelMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ),
  );
}

/// "Now · 9:10" on Today's timeline (ADR-046).
class NowLine extends StatelessWidget {
  const NowLine({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(now.toLocal()));
    final line = Expanded(
      child: Divider(color: c.brandPrimary.withValues(alpha: 0.4)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          line,
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 4,
            child: StatusChip(
              label: AppLocalizations.of(context).nowLine(time).toUpperCase(),
              tone: StatusTone.active,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          line,
        ],
      ),
    );
  }
}
