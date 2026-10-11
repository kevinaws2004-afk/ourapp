import '../../../core/design/themes/app_theme_id.dart';
import 'preferences_snapshot.dart';

/// App-wide preferences. A missing value means "use the default".
abstract interface class AppPreferencesRepository {
  Future<PreferencesSnapshot> load();

  /// The chosen theme (ADR-045).
  Stream<AppThemeId> watchTheme();

  Future<void> setTheme(AppThemeId value);

  Stream<bool> watchOnboardingCompleted();

  Future<void> setOnboardingCompleted({required bool completed});

  Stream<AppearanceMode> watchAppearance();

  Future<void> setAppearance(AppearanceMode value);

  /// What the app calls you (Today's greeting, Me).
  Stream<String> watchName();

  Future<void> setName(String value);

  /// Dark mode on pure black.
  Stream<bool> watchTrueBlack();

  Future<void> setTrueBlack({required bool value});
}
