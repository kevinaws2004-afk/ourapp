import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/typography.dart';

/// A small card with a label, a big number and an optional change ("+12 %").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.change,
  });

  final String label;
  final String value;

  /// Already formatted ("+12 %"), or null.
  final String? change;

  @override
  Widget build(BuildContext context) {
    final quiet = context.textStyles.labelMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceBase,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: quiet),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTypography.numericMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (change case final c?) Text(c, style: quiet),
          ],
        ),
      ),
    );
  }
}
