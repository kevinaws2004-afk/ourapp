import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/sizes.dart';

/// A pill track showing [fraction] (0 to 1). The fill is [color], or the
/// theme's progress fill (a gradient in some themes). Read to screen readers
/// as [semanticLabel] (e.g. "21 of 75 days").
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.fraction,
    required this.semanticLabel,
    this.color,
    this.height = AppSizes.progressBar,
  });

  final double fraction;
  final Color? color;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final stops = context.tokens.treatments.progressGradient;
    final fill = color != null
        ? BoxDecoration(color: color, borderRadius: AppRadius.pillAll)
        : BoxDecoration(
            color: stops.first,
            gradient: stops.length > 1 ? LinearGradient(colors: stops) : null,
            borderRadius: AppRadius.pillAll,
          );
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: Stack(
          children: [
            Container(height: height, color: context.colors.surfaceSunken),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0, 1).toDouble(),
              child: DecoratedBox(
                decoration: fill,
                child: SizedBox(height: height),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
