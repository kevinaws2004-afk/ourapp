import 'package:daylog/shared/widgets/charts/chart_axis.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chart axes step in round, distinct values (A22).
void main() {
  test('a count of 1 gets whole steps, never "1, 1, 0"', () {
    final axis = ChartAxis.fit(1, wholeNumbers: true);
    expect(axis.interval, 1);
    expect(axis.max, 1);
  });

  test('round steps cover the highest value', () {
    final axis = ChartAxis.fit(960);
    expect(axis.interval, 250);
    expect(axis.max, 1000);
    expect(ChartAxis.fit(37).interval, 10);
    expect(ChartAxis.fit(37).max, 40);
  });

  test('whole-number axes never step below 1', () {
    expect(ChartAxis.fit(3, wholeNumbers: true).interval, 1);
    expect(ChartAxis.fit(3).interval, 1);
    expect(ChartAxis.fit(0.6).interval, 0.2);
  });

  test('an empty chart still has an axis', () {
    final axis = ChartAxis.fit(0);
    expect((axis.interval, axis.max), (1.0, 1.0));
  });
}
