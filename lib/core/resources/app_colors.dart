import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors._();

  // Colors from Figma
  static const box1 = Color(0xFFE9D9FF);
  static const box2 = Color(0xFFD4FFFB);
  static const box3 = Color(0xFFDAFFC7);
  static const box4 = Color(0xFFFFF8BB);
  static const textHeadline = Color(0xFF323062);
  static const textSubtitle = Color(0xFFC2C1D0);
  static const waterFull = Color(0x80918DFE); // 50% opacity
  static const waterLow = Color(0x80E4F0FF); // 50% opacity
  static const lightBlue = Color(0xFF7671FF);
  static const checkBoxCircle = Color(0xFFF8F8F6);
  static const darkBlue = Color(0xFF323062);

  // Get water color based on progress
  static Color getWaterColor(double progress) {
    return Color.lerp(waterLow, waterFull, progress) ?? waterLow;
  }
}