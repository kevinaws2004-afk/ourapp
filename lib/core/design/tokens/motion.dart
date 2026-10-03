import 'package:flutter/animation.dart';

/// Motion tokens (design_system.md §9). Under reduced motion
/// (`MediaQuery.disableAnimations`), replace movement with short crossfades.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration emphasized = Duration(milliseconds: 400);
  static const Duration celebrate = Duration(milliseconds: 750);

  static const Curve instantCurve = Curves.easeOut;
  static const Curve fastCurve = Curves.easeOutCubic;
  static const Curve standardCurve = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;
}
