import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'tokens/color_tokens.dart';

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;

  AppColors get colors => tokens.colors;

  TextTheme get textStyles => Theme.of(this).textTheme;
}
