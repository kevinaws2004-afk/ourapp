import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Focus mode on the phone (`MainActivity.kt`, daylog/focusmode): pins the
/// app with Android's app pinning, so the timer stays in front until the
/// person ends focus mode, and keeps the screen on. Every call is safe
/// elsewhere (iOS, tests): it does nothing.
class FocusModePlatform {
  const FocusModePlatform();

  static const _channel = MethodChannel('daylog/focusmode');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<T?> _call<T>(String method) async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<T>(method);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Pins the app and keeps the screen on. False if pinning was refused.
  Future<bool> start() async => await _call<bool>('start') ?? false;

  /// Unpins and lets the screen sleep again.
  Future<void> stop() => _call<void>('stop');

  /// Whether the app is pinned right now (the person may have unpinned it).
  Future<bool> isPinned() async => await _call<bool>('isPinned') ?? false;
}
