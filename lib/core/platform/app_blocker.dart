import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Apps people most often lose time in, shown first when choosing what to
/// block (many don't declare a category).
const commonDistractions = {
  'com.instagram.android',
  'com.google.android.youtube',
  'com.zhiliaoapp.musically',
  'com.ss.android.ugc.trill',
  'com.facebook.katana',
  'com.facebook.lite',
  'com.twitter.android',
  'com.snapchat.android',
  'com.reddit.frontpage',
  'com.netflix.mediaclient',
  'in.startv.hotstar',
  'com.amazon.avod.thirdpartyclient',
  'com.pinterest',
  'com.linkedin.android',
  'org.telegram.messenger',
  'com.whatsapp',
  'com.discord',
  'tv.twitch.android.app',
  'com.spotify.music',
};

/// An app on the phone that can be blocked while focusing.
class LaunchableApp {
  const LaunchableApp(
    this.package,
    this.label, [
    this.icon,
    this.distracting = false,
  ]);

  final String package;
  final String label;

  /// A game, social or video app (Android's category), or a well-known one.
  final bool distracting;

  /// Its launcher icon as a small PNG, when Android gave one.
  final Uint8List? icon;
}

/// Focus-mode app blocking (`AppBlockerService.kt`): while a session runs,
/// opening a chosen app sends you back here. Needs the person to turn the
/// service on in Accessibility settings once. Every call is safe elsewhere
/// (iOS, tests): it does nothing.
class AppBlocker {
  const AppBlocker();

  static const _channel = MethodChannel('daylog/blocker');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<T?> _call<T>(String method, [Object? args]) async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Whether the service is on in Accessibility settings.
  Future<bool> isEnabled() async => await _call<bool>('isEnabled') ?? false;

  /// Opens Accessibility settings, where the service is turned on.
  Future<void> openSettings() => _call<void>('openSettings');

  /// The apps that could be blocked, by name.
  Future<List<LaunchableApp>> apps() async {
    final list = await _call<List<Object?>>('apps') ?? const [];
    return [
      for (final item in list)
        if (item case {'package': final String p, 'label': final String l})
          LaunchableApp(
            p,
            l,
            (item as Map)['icon'] as Uint8List?,
            item['distracting'] == true || commonDistractions.contains(p),
          ),
    ];
  }

  Future<void> setBlocked(List<String> packages) =>
      _call<void>('setBlocked', {'packages': packages});

  /// Blocks now (a session is running) or not.
  Future<void> setActive({required bool active}) =>
      _call<void>('setActive', {'active': active});
}
