import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:EthioFarm/core/l10n/app_languages.dart';
import 'package:EthioFarm/core/l10n/app_localizations.dart';

void main() {
  /// Keys actually referenced by `en`, the reference table.
  Set<String> keysFor(String lang) => AppLocalizations.keysFor(lang);

  group('translation table parity', () {
    final Set<String> reference = keysFor('en');

    test('reference table is non-trivial', () {
      expect(reference.length, greaterThan(100));
    });

    for (final AppLanguage language in AppLanguages.all) {
      test('${language.code} (${language.englishName}) covers every key', () {
        final Set<String> missing = reference.difference(keysFor(language.code));
        expect(
          missing,
          isEmpty,
          reason:
              '${language.code} is missing ${missing.length} key(s): '
              '${missing.toList()..sort()}',
        );
      });
    }

    test('no locale defines a key absent from the English reference', () {
      final Map<String, List<String>> orphans = <String, List<String>>{};
      for (final AppLanguage language in AppLanguages.all) {
        final Set<String> extra = keysFor(language.code).difference(reference);
        if (extra.isNotEmpty) orphans[language.code] = extra.toList()..sort();
      }
      expect(
        orphans,
        isEmpty,
        reason:
            'Keys present in a translation but not in English will never be '
            'reachable through the English fallback: $orphans',
      );
    });
  });

  group('every language has a table', () {
    for (final AppLanguage language in AppLanguages.all) {
      test('${language.code} is registered', () {
        expect(keysFor(language.code), isNotEmpty);
      });
    }
  });

  group('translate()', () {
    test('resolves camelCase keys against snake_case entries', () {
      expect(
        AppLocalizations(const Locale('en')).translate('phoneNumber'),
        'Phone Number',
      );
    });

    test('falls back to English for an untranslated key', () {
      // 'ussd' exists in en; if a locale ever drops it the English value shows
      // rather than the raw key.
      expect(
        AppLocalizations(const Locale('ti')).translate('ussd'),
        isNot('ussd'),
      );
    });

    test('returns the key itself only when no table has it', () {
      expect(
        AppLocalizations(const Locale('en')).translate('definitely_absent_key'),
        'definitely_absent_key',
      );
    });

    test('every language resolves every key to a non-empty string', () {
      for (final AppLanguage language in AppLanguages.all) {
        final AppLocalizations l10n = AppLocalizations(language.locale);
        for (final String key in keysFor('en')) {
          final String value = l10n.translate(key);
          expect(
            value,
            isNotEmpty,
            reason: '${language.code}/$key resolved to an empty string',
          );
          expect(
            value,
            isNot(key),
            reason:
                '${language.code}/$key fell through to the raw key — the UI '
                'would show "$key" to the user',
          );
        }
      }
    });
  });
}
