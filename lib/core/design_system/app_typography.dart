import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

/// Standardized typography system for consistent text styling throughout the app
class AppTypography {
  // Font family
  static const String fontFamily = 'Nunito';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Base text styles
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontWeight: regular,
  );

  // Display styles (for large text like numbers, titles)
  static final TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 89,
    fontWeight: extraBold,
    height: 1.0,
  );

  static final TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 58,
    fontWeight: bold,
    height: 1.0,
  );

  static final TextStyle displaySmall = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: medium,
    height: 1.2,
  );

  // Headline styles (for page titles, section headers)
  static final TextStyle headlineLarge = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
  );

  static final TextStyle headlineMedium = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
  );

  static final TextStyle headlineSmall = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
  );

  // Title styles (for card titles, dialog titles)
  static final TextStyle titleLarge = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
  );

  static final TextStyle titleMedium = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: medium,
    height: 1.4,
  );

  static final TextStyle titleSmall = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
  );

  // Body styles (for regular content)
  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );

  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
  );

  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );

  // Label styles (for buttons, form labels)
  static final TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
  );

  static final TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
  );

  static final TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
  );

  // Button text styles
  static final TextStyle buttonLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.buttonText,
    height: 1.2,
  );

  static final TextStyle buttonMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: semiBold,
    color: AppColors.buttonText,
    height: 1.2,
  );

  static final TextStyle buttonSmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.buttonText,
    height: 1.2,
  );

  // Specialized text styles
  static final TextStyle subtitle = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.textSubtitle,
    height: 1.5,
  );

  static final TextStyle caption = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textSubtitle,
    height: 1.4,
  );

  static final TextStyle overline = _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: medium,
    color: AppColors.textSubtitle,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Error text style
  static final TextStyle error = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.error,
    height: 1.4,
  );

  // Success text style
  static final TextStyle success = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.success,
    height: 1.4,
  );

  // Helper method to create responsive text styles
  static TextStyle responsive(TextStyle baseStyle, double scaleFactor) {
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
    );
  }

  // Helper method to create text style with custom color
  static TextStyle withColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }

  // Helper method to create text style with custom weight
  static TextStyle withWeight(TextStyle baseStyle, FontWeight weight) {
    return baseStyle.copyWith(fontWeight: weight);
  }
}
