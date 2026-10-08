import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/done_check.dart';
import '../../../shared/widgets/item_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../domain/watch_records_for_day.dart';
import 'value_formatting.dart';

/// A done item that wasn't planned (ADR-035), as the same item card as a
/// done plan: badge, time and duration, "Done", and a summary of what was
/// logged.
class DayRecordTile extends StatelessWidget {
  const DayRecordTile({super.key, required this.record, required this.onTap});

  final DayRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final DayRecord(:log, :type) = record;
    final activity = context.tokens.activity(
      ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
    );
    final time = [
      material.formatTimeOfDay(TimeOfDay.fromDateTime(log.startedAt.toLocal())),
      if (log.durationMs != null) formatDuration(l10n, log.durationMs!),
    ].join(' · ');
    return ItemCard(
      title: type.name,
      time: time,
      chip: StatusChip(
        label: l10n.planStatusDone,
        tone: StatusTone.done,
        icon: AppIcons.check,
      ),
      summary: summarizeLog(context, type, log),
      onTap: onTap,
      leading: ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
      // Done by definition: the check shows it, like every row (A17),
      // without toggling.
      trailing: [
        DoneCheck(done: true, color: activity.solid),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
