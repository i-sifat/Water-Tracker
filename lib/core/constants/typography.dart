// lib/core/constants/typography.dart

import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

class AppTypography {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w900, // ExtraBold
    color: AppColors.assessmentText,
    height: 1.2,
  );

  // Hydration interface specific typography
  static const TextStyle hydrationTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle progressMainText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textHeadline,
    height: 1.2,
  );

  static const TextStyle progressSubText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSubtitle,
    height: 1.2,
  );

  static const TextStyle progressSmallText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSubtitle,
    height: 1.2,
  );

  static const TextStyle buttonLargeText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle buttonSmallText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: Colors.white70,
    height: 1.2,
  );

  static const TextStyle timeIndicatorText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.buttonText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.pageCounter,
  );

  static const TextStyle welcomeHeadline = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold
    color: AppColors.assessmentText,
    height: 1.4,
  );

  // Add missing headlineLarge for compatibility
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w900, // ExtraBold
    color: AppColors.assessmentText,
    height: 1.2,
  );
}
