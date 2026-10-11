import 'package:flutter/material.dart';

import '../keys/activity_color_key.dart';

export '../keys/activity_color_key.dart';

/// The resolved colors for one activity in the current theme.
@immutable
class ActivityColors {
  const ActivityColors({required this.solid, required this.soft});

  /// Icons, accent bars, chart marks (≥ 3:1 on white and on [soft]). Never
  /// small text.
  final Color solid;

  /// Tinted surfaces. Text on it uses the text roles, not [solid].
  final Color soft;
}

/// The six activity colors of one theme (ADR-045). The keys are what the
/// database stores and never change; each theme tunes their values so an
/// activity's color sits in the theme.
@immutable
class ActivityPalette {
  const ActivityPalette(this._colors);

  final Map<ActivityColorKey, ActivityColors> _colors;

  ActivityColors resolve(ActivityColorKey key) =>
      _colors[key] ??
      extraActivityColors[key] ??
      _colors[ActivityColorKey.slate]!;

  /// The same palette with every color pair transformed (the dark variant).
  ActivityPalette map(ActivityColors Function(ActivityColors) transform) =>
      ActivityPalette({
        for (final key in ActivityColorKey.values) key: transform(resolve(key)),
      });
}

/// The activity colors added after the first six, shared by every theme
/// (themes may still tune them in their own palette).
const extraActivityColors = <ActivityColorKey, ActivityColors>{
  ActivityColorKey.indigo: ActivityColors(
    solid: Color(0xFF4F46E5),
    soft: Color(0xFFE0E7FF),
  ),
  ActivityColorKey.violet: ActivityColors(
    solid: Color(0xFF9333EA),
    soft: Color(0xFFF3E8FF),
  ),
  ActivityColorKey.fuchsia: ActivityColors(
    solid: Color(0xFFC026D3),
    soft: Color(0xFFFAE8FF),
  ),
  ActivityColorKey.red: ActivityColors(
    solid: Color(0xFFDC2626),
    soft: Color(0xFFFEE2E2),
  ),
  ActivityColorKey.yellow: ActivityColors(
    solid: Color(0xFFEAB308),
    soft: Color(0xFFFEF9C3),
  ),
  ActivityColorKey.amber: ActivityColors(
    solid: Color(0xFFD97706),
    soft: Color(0xFFFEF3C7),
  ),
  ActivityColorKey.lime: ActivityColors(
    solid: Color(0xFF65A30D),
    soft: Color(0xFFECFCCB),
  ),
  ActivityColorKey.navy: ActivityColors(
    solid: Color(0xFF1E40AF),
    soft: Color(0xFFDBEAFE),
  ),
  ActivityColorKey.cyan: ActivityColors(
    solid: Color(0xFF0891B2),
    soft: Color(0xFFCFFAFE),
  ),
  ActivityColorKey.brown: ActivityColors(
    solid: Color(0xFF92400E),
    soft: Color(0xFFF5E9DD),
  ),
};
