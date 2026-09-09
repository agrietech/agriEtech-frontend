import 'package:flutter/material.dart';

/// One language the app ships UI translations for.
@immutable
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.shortLabel,
  });

  /// ISO 639-1 code, also the key into `AppLocalizations`' tables.
  final String code;

  /// Endonym, shown to speakers of the language.
  final String nativeName;

  /// Exonym, shown alongside the endonym so any user can find their language.
  final String englishName;

  /// Two-or-three character label for compact switchers.
  final String shortLabel;

  Locale get locale => Locale(code);

  /// `አማርኛ (Amharic)` — the form used in pickers.
  String get pickerLabel =>
      nativeName == englishName ? nativeName : '$nativeName ($englishName)';
}

/// Single source of truth for the languages the app offers.
///
/// `MaterialApp.supportedLocales`, the profile picker and the drawer switcher
/// all derive from this list, so adding a language no longer means editing
/// three places that can silently drift apart.
///
/// Note: `om`, `ti` and `so` have no bundled framework translations — see
/// `kLocaleFrameworkFallbacks` in `fallback_localizations.dart`.
abstract final class AppLanguages {
  static const List<AppLanguage> all = <AppLanguage>[
    AppLanguage(
      code: 'en',
      nativeName: 'English',
      englishName: 'International',
      shortLabel: 'EN',
    ),
    AppLanguage(
      code: 'am',
      nativeName: 'አማርኛ',
      englishName: 'Amharic',
      shortLabel: 'አማ',
    ),
    AppLanguage(
      code: 'om',
      nativeName: 'Afaan Oromoo',
      englishName: 'Oromo',
      shortLabel: 'OM',
    ),
    AppLanguage(
      code: 'ti',
      nativeName: 'ትግርኛ',
      englishName: 'Tigrinya',
      shortLabel: 'ትግ',
    ),
    AppLanguage(
      code: 'so',
      nativeName: 'Soomaali',
      englishName: 'Somali',
      shortLabel: 'SO',
    ),
  ];

  /// Language used when nothing is stored, or a stored code is retired.
  static const String fallbackCode = 'en';

  static List<String> get codes =>
      all.map((AppLanguage l) => l.code).toList(growable: false);

  static List<Locale> get locales =>
      all.map((AppLanguage l) => l.locale).toList(growable: false);

  static bool isSupported(String? code) =>
      code != null && codes.contains(code);

  /// Metadata for [code], falling back to English for unknown codes.
  static AppLanguage byCode(String code) => all.firstWhere(
        (AppLanguage l) => l.code == code,
        orElse: () => all.first,
      );

  /// Next language in the list — powers the one-tap cycle in the app bar.
  static String nextAfter(String code) {
    final int index = codes.indexOf(code);
    if (index == -1) return fallbackCode;
    return codes[(index + 1) % codes.length];
  }
}
