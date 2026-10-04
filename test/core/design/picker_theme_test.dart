import 'package:daylog/core/design/app_theme.dart';
import 'package:daylog/core/design/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The date and time pickers are themed from tokens, not stock Material
/// (A26): brand selection, never the coral accent for AM/PM.
void main() {
  for (final (name, theme, c) in [
    ('light', AppTheme.light, AppColors.light),
    ('dark', AppTheme.dark, AppColors.dark),
  ]) {
    test('$name: time picker selection is brand soft', () {
      final time = theme.timePickerTheme;
      Color? resolve(Color? color, Set<WidgetState> states) =>
          color is WidgetStateColor ? color.resolve(states) : color;
      expect(
        resolve(time.dayPeriodColor, {WidgetState.selected}),
        c.brandPrimarySoft,
      );
      expect(
        resolve(time.hourMinuteColor, {WidgetState.selected}),
        c.brandPrimarySoft,
      );
      expect(time.dialHandColor, c.brandPrimary);
      expect(time.backgroundColor, c.surfaceRaised);
    });

    test('$name: date picker selects in brand', () {
      final date = theme.datePickerTheme;
      expect(
        date.dayBackgroundColor?.resolve({WidgetState.selected}),
        c.brandPrimary,
      );
      expect(date.todayBorder?.color, c.brandPrimary);
      expect(date.backgroundColor, c.surfaceRaised);
    });
  }
}
