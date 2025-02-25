import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(ColorScheme? dynamicColor) {
    final colorScheme = dynamicColor ?? ColorScheme.fromSeed(
      seedColor: const Color(0xFF382469),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      fontFamily: "Comfortaa",
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 60.0,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
    );
  }

  static ThemeData dark(ColorScheme? dynamicColor) {
    final colorScheme = dynamicColor ?? ColorScheme.fromSeed(
      seedColor: const Color(0xFF382469),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      fontFamily: "Comfortaa",
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 60.0,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
    );
  }
}