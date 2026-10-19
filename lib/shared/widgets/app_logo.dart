import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/color_tokens.dart';

/// The app's name, in one place.
const appBrandName = 'DayCraft';

/// The logo's colors, all taken from the current theme so the whole mark
/// changes with it.
@immutable
class LogoColors {
  const LogoColors({
    required this.flow,
    required this.glow,
    required this.pulse,
    required this.tile,
    required this.ring,
    required this.node,
    required this.edge,
  });

  /// From the current theme's three colors (primary, accent, action), so
  /// the whole mark changes with the theme.
  factory LogoColors.of(BuildContext context) => LogoColors.from(
    context.colors,
    dark: Theme.of(context).brightness == Brightness.dark,
  );

  factory LogoColors.from(AppColors c, {bool dark = false}) {
    Color lighter(Color color, double t) =>
        Color.lerp(color, Colors.white, dark ? t * 0.5 : t)!;
    return LogoColors(
      // First loop: primary flowing into the accent.
      flow: [c.brandPrimary, lighter(c.brandPrimary, 0.3), c.accent],
      // Second loop: the action color into the accent and back to primary.
      glow: [lighter(c.action, 0.15), lighter(c.accent, 0.2), c.brandPrimary],
      // The travelling dot and the sparkle.
      pulse: [c.action, lighter(c.action, 0.5)],
      tile: dark
          ? [
              c.surfaceRaised,
              Color.lerp(c.surfaceRaised, c.brandPrimary, 0.16)!,
            ]
          : [
              Color.lerp(c.surfaceCanvas, Colors.white, 0.6)!,
              c.brandPrimarySoft,
            ],
      ring: c.brandPrimary,
      node: Colors.white,
      edge: Colors.white.withValues(alpha: dark ? 0.1 : 0.7),
    );
  }

  final List<Color> flow;
  final List<Color> glow;
  final List<Color> pulse;
  final List<Color> tile;
  final Color ring;
  final Color node;

  /// The tile's outline.
  final Color edge;
}

/// The infinity mark (plan → do → log → understand, round again) in the
/// theme's colors. [tile] draws it on its rounded app-icon square.
///
/// [draw] (0–1) draws the two strands in; [travel] (0–1) moves the pulse
/// dot along the loop; [twinkle] (0–1) pulses the sparkle. Still, it's the
/// finished logo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.size,
    this.tile = true,
    this.colors,
    this.draw = 1,
    this.travel,
    this.twinkle = 0,
  });

  final double size;
  final bool tile;
  final LogoColors? colors;
  final double draw;
  final double? travel;
  final double twinkle;

  @override
  Widget build(BuildContext context) => Semantics(
    label: appBrandName,
    image: true,
    child: CustomPaint(
      size: Size.square(size),
      painter: LogoPainter(
        colors: colors ?? LogoColors.of(context),
        tile: tile,
        draw: draw,
        travel: travel,
        twinkle: twinkle,
      ),
    ),
  );
}

/// [AppLogo] while something loads: the strands draw in, then the pulse
/// travels round the loop and the sparkle twinkles, for as long as it's
/// shown. Still when animations are turned off.
class AnimatedAppLogo extends StatefulWidget {
  const AnimatedAppLogo({super.key, required this.size, this.tile = true});

  final double size;
  final bool tile;

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late final _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _draw.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return AppLogo(size: widget.size, tile: widget.tile);
    }
    final drawIn = CurvedAnimation(parent: _draw, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: Listenable.merge([_draw, _loop]),
      builder: (context, _) => AppLogo(
        size: widget.size,
        tile: widget.tile,
        draw: drawIn.value,
        travel: _draw.isCompleted ? _loop.value : null,
        twinkle: math.sin(_loop.value * math.pi),
      ),
    );
  }
}

/// Paints the mark in a 512×512 design space (the source artwork's),
/// scaled to the canvas.
class LogoPainter extends CustomPainter {
  LogoPainter({
    required this.colors,
    this.tile = true,
    this.draw = 1,
    this.travel,
    this.twinkle = 0,
  });

  final LogoColors colors;
  final bool tile;
  final double draw;
  final double? travel;
  final double twinkle;

  static final Path _back = Path()
    ..moveTo(190, 206)
    ..cubicTo(150, 160, 90, 190, 90, 256)
    ..cubicTo(90, 322, 152, 350, 200, 306)
    ..lineTo(312, 206)
    ..cubicTo(360, 162, 422, 190, 422, 256)
    ..cubicTo(422, 322, 362, 352, 322, 306);

