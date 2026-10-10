import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';

/// A ring showing [fraction] (0 to 1) with round ends, [child] in the middle
/// (e.g. "3/6"). The fill is [color], or the theme's progress fill. Read to
/// screen readers as [semanticLabel].
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    required this.semanticLabel,
    this.size = 96,
    this.stroke = 10,
    this.color,
    this.trackColor,
    this.child,
  });

  final double fraction;
  final String semanticLabel;
  final double size;
  final double stroke;
  final Color? color;

  /// The unfilled part; defaults to the sunken surface.
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final stops = color == null
        ? context.tokens.treatments.progressGradient
        : [color!];
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            fraction: fraction.clamp(0, 1).toDouble(),
            track: trackColor ?? context.colors.surfaceSunken,
            stops: stops,
            stroke: stroke,
          ),
          // The middle scales down rather than spill out (large text).
          child: Padding(
            padding: EdgeInsets.all(stroke + 4),
            child: Center(
              child: child == null
                  ? null
                  : FittedBox(fit: BoxFit.scaleDown, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.stops,
    required this.stroke,
  });

  final double fraction;
  final Color track;
  final List<Color> stops;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, base..color = track);
    if (fraction <= 0) return;
    final sweep = math.pi * 2 * fraction;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = stops.first;
    if (stops.length > 1) {
      fill.shader = SweepGradient(
        colors: stops,
        endAngle: sweep,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    }
    canvas.drawArc(arc, -math.pi / 2, sweep, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.track != track ||
      old.stroke != stroke ||
      !_sameColors(old.stops, stops);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
