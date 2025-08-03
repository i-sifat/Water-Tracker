import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

void main() {
  group('AppColors Accessibility Tests', () {
    test('Primary text colors meet WCAG AA contrast requirements', () {
      // Test primary text on light background
      final primaryOnLight = _calculateContrastRatio(
        AppColors.textPrimary,
        AppColors.surface,
      );
      expect(
        primaryOnLight,
        greaterThanOrEqualTo(4.5),
        reason: 'Primary text on light background should meet WCAG AA (4.5:1)',
      );

      // Test secondary text on light background
      final secondaryOnLight = _calculateContrastRatio(
        AppColors.textSecondary,
        AppColors.surface,
      );
      expect(
        secondaryOnLight,
        greaterThanOrEqualTo(4.5),
        reason:
            'Secondary text on light background should meet WCAG AA (4.5:1)',
      );
    });

    test('Interactive colors meet contrast requirements', () {
      // Test primary button text on primary background
      final primaryButtonContrast = _calculateContrastRatio(
        AppColors.textOnPrimary,
        AppColors.interactivePrimary,
      );
      expect(
        primaryButtonContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Primary button text should be readable',
      );

      // Test secondary button text on secondary background
      final secondaryButtonContrast = _calculateContrastRatio(
        AppColors.textOnSecondary,
        AppColors.interactiveSecondary,
      );
      expect(
        secondaryButtonContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Secondary button text should be readable',
      );
    });

    test('Status colors meet contrast requirements', () {
      // Test success text on success background
      final successContrast = _calculateContrastRatio(
        AppColors.statusSuccessText,
        AppColors.statusSuccessLight,
      );
      expect(
        successContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Success text should be readable on success background',
      );

      // Test error text on error background
      final errorContrast = _calculateContrastRatio(
        AppColors.statusErrorText,
        AppColors.statusErrorLight,
      );
      expect(
        errorContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Error text should be readable on error background',
      );

      // Test warning text on warning background
      final warningContrast = _calculateContrastRatio(
        AppColors.statusWarningText,
        AppColors.statusWarningLight,
      );
      expect(
        warningContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Warning text should be readable on warning background',
      );

      // Test info text on info background
      final infoContrast = _calculateContrastRatio(
        AppColors.statusInfoText,
        AppColors.statusInfoLight,
      );
      expect(
        infoContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Info text should be readable on info background',
      );
    });

    test('High contrast colors provide maximum accessibility', () {
      // Test high contrast text on high contrast background
      final highContrastRatio = _calculateContrastRatio(
        AppColors.highContrastText,
        AppColors.highContrastBackground,
      );
      expect(
        highContrastRatio,
        greaterThanOrEqualTo(15.0),
        reason: 'High contrast colors should provide maximum readability',
      );
    });

    test('Hydration button colors are distinguishable', () {
      final buttonColors = [
        AppColors.hydrationButton500ml,
        AppColors.hydrationButton250ml,
        AppColors.hydrationButton400ml,
        AppColors.hydrationButton100ml,
      ];

      // Test that each button color provides sufficient contrast with text
      for (final color in buttonColors) {
        final textColor = AppColors.getAccessibleTextColor(color);
        final contrast = _calculateContrastRatio(textColor, color);
        expect(
          contrast,
          greaterThanOrEqualTo(4.5),
          reason: 'Button color $color should provide readable text contrast',
        );
      }
    });

    test('getAccessibleTextColor returns appropriate text color', () {
      // Test with light background
      final textOnLight = AppColors.getAccessibleTextColor(AppColors.surface);
      expect(
        textOnLight,
        equals(AppColors.textAccessiblePrimary),
        reason: 'Should return dark text for light background',
      );

      // Test with dark background
      final textOnDark = AppColors.getAccessibleTextColor(
        AppColors.primaryDark,
      );
      expect(
        textOnDark,
        equals(AppColors.textAccessibleInverse),
        reason: 'Should return light text for dark background',
      );
    });

    test('getAccessibleColorPair returns compliant color combinations', () {
      // Test normal contrast mode
      final normalPair = AppColors.getAccessibleColorPair(
        preferredForeground: AppColors.textPrimary,
        preferredBackground: AppColors.surface,
      );

      final normalContrast = _calculateContrastRatio(
        normalPair['foreground']!,
        normalPair['background']!,
      );
      expect(
        normalContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Normal color pair should meet WCAG AA requirements',
      );

      // Test high contrast mode
      final highContrastPair = AppColors.getAccessibleColorPair(
        preferredForeground: AppColors.textPrimary,
        preferredBackground: AppColors.surface,
        highContrast: true,
      );

      final highContrast = _calculateContrastRatio(
        highContrastPair['foreground']!,
        highContrastPair['background']!,
      );
      expect(
        highContrast,
        greaterThanOrEqualTo(15.0),
        reason: 'High contrast pair should provide maximum readability',
      );
    });
  });
}

/// Calculate contrast ratio between two colors
/// Returns a value between 1 and 21, where 21 is maximum contrast
double _calculateContrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();

  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}
