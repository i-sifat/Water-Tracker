// lib/core/constants/typography.dart

import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class AppTypography {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w900, // ExtraBold
    color: AppColors.assessmentText,
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
}
