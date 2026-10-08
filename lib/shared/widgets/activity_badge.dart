import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/icons/activity_icon_registry.dart';
import '../../core/design/tokens/activity_palette.dart';

/// An activity's identity everywhere (design_system.md §8): its icon in the
/// palette `solid` color on a `soft` circle.
class ActivityBadge extends StatelessWidget {
  const ActivityBadge({
    super.key,
    required this.iconId,
    required this.colorKey,
    this.size = AppSizes.badge,
  });

  final String iconId;
  final String colorKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(colorKey) ?? ActivityColorKey.slate,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colors.soft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(
        ActivityIconRegistry.resolve(iconId),
        color: colors.solid,
        size: size * 0.5,
      ),
    );
  }
}
