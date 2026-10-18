import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import 'insight_formatting.dart';
import 'recap_providers.dart';

/// What a record is a best of: "Pages", "Chest Press · Weight".
String recordSubject(PersonalRecord record) {
  final field = record.chart.fieldName ?? '';
  return switch (record.chart.rowName) {
    final row? => '$row · $field',
    null => field,
  };
}

/// One personal best: "New best: 42 pages", with its activity, what it's a
/// best of and the day.
class PersonalRecordTile extends StatelessWidget {
  const PersonalRecordTile({super.key, required this.record, this.onTap});

  final PersonalRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final display = InsightDisplay.of(
      l10n,
      record.chart.config.source,
      record.type,
      material: MaterialLocalizations.of(context),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: c.surfaceBase,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: c.borderSubtle),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ActivityBadge(
                      iconId: record.type.iconId,
                      colorKey: record.type.colorKey,
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: c.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.personalRecord,
                          size: 12,
                          color: c.surfaceBase,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recordNewBest(display.format(record.point.value)),
                        style: context.textStyles.titleSmall,
                      ),
                      Text(
                        '${record.type.name} · ${recordSubject(record)} · '
                        '${formatDate(context, record.point.date)}',
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
      ),
    );
  }
}
