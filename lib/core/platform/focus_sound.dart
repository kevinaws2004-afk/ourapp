import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Calm sounds while a focus timer runs (`NoisePlayer.kt`): made on the
/// phone, no files and nothing downloaded.
enum FocusSound { off, rain, brown, white }

/// Plays a [FocusSound] (Android); safe and silent elsewhere.
class FocusSoundPlayer {
  const FocusSoundPlayer();

  static const _channel = MethodChannel('daylog/sound');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> _call(String method, [Object? args]) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on PlatformException {
      // No sound; the timer is what matters.
    } on MissingPluginException {
      // Tests.
    }
  }

  Future<void> play(FocusSound sound) => sound == FocusSound.off
      ? stop()
      : _call('play', {'kind': sound.name});

  Future<void> stop() => _call('stop');
}
