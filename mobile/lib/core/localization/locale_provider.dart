import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'app_locale_code';

  Locale _locale = const Locale('km', 'KH');

  Locale get locale => _locale;
  bool get isKhmer => _locale.languageCode == 'km';
  String get languageName => isKhmer ? 'ភាសាខ្មែរ' : 'English (US)';

  LocaleProvider() {
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'en') {
        _locale = const Locale('en', 'US');
      } else {
        _locale = const Locale('km', 'KH');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale preference: $e');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (code == 'en') {
      await setLocale(const Locale('en', 'US'));
    } else {
      await setLocale(const Locale('km', 'KH'));
    }
  }
}
