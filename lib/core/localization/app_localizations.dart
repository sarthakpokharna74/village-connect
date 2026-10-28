import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'translations.dart';

/// AppLocalizations handles language resolution and translation lookup.
/// Fully integrated with Flutter's standard localization system.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper to retrieve the current AppLocalizations instance from build context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Supported locales list
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('mr', ''), // Marathi
    Locale('hi', ''), // Hindi
  ];

  /// Static delegate instance
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// Translates a key based on the active locale. Falls back to English, then the key itself.
  String translate(String key) {
    final languageCode = locale.languageCode;
    
    // Resolve translations map or default to English
    final translations = AppTranslations.values[languageCode] ?? AppTranslations.values['en']!;
    
    // Return translation or key itself if missing
    return translations[key] ?? key;
  }
}

/// Custom delegate loader for AppLocalizations
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'mr', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Synchronous resolution prevents loading flickers on slow devices
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// Extension on BuildContext to quickly access translations:
/// e.g. context.translate('our_village')
extension LocalizationExtension on BuildContext {
  String translate(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
