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

  ActivityColors resolve(ActivityColorKey key) => _colors[key]!;
}
