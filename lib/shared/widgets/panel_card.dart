import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/spacing.dart';
import 'app_card.dart';

/// A titled card for a block of a screen (Insights, a challenge): a title, an
/// optional quiet subtitle, then [child].
class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textStyles.titleLarge),
          if (subtitle case final subtitle?)
            Text(
              subtitle,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    ),
  );
}
