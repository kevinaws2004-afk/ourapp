import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android's Do Not Disturb, for focus timers (`MainActivity.kt`). Needs
/// the person to allow Daylog under "Do Not Disturb access" once. Every
/// call is safe elsewhere (iOS, tests): it does nothing and reports false.
class DoNotDisturb {
  const DoNotDisturb();

  static const _channel = MethodChannel('daylog/dnd');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasAccess() async {
    if (!_supported) return false;
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens the system screen where Daylog can be allowed.
  Future<void> requestAccess() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('requestAccess');
    } on PlatformException {
      // No such screen on this phone.
    } on MissingPluginException {
      // Not available.
    }
  }

  /// Silences the phone (priority only), or puts back what it was.
  Future<bool> set({required bool on}) async {
    if (!_supported) return false;
    try {
      return await _channel.invokeMethod<bool>('set', {'on': on}) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
