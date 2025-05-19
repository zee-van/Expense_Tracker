import 'package:flutter/material.dart';
import 'package:expense_tracker/model/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _isDarkMode;
  ThemeProvider(this._themeData)
    : _isDarkMode = _themeData.brightness == Brightness.dark {
    _loadThemeFromPrefs();
  }

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
    _saveThemeToPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _isDarkMode = isDark;
    _themeData = isDark ? AppTheme.darkMode : AppTheme.lightMode;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }
}
