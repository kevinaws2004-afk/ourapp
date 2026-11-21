import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/color_tokens.dart';

/// The app's name, in one place.
const appBrandName = 'DayMeter';

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
      // The leaves: the action color into the accent and back to primary.
      glow: [lighter(c.action, 0.15), lighter(c.accent, 0.2), c.brandPrimary],
      // Accents (unused by the bonsai; kept for the flat icon variants).
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

/// The bonsai mark in the theme's colors. [tile] draws it on its rounded
/// app-icon square.
///
/// [draw] (0–1) grows it in: pot and trunk, then the leaf pads; [travel]
/// (0–1) sways the tree. Still, it's the finished logo.
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

/// [AppLogo] while something loads: the bonsai grows in, then sways gently
/// for as long as it's shown. Still when animations are turned off.
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

/// Paints the mark, a bonsai, in a 512×512 design space scaled to the
/// canvas: three cloud-shaped leaf pads on a curved trunk, in a pot. Small
/// daily care, grown into something beautiful, which
/// is what the app is about. While loading ([draw] < 1) the pot and trunk
/// come first and the pads grow in one by one; [travel] sways the tree
/// gently. [twinkle] isn't drawn any more (kept so callers don't change).
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

  /// The trunk: a spine rising from the pot with one branch curving out
  /// and back down to it, a soft "D" (for DayMeter) that still reads as a
  /// tree.
  static final Path _spine = Path()
    ..moveTo(228, 354)
    ..cubicTo(220, 300, 236, 250, 226, 200)
    ..cubicTo(220, 170, 224, 150, 230, 132);

  static final Path _bowl = Path()
    ..moveTo(228, 150)
    ..cubicTo(312, 140, 366, 190, 362, 244)
    ..cubicTo(358, 302, 300, 342, 236, 338);

  /// A short branch out to the left pad, for balance.
  static final Path _leftBranch = Path()
    ..moveTo(226, 262)
    ..quadraticBezierTo(196, 258, 170, 240);

  /// The leaf pads: wide leaves overlapping like a little cloud, on the top
  /// of the D, on the outside of its curve and on the left branch. Each
  /// with where it grows from.
  static const List<(List<(double, double, double, double)>, Offset)> _pads = [
    (
      [(178, 136, 50, 32), (232, 114, 58, 40), (288, 132, 46, 30)],
      Offset(230, 150),
    ),
    ([(354, 236, 40, 28), (396, 222, 42, 30)], Offset(362, 244)),
    ([(144, 236, 36, 24), (178, 226, 40, 28)], Offset(170, 240)),
  ];

  static final Path _pot = Path()
    ..moveTo(166, 370)
    ..lineTo(346, 370)
    ..lineTo(326, 416)
    ..quadraticBezierTo(322, 426, 310, 426)
    ..lineTo(202, 426)
    ..quadraticBezierTo(190, 426, 186, 416)
    ..close();

  Shader _linear(Rect r, List<Color> c) => ui.Gradient.linear(
    r.topLeft,
    r.bottomRight,
    c,
    c.length == 3 ? const [0, 0.5, 1] : null,
  );

  Color _deeper(Color c, double t) =>
      Color.lerp(c, const Color(0xFF1B1030), t)!;

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
      // A soft sun behind the tree.
      canvas.drawCircle(
        const Offset(256, 224),
        150,
        Paint()..color = colors.ring.withValues(alpha: 0.07),
      );
    }

    final appear = draw.clamp(0.0, 1.0);
    final base = Curves.easeOut.transform((appear / 0.3).clamp(0.0, 1.0));
    final potColor = colors.flow.first;
    final trunkColor = _deeper(colors.flow.first, 0.55);

    // A soft shadow under the pot.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(256, 432), width: 210, height: 18),
      Paint()
        ..color = colors.ring.withValues(alpha: 0.16 * base)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // The tree sways a little around the trunk's foot.
    final sway = travel == null ? 0.0 : math.sin(travel! * 2 * math.pi) * 0.025;
    canvas.save();
    canvas.translate(250, 344);
    canvas.rotate(sway);
    canvas.scale(1, base);
    canvas.translate(-250, -344);
    final wood = Paint()
      ..color = trunkColor.withValues(alpha: base)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_spine, wood..strokeWidth = 30);
    canvas.drawPath(_bowl, wood..strokeWidth = 22);
    canvas.drawPath(_leftBranch, wood..strokeWidth = 14);
    canvas.restore();

    canvas.save();
    canvas.translate(250, 344);
    canvas.rotate(sway * 1.6);
    canvas.translate(-250, -344);
    final leaves = _linear(const Rect.fromLTWH(140, 70, 280, 260), colors.glow);
    for (final (i, (circles, from)) in _pads.indexed) {
      final k = Curves.easeOutBack.transform(
        ((appear - 0.25 - i * 0.18) / 0.35).clamp(0.0, 1.0),
      );
      if (k <= 0) continue;
      canvas.save();
      canvas.translate(from.dx, from.dy);
      canvas.scale(k);
      canvas.translate(-from.dx, -from.dy);
      // Back leaves first; a thin rim on each front leaf shows the overlap.
      for (final (j, (x, y, rx, ry)) in circles.indexed) {
        final leaf = Rect.fromCenter(
          center: Offset(x, y),
          width: rx * 2,
          height: ry * 2,
        );
        if (j > 0) {
          canvas.drawOval(
            leaf.inflate(3),
            Paint()..color = colors.tile.last.withValues(alpha: 0.85),
          );
        }
        canvas.drawOval(leaf, Paint()..shader = leaves);
      }
      canvas.restore();
    }
    canvas.restore();

    // The pot: rim and body.
    canvas.drawPath(
      _pot,
      Paint()
        ..shader = _linear(const Rect.fromLTWH(166, 360, 180, 70), [
          potColor,
          _deeper(potColor, 0.25),
        ]),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(148, 344, 364, 376, const Radius.circular(14)),
      Paint()..color = _deeper(potColor, 0.2),
    );
    // A small highlight on the pot.
    canvas.drawRRect(
      RRect.fromLTRBR(186, 384, 198, 410, const Radius.circular(6)),
      Paint()..color = colors.node.withValues(alpha: 0.35),
    );

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
