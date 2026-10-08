import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';

/// A small fact about something ("Duration · 45 min"): a tile with its icon
/// in a tinted circle and a quiet label, or, in themes that show facts as
/// chips, one compact pill (ADR-045).
class FactPill extends StatelessWidget {
  const FactPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chips = context.tokens.treatments.factsAsChips;
    if (chips) {
      return Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: AppRadius.pillAll,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: c.brandPrimary),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceBase,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: c.borderSubtle, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.brandPrimarySoft,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(icon, size: 18, color: c.brandPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
