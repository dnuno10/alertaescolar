import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _locale = const Locale('es', 'ES');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  static const List<Locale> supportedLocales = [
    Locale('es', 'ES'),
    Locale('en', 'US'),
  ];

  // Constructor que carga el idioma automáticamente
  LocaleProvider() {
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await loadSavedLanguage();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _languageKey, '${newLocale.languageCode}_${newLocale.countryCode}');

      print(
          'Language saved: ${newLocale.languageCode}_${newLocale.countryCode}');
    }
  }

  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      print('Loading saved language: $savedLanguage');

      if (savedLanguage != null && savedLanguage.contains('_')) {
        final parts = savedLanguage.split('_');
        final newLocale = Locale(parts[0], parts[1]);

        // Verificar que el locale sea soportado
        if (supportedLocales
            .any((locale) => locale.languageCode == newLocale.languageCode)) {
          _locale = newLocale;
          print('Language loaded: ${_locale.languageCode}');
        }
      }
    } catch (e) {
      print('Error loading saved language: $e');
      // Mantener el idioma por defecto si hay error
    }
  }
}
