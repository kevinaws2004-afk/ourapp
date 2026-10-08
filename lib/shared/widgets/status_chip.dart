import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';

/// What a status chip says about something.
enum StatusTone {
  /// Done, recorded.
  done,

  /// Happening now, in progress, up next.
  active,

  /// Planned for later.
  scheduled,

  /// Needs attention (a streak at risk).
  warning,

  /// Skipped, cancelled, nothing special.
  neutral,
}

/// A small pill with a soft fill and its text in the matching deep color
/// ("Done", "Planned", "In progress", ADR-045). Text, never color alone,
/// carries the meaning.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.filled = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  /// Solid fill for the loudest state (e.g. "Up next").
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color fill, Color text) = switch ((tone, filled)) {
      (StatusTone.active, true) => (c.brandPrimary, c.onBrandPrimary),
      (StatusTone.done, true) => (c.action, c.onAction),
      (StatusTone.done, _) => (c.successContainer, c.onActionSoft),
      (StatusTone.active, _) => (c.brandPrimarySoft, c.onBrandPrimarySoft),
      (StatusTone.scheduled, _) => (c.accentSoft, c.onAccentSoft),
      (StatusTone.warning, _) => (c.warningContainer, c.textPrimary),
      (StatusTone.neutral, _) => (c.surfaceSunken, c.textSecondary),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: AppRadius.pillAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: text),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.labelSmall?.copyWith(color: text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
