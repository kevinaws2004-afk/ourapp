import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../domain/watch_records_for_day.dart';
import 'value_formatting.dart';

/// A done item that wasn't planned (ADR-035), in the same filled "done"
/// grammar as a done plan: badge, activity, time, duration and a summary of
/// what was logged.
class DayRecordTile extends StatelessWidget {
  const DayRecordTile({super.key, required this.record, required this.onTap});

  final DayRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final colors = context.colors;
    final DayRecord(:log, :type) = record;
    final activity = context.tokens.activity(
      ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
    );
    final details = [
      material.formatTimeOfDay(TimeOfDay.fromDateTime(log.startedAt.toLocal())),
      if (log.durationMs != null) formatDuration(l10n, log.durationMs!),
    ].join(' · ');
    final summary = summarizeLog(context, type, log);
    final secondary = context.textStyles.bodyMedium?.copyWith(
      color: colors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: activity.soft,
              borderRadius: AppRadius.mdAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.name, style: context.textStyles.titleMedium),
                        Text(details, style: secondary),
                        if (summary.isNotEmpty)
                          Text(
                            summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: secondary,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.taskDone,
                    color: colors.success,
                    semanticLabel: l10n.planStatusRecorded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
