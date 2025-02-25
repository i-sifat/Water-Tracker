import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(ColorScheme? dynamicColor) {
    final colorScheme = dynamicColor ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF382469),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Comfortaa',
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
          fontSize: 60,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData dark(ColorScheme? dynamicColor) {
    final colorScheme = dynamicColor ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF382469),
          brightness: Brightness.dark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Comfortaa',
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
          fontSize: 60,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
    );
  }
}
