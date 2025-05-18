import 'package:flutter/material.dart';
import 'package:expense_tracker/model/theme_model.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _isDarkMode;
  ThemeProvider(this._themeData)
    : _isDarkMode = _themeData.brightness == Brightness.dark;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      _themeData = AppTheme.lightMode;
      _isDarkMode = false;
    } else {
      _themeData = AppTheme.darkMode;
      _isDarkMode = true;
    }
    notifyListeners();
  }
}
