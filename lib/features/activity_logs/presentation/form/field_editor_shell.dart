import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Consistent label / editor / error layout for every field editor
/// (ui_guidelines.md §7.5: labels always visible).
class FieldEditorShell extends StatelessWidget {
  const FieldEditorShell({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.error,
    this.onClear,
  });

  final String label;
  final bool required;
  final String? error;
  final VoidCallback? onClear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  required ? '$label *' : label,
                  style: context.textStyles.labelMedium?.copyWith(
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
      ),
    );
  }
}
