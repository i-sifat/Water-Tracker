import 'package:flutter/material.dart';

class AppColors {
  // Text colors
  static const Color textHeadline = Color(0xFF313A34);
  static const Color textSubtitle = Color(0xFF647067);
  static const Color textPrimary = Color(0xFF313A34);
  static const Color assessmentText = Color(0xFF313A34);
  static const Color buttonText = Colors.white;
  static const Color pageCounter = Color(0xFF666666);

  // Water visualization colors - Updated for design mockup
  static const Color waterFull = Color(
    0xFF6B73FF,
  ); // Primary blue from gradient
  static const Color waterFullTransparent = Color(0x806B73FF);
  static const Color waterLow = Color(0xFFE4F0FF);
  static const Color waterLowTransparent = Color(0x80E4F0FF);
  static const Color lightPurple = Color(
    0xFF918DFE,
  ); // Light purple for age selection

  // Gradient colors for main background
  static const Color gradientTop = Color(0xFF6B73FF); // Top gradient color
  static const Color gradientBottom = Color(
    0xFF9546C4,
  ); // Bottom gradient color

  // UI element colors
  static const Color checkBoxCircle = Color(0xFFF8F8F6);
  static const Color lightBlue = Color(0xFF918DFE);
  static const Color darkBlue = Color(0xFF323062);
  static const Color chartBlue = Color(0xFF918DFE);
  static const Color chartBackground = Color(0xFFF2F6FF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color appBar = Color(0xFFF5F5F5);
  static const Color boxIconBackground = Color(0xFFF5F5F5);
  static const Color onBoardingpagebackground = Color(0xFFF5F5F5);
  static const Color onboardingBackground = Color(0xFFF5F5F5);

  // Button box colors - Updated to minimal, consistent design
  static const Color box1 = Color(0xFFF0F0F0); // Light Gray - 500ml button
  static const Color box2 = Color(0xFFF5F5F5); // Lighter Gray - 250ml button
  static const Color box3 = Color(0xFFFAFAFA); // Very Light Gray - 400ml button
  static const Color box4 = Color(0xFFF8F8F8); // Off White - 100ml button

  // Selection background
  static const Color selectedWeekBackground = Color(0xFF323062);
  static const Color unselectedWeekBackground = Colors.white;
  static const Color selectedBorder = Color(0xFF7671FF);
  static const Color weatherUnselectedCard = Color.fromARGB(255, 204, 203, 250);
  static const Color weatherSelectedCard = Color(0xFF313A34);
  static const Color weatherUnselectedFace = Color(0xFFE8E8E8);
  static const Color weatherSelectedFace = Color(0xFF313A34);
  static const Color weatherFaceEyes = Color(0xFFBDBDBD);
  static const Color weatherFaceMouth = Color(0xFFBDBDBD);
  static const Color selectedShade = Color(0x1A7671FF);
  static const Color unselectedBorder = Color(0xFFE8E8E8);

  // Gender selection colors
  static const Color genderUnselected = Color(0xFFE4E4E4);
  static const Color genderSelected = Color(0xFF7671FF);
  static const Color preferNotToAnswer = Color(0xFFF3F1FF);

  // Tab indicator color
  static const Color activeTabIndicator = Color(0xFF323062);

  // Goal selection colors
  static const Color goalGreen = Color(0xFF4CAF50);
  static const Color goalBlue = Color(0xFF2196F3);
  static const Color goalPurple = Color(0xFF9C27B0);
  static const Color goalGrey = Color(0xFFE0E0E0);
  static const Color goalYellow = Color(0xFFFFC107);

  // Gender selection avatar colors
  static const Color maleHair = Color(0xFFFFD700);
  static const Color maleFace = Color(0xFFFFB6C1);
  static const Color femaleHair = Color(0xFFCCCCCC);
  static const Color femaleFace = Color(0xFFCCCCCC);
  static const Color avatarShoulders = Color(0xFF666666);

  // Age selection colors
  static const Color ageSelectionHighlight = Color(0xFF918DFE);
  static const Color ageSelectionText = Color(0xFF313A34);
  static const Color ageSelectionTextLight = Color(0xFF647067);

  // Weight selection colors
  static const Color weightUnitSelected = Color(0xFF313A34);
  static const Color weightUnitUnselected = Color(0xFFF5F5F5);
  static const Color weightUnitTextSelected = Colors.white;
  static const Color weightUnitTextUnselected = Color(0xFF313A34);

  // Pregnancy status colors
  static const Color pregnancyIconBackground = Color(0xFFF5F5F5);
  static const Color breastfeedingIconBackground = Color(0xFFD9F7BE);
  static const Color breastfeedingIconColor = Color(0xFF4CAF50);
  static const Color pregnancyIconColor = Color(0xFF313A34);

  // Sugary beverages colors
  static const Color sugaryIconBackground = Color(0xFFF5F5F5);
  static const Color sugaryIconBackgroundSelected = Color(0xFFD9F7BE);
  static const Color sugaryIconColor = Color(0xFF4CAF50);

  // Vegetable intake colors
  static const Color vegetableIconBackground = Color(0xFFF5F5F5);
  static const Color vegetableIconBackgroundSelected = Color(0xFFD9F7BE);
  static const Color vegetableIconColor = Color(0xFF4CAF50);

  // Fitness level screen colors
  static const Color fitnessSliderBackground = Color(0xFFF0F0FF);
  static const Color fitnessSliderMarkers = Color(0xFF918DFE);
  static const Color fitnessQuestionMark = Color(0xFFCCCCCC);

  // Circular progress colors - Updated to consistent, minimal design
  static const Color progressBackground = Color(
    0xFFE5E5E5,
  ); // Background circle
  static const Color progressGradientStart = Color(
    0xFF6B73FF,
  ); // Primary app color gradient start
  static const Color progressGradientEnd = Color(
    0xFF9546C4,
  ); // Primary app color gradient end
  static const Color progressInnerRing = Color(0xFF918DFE); // Light purple inner ring

  // Page indicator colors
  static const Color pageIndicatorActive = Color(
    0xFFFFFFFF,
  ); // White for active dot
  static const Color pageIndicatorInactive = Color(
    0x4DFFFFFF,
  ); // Semi-transparent white
}
