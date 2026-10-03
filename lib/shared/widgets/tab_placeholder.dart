import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/window_size_class.dart';

/// Temporary content for a primary tab whose feature isn't built yet:
/// a large display title and a calm explanatory line.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({
    super.key,
    required this.title,
    required this.message,
    this.footer,
  });

  final String title;
  final String message;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final margin = WindowSizeClass.of(context).screenMargin;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.xxxl,
            ),
            children: [
              Text(title, style: context.textStyles.displayMedium),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.xxxl),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
