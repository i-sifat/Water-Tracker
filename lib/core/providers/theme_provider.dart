import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/services/accessibility_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;
  AccessibilityService? _accessibilityService;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  /// Initialize theme provider and load saved theme preference
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_themeKey);

      if (savedThemeIndex != null &&
          savedThemeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[savedThemeIndex];
      }

      // Initialize accessibility service
      _accessibilityService = await AccessibilityService.initialize();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme provider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Set to system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Set to light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get all available theme modes with display names
  Map<ThemeMode, String> get availableThemes => {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  /// Get accessibility service instance
  AccessibilityService? get accessibilityService => _accessibilityService;

  /// Get text scale factor for accessibility
  double get textScaleFactor => _accessibilityService?.textScaleFactor ?? 1.0;

  /// Check if high contrast mode is enabled
  bool get isHighContrastEnabled =>
      _accessibilityService?.isHighContrastEnabled ?? false;

  /// Check if reduced motion is enabled
  bool get isReducedMotionEnabled =>
      _accessibilityService?.isReducedMotionEnabled ?? false;

  /// Set high contrast mode
  Future<void> setHighContrastMode({required bool enabled}) async {
    await _accessibilityService?.setHighContrastMode(enabled: enabled);
    notifyListeners();
  }

  /// Set text scale factor
  Future<void> setTextScaleFactor(double scale) async {
    await _accessibilityService?.setTextScaleFactor(scale);
    notifyListeners();
  }

  /// Set reduced motion
  Future<void> setReducedMotion({required bool enabled}) async {
    await _accessibilityService?.setReducedMotion(enabled: enabled);
    notifyListeners();
  }

  /// Get animation duration based on accessibility settings
  Duration getAnimationDuration(Duration defaultDuration) {
    return _accessibilityService?.getAnimationDuration(defaultDuration) ??
        defaultDuration;
  }
}
