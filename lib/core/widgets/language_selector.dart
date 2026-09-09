import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_languages.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_extension.dart';
import '../theme/app_theme.dart';

/// Shared language-switching UI.
///
/// Every entry point (drawer, profile, app bar) renders from
/// [AppLanguages.all], so the set of offered languages cannot drift between
/// screens the way the old hard-coded English/Amharic toggle did.
abstract final class LanguageSelector {
  /// Bottom sheet listing every shipped language.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => const _LanguageSheet(),
    );
  }
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLang = ref.watch(appLocaleProvider);
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.language_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.tr('language'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            for (final AppLanguage language in AppLanguages.all)
              _LanguageOption(
                language: language,
                selected: language.code == currentLang,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(appLocaleProvider.notifier).state = language.code;
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: '${language.nativeName}, ${language.englishName}',
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.radiusSm,
          ),
          child: Text(
            language.shortLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          language.nativeName,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: Text(language.englishName),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}

/// Compact app-bar pill showing the active language; opens the full sheet.
///
/// Replaces the two-way English/Amharic cycle, which could never reach the
/// three other languages the app ships.
class LanguagePill extends ConsumerWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLang = ref.watch(appLocaleProvider);
    final AppLanguage language = AppLanguages.byCode(currentLang);
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Change language. Current: ${language.englishName}',
      child: Tooltip(
        message: language.pickerLabel,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            LanguageSelector.show(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  language.shortLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer row that reports the active language and opens the full sheet.
class LanguageDrawerTile extends ConsumerWidget {
  const LanguageDrawerTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLang = ref.watch(appLocaleProvider);
    final AppLanguage language = AppLanguages.byCode(currentLang);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: Semantics(
        button: true,
        label: 'Change language. Current: ${language.englishName}',
        child: InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: () {
            HapticFeedback.lightImpact();
            LanguageSelector.show(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: isDark ? Colors.white70 : const Color(0xFF14532D),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.tr('language'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF14532D),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
