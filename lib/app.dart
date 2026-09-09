import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_languages.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/fallback_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/storage/app_preferences.dart';
import 'core/theme/app_theme.dart';

/// Main application widget
class EthioFarmApp extends ConsumerWidget {
  const EthioFarmApp({super.key});

  /// Upper bound on OS font scaling.
  ///
  /// Honouring the device accessibility setting matters for the older,
  /// low-vision farmers this app serves, but the dense telemetry cards start
  /// clipping past ~1.3x, so scaling is clamped rather than ignored.
  static const double _maxTextScale = 1.3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.watch(appPreferencesProvider);

    // Persist preference changes. Kept here rather than in the providers so
    // both stay plain StateProviders that any call site can set directly.
    ref.listen<String>(appLocaleProvider, (_, String next) {
      prefs?.setLocale(next);
    });
    ref.listen<ThemeMode>(themeModeProvider, (_, ThemeMode next) {
      prefs?.setThemeMode(next);
    });

    return MaterialApp.router(
      title: 'EthioFarm',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(currentLang),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // Bundled framework translations. These cover 'en' and 'am' only.
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Must come last: fills in 'om', 'ti' and 'so', which the Global
        // delegates above do not support. Without these, MaterialLocalizations
        // is absent for those locales and every Material widget that reads it
        // throws.
        FallbackMaterialLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLanguages.locales,
      builder: (context, child) {
        final TextScaler scaler = MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: _maxTextScale);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child!,
        );
      },
>>>>>>> develop
    );
  }
}
