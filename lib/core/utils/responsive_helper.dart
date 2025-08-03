import 'package:flutter/material.dart';

/// Device type categories based on screen width
enum DeviceType {
  smallPhone, // < 360dp width
  mediumPhone, // 360-400dp width
  largePhone, // 400-600dp width
  tablet, // > 600dp width
}

/// Responsive helper utility class for MediaQuery-based responsive design
class ResponsiveHelper {
  // Private constructor to prevent instantiation
  ResponsiveHelper._();

  // Breakpoint constants
  static const double _smallPhoneMaxWidth = 360.0;
  static const double _mediumPhoneMaxWidth = 400.0;
  static const double _largePhoneMaxWidth = 600.0;

  // Base design dimensions (based on a standard phone design)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < _smallPhoneMaxWidth) {
      return DeviceType.smallPhone;
    } else if (screenWidth < _mediumPhoneMaxWidth) {
      return DeviceType.mediumPhone;
    } else if (screenWidth < _largePhoneMaxWidth) {
      return DeviceType.largePhone;
    } else {
      return DeviceType.tablet;
    }
  }

  /// Get responsive width based on screen size
  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;

    // Apply constraints to prevent extreme scaling
    final constrainedScale = scaleFactor.clamp(0.7, 1.5);
    return baseWidth * constrainedScale;
  }

  /// Get responsive height based on screen size
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight / _baseHeight;

    // Apply constraints to prevent extreme scaling
    final constrainedScale = scaleFactor.clamp(0.7, 1.5);
    return baseHeight * constrainedScale;
  }

  /// Get responsive font size based on screen size and accessibility settings
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Base scale factor from screen width
    final screenScaleFactor = screenWidth / _baseWidth;
    final constrainedScreenScale = screenScaleFactor.clamp(0.8, 1.3);

    // Combine screen scaling with accessibility text scaling
    final combinedScale =
        constrainedScreenScale * textScaleFactor.clamp(0.8, 2.0);

    return baseFontSize * combinedScale;
  }

  /// Get responsive padding based on screen size and device type
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final deviceType = getDeviceType(context);

    // Base padding values
    double basePadding = all ?? 16.0;
    double baseHorizontal = horizontal ?? basePadding;
    double baseVertical = vertical ?? basePadding;

    // Adjust padding based on device type
    double paddingMultiplier;
    switch (deviceType) {
      case DeviceType.smallPhone:
        paddingMultiplier = 0.8;
        break;
      case DeviceType.mediumPhone:
        paddingMultiplier = 1.0;
        break;
      case DeviceType.largePhone:
        paddingMultiplier = 1.1;
        break;
      case DeviceType.tablet:
        paddingMultiplier = 1.3;
        break;
    }

    return EdgeInsets.symmetric(
      horizontal: baseHorizontal * paddingMultiplier,
      vertical: baseVertical * paddingMultiplier,
    );
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    // Use same logic as padding but with slightly reduced values
    final padding = getResponsivePadding(
      context,
      horizontal: horizontal,
      vertical: vertical,
      all: all,
    );

    return EdgeInsets.symmetric(
      horizontal: padding.horizontal * 0.8,
      vertical: padding.vertical * 0.8,
    );
  }

  /// Get responsive border radius based on screen size
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.smallPhone:
        return baseRadius * 0.9;
      case DeviceType.mediumPhone:
        return baseRadius;
      case DeviceType.largePhone:
        return baseRadius * 1.1;
      case DeviceType.tablet:
        return baseRadius * 1.2;
    }
  }

  /// Get responsive icon size based on screen size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;

    // Apply constraints for icon scaling
    final constrainedScale = scaleFactor.clamp(0.8, 1.4);
    return baseSize * constrainedScale;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is a small phone
  static bool isSmallPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.smallPhone;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    const baseHeight = kToolbarHeight;

    switch (deviceType) {
      case DeviceType.smallPhone:
        return baseHeight * 0.9;
      case DeviceType.mediumPhone:
        return baseHeight;
      case DeviceType.largePhone:
        return baseHeight * 1.05;
      case DeviceType.tablet:
        return baseHeight * 1.1;
    }
  }

  /// Get responsive bottom navigation bar height
  static double getResponsiveBottomNavHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    const baseHeight = kBottomNavigationBarHeight;

    switch (deviceType) {
      case DeviceType.smallPhone:
        return baseHeight * 0.9;
      case DeviceType.mediumPhone:
        return baseHeight;
      case DeviceType.largePhone:
        return baseHeight * 1.05;
      case DeviceType.tablet:
        return baseHeight * 1.1;
    }
  }

  /// Get responsive spacing value
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.smallPhone:
        return baseSpacing * 0.8;
      case DeviceType.mediumPhone:
        return baseSpacing;
      case DeviceType.largePhone:
        return baseSpacing * 1.1;
      case DeviceType.tablet:
        return baseSpacing * 1.3;
    }
  }

  /// Get maximum content width for tablets to prevent excessive stretching
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.tablet:
        return screenWidth * 0.7; // Limit to 70% of screen width on tablets
      default:
        return screenWidth; // Use full width on phones
    }
  }
}
