import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Complete localization implementation for the Water Tracker app
class AppLocalizationsComplete {
  final Locale locale;

  AppLocalizationsComplete(this.locale);

  static AppLocalizationsComplete? of(BuildContext context) {
    return Localizations.of<AppLocalizationsComplete>(context, AppLocalizationsComplete);
  }

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('ar', 'SA'),
  ];

  static const LocalizationsDelegate<AppLocalizationsComplete> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Water Tracker',
      'accessibility': 'Accessibility',
      'high_contrast': 'High Contrast',
      'text_size': 'Text Size',
      'reduced_motion': 'Reduced Motion',
      'back_button': 'Back',
      'menu_button': 'Menu',
      'settings': 'Settings',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'premium': 'Premium',
      'donate': 'Donate',
      'unlock_premium': 'Unlock Premium',
      'daily_goal': 'Daily Goal',
      'water_intake': 'Water Intake',
      'add_water': 'Add Water',
      'history': 'History',
      'analytics': 'Analytics',
      'goal_completed': 'Goal Completed!',
      'congratulations': 'Congratulations!',
      'keep_it_up': 'Keep it up!',
    },
    'es': {
      'app_name': 'Rastreador de Agua',
      'accessibility': 'Accesibilidad',
      'high_contrast': 'Alto Contraste',
      'text_size': 'Tamaño de Texto',
      'reduced_motion': 'Movimiento Reducido',
      'back_button': 'Atrás',
      'menu_button': 'Menú',
      'settings': 'Configuración',
      'profile': 'Perfil',
      'notifications': 'Notificaciones',
      'premium': 'Premium',
      'donate': 'Donar',
      'unlock_premium': 'Desbloquear Premium',
      'daily_goal': 'Meta Diaria',
      'water_intake': 'Consumo de Agua',
      'add_water': 'Agregar Agua',
      'history': 'Historial',
      'analytics': 'Análisis',
      'goal_completed': '¡Meta Completada!',
      'congratulations': '¡Felicitaciones!',
      'keep_it_up': '¡Sigue así!',
    },
    'fr': {
      'app_name': "Suivi d'Hydratation",
      'accessibility': 'Accessibilité',
      'high_contrast': 'Contraste Élevé',
      'text_size': 'Taille du Texte',
      'reduced_motion': 'Mouvement Réduit',
      'back_button': 'Retour',
      'menu_button': 'Menu',
      'settings': 'Paramètres',
      'profile': 'Profil',
      'notifications': 'Notifications',
      'premium': 'Premium',
      'donate': 'Faire un don',
      'unlock_premium': 'Débloquer Premium',
      'daily_goal': 'Objectif Quotidien',
      'water_intake': "Consommation d'Eau",
      'add_water': 'Ajouter de l\'Eau',
      'history': 'Historique',
      'analytics': 'Analyses',
      'goal_completed': 'Objectif Atteint!',
      'congratulations': 'Félicitations!',
      'keep_it_up': 'Continuez!',
    },
    'de': {
      'app_name': 'Wasser Tracker',
      'accessibility': 'Barrierefreiheit',
      'high_contrast': 'Hoher Kontrast',
      'text_size': 'Textgröße',
      'reduced_motion': 'Reduzierte Bewegung',
      'back_button': 'Zurück',
      'menu_button': 'Menü',
      'settings': 'Einstellungen',
      'profile': 'Profil',
      'notifications': 'Benachrichtigungen',
      'premium': 'Premium',
      'donate': 'Spenden',
      'unlock_premium': 'Premium Freischalten',
      'daily_goal': 'Tagesziel',
      'water_intake': 'Wasseraufnahme',
      'add_water': 'Wasser Hinzufügen',
      'history': 'Verlauf',
      'analytics': 'Analytik',
      'goal_completed': 'Ziel Erreicht!',
      'congratulations': 'Glückwunsch!',
      'keep_it_up': 'Weiter so!',
    },
    'ar': {
      'app_name': 'متتبع المياه',
      'accessibility': 'إمكانية الوصول',
      'high_contrast': 'تباين عالي',
      'text_size': 'حجم النص',
      'reduced_motion': 'حركة مقللة',
      'back_button': 'رجوع',
      'menu_button': 'القائمة',
      'settings': 'الإعدادات',
      'profile': 'الملف الشخصي',
      'notifications': 'الإشعارات',
      'premium': 'المميز',
      'donate': 'تبرع',
      'unlock_premium': 'فتح المميز',
      'daily_goal': 'الهدف اليومي',
      'water_intake': 'شرب الماء',
      'add_water': 'إضافة ماء',
      'history': 'التاريخ',
      'analytics': 'التحليلات',
      'goal_completed': 'تم تحقيق الهدف!',
      'congratulations': 'تهانينا!',
      'keep_it_up': 'استمر!',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters for common strings
  String get appName => translate('app_name');
  String get accessibility => translate('accessibility');
  String get highContrast => translate('high_contrast');
  String get textSize => translate('text_size');
  String get reducedMotion => translate('reduced_motion');
  String get backButton => translate('back_button');
  String get menuButton => translate('menu_button');
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get premium => translate('premium');
  String get donate => translate('donate');
  String get unlockPremium => translate('unlock_premium');
  String get dailyGoal => translate('daily_goal');
  String get waterIntake => translate('water_intake');
  String get addWater => translate('add_water');
  String get history => translate('history');
  String get analytics => translate('analytics');
  String get goalCompleted => translate('goal_completed');
  String get congratulations => translate('congratulations');
  String get keepItUp => translate('keep_it_up');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizationsComplete> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizationsComplete.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizationsComplete> load(Locale locale) async {
    return AppLocalizationsComplete(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}