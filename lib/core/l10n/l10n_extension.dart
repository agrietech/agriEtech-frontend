import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Ergonomic BuildContext extensions for localization
extension LocalizationContextExtension on BuildContext {
  /// Access AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Convenient shorthand for translation
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
