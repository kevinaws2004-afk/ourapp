import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/sizes.dart';

/// A thin bar showing [fraction] (0 to 1) in [color] on the sunken surface.
/// Read to screen readers as [semanticLabel] (e.g. "21 of 75 days").
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    required this.semanticLabel,
  });

  final double fraction;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    excludeSemantics: true,
    child: ClipRRect(
      borderRadius: AppRadius.pillAll,
      child: Stack(
        children: [
          Container(
            height: AppSizes.progressBar,
            color: context.colors.surfaceSunken,
          ),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0, 1).toDouble(),
            child: Container(height: AppSizes.progressBar, color: color),
          ),
        ],
      ),
    ),
  );
}
