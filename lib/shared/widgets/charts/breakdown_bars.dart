import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';

/// One row of a [BreakdownBars]: a label and how many.
class BreakdownEntry {
  const BreakdownEntry(this.label, this.count);

  final String label;
  final int count;
}

/// "How often each": a label, a bar as long as its share of the largest,
/// and the number (B3: choices; when in the day). Bars use [color]; the
/// track is the sunken surface.
class BreakdownBars extends StatelessWidget {
  const BreakdownBars({super.key, required this.entries, required this.color});

  final List<BreakdownEntry> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final most = entries.fold<int>(0, (m, e) => e.count > m ? e.count : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries)
          Semantics(
            label: '${entry.label}: ${entry.count}',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: AppRadius.smAll,
                      child: Stack(
                        children: [
                          Container(
                            height: AppSizes.breakdownBar,
                            color: context.colors.surfaceSunken,
                          ),
                          FractionallySizedBox(
                            widthFactor: most == 0 ? 0 : entry.count / most,
                            child: Container(
                              height: AppSizes.breakdownBar,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${entry.count}',
                    style: AppTypography.numericMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