  static final Path _front = Path()
    ..moveTo(210, 216)
    ..lineTo(302, 296)
    ..cubicTo(346, 336, 404, 316, 414, 266)
    ..cubicTo(424, 216, 384, 184, 340, 196)
    ..cubicTo(304, 206, 270, 236, 256, 256);

  static final Path _sparkle = Path()
    ..moveTo(388, 126)
    ..quadraticBezierTo(396, 142, 412, 150)
    ..quadraticBezierTo(396, 158, 388, 174)
    ..quadraticBezierTo(380, 158, 364, 150)
    ..quadraticBezierTo(380, 142, 388, 126)
    ..close();

  static Path _partial(Path path, double t) {
    if (t >= 1) return path;
    final out = Path();
    for (final m in path.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return out;
  }

  static Offset _pointAt(Path path, double t) {
    final m = path.computeMetrics().first;
    return m.getTangentForOffset(m.length * t)!.position;
  }

  Shader _linear(Rect r, List<Color> c, {bool reverse = false}) =>
      ui.Gradient.linear(
        reverse ? r.topRight : r.topLeft,
        reverse ? r.bottomLeft : r.bottomRight,
        c,
        c.length == 3 ? const [0, 0.48, 1] : null,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 512;
    canvas.save();
    canvas.scale(s);
    const box = Rect.fromLTWH(0, 0, 512, 512);

    if (tile) {
      final tileRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 32, 448, 448),
        const Radius.circular(112),
      );
      canvas.drawRRect(
        tileRect.shift(const Offset(0, 10)),
        Paint()
          ..color = colors.ring.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawRRect(tileRect, Paint()..shader = _linear(box, colors.tile));
      canvas.drawRRect(
        tileRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = colors.edge,
      );
      // Ambient rings.
      canvas.drawCircle(
        const Offset(256, 256),
        160,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 32
          ..color = colors.ring.withValues(alpha: 0.06),
      );
      final dashed = Path()
        ..addOval(Rect.fromCircle(center: const Offset(256, 256), radius: 120));
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = colors.pulse.first.withValues(alpha: 0.14);
      for (final m in dashed.computeMetrics()) {
        for (double d = 0; d < m.length; d += 14) {
          canvas.drawPath(m.extractPath(d, d + 6), ring);
        }
      }
    }

    Paint strand(List<Color> c, {bool reverse = false}) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = _linear(
        const Rect.fromLTWH(90, 160, 332, 192),
        c,
        reverse: reverse,
      );

    // A soft colored shadow under the strands.
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round
      ..color = colors.ring.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(_partial(_back, draw).shift(const Offset(0, 10)), shadow);

    canvas.drawPath(_partial(_back, draw), strand(colors.flow));
    final glow = strand(colors.glow, reverse: true)
      ..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawPath(_partial(_front, draw), glow);

    // The pulse: at the crossing, or travelling round the loop.
    final pulseAt = travel == null
        ? const Offset(256, 256)
        : _pointAt(_back, travel!);
    final appear = draw.clamp(0.0, 1.0);
    if (appear > 0.6) {
      final k = (appear - 0.6) / 0.4;
      canvas.drawCircle(pulseAt, 18 * k, Paint()..color = colors.node);
      canvas.drawCircle(
        pulseAt,
        11 * k,
        Paint()
          ..shader = ui.Gradient.linear(
            pulseAt.translate(-11, 11),
            pulseAt.translate(11, -11),
            colors.pulse,
          ),
      );

      // Sparkle and the small dot.
      canvas.save();
      final sparkleScale = k * (1 + 0.18 * twinkle);
      canvas.translate(388, 150);
      canvas.scale(sparkleScale);
      canvas.translate(-388, -150);
      canvas.drawPath(
        _sparkle,
        Paint()
          ..shader = _linear(
            const Rect.fromLTWH(364, 126, 48, 48),
            colors.glow,
            reverse: true,
          ),
      );
      canvas.restore();
      canvas.drawCircle(
        const Offset(114, 374),
        8 * k,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(106, 382),
            const Offset(122, 366),
            colors.pulse,
          ),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.colors != colors ||
      old.draw != draw ||
      old.travel != travel ||
      old.twinkle != twinkle ||
      old.tile != tile;
}
