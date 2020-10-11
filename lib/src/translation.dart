import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

/// A class that provides translations based on localization.
class TranslationLocalizations {
  /// Creates translation helper class for specific localization.
  TranslationLocalizations(this.locale);

  /// The locale that specify translations.
  final Locale locale;

  /// Returns the localized resources object for the widget tree that corresponds to the given [context].
  static TranslationLocalizations of(BuildContext context) {
    return Localizations.of<TranslationLocalizations>(context, TranslationLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
    'en': <String, String>{
      'title': 'Trees Quiz',
    },
    'pl': <String, String>{
      'title': 'Quiz o drzewach',
    },
  };

  /// Returns translation of text with given [label] based of localization.
  String getTranslation(String label) {
    if (locale.languageCode == null) {
      return _localizedValues['en'][label];
    }
    return _localizedValues[locale.languageCode][label];
  }
}

/// A [LocalizationsDelegate] that adds [TranslationLocalizations] localized resources.
class TranslationLocalizationsDelegate extends LocalizationsDelegate<TranslationLocalizations> {
  /// Creates a translation localizations delegate.
  const TranslationLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  Future<TranslationLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<TranslationLocalizations>(TranslationLocalizations(locale));
  }

  @override
  bool shouldReload(TranslationLocalizationsDelegate old) => false;
}
