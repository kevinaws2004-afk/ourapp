import 'dart:math' as math;

/// A value axis with round steps (A22): no repeated labels, the ends whole
/// steps.
class ChartAxis {
  const ChartAxis({required this.interval, required this.max, this.min = 0});

  /// The step between labelled lines.
  final double interval;

  /// The bottom of the axis, a whole number of steps.
  final double min;

  /// The top of the axis, a whole number of steps.
  final double max;

  /// About [targetSteps] round steps (1, 2, 2.5 or 5 × a power of ten) from
  /// 0 up to at least [maxValue]. With [wholeNumbers] (counts) steps are
  /// whole.
  factory ChartAxis.fit(
    double maxValue, {
    bool wholeNumbers = false,
    int targetSteps = 4,
  }) => ChartAxis.fitRange(
    0,
    maxValue,
    wholeNumbers: wholeNumbers,
    targetSteps: targetSteps,
  );

  /// Round steps covering `[minValue, maxValue]` without forcing zero in
  /// (D1): a body weight of 70–72 kg uses the chart's height instead of
  /// hugging its top, and negative values (°C) fit.
  factory ChartAxis.fitRange(
    double minValue,
    double maxValue, {
    bool wholeNumbers = false,
    int targetSteps = 4,
  }) {
    var low = math.min(minValue, maxValue);
    var high = math.max(minValue, maxValue);
    if (low == 0 && high <= 0) return const ChartAxis(interval: 1, max: 1);
    if (high == low) {
      // One value: give it room above and below.
      final pad = high == 0 ? 1.0 : high.abs() * 0.1;
      low -= pad;
      high += pad;
    }
    final raw = (high - low) / targetSteps;
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
    final bottom = (low / interval).floor() * interval;
    var top = (high / interval).ceil() * interval;
    if (top <= bottom) top = bottom + interval;
    // Never dip below zero for values that never do.
    final min = minValue >= 0 && bottom < 0 ? 0.0 : bottom;
    return ChartAxis(interval: interval, min: min, max: top);
  }
}
