import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../domain/watch_records_for_day.dart';
import 'value_formatting.dart';

/// One record on a day's timeline (Today, Plan tab): badge, activity, time,
/// duration and a summary line. Filled grammar: this is what happened.
class DayRecordTile extends StatelessWidget {
  const DayRecordTile({super.key, required this.record, required this.onTap});

  final DayRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final DayRecord(:log, :type) = record;
    final summary = summarizeLog(context, type, log);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
      title: Text(
        [
          type.name,
          material.formatTimeOfDay(
            TimeOfDay.fromDateTime(log.startedAt.toLocal()),
          ),
          if (log.durationMs != null) formatDuration(l10n, log.durationMs!),
        ].join(' · '),
      ),
      subtitle: summary.isEmpty ? null : Text(summary),
      trailing: const Icon(AppIcons.chevron),
      onTap: onTap,
    );
  }
}
