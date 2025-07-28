import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:watertracker/core/services/premium_service.dart';
import 'package:watertracker/core/services/storage_service.dart';

/// Enhanced notification service with smart reminders and premium features
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final PremiumService _premiumService = PremiumService();
  final StorageService _storageService = StorageService();

  static const String _notificationChannelId = 'water_reminder';
  static const String _notificationChannelName = 'Water Reminder';
  static const String _notificationChannelDescription = 'Reminds you to drink water';
  
  // Storage keys
  static const String _lastNotificationKey = 'last_notification_time';
  static const String _notificationCountKey = 'notification_count';
  static const String _notificationInteractionsKey = 'notification_interactions';
  static const String _customRemindersKey = 'custom_reminders';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _usagePatternKey = 'usage_pattern';

  bool _isInitialized = false;


  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      await _storageService.initialize();
      
      _isInitialized = true;
      debugPrint('Enhanced NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }



  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Check current permission status
      final permissionStatus = await Permission.notification.status;
      
      if (permissionStatus.isGranted) {
        return true;
      }
      
      if (permissionStatus.isDenied) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      
      // Handle permanently denied case
      if (permissionStatus.isPermanentlyDenied) {
        debugPrint('Notification permission permanently denied');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final permissionStatus = await Permission.notification.status;
      return permissionStatus.isGranted;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Schedule smart water reminders based on usage patterns
  Future<void> scheduleSmartReminders() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel existing notifications first
      await cancelAllNotifications();

      // Check if notifications are enabled
      if (!await areNotificationsEnabled()) {
        debugPrint('Notifications not enabled, skipping scheduling');
        return;
      }

      final isPremium = await _premiumService.isPremiumUnlocked();
      
      if (isPremium) {
        await _scheduleCustomReminders();
      } else {
        await _scheduleBasicReminders();
      }

      // Update last scheduling time
      await _storageService.saveInt(
        'last_reminder_schedule',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('Smart reminders scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling smart reminders: $e');
    }
  }

  /// Schedule basic reminders for free users
  Future<void> _scheduleBasicReminders() async {
    final settings = await _getNotificationSettings();
    final usagePattern = await _getUsagePattern();
    
    // Default schedule: every 2 hours between 8 AM and 10 PM
    final startHour = (settings['startHour'] as int?) ?? 8;
    final endHour = (settings['endHour'] as int?) ?? 22;
    final interval = (settings['interval'] as num?)?.toInt() ?? 2;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, startHour);
    
    // If current time is past start time, schedule for next day
    if (now.hour >= startHour) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    var notificationId = 0;
    for (var hour = startHour; hour <= endHour; hour += interval) {
      if (hour > endHour) break;

      final notificationTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        hour,
      );

      // Adjust timing based on usage pattern
      final adjustedTime = _adjustTimeBasedOnUsage(notificationTime, usagePattern);

      await _scheduleNotification(
        id: notificationId++,
        title: _getSmartTitle(adjustedTime, usagePattern),
        body: _getSmartBody(adjustedTime, usagePattern),
        scheduledTime: adjustedTime,
        payload: 'basic_reminder',
      );
    }
  }

  /// Schedule custom reminders for premium users
  Future<void> _scheduleCustomReminders() async {
    final customReminders = await _getCustomReminders();
    
    if (customReminders.isEmpty) {
      // Fall back to smart basic reminders if no custom reminders set
      await _scheduleBasicReminders();
      return;
    }

    var notificationId = 100; // Start from 100 to avoid conflicts
    
    for (final reminder in customReminders) {
      if (!(reminder['enabled'] as bool? ?? false)) continue;

      final hour = reminder['hour'] as int;
      final minute = reminder['minute'] as int;
      final title = reminder['title'] as String? ?? 'Time to Hydrate!';
      final body = reminder['body'] as String? ?? 'Remember to drink water and stay healthy.';
      final days = reminder['days'] as List<int>? ?? [1, 2, 3, 4, 5, 6, 7]; // All days by default

      final now = DateTime.now();
      
      for (final dayOfWeek in days) {
        var scheduledDate = _getNextDateForDayOfWeek(now, dayOfWeek);
        final scheduledTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );

        // If the time has passed today, schedule for next week
        if (scheduledTime.isBefore(now) && scheduledDate.day == now.day) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
          final newScheduledTime = DateTime(
            scheduledDate.year,
            scheduledDate.month,
            scheduledDate.day,
            hour,
            minute,
          );
          
          await _scheduleNotification(
            id: notificationId++,
            title: title,
            body: body,
            scheduledTime: newScheduledTime,
            payload: 'custom_reminder',
            repeatWeekly: true,
          );
        } else {
          await _scheduleNotification(
            id: notificationId++,
            title: title,
            body: body,
            scheduledTime: scheduledTime,
            payload: 'custom_reminder',
            repeatWeekly: true,
          );
        }
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool repeatWeekly = false,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        ledColor: Color.fromARGB(255, 0, 150, 255),
        ledOnMs: 1000,
        ledOffMs: 500,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      if (repeatWeekly) {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
      } else {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      }

      // Track scheduled notification
      await _trackNotificationScheduled(id, title, scheduledTime);
      
    } catch (e) {
      debugPrint('Error scheduling notification $id: $e');
    }
  }

  /// Get smart notification title based on time and usage
  String _getSmartTitle(DateTime time, Map<String, dynamic> usagePattern) {
    final hour = time.hour;
    final titles = <String>[];

    // Time-based titles
    if (hour >= 6 && hour < 12) {
      titles.addAll([
        'Good Morning! Time to Hydrate 🌅',
        'Start Your Day with Water 💧',
        'Morning Hydration Reminder ☀️',
      ]);
    } else if (hour >= 12 && hour < 17) {
      titles.addAll([
        'Afternoon Hydration Break 🌞',
        'Stay Hydrated This Afternoon 💧',
        'Midday Water Reminder 🚰',
      ]);
    } else if (hour >= 17 && hour < 21) {
      titles.addAll([
        'Evening Hydration Time 🌆',
        'Drink Water Before Dinner 💧',
        'Stay Hydrated This Evening 🌙',
      ]);
    } else {
      titles.addAll([
        'Time to Hydrate! 💧',
        'Water Reminder 🚰',
        'Stay Hydrated 💙',
      ]);
    }

    // Add usage-based variations
    final lastIntake = usagePattern['lastIntakeHour'] as int?;
    if (lastIntake != null && (hour - lastIntake) > 3) {
      titles.addAll([
        "It's Been a While - Drink Water! ⏰",
        "Don't Forget to Hydrate 💧",
        'Time for Some Water 🚰',
      ]);
    }

    return titles[Random().nextInt(titles.length)];
  }

  /// Get smart notification body based on time and usage
  String _getSmartBody(DateTime time, Map<String, dynamic> usagePattern) {
    final bodies = <String>[
      'Remember to drink water and stay healthy.',
      'Your body needs hydration to function at its best.',
      'A glass of water now will keep you energized.',
      'Stay hydrated, stay healthy! 💪',
      'Water is the best medicine for your body.',
      'Keep your hydration levels up throughout the day.',
      'Your future self will thank you for staying hydrated.',
      'Small sips, big benefits. Drink water now!',
    ];

    // Add contextual messages
    final hour = time.hour;
    if (hour >= 6 && hour < 9) {
      bodies
        ..add('Start your day right with a refreshing glass of water.')
        ..add("Rehydrate after a good night's sleep.");
    } else if (hour >= 12 && hour < 14) {
      bodies
        ..add('Lunch time hydration is important for digestion.')
        ..add('Pair your meal with a glass of water.');
    } else if (hour >= 15 && hour < 17) {
      bodies
        ..add('Beat the afternoon slump with hydration.')
        ..add('Water can help you stay focused and alert.');
    }

    return bodies[Random().nextInt(bodies.length)];
  }

  /// Adjust notification time based on usage patterns
  DateTime _adjustTimeBasedOnUsage(DateTime originalTime, Map<String, dynamic> usagePattern) {
    // For now, return original time
    // In the future, this could analyze when user typically drinks water
    // and adjust timing accordingly
    return originalTime;
  }

  /// Get next date for a specific day of week (1 = Monday, 7 = Sunday)
  DateTime _getNextDateForDayOfWeek(DateTime from, int dayOfWeek) {
    final currentDayOfWeek = from.weekday;
    final daysUntilTarget = (dayOfWeek - currentDayOfWeek) % 7;
    
    if (daysUntilTarget == 0) {
      return from; // Today
    }
    
    return from.add(Duration(days: daysUntilTarget));
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification $id: $e');
    }
  }

  /// Show immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
    }
  }

  // MARK: - Premium Features

  /// Add custom reminder (Premium feature)
  Future<bool> addCustomReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    List<int>? days, // 1 = Monday, 7 = Sunday
    bool enabled = true,
  }) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) {
      debugPrint('Custom reminders require premium unlock');
      return false;
    }

    try {
      final customReminders = await _getCustomReminders();
      
      final newReminder = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'hour': hour,
        'minute': minute,
        'title': title,
        'body': body,
        'days': days ?? [1, 2, 3, 4, 5, 6, 7],
        'enabled': enabled,
        'created': DateTime.now().toIso8601String(),
      };

      customReminders.add(newReminder);
      await _saveCustomReminders(customReminders);
      
      // Reschedule all reminders
      await scheduleSmartReminders();
      
      return true;
    } catch (e) {
      debugPrint('Error adding custom reminder: $e');
      return false;
    }
  }

  /// Update custom reminder (Premium feature)
  Future<bool> updateCustomReminder({
    required int id,
    int? hour,
    int? minute,
    String? title,
    String? body,
    List<int>? days,
    bool? enabled,
  }) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) return false;

    try {
      final customReminders = await _getCustomReminders();
      final reminderIndex = customReminders.indexWhere((r) => r['id'] == id);
      
      if (reminderIndex == -1) return false;

      final reminder = customReminders[reminderIndex];
      if (hour != null) reminder['hour'] = hour;
      if (minute != null) reminder['minute'] = minute;
      if (title != null) reminder['title'] = title;
      if (body != null) reminder['body'] = body;
      if (days != null) reminder['days'] = days;
      if (enabled != null) reminder['enabled'] = enabled;
      reminder['updated'] = DateTime.now().toIso8601String();

      await _saveCustomReminders(customReminders);
      await scheduleSmartReminders();
      
      return true;
    } catch (e) {
      debugPrint('Error updating custom reminder: $e');
      return false;
    }
  }

  /// Delete custom reminder (Premium feature)
  Future<bool> deleteCustomReminder(int id) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) return false;

    try {
      final customReminders = await _getCustomReminders();
      customReminders.removeWhere((r) => r['id'] == id);
      
      await _saveCustomReminders(customReminders);
      await scheduleSmartReminders();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting custom reminder: $e');
      return false;
    }
  }

  /// Get custom reminders (Premium feature)
  Future<List<Map<String, dynamic>>> getCustomReminders() async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) return [];

    return _getCustomReminders();
  }

  // MARK: - Analytics and Tracking



  /// Track notification scheduled
  Future<void> _trackNotificationScheduled(int id, String title, DateTime scheduledTime) async {
    try {
      await _storageService.saveInt(_lastNotificationKey, DateTime.now().millisecondsSinceEpoch);
      
      final count = await _storageService.getInt(_notificationCountKey) ?? 0;
      await _storageService.saveInt(_notificationCountKey, count + 1);
    } catch (e) {
      debugPrint('Error tracking notification scheduled: $e');
    }
  }

  /// Get notification analytics (Premium feature)
  Future<Map<String, dynamic>> getNotificationAnalytics() async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) {
      return {
        'error': 'Premium feature',
        'totalScheduled': 0,
        'totalInteractions': 0,
      };
    }

    try {
      final interactions = await _storageService.getJson(_notificationInteractionsKey) ?? {};
      final totalScheduled = await _storageService.getInt(_notificationCountKey) ?? 0;
      
      var totalInteractions = 0;
      for (final dayData in interactions.values) {
        if (dayData is Map<String, dynamic>) {
          totalInteractions += dayData.length;
        }
      }

      return {
        'totalScheduled': totalScheduled,
        'totalInteractions': totalInteractions,
        'interactionRate': totalScheduled > 0 ? totalInteractions / totalScheduled : 0.0,
        'dailyInteractions': interactions,
      };
    } catch (e) {
      debugPrint('Error getting notification analytics: $e');
      return {
        'error': e.toString(),
        'totalScheduled': 0,
        'totalInteractions': 0,
      };
    }
  }

  // MARK: - Settings and Configuration

  /// Update notification settings
  Future<void> updateNotificationSettings({
    int? startHour,
    int? endHour,
    int? interval,
    bool? enabled,
  }) async {
    try {
      final settings = await _getNotificationSettings();
      
      if (startHour != null) settings['startHour'] = startHour;
      if (endHour != null) settings['endHour'] = endHour;
      if (interval != null) settings['interval'] = interval;
      if (enabled != null) settings['enabled'] = enabled;
      
      await _storageService.saveJson(_notificationSettingsKey, settings);
      
      // Reschedule notifications with new settings
      if (settings['enabled'] == true) {
        await scheduleSmartReminders();
      } else {
        await cancelAllNotifications();
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    return _getNotificationSettings();
  }

  // MARK: - Private Helper Methods

  Future<Map<String, dynamic>> _getNotificationSettings() async {
    final settings = await _storageService.getJson(_notificationSettingsKey);
    return settings ?? {
      'enabled': true,
      'startHour': 8,
      'endHour': 22,
      'interval': 2,
    };
  }

  Future<List<Map<String, dynamic>>> _getCustomReminders() async {
    final reminders = await _storageService.getJson(_customRemindersKey);
    if (reminders == null) return [];
    
    final remindersList = reminders['reminders'] as List<dynamic>?;
    return remindersList?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> _saveCustomReminders(List<Map<String, dynamic>> reminders) async {
    await _storageService.saveJson(_customRemindersKey, {
      'reminders': reminders,
      'updated': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> _getUsagePattern() async {
    final pattern = await _storageService.getJson(_usagePatternKey);
    return pattern ?? {
      'lastIntakeHour': null,
      'averageIntakeHours': <int>[],
      'preferredTimes': <int>[],
    };
  }

  /// Update usage pattern based on hydration data
  Future<void> updateUsagePattern({
    int? lastIntakeHour,
    List<int>? recentIntakeHours,
  }) async {
    try {
      final pattern = await _getUsagePattern();
      
      if (lastIntakeHour != null) {
        pattern['lastIntakeHour'] = lastIntakeHour;
      }
      
      if (recentIntakeHours != null) {
        pattern['averageIntakeHours'] = recentIntakeHours;
        // Calculate preferred times based on frequency
        final hourCounts = <int, int>{};
        for (final hour in recentIntakeHours) {
          hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
        }
        
        // Get top 3 most frequent hours
        final sortedHours = hourCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        pattern['preferredTimes'] = sortedHours.take(3).map((e) => e.key).toList();
      }
      
      await _storageService.saveJson(_usagePatternKey, pattern);
    } catch (e) {
      debugPrint('Error updating usage pattern: $e');
    }
  }

  /// Legacy method for backward compatibility
  Future<void> scheduleWaterReminder() async {
    await scheduleSmartReminders();
  }
}
