import 'package:flutter/material.dart';

/// Standardized spacing constants for consistent design throughout the app
class AppSpacing {
  // Base spacing unit (8dp)
  static const double _baseUnit = 8.0;

  // Spacing values based on 8dp grid system
  static const double xs = _baseUnit * 0.5; // 4dp
  static const double sm = _baseUnit; // 8dp
  static const double md = _baseUnit * 2; // 16dp
  static const double lg = _baseUnit * 3; // 24dp
  static const double xl = _baseUnit * 4; // 32dp
  static const double xxl = _baseUnit * 5; // 40dp
  static const double xxxl = _baseUnit * 6; // 48dp

  // Specific spacing for common use cases
  static const double screenPadding = md; // 16dp
  static const double cardPadding = md; // 16dp
  static const double buttonPadding = sm; // 8dp
  static const double sectionSpacing = lg; // 24dp
  static const double itemSpacing = sm; // 8dp

  // EdgeInsets presets for common layouts
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(
    vertical: screenPadding,
  );

  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: cardPadding,
  );
  static const EdgeInsets cardPaddingVertical = EdgeInsets.symmetric(
    vertical: cardPadding,
  );

  static const EdgeInsets buttonPaddingAll = EdgeInsets.all(buttonPadding);
  static const EdgeInsets buttonPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: buttonPadding,
  );
  static const EdgeInsets buttonPaddingVertical = EdgeInsets.symmetric(
    vertical: buttonPadding,
  );

  // SizedBox presets for common spacing
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);
  static const SizedBox verticalSpaceXXXL = SizedBox(height: xxxl);

  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);
  static const SizedBox horizontalSpaceXXL = SizedBox(width: xxl);
  static const SizedBox horizontalSpaceXXXL = SizedBox(width: xxxl);

  // Border radius values
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 999.0; // For circular elements

  // BorderRadius presets
  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );
  static const BorderRadius borderRadiusCircular = BorderRadius.all(
    Radius.circular(radiusCircular),
  );

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // Minimum touch target size for accessibility
  static const double minTouchTarget = 44.0;
  static const Size minTouchTargetSize = Size(minTouchTarget, minTouchTarget);
}
