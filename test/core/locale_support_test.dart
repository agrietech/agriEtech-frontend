import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:EthioFarm/core/l10n/app_languages.dart';
import 'package:EthioFarm/core/l10n/app_localizations.dart';
import 'package:EthioFarm/core/l10n/fallback_localizations.dart';

void main() {
  // Mirrors the delegate stack configured in lib/app.dart.
  Widget buildApp(String lang) => MaterialApp(
        locale: Locale(lang),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackWidgetsLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        supportedLocales: AppLanguages.locales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            drawer: const Drawer(),
            appBar: AppBar(title: const Text('l10n')),
            body: Column(
              children: <Widget>[
                // Each of these throws if its localizations are missing.
                Text(MaterialLocalizations.of(context).okButtonLabel),
                Text(CupertinoLocalizations.of(context).todayLabel),
                Text(WidgetsLocalizations.of(context).reorderItemUp),
              ],
            ),
          ),
        ),
      );

  group('every shipped language resolves framework localizations', () {
    for (final AppLanguage language in AppLanguages.all) {
      testWidgets('${language.code} (${language.englishName})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildApp(language.code));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason:
              'Locale "${language.code}" failed to resolve framework '
              'localizations. If this is a newly added language, add a base '
              'locale for it to kLocaleFrameworkFallbacks.',
        );
      });
    }
  });

  group('fallback wiring', () {
    test('every fallback base locale is itself natively supported', () {
      for (final MapEntry<String, String> entry
          in kLocaleFrameworkFallbacks.entries) {
        expect(
          GlobalMaterialLocalizations.delegate.isSupported(
            Locale(entry.value),
          ),
          isTrue,
          reason:
              '"${entry.key}" falls back to "${entry.value}", which '
              'flutter_localizations does not ship either.',
        );
      }
    });

    test('fallbacks cover exactly the languages the framework lacks', () {
      final Set<String> unsupported = AppLanguages.codes
          .where(
            (String code) => !GlobalMaterialLocalizations.delegate.isSupported(
              Locale(code),
            ),
          )
          .toSet();

      expect(
        kLocaleFrameworkFallbacks.keys.toSet(),
        unsupported,
        reason:
            'kLocaleFrameworkFallbacks must name every app language that '
            'flutter_localizations does not bundle — no more, no less.',
      );
    });
  });

  group('AppLanguages', () {
    test('codes are unique', () {
      expect(AppLanguages.codes.toSet(), hasLength(AppLanguages.all.length));
    });

    test('byCode falls back to English for unknown codes', () {
      expect(AppLanguages.byCode('zz').code, 'en');
    });

    test('nextAfter cycles through every language and wraps', () {
      String code = AppLanguages.codes.first;
      final List<String> visited = <String>[code];
      for (int i = 0; i < AppLanguages.all.length - 1; i++) {
        code = AppLanguages.nextAfter(code);
        visited.add(code);
      }
      expect(visited, AppLanguages.codes);
      expect(AppLanguages.nextAfter(code), AppLanguages.codes.first);
    });
  });
}
