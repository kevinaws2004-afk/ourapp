import 'theme_preference.dart';

/// All preferences read at once, used at startup so the first frame already
/// has the right theme and route.
class PreferencesSnapshot {
  const PreferencesSnapshot({
    required this.themePreference,
    required this.onboardingCompleted,
  });

  static const defaults = PreferencesSnapshot(
    themePreference: ThemePreference.system,
    onboardingCompleted: false,
  );

  final ThemePreference themePreference;
  final bool onboardingCompleted;

  @override
  bool operator ==(Object other) =>
      other is PreferencesSnapshot &&
      other.themePreference == themePreference &&
      other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode => Object.hash(themePreference, onboardingCompleted);
}
