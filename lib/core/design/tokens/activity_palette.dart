import 'package:flutter/material.dart';

import '../keys/activity_color_key.dart';

export '../keys/activity_color_key.dart';

/// The resolved colors for one activity in one brightness.
@immutable
class ActivityColors {
  const ActivityColors({required this.solid, required this.soft});

  /// Icons, accent bars, chart marks. Never small text in light mode.
  final Color solid;

  /// Tinted surfaces. Text on it uses the text roles, not [solid].
  final Color soft;
}

abstract final class ActivityPalette {
  static ActivityColors resolve(ActivityColorKey key, Brightness brightness) =>
      brightness == Brightness.light ? _light[key]! : _dark[key]!;

  static const Map<ActivityColorKey, ActivityColors> _light = {
    ActivityColorKey.sky: ActivityColors(
      solid: Color(0xFF4A78A8),
      soft: Color(0xFFE1ECF7),
    ),
    ActivityColorKey.lilac: ActivityColors(
      solid: Color(0xFF7A62B5),
      soft: Color(0xFFECE6F8),
    ),
    ActivityColorKey.rose: ActivityColors(
      solid: Color(0xFFB04E62),
      soft: Color(0xFFF8E3E7),
    ),
    ActivityColorKey.teal: ActivityColors(
      solid: Color(0xFF2F8180),
      soft: Color(0xFFDDF0EF),
    ),
    ActivityColorKey.coral: ActivityColors(
      solid: Color(0xFFC0503E),
      soft: Color(0xFFFBE4DF),
    ),
    ActivityColorKey.slate: ActivityColors(
      solid: Color(0xFF5D6A80),
      soft: Color(0xFFE6E9EF),
    ),
  };

  static const Map<ActivityColorKey, ActivityColors> _dark = {
    ActivityColorKey.sky: ActivityColors(
      solid: Color(0xFF8DB6E3),
      soft: Color(0xFF1B2533),
    ),
    ActivityColorKey.lilac: ActivityColors(
      solid: Color(0xFFB9A6EC),
      soft: Color(0xFF251F35),
    ),
    ActivityColorKey.rose: ActivityColors(
      solid: Color(0xFFEE9AAA),
      soft: Color(0xFF331E24),
    ),
    ActivityColorKey.teal: ActivityColors(
      solid: Color(0xFF7CCBC8),
      soft: Color(0xFF162B2B),
    ),
    ActivityColorKey.coral: ActivityColors(
      solid: Color(0xFFF29A89),
      soft: Color(0xFF341E1A),
    ),
    ActivityColorKey.slate: ActivityColors(
      solid: Color(0xFFA8B3C7),
      soft: Color(0xFF20242C),
    ),
  };
}
