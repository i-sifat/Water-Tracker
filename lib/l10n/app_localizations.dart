import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Localization delegate for the app
class AppLocalizations {

  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('ar', 'SA'), // Arabic
  ];

  // Common
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;

  // Onboarding
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get welcomeMessage => _localizedValues[locale.languageCode]!['welcome_message']!;
  String get getStarted => _localizedValues[locale.languageCode]!['get_started']!;
  String get selectGender => _localizedValues[locale.languageCode]!['select_gender']!;
  String get male => _localizedValues[locale.languageCode]!['male']!;
  String get female => _localizedValues[locale.languageCode]!['female']!;
  String get preferNotToAnswer => _localizedValues[locale.languageCode]!['prefer_not_to_answer']!;
  String get selectAge => _localizedValues[locale.languageCode]!['select_age']!;
  String get selectWeight => _localizedValues[locale.languageCode]!['select_weight']!;
  String get selectGoal => _localizedValues[locale.languageCode]!['select_goal']!;
  String get exerciseFrequency => _localizedValues[locale.languageCode]!['exercise_frequency']!;
  String get pregnancyStatus => _localizedValues[locale.languageCode]!['pregnancy_status']!;
  String get sugarDrinks => _localizedValues[locale.languageCode]!['sugar_drinks']!;
  String get vegetableIntake => _localizedValues[locale.languageCode]!['vegetable_intake']!;
  String get weatherPreference => _localizedValues[locale.languageCode]!['weather_preference']!;
  String get notificationSetup => _localizedValues[locale.languageCode]!['notification_setup']!;
  String get onboardingComplete => _localizedValues[locale.languageCode]!['onboarding_complete']!;

  // Hydration
  String get dailyGoal => _localizedValues[locale.languageCode]!['daily_goal']!;
  String get currentIntake => _localizedValues[locale.languageCode]!['current_intake']!;
  String get remaining => _localizedValues[locale.languageCode]!['remaining']!;
  String get addWater => _localizedValues[locale.languageCode]!['add_water']!;
  String get goalAchieved => _localizedValues[locale.languageCode]!['goal_achieved']!;
  String get congratulations => _localizedValues[locale.languageCode]!['congratulations']!;
  String get keepItUp => _localizedValues[locale.languageCode]!['keep_it_up']!;
  String get ml => _localizedValues[locale.languageCode]!['ml']!;
  String get liters => _localizedValues[locale.languageCode]!['liters']!;

  // History
  String get weeklyProgress => _localizedValues[locale.languageCode]!['weekly_progress']!;
  String get monthlyTrend => _localizedValues[locale.languageCode]!['monthly_trend']!;
  String get streak => _localizedValues[locale.languageCode]!['streak']!;
  String get days => _localizedValues[locale.languageCode]!['days']!;
  String get average => _localizedValues[locale.languageCode]!['average']!;
  String get noDataAvailable => _localizedValues[locale.languageCode]!['no_data_available']!;

  // Settings
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get accessibility => _localizedValues[locale.languageCode]!['accessibility']!;
  String get highContrast => _localizedValues[locale.languageCode]!['high_contrast']!;
  String get textSize => _localizedValues[locale.languageCode]!['text_size']!;
  String get reducedMotion => _localizedValues[locale.languageCode]!['reduced_motion']!;
  String get dataManagement => _localizedValues[locale.languageCode]!['data_management']!;
  String get backup => _localizedValues[locale.languageCode]!['backup']!;
  String get restore => _localizedValues[locale.languageCode]!['restore']!;
  String get clearData => _localizedValues[locale.languageCode]!['clear_data']!;
  String get premium => _localizedValues[locale.languageCode]!['premium']!;

  // Premium
  String get unlockPremium => _localizedValues[locale.languageCode]!['unlock_premium']!;
  String get donationRequired => _localizedValues[locale.languageCode]!['donation_required']!;
  String get deviceCode => _localizedValues[locale.languageCode]!['device_code']!;
  String get submitProof => _localizedValues[locale.languageCode]!['submit_proof']!;
  String get enterUnlockCode => _localizedValues[locale.languageCode]!['enter_unlock_code']!;
  String get premiumUnlocked => _localizedValues[locale.languageCode]!['premium_unlocked']!;

  // Notifications
  String get reminderTitle => _localizedValues[locale.languageCode]!['reminder_title']!;
  String get reminderBody => _localizedValues[locale.languageCode]!['reminder_body']!;
  String get goalAchievedTitle => _localizedValues[locale.languageCode]!['goal_achieved_title']!;
  String get goalAchievedBody => _localizedValues[locale.languageCode]!['goal_achieved_body']!;

  // Accessibility
  String get increaseWaterButton => _localizedValues[locale.languageCode]!['increase_water_button']!;
  String get decreaseWaterButton => _localizedValues[locale.languageCode]!['decrease_water_button']!;
  String get waterProgressIndicator => _localizedValues[locale.languageCode]!['water_progress_indicator']!;
  String get navigationTab => _localizedValues[locale.languageCode]!['navigation_tab']!;
  String get backButton => _localizedValues[locale.languageCode]!['back_button']!;
  String get menuButton => _localizedValues[locale.languageCode]!['menu_button']!;

  // Date formatting
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.languageCode).format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd(locale.languageCode).add_Hm().format(dateTime);
  }

  // Number formatting
  String formatNumber(num number) {
    return NumberFormat.decimalPattern(locale.languageCode).format(number);
  }

  String formatPercentage(double percentage) {
    return NumberFormat.percentPattern(locale.languageCode).format(percentage);
  }

  // Pluralization
  String daysPlural(int count) {
    if (locale.languageCode == 'en') {
      return count == 1 ? 'day' : 'days';
    } else if (locale.languageCode == 'es') {
      return count == 1 ? 'día' : 'días';
    } else if (locale.languageCode == 'fr') {
      return count == 1 ? 'jour' : 'jours';
    } else if (locale.languageCode == 'de') {
      return count == 1 ? 'Tag' : 'Tage';
    } else if (locale.languageCode == 'ar') {
      return count == 1 ? 'يوم' : 'أيام';
    }
    return 'days';
  }

  // Localized values map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Water Tracker',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'next': 'Next',
      'back': 'Back',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'home': 'Home',
      'history': 'History',
      'settings': 'Settings',
      'welcome': 'Welcome',
      'welcome_message': 'Stay hydrated and healthy with our water tracking app',
      'get_started': 'Get Started',
      'select_gender': 'Select Gender',
      'male': 'Male',
      'female': 'Female',
      'prefer_not_to_answer': 'Prefer not to answer',
      'select_age': 'Select Age',
      'select_weight': 'Select Weight',
      'select_goal': 'Select Goal',
      'exercise_frequency': 'Exercise Frequency',
      'pregnancy_status': 'Pregnancy Status',
      'sugar_drinks': 'Sugar Drinks',
      'vegetable_intake': 'Vegetable Intake',
      'weather_preference': 'Weather Preference',
      'notification_setup': 'Notification Setup',
      'onboarding_complete': 'Setup Complete',
      'daily_goal': 'Daily Goal',
      'current_intake': 'Current Intake',
      'remaining': 'Remaining',
      'add_water': 'Add Water',
      'goal_achieved': 'Goal Achieved!',
      'congratulations': 'Congratulations!',
      'keep_it_up': 'Keep it up!',
      'ml': 'ml',
      'liters': 'L',
      'weekly_progress': 'Weekly Progress',
      'monthly_trend': 'Monthly Trend',
      'streak': 'Streak',
      'days': 'days',
      'average': 'Average',
      'no_data_available': 'No data available',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'theme': 'Theme',
      'language': 'Language',
      'accessibility': 'Accessibility',
      'high_contrast': 'High Contrast',
      'text_size': 'Text Size',
      'reduced_motion': 'Reduced Motion',
      'data_management': 'Data Management',
      'backup': 'Backup',
      'restore': 'Restore',
      'clear_data': 'Clear Data',
      'premium': 'Premium',
      'unlock_premium': 'Unlock Premium',
      'donation_required': 'Donation Required',
      'device_code': 'Device Code',
      'submit_proof': 'Submit Proof',
      'enter_unlock_code': 'Enter Unlock Code',
      'premium_unlocked': 'Premium Unlocked',
      'reminder_title': 'Time to Hydrate!',
      'reminder_body': "Don't forget to drink water",
      'goal_achieved_title': 'Goal Achieved!',
      'goal_achieved_body': 'Congratulations on reaching your daily goal!',
      'increase_water_button': 'Increase water intake',
      'decrease_water_button': 'Decrease water intake',
      'water_progress_indicator': 'Water intake progress',
      'navigation_tab': 'Navigation tab',
      'back_button': 'Back',
      'menu_button': 'Menu',
    },
    'es': {
      'app_name': 'Rastreador de Agua',
      'accessibility': 'Accesibilidad',
      'high_contrast': 'Alto Contraste',
      'text_size': 'Tamaño de Texto',
      'reduced_motion': 'Movimiento Reducido',
      'back_button': 'Atrás',
      'menu_button': 'Menú',
    },
    'fr': {
      'app_name': "Suivi d'Hydratation",
      'accessibility': 'Accessibilité',
      'high_contrast': 'Contraste Élevé',
      'text_size': 'Taille du Texte',
      'reduced_motion': 'Mouvement Réduit',
      'back_button': 'Retour',
      'menu_button': 'Menu',
    },
    'de': {
      'app_name': 'Wasser Tracker',
      'accessibility': 'Barrierefreiheit',
      'high_contrast': 'Hoher Kontrast',
      'text_size': 'Textgröße',
      'reduced_motion': 'Reduzierte Bewegung',
      'back_button': 'Zurück',
      'menu_button': 'Menü',
    },
    'ar': {
      'app_name': 'متتبع المياه',
      'accessibility': 'إمكانية الوصول',
      'high_contrast': 'تباين عالي',
      'text_size': 'حجم النص',
      'reduced_motion': 'حركة مقللة',
      'back_button': 'رجوع',
      'menu_button': 'القائمة',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
