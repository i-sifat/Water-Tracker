import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Material 3 light theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.waterFull,
    ).copyWith(
      primary: AppColors.waterFull,
      secondary: AppColors.lightBlue,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textHeadline,
      outline: AppColors.unselectedBorder,
      outlineVariant: AppColors.genderUnselected,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Nunito',
      
      // Text theme
      textTheme: _buildTextTheme(colorScheme),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBar,
        foregroundColor: AppColors.textHeadline,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeadline,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.waterFull,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.unselectedBorder,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unselectedBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unselectedBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.waterFull, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Scaffold theme
      scaffoldBackgroundColor: AppColors.background,
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.waterFull,
        unselectedItemColor: AppColors.textSubtitle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.unselectedBorder, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull;
          }
          return AppColors.genderUnselected;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull.withOpacity(0.3);
          }
          return AppColors.genderUnselected.withOpacity(0.3);
        }),
      ),
    );
  }

  // Material 3 dark theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.waterFull,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.waterFull,
      secondary: AppColors.lightBlue,
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      outline: const Color(0xFF3E3E3E),
      outlineVariant: const Color(0xFF2E2E2E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Nunito',
      
      // Text theme
      textTheme: _buildTextTheme(colorScheme),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.waterFull,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.waterFull, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Scaffold theme
      scaffoldBackgroundColor: colorScheme.surface,
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.waterFull,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.waterFull.withOpacity(0.3);
          }
          return colorScheme.outline.withOpacity(0.3);
        }),
      ),
    );
  }

  // Build text theme for both light and dark themes
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 45,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        height: 1.22,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.33,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.43,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.7),
        height: 1.33,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.45,
      ),
    );
  }
}