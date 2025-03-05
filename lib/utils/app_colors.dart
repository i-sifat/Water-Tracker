import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  // Main text colors
  static const Color textHeadline = Color(0xFF323062);
  static const Color textSubtitle = Color(0xFFC2C1D0);

  // Water visualization colors
  static const Color waterFull = Color(0xFF918DFE);
  static const Color waterFullTransparent = Color(0x80918DFE); // 50% opacity
  static const Color waterLow = Color(0xFFE4F0FF);
  static const Color waterLowTransparent = Color(0x80E4F0FF); // 50% opacity

  // UI element colors
  static const Color checkBoxCircle = Color(0xFFF8F8F6);
  static const Color lightBlue = Color(0xFF7671FF);
  static const Color darkBlue = Color(0xFF323062);
  static const Color chartBlue = Color(0xFF918DFE);
  static const Color chartBackground = Color(0xFFF2F6FF);

  // Button box colors
  static const Color box1 = Color(0xFFE9D9FF); // Light purple
  static const Color box2 = Color(0xFFD4FFFB); // Light cyan
  static const Color box3 = Color(0xFFDAFFC7); // Light green
  static const Color box4 = Color(0xFFFFF8BB); // Light yellow

  // Selection background
  static const Color selectedWeekBackground = Color(0xFF323062);
  static const Color unselectedWeekBackground = Colors.white;

  // Tab indicator color
  static const Color activeTabIndicator = Color(0xFF323062);

  // Static methods to get colors with custom opacity
  static Color getWaterFullWithOpacity(double opacity) {
    return waterFull.withOpacity(opacity);
  }

  static Color getDarkBlueWithOpacity(double opacity) {
    return darkBlue.withOpacity(opacity);
  }
}
