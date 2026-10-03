import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Three elevation levels (design_system.md §7). Dark mode shows depth with
/// lighter surface tones instead of shadows at the raised level.
@immutable
class AppShadows {
  const AppShadows({required this.raised, required this.overlay});

  static const light = AppShadows(
    raised: [
      BoxShadow(color: Color(0x0F1F1D2B), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x0F1F1D2B), offset: Offset(0, 4), blurRadius: 12),
    ],
    overlay: [
      BoxShadow(color: Color(0x1F1F1D2B), offset: Offset(0, 8), blurRadius: 24),
    ],
  );

  static const dark = AppShadows(
    raised: [],
    overlay: [
      BoxShadow(color: Color(0x80000000), offset: Offset(0, 8), blurRadius: 24),
    ],
  );

  /// `flat` is the default and has no shadow (use a hairline border).
  static const List<BoxShadow> flat = [];

  final List<BoxShadow> raised;
  final List<BoxShadow> overlay;
}
