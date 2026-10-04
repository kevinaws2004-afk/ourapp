import 'dart:math' as math;

/// A value axis with round steps (A22): no repeated labels, the top a step.
class ChartAxis {
  const ChartAxis({required this.interval, required this.max});

  /// The step between labelled lines.
  final double interval;

  /// The top of the axis, a whole number of steps.
  final double max;

  /// About [targetSteps] round steps (1, 2, 2.5 or 5 × a power of ten) up
  /// to at least [maxValue]. With [wholeNumbers] (counts) steps are whole.
  factory ChartAxis.fit(
    double maxValue, {
    bool wholeNumbers = false,
    int targetSteps = 4,
  }) {
    if (maxValue <= 0) return const ChartAxis(interval: 1, max: 1);
    final raw = maxValue / targetSteps;
    final magnitude = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    var interval = magnitude * 10;
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (magnitude * m >= raw) {
        interval = magnitude * m;
        break;
      }
    }
    if (wholeNumbers) interval = math.max(1, interval.ceilToDouble());
    final steps = (maxValue / interval).ceil();
    return ChartAxis(interval: interval, max: math.max(1, steps) * interval);
  }
}
