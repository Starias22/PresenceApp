import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  french,
}

class Language extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.french;

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }
}
