import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/l10n/app_localizations.dart';

/// Provider to manage app locale and language settings
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_language';
  
  Locale _locale = const Locale('en', 'US');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Initialize locale provider and load saved language preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      
      if (savedLanguageCode != null) {
        final supportedLocale = AppLocalizations.supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguageCode,
          orElse: () => const Locale('en', 'US'),
        );
        _locale = supportedLocale;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing locale provider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set locale and persist to storage
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    // Check if locale is supported
    final isSupported = AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
    
    if (!isSupported) {
      debugPrint('Unsupported locale: ${locale.languageCode}');
      return;
    }
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  /// Set locale by language code
  Future<void> setLocaleByLanguageCode(String languageCode) async {
    final locale = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'),
    );
    await setLocale(locale);
  }

  /// Check if current locale is RTL
  bool get isRTL => _locale.languageCode == 'ar';

  /// Get text direction based on current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Get all supported locales with display names
  Map<Locale, String> get supportedLocalesWithNames {
    return {
      for (final locale in AppLocalizations.supportedLocales)
        locale: _getLanguageDisplayName(locale),
    };
  }

  /// Get display name for a locale
  String _getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  /// Get native language name
  String getNativeLanguageName(Locale locale) {
    return _getLanguageDisplayName(locale);
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLocale = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == systemLocale.languageCode,
      orElse: () => const Locale('en', 'US'),
    );
    await setLocale(supportedLocale);
  }
}
