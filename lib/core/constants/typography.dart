import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class AppTypography {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 36, // Converted from Figma's 90
    fontWeight: FontWeight.w800, // ExtraBold
    color: AppColors.assessmentText,
    height: 1.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16, // Converted from Figma's 53
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.buttonText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16, // Converted from Figma's 53
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.pageCounter,
  );
}
