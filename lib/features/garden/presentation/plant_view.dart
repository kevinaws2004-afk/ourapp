import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/day_streak.dart';

/// The plant that grows with every day something gets done: a seed in a
/// pot, then a sprout, leaves, buds, flowers, a little tree. [thirsty]
/// (nothing done yet today) droops it a little and dulls its green; it
/// perks up the moment something's done. Sways gently unless animations
/// are off.
class PlantView extends StatefulWidget {
  const PlantView({
    super.key,
    required this.stage,
    required this.thirsty,
    this.size = 88,
  });

  final PlantStage stage;
  final bool thirsty;
  final double size;

  @override
  State<PlantView> createState() => _PlantViewState();
}

class _PlantViewState extends State<PlantView>
    with SingleTickerProviderStateMixin {
  late final _sway = AnimationController(
    vsync: this,
    value: 0.5,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _swayAWhile();
  }

  @override
  void didUpdateWidget(PlantView old) {
    super.didUpdateWidget(old);
    if (old.thirsty != widget.thirsty || old.stage != widget.stage) {
      _swayAWhile();
    }
  }

  /// A few gentle sways when it appears or changes, then still (a plant
  /// that never stops moving is tiring, and keeps the screen busy).
  void _swayAWhile() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _sway.value = 0.5;
      return;
    }
    if (_sway.isAnimating) return;
    unawaited(
      _sway
          .repeat(reverse: true, count: 3)
          .then((_) => _sway.animateTo(0.5), onError: (_) {}),
    );
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      // 1 = perky, 0 = thirsty; eases between them when watered.
      tween: Tween(end: widget.thirsty ? 0 : 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, perk, _) => AnimatedBuilder(
        animation: _sway,
        builder: (context, _) => CustomPaint(
          size: Size(widget.size, widget.size * 1.1),
          painter: _PlantPainter(
            stage: widget.stage,
            perk: perk,
            sway: Curves.easeInOut.transform(_sway.value) * 2 - 1,
            dark: dark,
          ),
        ),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  _PlantPainter({
    required this.stage,
    required this.perk,
    required this.sway,
    required this.dark,
  });

  final PlantStage stage;
  final double perk;
  final double sway;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final level = stage.index;
    // Greens: dull when thirsty, fresh when watered.
    final fresh = dark ? const Color(0xFF6FD08C) : const Color(0xFF3FAE62);
    final dull = dark ? const Color(0xFF8F9A7C) : const Color(0xFF9AA37A);
    final leaf = Color.lerp(dull, fresh, perk.clamp(0, 1))!;
    final leafDark = Color.lerp(leaf, Colors.black, 0.18)!;
    final stem = Color.lerp(leafDark, const Color(0xFF6B8E4E), 0.4)!;

    // The pot.
    final potTop = h * 0.72;
    final pot = Path()
      ..moveTo(w * 0.24, potTop)
      ..lineTo(w * 0.76, potTop)
      ..lineTo(w * 0.68, h * 0.98)
      ..lineTo(w * 0.32, h * 0.98)
      ..close();
    canvas.drawPath(pot, Paint()..color = const Color(0xFFD9825B));
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.2,
        potTop - h * 0.05,
        w * 0.8,
        potTop + h * 0.03,
        Radius.circular(w * 0.03),
      ),
      Paint()..color = const Color(0xFFC46E48),
    );
    // Soil.
    canvas.drawOval(
      Rect.fromLTRB(w * 0.27, potTop - h * 0.055, w * 0.73, potTop - h * 0.01),
      Paint()..color = const Color(0xFF6B4A3A),
    );

    final base = Offset(w / 2, potTop - h * 0.035);
    if (stage == PlantStage.seed) {
      canvas.drawOval(
        Rect.fromCenter(
          center: base.translate(0, -h * 0.02),
          width: w * 0.1,
          height: h * 0.06,
        ),
        Paint()..color = const Color(0xFF9C7A54),
      );
      return;
    }

    // The stem: taller with each stage, leaning with the sway, bent over a
    // little when thirsty.
    final height = h * (0.16 + 0.07 * math.min(level, 6));
    final droop = (1 - perk) * w * 0.12;
    final lean = sway * w * 0.025;
    final top = base.translate(lean + droop, -height + (1 - perk) * h * 0.04);
    final stemPath = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + lean * 0.3,
        base.dy - height * 0.55,
        top.dx,
        top.dy,
      );
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = stem
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * (level >= 6 ? 0.07 : 0.035),
    );

    Offset along(double t) {
      final mt = 1 - t;
      final cx = base.dx + lean * 0.3;
      final cy = base.dy - height * 0.55;
      return Offset(
        mt * mt * base.dx + 2 * mt * t * cx + t * t * top.dx,
        mt * mt * base.dy + 2 * mt * t * cy + t * t * top.dy,
      );
    }

    void drawLeaf(Offset at, double angle, double length) {
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        // Thirsty leaves hang lower.
        ..rotate(angle + (angle > 0 ? 1 : -1) * (1 - perk) * 0.6);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.5, -length * 0.38, length, 0)
        ..quadraticBezierTo(length * 0.5, length * 0.38, 0, 0);
      canvas
        ..drawPath(path, Paint()..color = leaf)
        ..drawLine(
          Offset.zero,
          Offset(length * 0.85, 0),
          Paint()
            ..color = leafDark
            ..strokeWidth = 1,
        )
        ..restore();
    }

    if (level >= 6) {
      // A little tree: a round, layered canopy.
      final r = w * (level >= 7 ? 0.3 : 0.25);
      final canopy = top.translate(0, -r * 0.4);
      for (final (dx, dy, k) in [
        (-0.55, 0.25, 0.75),
        (0.55, 0.25, 0.75),
        (0.0, -0.2, 1.0),
      ]) {
        canvas.drawCircle(
          canopy.translate(dx * r, dy * r),
          r * k,
          Paint()..color = k == 1 ? leaf : leafDark,
        );
      }
      if (level >= 7) {
        for (final (dx, dy) in [(-0.5, -0.1), (0.35, 0.2), (0.1, -0.55)]) {
          canvas.drawCircle(
            canopy.translate(dx * r, dy * r),
            w * 0.035,
            Paint()..color = const Color(0xFFE8556D),
          );
        }
      }
      return;
    }

    // Pairs of leaves up the stem, more with each stage.
    final pairs = switch (stage) {
      PlantStage.sprout => 1,
      PlantStage.seedling => 2,
      PlantStage.young => 3,
      _ => 4,
    };
    final leafLength = w * (0.16 + 0.025 * level);
    for (var i = 0; i < pairs; i++) {
      final t = 0.35 + 0.6 * (i + 1) / (pairs + 1);
      final at = along(t);
      final shrink = 1 - i * 0.12;
      drawLeaf(at, -math.pi + 0.5, leafLength * shrink);
      drawLeaf(at, -0.5, leafLength * shrink);
    }
    // The top: a bud, then a flower.
    if (stage == PlantStage.budding) {
      canvas.drawOval(
        Rect.fromCenter(center: top, width: w * 0.09, height: w * 0.13),
        Paint()..color = const Color(0xFFF29BB0),
      );
    } else if (stage == PlantStage.blooming) {
      final petal = Paint()
        ..color = Color.lerp(
          const Color(0xFFC9A0AA),
          const Color(0xFFF07A97),
          perk.clamp(0, 1),
        )!;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + sway * 0.1;
        canvas.drawCircle(
          top + Offset(math.cos(a), math.sin(a)) * w * 0.06,
          w * 0.045,
          petal,
        );
      }
      canvas.drawCircle(
        top,
        w * 0.04,
        Paint()..color = const Color(0xFFFFC94A),
      );
    } else {
      drawLeaf(top, -math.pi / 2 - 0.25, leafLength * 0.7);
      drawLeaf(top, -math.pi / 2 + 0.25, leafLength * 0.7);
    }
  }

  @override
  bool shouldRepaint(_PlantPainter old) =>
      old.stage != stage ||
      old.perk != perk ||
      old.sway != sway ||
      old.dark != dark;
}
