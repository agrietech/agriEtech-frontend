import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Locales the app offers that `flutter_localizations` has no built-in
/// `MaterialLocalizations` / `CupertinoLocalizations` for, mapped to the
/// closest locale that *is* bundled.
///
/// Without these fallbacks, `Localizations` silently skips the unsupported
/// Global delegates, `MaterialLocalizations.of(context)` returns null, and
/// every Material widget that reads it (drawer tooltip, back button label,
/// date/time pickers, text-selection toolbar) throws — so picking one of
/// these languages broke the app.
///
/// Base locale is chosen by script so built-in framework strings stay legible:
///   * `om` (Afaan Oromoo) and `so` (Soomaali) use the Latin script -> `en`
///   * `ti` (ትግርኛ) uses the Ge'ez script, like Amharic          -> `am`
const Map<String, String> kLocaleFrameworkFallbacks = <String, String>{
  'om': 'en',
  'so': 'en',
  'ti': 'am',
};

/// Supplies `MaterialLocalizations` for the locales in
/// [kLocaleFrameworkFallbacks].
///
/// Register this *after* [GlobalMaterialLocalizations.delegate] so natively
/// supported locales (`en`, `am`) keep their real translations —
/// `Localizations` uses the first delegate that both supports the locale and
/// provides the type.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kLocaleFrameworkFallbacks.containsKey(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final base = kLocaleFrameworkFallbacks[locale.languageCode] ?? 'en';
    return GlobalMaterialLocalizations.delegate.load(Locale(base));
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Supplies `CupertinoLocalizations` for the locales in
/// [kLocaleFrameworkFallbacks]. Needed by Cupertino-flavoured widgets such as
/// `CupertinoDatePicker` and the iOS-style text-selection controls.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kLocaleFrameworkFallbacks.containsKey(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final base = kLocaleFrameworkFallbacks[locale.languageCode] ?? 'en';
    return GlobalCupertinoLocalizations.delegate.load(Locale(base));
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Supplies `WidgetsLocalizations` (text direction, reorder hints) for the
/// locales in [kLocaleFrameworkFallbacks]. All five app languages are
/// left-to-right, so the Latin/Ge'ez base mapping is safe here too.
class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kLocaleFrameworkFallbacks.containsKey(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    final base = kLocaleFrameworkFallbacks[locale.languageCode] ?? 'en';
    return GlobalWidgetsLocalizations.delegate.load(Locale(base));
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}
