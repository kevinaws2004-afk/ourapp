import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../activity_logs/presentation/value_formatting.dart';

/// "How long did it take?" after ticking something done without its timer:
/// one tap on a length (the planned one first), or Skip. Returns the length
/// in ms, or null.
Future<int?> showHowLongSheet(
  BuildContext context, {
  required String title,
  int? planned,
}) {
  final l10n = AppLocalizations.of(context);
  const minutes = [15, 30, 45, 60, 90, 120];
  final choices = <int>{
    ?planned,
    for (final m in minutes) m * Duration.millisecondsPerMinute,
  }.toList();
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.howLongTitle, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            title,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final ms in choices)
                ActionChip(
                  label: Text(formatDuration(l10n, ms)),
                  onPressed: () => Navigator.pop(context, ms),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.howLongSkip),
            ),
          ),
        ],
      ),
    ),
  );
}
