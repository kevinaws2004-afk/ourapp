import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/day_streak.dart';
import 'garden_card.dart';
import 'plant_view.dart';

/// The moment the first thing of the day is done: confetti, the plant
/// perking up, the streak, and what it grew into or earned. Once a day.
Future<void> showStreakCelebration(
  BuildContext context, {
  required DayStreak before,
  required DayStreak after,
}) {
  unawaited(HapticFeedback.heavyImpact());
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (context, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: animation, child: child),
    ),
    pageBuilder: (context, _, _) => _Celebration(before: before, after: after),
  );
}

class _Celebration extends ConsumerWidget {
  const _Celebration({required this.before, required this.after});

  final DayStreak before;
  final DayStreak after;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final name = plantNameOf(l10n, ref);
    final stage = PlantStage.of(after.totalDays);
    final grew = stage != PlantStage.of(before.totalDays);
    final earnedRest = after.restDays > before.restDays;
    return Stack(
      children: [
        const Positioned.fill(child: IgnorePointer(child: Confetti())),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Material(
              color: c.surfaceBase,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlantView(stage: stage, thirsty: false, size: 120),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.streakCelebrateTitle(after.current),
                      textAlign: TextAlign.center,
                      style: context.textStyles.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      switch ((grew, stage)) {
                        (true, PlantStage.sprout) =>
                          l10n.streakCelebrateSprouted(name),
                        (true, _) => l10n.streakCelebrateGrew(
                          name,
                          stageName(l10n, stage),
                        ),
                        _ => l10n.streakCelebrateBody(name),
                      },
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    if (earnedRest) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '❄ ${l10n.streakCelebrateRestDay}',
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.streakCelebrateOk),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A short burst of confetti falling from the top (skipped when
/// animations are off).
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  final _pieces = List.generate(70, (i) {
    final r = math.Random(i * 7919);
    return (
      x: r.nextDouble(),
      delay: r.nextDouble() * 0.35,
      speed: 0.7 + r.nextDouble() * 0.6,
      drift: (r.nextDouble() - 0.5) * 0.3,
      spin: r.nextDouble() * 6,
      color: const [
        Color(0xFFF07A97),
        Color(0xFFFFC94A),
        Color(0xFF4FB3A9),
        Color(0xFF7C8CF8),
        Color(0xFF8BCF7A),
        Color(0xFFF0A86E),
      ][i % 6],
    );
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_controller.isAnimating) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) =>
        CustomPaint(painter: _ConfettiPainter(_controller.value, _pieces)),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.pieces);

  final double t;
  final List<
    ({
      double x,
      double delay,
      double speed,
      double drift,
      double spin,
      Color color,
    })
  >
  pieces;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -20 + local * p.speed * (size.height + 40);
      final x = (p.x + p.drift * local) * size.width;
      final paint = Paint()
        ..color = p.color.withValues(alpha: 1 - math.max(0, local - 0.8) * 5);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * local * math.pi)
        ..drawRect(const Rect.fromLTWH(-4, -2.5, 8, 5), paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
