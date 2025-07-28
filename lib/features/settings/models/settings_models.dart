import 'package:equatable/equatable.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// Model for notification settings
class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.enabled = true,
    this.startHour = 8,
    this.endHour = 22,
    this.interval = 2,
    this.customReminders = const [],
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      startHour: json['startHour'] as int? ?? 8,
      endHour: json['endHour'] as int? ?? 22,
      interval: json['interval'] as int? ?? 2,
      customReminders: (json['customReminders'] as List<dynamic>?)
          ?.map((r) => CustomReminder.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  final bool enabled;
  final int startHour;
  final int endHour;
  final int interval;
  final List<CustomReminder> customReminders;

  NotificationSettings copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
    int? interval,
    List<CustomReminder>? customReminders,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      interval: interval ?? this.interval,
      customReminders: customReminders ?? this.customReminders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startHour': startHour,
      'endHour': endHour,
      'interval': interval,
      'customReminders': customReminders.map((r) => r.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [enabled, startHour, endHour, interval, customReminders];
}

/// Model for custom reminder
class CustomReminder extends Equatable {
  const CustomReminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    this.days = const [1, 2, 3, 4, 5, 6, 7],
    this.enabled = true,
    this.createdAt,
  });

  factory CustomReminder.fromJson(Map<String, dynamic> json) {
    return CustomReminder(
      id: json['id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      days: (json['days'] as List<dynamic>?)?.cast<int>() ?? [1, 2, 3, 4, 5, 6, 7],
      enabled: json['enabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
  final List<int> days; // 1 = Monday, 7 = Sunday
  final bool enabled;
  final DateTime? createdAt;

  String get timeString {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String get daysString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }
    return days.map((day) => dayNames[day - 1]).join(', ');
  }

  CustomReminder copyWith({
    int? id,
    int? hour,
    int? minute,
    String? title,
    String? body,
    List<int>? days,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return CustomReminder(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      title: title ?? this.title,
      body: body ?? this.body,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'title': title,
      'body': body,
      'days': days,
      'enabled': enabled,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [id, hour, minute, title, body, days, enabled, createdAt];
}

/// Model for app preferences
class AppPreferences extends Equatable {
  const AppPreferences({
    this.selectedAvatar = AvatarOption.male,
    this.dailyGoal = 2000,
    this.units = WaterUnits.milliliters,
    this.soundEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.showProgressInNotifications = true,
  });

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      selectedAvatar: AvatarOption.values.firstWhere(
        (e) => e.name == json['selectedAvatar'],
        orElse: () => AvatarOption.male,
      ),
      dailyGoal: json['dailyGoal'] as int? ?? 2000,
      units: WaterUnits.values.firstWhere(
        (e) => e.name == json['units'],
        orElse: () => WaterUnits.milliliters,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] as bool? ?? true,
      showProgressInNotifications: json['showProgressInNotifications'] as bool? ?? true,
    );
  }

  final AvatarOption selectedAvatar;
  final int dailyGoal;
  final WaterUnits units;
  final bool soundEnabled;
  final bool hapticFeedbackEnabled;
  final bool showProgressInNotifications;

  AppPreferences copyWith({
    AvatarOption? selectedAvatar,
    int? dailyGoal,
    WaterUnits? units,
    bool? soundEnabled,
    bool? hapticFeedbackEnabled,
    bool? showProgressInNotifications,
  }) {
    return AppPreferences(
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      units: units ?? this.units,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      showProgressInNotifications: showProgressInNotifications ?? this.showProgressInNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedAvatar': selectedAvatar.name,
      'dailyGoal': dailyGoal,
      'units': units.name,
      'soundEnabled': soundEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'showProgressInNotifications': showProgressInNotifications,
    };
  }

  @override
  List<Object?> get props => [
    selectedAvatar, dailyGoal, units, soundEnabled, 
    hapticFeedbackEnabled, showProgressInNotifications
  ];
}

/// Enum for water units
enum WaterUnits {
  milliliters,
  ounces,
  cups;

  String get displayName {
    switch (this) {
      case WaterUnits.milliliters:
        return 'Milliliters (ml)';
      case WaterUnits.ounces:
        return 'Fluid Ounces (fl oz)';
      case WaterUnits.cups:
        return 'Cups';
    }
  }

  String get shortName {
    switch (this) {
      case WaterUnits.milliliters:
        return 'ml';
      case WaterUnits.ounces:
        return 'fl oz';
      case WaterUnits.cups:
        return 'cups';
    }
  }

  /// Convert from milliliters to this unit
  double fromMilliliters(int ml) {
    switch (this) {
      case WaterUnits.milliliters:
        return ml.toDouble();
      case WaterUnits.ounces:
        return ml / 29.5735; // 1 fl oz = 29.5735 ml
      case WaterUnits.cups:
        return ml / 236.588; // 1 cup = 236.588 ml
    }
  }

  /// Convert from this unit to milliliters
  int toMilliliters(double value) {
    switch (this) {
      case WaterUnits.milliliters:
        return value.round();
      case WaterUnits.ounces:
        return (value * 29.5735).round();
      case WaterUnits.cups:
        return (value * 236.588).round();
    }
  }
}

/// Model for data management options
class DataManagementOptions extends Equatable {
  const DataManagementOptions({
    this.autoBackupEnabled = true,
    this.backupFrequency = BackupFrequency.weekly,
    this.cloudSyncEnabled = false,
    this.dataRetentionDays = 365,
  });

  factory DataManagementOptions.fromJson(Map<String, dynamic> json) {
    return DataManagementOptions(
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      backupFrequency: BackupFrequency.values.firstWhere(
        (e) => e.name == json['backupFrequency'],
        orElse: () => BackupFrequency.weekly,
      ),
      cloudSyncEnabled: json['cloudSyncEnabled'] as bool? ?? false,
      dataRetentionDays: json['dataRetentionDays'] as int? ?? 365,
    );
  }

  final bool autoBackupEnabled;
  final BackupFrequency backupFrequency;
  final bool cloudSyncEnabled;
  final int dataRetentionDays;

  DataManagementOptions copyWith({
    bool? autoBackupEnabled,
    BackupFrequency? backupFrequency,
    bool? cloudSyncEnabled,
    int? dataRetentionDays,
  }) {
    return DataManagementOptions(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'backupFrequency': backupFrequency.name,
      'cloudSyncEnabled': cloudSyncEnabled,
      'dataRetentionDays': dataRetentionDays,
    };
  }

  @override
  List<Object?> get props => [autoBackupEnabled, backupFrequency, cloudSyncEnabled, dataRetentionDays];
}

/// Enum for backup frequency
enum BackupFrequency {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case BackupFrequency.daily:
        return 'Daily';
      case BackupFrequency.weekly:
        return 'Weekly';
      case BackupFrequency.monthly:
        return 'Monthly';
    }
  }
}
