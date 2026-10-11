import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/typography.dart';

/// You, as a circle: your initial on the theme's soft signature color, or a
/// person glyph before you've given a name.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.onTap,
    this.tooltip,
  });

  final String name;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = name.trim().isEmpty
        ? null
        : name.trim().characters.first.toUpperCase();
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.brandPrimarySoft,
        border: Border.all(color: c.surfaceBase, width: size > 60 ? 4 : 2),
      ),
      alignment: Alignment.center,
      child: initial == null
          ? Icon(
              AppIcons.me.filled,
              size: size * 0.48,
              color: c.brandPrimary,
            )
          : Text(
              initial,
              style: AppTypography.titleLarge.copyWith(
                fontSize: size * 0.42,
                height: 1,
                fontWeight: FontWeight.w800,
                color: c.onBrandPrimarySoft,
              ),
            ),
    );
    if (onTap != null) {
      avatar = Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(onTap: onTap, child: avatar),
      );
    }
    return avatar;
  }
}
