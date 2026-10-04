import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/domain/activity_log.dart';
import '../../domain/watch_day_overview.dart';
import '../plan_actions.dart';
import '../plan_providers.dart';
import 'plan_item_tile.dart';

/// A date's plans (Today, Plan tab): timed plans in time order, then untimed
/// ones in manual order. With [reorderable], untimed plans can be dragged
/// (FR-PL-08).
///
/// Tapping a plan does it (ADR-030): an activity plan without a record opens
/// its record form ([onRecord]); a recorded one opens its latest record
/// ([onOpenRecord]); a task offers "Mark as done" or "Track details"
/// ([onTrack]). Plan options sit behind More.
class PlannedList extends ConsumerWidget {
  const PlannedList({
    super.key,
    required this.items,
    required this.onRecord,
    required this.onOpenRecord,
    required this.onTrack,
    this.reorderable = false,
  });

  final List<PlannedItem> items;
  final ValueChanged<PlannedItem> onRecord;
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Set up what to track for a task, then record it (ADR-030).
  final ValueChanged<PlannedItem> onTrack;
  final bool reorderable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = PlanActions(context, ref);
    Widget tile(PlannedItem item, {Widget? dragHandle}) => PlanItemTile(
      key: ValueKey(item.plan.id),
      item: item,
      onTap: () {
        if (item.plan.isTask) {
          unawaited(actions.chooseForTask(item, onTrack: onTrack));
        } else if (item.records.isNotEmpty) {
          onOpenRecord(item.records.last);
        } else {
          onRecord(item);
        }
      },
      onMore: () => actions.open(item, onRecord: onRecord, onTrack: onTrack),
      onToggleTask: () => actions.toggleTask(item),
      dragHandle: dragHandle,
    );

    final timed = items.where((i) => i.plan.isTimed).toList();
    final untimed = items.where((i) => !i.plan.isTimed).toList();
    if (!reorderable || untimed.length < 2) {
      return Column(children: [for (final item in items) tile(item)]);
    }
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final item in timed) tile(item),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) async {
            final order = [for (final i in untimed) i.plan.id];
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
            for (final (index, item) in untimed.indexed)
              tile(
                item,
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
