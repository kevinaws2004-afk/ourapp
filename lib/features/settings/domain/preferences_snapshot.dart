import '../../../core/design/themes/app_theme_id.dart';

/// All preferences read at once, used at startup so the first frame already
/// has the right theme and route.
class PreferencesSnapshot {
  const PreferencesSnapshot({
    required this.theme,
    required this.onboardingCompleted,
  });

  static const defaults = PreferencesSnapshot(
    theme: AppThemeId.fallback,
    onboardingCompleted: false,
  );

  final AppThemeId theme;
  final bool onboardingCompleted;

  @override
  bool operator ==(Object other) =>
      other is PreferencesSnapshot &&
      other.theme == theme &&
      other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode => Object.hash(theme, onboardingCompleted);
}
