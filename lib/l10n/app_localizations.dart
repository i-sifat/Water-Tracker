import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Localization delegate for the app
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

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
      'reminder_body': 'Don\'t forget to drink water',
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
      'ok': 'OK',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'close': 'Cerrar',
      'next': 'Siguiente',
      'back': 'Atrás',
      'done': 'Hecho',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
      'home': 'Inicio',
      'history': 'Historial',
      'settings': 'Configuración',
      'welcome': 'Bienvenido',
      'welcome_message': 'Mantente hidratado y saludable con nuestra app',
      'get_started': 'Comenzar',
      'select_gender': 'Seleccionar Género',
      'male': 'Masculino',
      'female': 'Femenino',
      'prefer_not_to_answer': 'Prefiero no responder',
      'select_age': 'Seleccionar Edad',
      'select_weight': 'Seleccionar Peso',
      'select_goal': 'Seleccionar Objetivo',
      'exercise_frequency': 'Frecuencia de Ejercicio',
      'pregnancy_status': 'Estado de Embarazo',
      'sugar_drinks': 'Bebidas Azucaradas',
      'vegetable_intake': 'Consumo de Vegetales',
      'weather_preference': 'Preferencia Climática',
      'notification_setup': 'Configurar Notificaciones',
      'onboarding_complete': 'Configuración Completa',
      'daily_goal': 'Objetivo Diario',
      'current_intake': 'Consumo Actual',
      'remaining': 'Restante',
      'add_water': 'Agregar Agua',
      'goal_achieved': '¡Objetivo Alcanzado!',
      'congratulations': '¡Felicitaciones!',
      'keep_it_up': '¡Sigue así!',
      'ml': 'ml',
      'liters': 'L',
      'weekly_progress': 'Progreso Semanal',
      'monthly_trend': 'Tendencia Mensual',
      'streak': 'Racha',
      'days': 'días',
      'average': 'Promedio',
      'no_data_available': 'No hay datos disponibles',
      'profile': 'Perfil',
      'notifications': 'Notificaciones',
      'theme': 'Tema',
      'language': 'Idioma',
      'accessibility': 'Accesibilidad',
      'high_contrast': 'Alto Contraste',
      'text_size': 'Tamaño de Texto',
      'reduced_motion': 'Movimiento Reducido',
      'data_management': 'Gestión de Datos',
      'backup': 'Respaldo',
      'restore': 'Restaurar',
      'clear_data': 'Limpiar Datos',
      'premium': 'Premium',
      'unlock_premium': 'Desbloquear Premium',
      'donation_required': 'Donación Requerida',
      'device_code': 'Código del Dispositivo',
      'submit_proof': 'Enviar Prueba',
      'enter_unlock_code': 'Ingresar Código',
      'premium_unlocked': 'Premium Desbloqueado',
      'reminder_title': '¡Hora de Hidratarse!',
      'reminder_body': 'No olvides beber agua',
      'goal_achieved_title': '¡Objetivo Alcanzado!',
      'goal_achieved_body': '¡Felicitaciones por alcanzar tu objetivo diario!',
      'increase_water_button': 'Aumentar consumo de agua',
      'decrease_water_button': 'Disminuir consumo de agua',
      'water_progress_indicator': 'Progreso de consumo de agua',
      'navigation_tab': 'Pestaña de navegación',
      'back_button': 'Atrás',
      'menu_button': 'Menú',
    },
    'fr': {
      'app_name': 'Suivi d\'Hydratation',
      'ok': 'OK',
      'cancel': 'Annuler',
      'save': 'Sauvegarder',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'next': 'Suivant',
      'back': 'Retour',
      'done': 'Terminé',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'home': 'Accueil',
      'history': 'Historique',
      'settings': 'Paramètres',
      'welcome': 'Bienvenue',
      'welcome_message': 'Restez hydraté et en bonne santé avec notre app',
      'get_started': 'Commencer',
      'select_gender': 'Sélectionner le Genre',
      'male': 'Masculin',
      'female': 'Féminin',
      'prefer_not_to_answer': 'Préfère ne pas répondre',
      'select_age': 'Sélectionner l\'Âge',
      'select_weight': 'Sélectionner le Poids',
      'select_goal': 'Sélectionner l\'Objectif',
      'exercise_frequency': 'Fréquence d\'Exercice',
      'pregnancy_status': 'Statut de Grossesse',
      'sugar_drinks': 'Boissons Sucrées',
      'vegetable_intake': 'Consommation de Légumes',
      'weather_preference': 'Préférence Météo',
      'notification_setup': 'Configuration des Notifications',
      'onboarding_complete': 'Configuration Terminée',
      'daily_goal': 'Objectif Quotidien',
      'current_intake': 'Consommation Actuelle',
      'remaining': 'Restant',
      'add_water': 'Ajouter de l\'Eau',
      'goal_achieved': 'Objectif Atteint!',
      'congratulations': 'Félicitations!',
      'keep_it_up': 'Continuez!',
      'ml': 'ml',
      'liters': 'L',
      'weekly_progress': 'Progrès Hebdomadaire',
      'monthly_trend': 'Tendance Mensuelle',
      'streak': 'Série',
      'days': 'jours',
      'average': 'Moyenne',
      'no_data_available': 'Aucune donnée disponible',
      'profile': 'Profil',
      'notifications': 'Notifications',
      'theme': 'Thème',
      'language': 'Langue',
      'accessibility': 'Accessibilité',
      'high_contrast': 'Contraste Élevé',
      'text_size': 'Taille du Texte',
      'reduced_motion': 'Mouvement Réduit',
      'data_management': 'Gestion des Données',
      'backup': 'Sauvegarde',
      'restore': 'Restaurer',
      'clear_data': 'Effacer les Données',
      'premium': 'Premium',
      'unlock_premium': 'Débloquer Premium',
      'donation_required': 'Don Requis',
      'device_code': 'Code de l\'Appareil',
      'submit_proof': 'Soumettre la Preuve',
      'enter_unlock_code': 'Entrer le Code',
      'premium_unlocked': 'Premium Débloqué',
      'reminder_title': 'Temps de s\'Hydrater!',
      'reminder_body': 'N\'oubliez pas de boire de l\'eau',
      'goal_achieved_title': 'Objectif Atteint!',
      'goal_achieved_body': 'Félicitations pour avoir atteint votre objectif quotidien!',
      'increase_water_button': 'Augmenter la consommation d\'eau',
      'decrease_water_button': 'Diminuer la consommation d\'eau',
      'water_progress_indicator': 'Indicateur de progrès d\'hydratation',
      'navigation_tab': 'Onglet de navigation',
      'back_button': 'Retour',
      'menu_button': 'Menu',
    },
    'de': {
      'app_name': 'Wasser Tracker',
      'ok': 'OK',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'delete': 'Löschen',
      'edit': 'Bearbeiten',
      'close': 'Schließen',
      'next': 'Weiter',
      'back': 'Zurück',
      'done': 'Fertig',
      'loading': 'Laden...',
      'error': 'Fehler',
      'retry': 'Wiederholen',
      'home': 'Startseite',
      'history': 'Verlauf',
      'settings': 'Einstellungen',
      'welcome': 'Willkommen',
      'welcome_message': 'Bleiben Sie hydratisiert und gesund mit unserer App',
      'get_started': 'Loslegen',
      'select_gender': 'Geschlecht Auswählen',
      'male': 'Männlich',
      'female': 'Weiblich',
      'prefer_not_to_answer': 'Möchte nicht antworten',
      'select_age': 'Alter Auswählen',
      'select_weight': 'Gewicht Auswählen',
      'select_goal': 'Ziel Auswählen',
      'exercise_frequency': 'Trainingshäufigkeit',
      'pregnancy_status': 'Schwangerschaftsstatus',
      'sugar_drinks': 'Zuckerhaltige Getränke',
      'vegetable_intake': 'Gemüseaufnahme',
      'weather_preference': 'Wetterpräferenz',
      'notification_setup': 'Benachrichtigungen Einrichten',
      'onboarding_complete': 'Einrichtung Abgeschlossen',
      'daily_goal': 'Tagesziel',
      'current_intake': 'Aktuelle Aufnahme',
      'remaining': 'Verbleibend',
      'add_water': 'Wasser Hinzufügen',
      'goal_achieved': 'Ziel Erreicht!',
      'congratulations': 'Herzlichen Glückwunsch!',
      'keep_it_up': 'Weiter so!',
      'ml': 'ml',
      'liters': 'L',
      'weekly_progress': 'Wöchentlicher Fortschritt',
      'monthly_trend': 'Monatlicher Trend',
      'streak': 'Serie',
      'days': 'Tage',
      'average': 'Durchschnitt',
      'no_data_available': 'Keine Daten verfügbar',
      'profile': 'Profil',
      'notifications': 'Benachrichtigungen',
      'theme': 'Design',
      'language': 'Sprache',
      'accessibility': 'Barrierefreiheit',
      'high_contrast': 'Hoher Kontrast',
      'text_size': 'Textgröße',
      'reduced_motion': 'Reduzierte Bewegung',
      'data_management': 'Datenverwaltung',
      'backup': 'Sicherung',
      'restore': 'Wiederherstellen',
      'clear_data': 'Daten Löschen',
      'premium': 'Premium',
      'unlock_premium': 'Premium Freischalten',
      'donation_required': 'Spende Erforderlich',
      'device_code': 'Gerätecode',
      'submit_proof': 'Nachweis Einreichen',
      'enter_unlock_code': 'Code Eingeben',
      'premium_unlocked': 'Premium Freigeschaltet',
      'reminder_title': 'Zeit zu Trinken!',
      'reminder_body': 'Vergessen Sie nicht, Wasser zu trinken',
      'goal_achieved_title': 'Ziel Erreicht!',
      'goal_achieved_body': 'Herzlichen Glückwunsch zum Erreichen Ihres Tagesziels!',
      'increase_water_button': 'Wasseraufnahme erhöhen',
      'decrease_water_button': 'Wasseraufnahme verringern',
      'water_progress_indicator': 'Wasseraufnahme-Fortschritt',
      'navigation_tab': 'Navigationsregisterkarte',
      'back_button': 'Zurück',
      'menu_button': 'Menü',
    },
    'ar': {
      'app_name': 'متتبع المياه',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'close': 'إغلاق',
      'next': 'التالي',
      'back': 'رجوع',
      'done': 'تم',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'home': 'الرئيسية',
      'history': 'التاريخ',
      'settings': 'الإعدادات',
      'welcome': 'مرحباً',
      'welcome_message': 'ابق رطباً وصحياً مع تطبيقنا',
      'get_started': 'ابدأ',
      'select_gender': 'اختر الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'prefer_not_to_answer': 'أفضل عدم الإجابة',
      'select_age': 'اختر العمر',
      'select_weight': 'اختر الوزن',
      'select_goal': 'اختر الهدف',
      'exercise_frequency': 'تكرار التمرين',
      'pregnancy_status': 'حالة الحمل',
      'sugar_drinks': 'المشروبات السكرية',
      'vegetable_intake': 'تناول الخضروات',
      'weather_preference': 'تفضيل الطقس',
      'notification_setup': 'إعداد الإشعارات',
      'onboarding_complete': 'اكتمل الإعداد',
      'daily_goal': 'الهدف اليومي',
      'current_intake': 'الاستهلاك الحالي',
      'remaining': 'المتبقي',
      'add_water': 'إضافة ماء',
      'goal_achieved': 'تم تحقيق الهدف!',
      'congratulations': 'تهانينا!',
      'keep_it_up': 'استمر!',
      'ml': 'مل',
      'liters': 'لتر',
      'weekly_progress': 'التقدم الأسبوعي',
      'monthly_trend': 'الاتجاه الشهري',
      'streak': 'السلسلة',
      'days': 'أيام',
      'average': 'المتوسط',
      'no_data_available': 'لا توجد بيانات متاحة',
      'profile': 'الملف الشخصي',
      'notifications': 'الإشعارات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'accessibility': 'إمكانية الوصول',
      'high_contrast': 'تباين عالي',
      'text_size': 'حجم النص',
      'reduced_motion': 'حركة مقللة',
      'data_management': 'إدارة البيانات',
      'backup': 'نسخ احتياطي',
      'restore': 'استعادة',
      'clear_data': 'مسح البيانات',
      'premium': 'مميز',
      'unlock_premium': 'فتح المميز',
      'donation_required': 'التبرع مطلوب',
      'device_code': 'رمز الجهاز',
      'submit_proof': 'إرسال الإثبات',
      'enter_unlock_code': 'أدخل الرمز',
      'premium_unlocked': 'تم فتح المميز',
      'reminder_title': 'وقت الترطيب!',
      'reminder_body': 'لا تنس شرب الماء',
      'goal_achieved_title': 'تم تحقيق الهدف!',
      'goal_achieved_body': 'تهانينا على تحقيق هدفك اليومي!',
      'increase_water_button': 'زيادة استهلاك الماء',
      'decrease_water_button': 'تقليل استهلاك الماء',
      'water_progress_indicator': 'مؤشر تقدم الماء',
      'navigation_tab': 'علامة تبويب التنقل',
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