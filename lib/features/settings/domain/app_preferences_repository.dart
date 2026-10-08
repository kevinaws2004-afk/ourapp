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
}
