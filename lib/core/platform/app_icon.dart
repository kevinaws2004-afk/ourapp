import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../design/themes/app_theme_id.dart';

/// The home-screen icon in the color theme's colors (`IconSwitcher.kt`,
/// daylog/icon). Does nothing off Android or when nothing changes.
class AppIconSwitcher {
  const AppIconSwitcher();

  static const _channel = MethodChannel('daylog/icon');

  Future<void> set(AppThemeId theme) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('set', {'theme': theme.name});
    } on PlatformException {
      // The old icon stays; nothing else depends on it.
    } on MissingPluginException {
      // Tests.
    }
  }
}
