import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    primaryColor: const Color(0xFF382469),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF382469),
      secondary: Color(0xFF8762FF),
    ),
    indicatorColor: const Color(0xFF382469),
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    unselectedWidgetColor: const Color(0xFFF0F7FF),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
    ),
    fontFamily: "Comfortaa",
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF382469),
        fontWeight: FontWeight.bold,
        fontSize: 60.0,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF382469),
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
      ),
      bodySmall: TextStyle(
        color: Color(0xFFBDBDBD),
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF382469),
      selectionHandleColor: Color(0xFF382469),
      selectionColor: Color(0x1F382469),
    ),
  );
}