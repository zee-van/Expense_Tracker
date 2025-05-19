import 'package:flutter/material.dart';

class AppTheme {
  static final Color _lightPrimary = const Color(0xFF2E2C2C);
  static final Color _lightSecondary = const Color(0xFF474646);
  static final Color _lightBackground = Colors.grey.shade100;
  static final Color _lightSurface = Colors.grey.shade300;
  static final Color _lightOnPrimary = Colors.white;
  static final Color _lightOnSurface = Colors.black;

  static final Color _darkPrimary = Colors.grey.shade800;
  static final Color _darkSecondary = Colors.grey.shade600;
  static final Color _darkBackground = const Color(0xFF121212);
  static final Color _darkSurface = const Color(0xFF1E1E1E);
  static final Color _darkOnPrimary = Colors.black;
  static final Color _darkOnSurface = Colors.white;

  static ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: ColorScheme.light(
      surface: _lightSurface,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      secondary: _lightSecondary,
      onSecondary: Colors.white,
      onSurface: _lightOnSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightOnSurface,
      elevation: 1,
    ),
    cardTheme: CardTheme(
      color: _lightSurface,
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: _lightOnPrimary,
    ),
    iconTheme: IconThemeData(color: _lightOnSurface),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: _lightOnSurface,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: _lightOnSurface),
      labelLarge: TextStyle(color: _lightPrimary),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightSurface,
      titleTextStyle: TextStyle(
        color: _lightOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: _lightOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightPrimary),
      ),
      labelStyle: TextStyle(color: _lightPrimary),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: _lightSurface,
      textColor: _lightOnSurface,
      iconColor: _lightPrimary,
    ),
  );

  static ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: _darkBackground,
    colorScheme: ColorScheme.dark(
      surface: _darkSurface,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      secondary: _darkSecondary,
      onSecondary: Colors.black,
      onSurface: _darkOnSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkOnSurface,
      elevation: 1,
    ),
    cardTheme: CardTheme(
      color: _darkSurface,
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: _darkOnPrimary,
    ),
    iconTheme: IconThemeData(color: _darkOnSurface),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: _darkOnSurface, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: _darkOnSurface),
      labelLarge: TextStyle(color: _darkOnSurface),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkSurface,
      titleTextStyle: TextStyle(
        color: _darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: _darkOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkOnSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkPrimary),
      ),
      labelStyle: TextStyle(color: _darkOnSurface),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: _darkSurface,
      textColor: _darkOnSurface,
      iconColor: _darkOnSurface,
    ),
  );
}
