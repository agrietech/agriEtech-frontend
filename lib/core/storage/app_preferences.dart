import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_languages.dart';

/// Non-sensitive, user-facing app preferences (language, theme).
///
/// Sensitive values (tokens, cached identity) belong in
/// `SecureStorageService` — this is deliberately the plain-text store so
/// preferences can be read synchronously during the first frame.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _localeKey = 'app_locale';
  static const String _themeModeKey = 'app_theme_mode';

  /// Stored language code, or `en` when absent or no longer shipped.
  String get locale {
    final stored = _prefs.getString(_localeKey);
    return AppLanguages.isSupported(stored) ? stored! : AppLanguages.fallbackCode;
  }

  Future<void> setLocale(String languageCode) =>
      _prefs.setString(_localeKey, languageCode);

  ThemeMode get themeMode {
    switch (_prefs.getString(_themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);
}

/// Overridden in `main()` with the instance resolved before `runApp`, so
/// preferences are available synchronously and the app never flashes the
/// wrong language or theme on launch.
///
/// Left `null` when unavailable — widget tests, or a platform where
/// `SharedPreferences` failed to initialise. Dependants fall back to
/// in-memory defaults rather than crashing at startup.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final appPreferencesProvider = Provider<AppPreferences?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs == null ? null : AppPreferences(prefs);
});

/// User-selected theme mode, seeded from disk on launch.
///
/// Writes are persisted by the `ref.listen` wiring in `EthioFarmApp`, which
/// keeps this a plain [StateProvider] that every call site can set directly.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ref.watch(appPreferencesProvider)?.themeMode ?? ThemeMode.system;
});
