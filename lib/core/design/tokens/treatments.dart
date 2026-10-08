import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// How a card's edge is drawn.
enum CardEdge {
  /// No line; separated by tone and its glow.
  none,

  /// A faint line in the theme's color.
  hairline,

  /// A white rim over a faint ink line, like lacquerware.
  rim,
}

/// How the bottom navigation sits.
enum NavStyle {
  /// Full width along the bottom.
  bar,

  /// A rounded bar floating above the bottom edge.
  floating,
}

/// How a few things are drawn in one theme (ADR-045). Only shared components
/// read these; screens never branch on the theme. Everything else about a
/// theme is a value (colors, shadows).
@immutable
class AppTreatments {
  const AppTreatments({
    required this.cardEdge,
    required this.navStyle,
    required this.progressGradient,
    required this.heroWash,
    required this.factsAsChips,
    required this.timeColumn,
  });

  final CardEdge cardEdge;
  final NavStyle navStyle;

  /// Progress fills run through these colors; one color = a solid fill.
  final List<Color> progressGradient;

  /// The soft glow in the corner of a hero card.
  final Color heroWash;

  /// Small facts (a duration, a count) as chips rather than tiles.
  final bool factsAsChips;

  /// Day rows lead with the time in a column (else with the activity's
  /// icon, the time in the row's text).
  final bool timeColumn;
}
