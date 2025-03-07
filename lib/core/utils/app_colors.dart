import 'package:flutter/material.dart';

class AppColors {
  // Text colors
  static const Color textHeadline = Color(0xFF313A34);
  static const Color textSubtitle = Color(0xFFC2C1D0);
  static const Color assessmentText = Color(0xFF313A34);
  static const Color buttonText = Colors.white;
  static const Color pageCounter = Color(0xFF666666);

  // Water visualization colors
  static const Color waterFull = Color(0xFF918DFE);
  static const Color waterFullTransparent = Color(0x80918DFE);
  static const Color waterLow = Color(0xFFE4F0FF);
  static const Color waterLowTransparent = Color(0x80E4F0FF);

  // UI element colors
  static const Color checkBoxCircle = Color(0xFFF8F8F6);
  static const Color lightBlue = Color(0xFF7671FF);
  static const Color darkBlue = Color(0xFF323062);
  static const Color chartBlue = Color(0xFF918DFE);
  static const Color chartBackground = Color(0xFFF2F6FF);
  static const Color background = Colors.white;
  static const Color appBar = Colors.white;
  static const Color boxIconBackground = Color(0xFFF5F5F5);

  // Button box colors
  static const Color box1 = Color(0xFFE9D9FF);
  static const Color box2 = Color(0xFFD4FFFB);
  static const Color box3 = Color(0xFFDAFFC7);
  static const Color box4 = Color(0xFFFFF8BB);

  // Selection background
  static const Color selectedWeekBackground = Color(0xFF323062);
  static const Color unselectedWeekBackground = Colors.white;
  static const Color selectedBorder = Color(0xFF7671FF);
  static const Color selectedShade = Color(0x1A7671FF);
  static const Color unselectedBorder = Color(0xFFE8E8E8);

  // Gender selection colors
  static const Color genderUnselected = Color(0xFFE4E4E4);
  static const Color genderSelected = Color(0xFF7671FF);
  static const Color preferNotToAnswer = Color(0xFFF3F1FF);

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
