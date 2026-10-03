import 'package:flutter/widgets.dart';

import 'tokens/spacing.dart';

/// Window width classes (responsive_design.md §1). Based on the available
/// window width, not the device type.
enum WindowSizeClass {
  compact,
  medium,
  expanded;

  static WindowSizeClass fromWidth(double width) {
    if (width < 600) return WindowSizeClass.compact;
    if (width < 840) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }

  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Horizontal screen margin for this class.
  double get screenMargin => switch (this) {
    WindowSizeClass.compact => AppSpacing.xl,
    WindowSizeClass.medium => AppSpacing.xxl,
    WindowSizeClass.expanded => AppSpacing.xxxl,
  };

  bool get usesNavigationRail => this != WindowSizeClass.compact;
}

/// Content width limits (responsive_design.md §2).
abstract final class AppContentWidth {
  static const double reading = 600;
  static const double list = 720;
  static const double chart = 960;
}
