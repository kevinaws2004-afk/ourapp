import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';

/// Consistent label / editor / error layout for every field editor
/// (ui_guidelines.md §7.5: labels always visible). [boxed] puts it in its
/// own card (logging into an item, ADR-045).
class FieldEditorShell extends StatelessWidget {
  const FieldEditorShell({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.error,
    this.onClear,
    this.boxed = false,
  });

  final String label;
  final bool required;
  final String? error;
  final VoidCallback? onClear;
  final Widget child;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                required ? '$label *' : label,
                style: boxed
                    ? context.textStyles.titleMedium
                    : context.textStyles.labelMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
              ),
            ),
            if (onClear != null)
              TextButton(onPressed: onClear, child: Text(l10n.actionClear)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.danger,
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: EdgeInsets.only(bottom: boxed ? AppSpacing.lg : AppSpacing.xl),
      child: boxed ? AppCard(child: content) : content,
    );
  }
}
