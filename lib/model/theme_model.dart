import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.grey.shade300,
      primary: const Color.fromARGB(255, 46, 44, 44),
      secondary: const Color.fromARGB(255, 71, 70, 70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
    ),
    iconTheme: IconThemeData(color: Colors.black),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
      splashColor: Colors.grey,
    ),
  );

  static final ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: const Color.fromARGB(255, 14, 13, 13),
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      splashColor: Colors.grey,
    ),
  );
}
