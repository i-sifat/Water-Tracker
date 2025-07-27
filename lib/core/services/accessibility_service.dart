import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle accessibility features like focus management,
/// high contrast mode, and scalable text
class AccessibilityService {
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _textScaleKey = 'text_scale_factor';
  static const String _reducedMotionKey = 'reduced_motion';
  
  final SharedPreferences _prefs;
  
  AccessibilityService(this._prefs);
  
  /// Initialize accessibility service
  static Future<AccessibilityService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return AccessibilityService(prefs);
  }
  
  // High Contrast Mode
  bool get isHighContrastEnabled => _prefs.getBool(_highContrastKey) ?? false;
  
  Future<void> setHighContrastMode(bool enabled) async {
    await _prefs.setBool(_highContrastKey, enabled);
    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }
  
  // Text Scale Factor
  double get textScaleFactor => _prefs.getDouble(_textScaleKey) ?? 1.0;
  
  Future<void> setTextScaleFactor(double scale) async {
    // Clamp between 0.8 and 2.0 for reasonable bounds
    final clampedScale = scale.clamp(0.8, 2.0);
    await _prefs.setDouble(_textScaleKey, clampedScale);
    HapticFeedback.selectionClick();
  }
  
  // Reduced Motion
  bool get isReducedMotionEnabled => _prefs.getBool(_reducedMotionKey) ?? false;
  
  Future<void> setReducedMotion(bool enabled) async {
    await _prefs.setBool(_reducedMotionKey, enabled);
  }
  
  /// Get animation duration based on reduced motion setting
  Duration getAnimationDuration(Duration defaultDuration) {
    if (isReducedMotionEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }
  
  /// Announce text to screen readers
  void announceToScreenReader(String message) {
    // Use SemanticsService from flutter/semantics
    // SemanticsService.announce(message, TextDirection.ltr);
    // For now, we'll skip this as it requires additional setup
  }
  
  /// Focus management helper
  void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
    HapticFeedback.selectionClick();
  }
  
  /// Move focus to next focusable element
  void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
    HapticFeedback.selectionClick();
  }
  
  /// Move focus to previous focusable element
  void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
    HapticFeedback.selectionClick();
  }
  
  /// Clear focus
  void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  /// Check if device has accessibility features enabled
  bool get hasAccessibilityFeatures {
    return MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).accessibleNavigation;
  }
  
  /// Get high contrast color scheme
  ColorScheme getHighContrastColorScheme(ColorScheme baseScheme) {
    if (!isHighContrastEnabled) return baseScheme;
    
    return baseScheme.copyWith(
      primary: baseScheme.brightness == Brightness.light 
          ? Colors.black 
          : Colors.white,
      onPrimary: baseScheme.brightness == Brightness.light 
          ? Colors.white 
          : Colors.black,
      secondary: baseScheme.brightness == Brightness.light 
          ? Colors.black87 
          : Colors.white70,
      onSecondary: baseScheme.brightness == Brightness.light 
          ? Colors.white 
          : Colors.black,
      surface: baseScheme.brightness == Brightness.light 
          ? Colors.white 
          : Colors.black,
      onSurface: baseScheme.brightness == Brightness.light 
          ? Colors.black 
          : Colors.white,
      background: baseScheme.brightness == Brightness.light 
          ? Colors.white 
          : Colors.black,
      onBackground: baseScheme.brightness == Brightness.light 
          ? Colors.black 
          : Colors.white,
    );
  }
  
  /// Get minimum touch target size (44x44 dp as per accessibility guidelines)
  static const double minimumTouchTargetSize = 44.0;
  
  /// Ensure widget meets minimum touch target size
  Widget ensureMinimumTouchTarget({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: minimumTouchTargetSize,
      height: minimumTouchTargetSize,
      child: onTap != null 
          ? GestureDetector(
              onTap: onTap,
              child: child,
            )
          : child,
    );
  }
}