import '../../../core/design/themes/app_theme_id.dart';

/// Light, dark, or following the phone's setting.
enum AppearanceMode {
  system,
  light,
  dark;

  /// Light until the person chooses otherwise.
  static const fallback = light;

  static AppearanceMode fromName(Object? name) {
    for (final m in values) {
      if (m.name == name) return m;
    }
    return fallback;
  }
}

/// All preferences read at once, used at startup so the first frame already
/// has the right theme and route.
class PreferencesSnapshot {
  const PreferencesSnapshot({
    required this.theme,
    required this.onboardingCompleted,
    this.appearance = AppearanceMode.fallback,
    this.name = '',
    this.trueBlack = false,
  });

  static const defaults = PreferencesSnapshot(
    theme: AppThemeId.fallback,
    onboardingCompleted: false,
  );

  final AppThemeId theme;
  final bool onboardingCompleted;
  final AppearanceMode appearance;

  /// What the app calls you; empty until you tell it.
  final String name;

  /// Dark mode on pure black (OLED phones).
  final bool trueBlack;

  @override
  bool operator ==(Object other) =>
      other is PreferencesSnapshot &&
      other.theme == theme &&
      other.onboardingCompleted == onboardingCompleted &&
      other.appearance == appearance &&
      other.name == name &&
      other.trueBlack == trueBlack;

  @override
  int get hashCode =>
      Object.hash(theme, onboardingCompleted, appearance, name, trueBlack);
}
