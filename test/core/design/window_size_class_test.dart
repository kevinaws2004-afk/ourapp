import 'package:daylog/core/design/window_size_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies widths at the documented breakpoints (600, 840)', () {
    expect(WindowSizeClass.fromWidth(360), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(839.9), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
    expect(WindowSizeClass.fromWidth(1280), WindowSizeClass.expanded);
  });

  test('only compact windows use the bottom navigation bar', () {
    expect(WindowSizeClass.compact.usesNavigationRail, isFalse);
    expect(WindowSizeClass.medium.usesNavigationRail, isTrue);
    expect(WindowSizeClass.expanded.usesNavigationRail, isTrue);
  });
}
