import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi');
  
  Locale get locale => _locale;
  
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString('countryCode', locale.countryCode!);
      } else {
        await prefs.remove('countryCode');
      }
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }
  
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode');
      final countryCode = prefs.getString('countryCode');
      
      if (languageCode != null && languageCode.isNotEmpty) {
        _locale = Locale(languageCode, countryCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load saved locale: $e');
    }
  }
}
