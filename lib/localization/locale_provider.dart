import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default is Arabic as requested
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isRtl => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(AppConstants.keyLocale);
    if (savedCode != null && ['ar', 'fr', 'en'].contains(savedCode)) {
      _locale = Locale(savedCode);
    } else {
      _locale = const Locale('ar');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['ar', 'fr', 'en'].contains(newLocale.languageCode)) return;
    if (_locale == newLocale) return;

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, newLocale.languageCode);
  }
}
