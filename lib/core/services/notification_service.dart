import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
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

  // Notification channels
  static const String _defaultChannelId = 'water_reminder';
  static const String _defaultChannelName = 'Water Reminders';
  static const String _defaultChannelDescription =
      'Regular hydration reminders';

  static const String _urgentChannelId = 'urgent_reminder';
  static const String _urgentChannelName = 'Urgent Reminders';
  static const String _urgentChannelDescription = 'Important hydration alerts';

  static const String _goalChannelId = 'goal_notifications';
  static const String _goalChannelName = 'Goal Achievements';
  static const String _goalChannelDescription =
      'Notifications for reaching hydration goals';

  static const String _systemChannelId = 'system_notifications';
  static const String _systemChannelName = 'System Notifications';
  static const String _systemChannelDescription =
      'App updates and system messages';

  // Storage keys
  static const String _lastNotificationKey = 'last_notification_time';
  static const String _notificationCountKey = 'notification_count';
  static const String _notificationInteractionsKey =
      'notification_interactions';
  static const String _customRemindersKey = 'custom_reminders';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _usagePatternKey = 'usage_pattern';
  static const String _deliveryTrackingKey = 'delivery_tracking';

  // Legacy constants for backward compatibility
  static const String _notificationChannelId = _defaultChannelId;
  static const String _notificationChannelName = _defaultChannelName;
  static const String _notificationChannelDescription =
      _defaultChannelDescription;

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
      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint('Enhanced NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  /// Create notification channels for different types of notifications
  Future<void> _createNotificationChannels() async {
    try {
      // Default water reminder channel
      const defaultChannel = AndroidNotificationChannel(
        _defaultChannelId,
        _defaultChannelName,
        description: _defaultChannelDescription,
        importance: Importance.high,
        enableLights: true,
        ledColor: Color.fromARGB(255, 0, 150, 255),
        enableVibration: true,
        playSound: true,
      );

      // Urgent reminder channel
      const urgentChannel = AndroidNotificationChannel(
        _urgentChannelId,
        _urgentChannelName,
        description: _urgentChannelDescription,
        importance: Importance.max,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
        enableVibration: true,
        playSound: true,
      );

      // Goal achievement channel
      const goalChannel = AndroidNotificationChannel(
        _goalChannelId,
        _goalChannelName,
        description: _goalChannelDescription,
        importance: Importance.high,
        enableLights: true,
        ledColor: Color.fromARGB(255, 0, 255, 0),
        enableVibration: true,
        playSound: true,
      );

      // System notifications channel
      const systemChannel = AndroidNotificationChannel(
        _systemChannelId,
        _systemChannelName,
        description: _systemChannelDescription,
        importance: Importance.defaultImportance,
        enableLights: false,
        enableVibration: false,
        playSound: false,
      );

      // Create channels on Android
      final plugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (plugin != null) {
        await plugin.createNotificationChannel(defaultChannel);
        await plugin.createNotificationChannel(urgentChannel);
        await plugin.createNotificationChannel(goalChannel);
        await plugin.createNotificationChannel(systemChannel);

        debugPrint('Notification channels created successfully');
      }
    } catch (e) {
      debugPrint('Error creating notification channels: $e');
    }
  }

  /// Get notification channel for reminder type
  String _getChannelForReminderType(String reminderType) {
    switch (reminderType) {
      case 'urgent':
        return _urgentChannelId;
      case 'goal':
        return _goalChannelId;
      case 'system':
        return _systemChannelId;
      default:
        return _defaultChannelId;
    }
  }

  /// Request notification permissions with user guidance
  Future<Map<String, dynamic>> requestPermissions({
    bool showGuidance = true,
  }) async {
    try {
      // Check current permission status
      final permissionStatus = await Permission.notification.status;

      if (permissionStatus.isGranted) {
        await _logPermissionEvent(
          'already_granted',
          'Permissions already granted',
        );
        return {
          'granted': true,
          'status': 'already_granted',
          'message': 'Notification permissions are already granted',
          'needsGuidance': false,
        };
      }

      if (permissionStatus.isDenied) {
        await _logPermissionEvent(
          'requesting',
          'Requesting notification permissions',
        );

        final status = await Permission.notification.request();

        if (status.isGranted) {
          await _logPermissionEvent('granted', 'Permissions granted by user');
          return {
            'granted': true,
            'status': 'granted',
            'message': 'Notification permissions granted successfully',
            'needsGuidance': false,
          };
        } else {
          await _logPermissionEvent('denied', 'Permissions denied by user');
          return {
            'granted': false,
            'status': 'denied',
            'message': 'Notification permissions were denied',
            'needsGuidance': showGuidance,
            'guidance': _getPermissionGuidance('denied'),
          };
        }
      }

      // Handle permanently denied case
      if (permissionStatus.isPermanentlyDenied) {
        await _logPermissionEvent(
          'permanently_denied',
          'Permissions permanently denied',
        );
        return {
          'granted': false,
          'status': 'permanently_denied',
          'message': 'Notification permissions are permanently denied',
          'needsGuidance': showGuidance,
          'guidance': _getPermissionGuidance('permanently_denied'),
          'canOpenSettings': true,
        };
      }

      return {
        'granted': false,
        'status': 'unknown',
        'message': 'Unknown permission status',
        'needsGuidance': false,
      };
    } catch (e) {
      await _logPermissionEvent('error', 'Error requesting permissions: $e');
      debugPrint('Error requesting notification permissions: $e');
      return {
        'granted': false,
        'status': 'error',
        'message': 'Error requesting notification permissions: $e',
        'needsGuidance': false,
      };
    }
  }

  /// Get permission guidance based on status
  Map<String, dynamic> _getPermissionGuidance(String status) {
    switch (status) {
      case 'denied':
        return {
          'title': 'Enable Notifications',
          'message':
              'To receive hydration reminders, please allow notifications when prompted again.',
          'steps': [
            'Tap "Allow" when the permission dialog appears',
            'Notifications help you stay on track with your hydration goals',
            'You can change this setting later in your device settings',
          ],
          'canRetry': true,
        };
      case 'permanently_denied':
        return {
          'title': 'Enable Notifications in Settings',
          'message':
              'Notifications are disabled. Please enable them in your device settings to receive hydration reminders.',
          'steps': [
            'Open your device Settings',
            'Find "Apps" or "Application Manager"',
            'Select "Water Tracker"',
            'Tap "Notifications" or "Permissions"',
            'Enable "Allow notifications"',
          ],
          'canRetry': false,
          'canOpenSettings': true,
        };
      default:
        return {
          'title': 'Notification Setup',
          'message': 'Allow notifications to receive hydration reminders.',
          'steps': [],
          'canRetry': true,
        };
    }
  }

  /// Open app settings (for permanently denied permissions)
  Future<bool> openAppSettings() async {
    try {
      final opened = await openAppSettings();
      await _logPermissionEvent('settings_opened', 'App settings opened');
      return opened;
    } catch (e) {
      await _logPermissionEvent('settings_error', 'Error opening settings: $e');
      debugPrint('Error opening app settings: $e');
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
      final adjustedTime = _adjustTimeBasedOnUsage(
        notificationTime,
        usagePattern,
      );

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
      final body =
          reminder['body'] as String? ??
          'Remember to drink water and stay healthy.';
      final days =
          reminder['days'] as List<int>? ??
          [1, 2, 3, 4, 5, 6, 7]; // All days by default

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
    String reminderType = 'default',
  }) async {
    try {
      final channelId = _getChannelForReminderType(reminderType);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelNameForId(channelId),
        channelDescription: _getChannelDescriptionForId(channelId),
        importance: _getImportanceForChannel(channelId),
        priority: _getPriorityForChannel(channelId),
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
  DateTime _adjustTimeBasedOnUsage(
    DateTime originalTime,
    Map<String, dynamic> usagePattern,
  ) {
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
  Future<void> _trackNotificationScheduled(
    int id,
    String title,
    DateTime scheduledTime,
  ) async {
    try {
      await _storageService.saveInt(
        _lastNotificationKey,
        DateTime.now().millisecondsSinceEpoch,
      );

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
      final interactions =
          await _storageService.getJson(_notificationInteractionsKey) ?? {};
      final totalScheduled =
          await _storageService.getInt(_notificationCountKey) ?? 0;

      var totalInteractions = 0;
      for (final dayData in interactions.values) {
        if (dayData is Map<String, dynamic>) {
          totalInteractions += dayData.length;
        }
      }

      return {
        'totalScheduled': totalScheduled,
        'totalInteractions': totalInteractions,
        'interactionRate':
            totalScheduled > 0 ? totalInteractions / totalScheduled : 0.0,
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
    return settings ??
        {'enabled': true, 'startHour': 8, 'endHour': 22, 'interval': 2};
  }

  Future<List<Map<String, dynamic>>> _getCustomReminders() async {
    final reminders = await _storageService.getJson(_customRemindersKey);
    if (reminders == null) return [];

    final remindersList = reminders['reminders'] as List<dynamic>?;
    return remindersList?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> _saveCustomReminders(
    List<Map<String, dynamic>> reminders,
  ) async {
    await _storageService.saveJson(_customRemindersKey, {
      'reminders': reminders,
      'updated': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> _getUsagePattern() async {
    final pattern = await _storageService.getJson(_usagePatternKey);
    return pattern ??
        {
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
        final sortedHours =
            hourCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        pattern['preferredTimes'] =
            sortedHours.take(3).map((e) => e.key).toList();
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

  // MARK: - Notification Testing Tools

  /// Test notification delivery with different priorities
  Future<Map<String, dynamic>> testNotificationDelivery() async {
    final results = <String, dynamic>{
      'testStarted': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };

    try {
      // Test default notification
      await showImmediateNotification(
        title: 'Test: Default Priority',
        body: 'This is a default priority test notification',
        payload: 'test_default',
      );
      results['tests']['default'] = {
        'sent': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await Future.delayed(const Duration(seconds: 2));

      // Test high priority notification
      await _showTestNotification(
        id: 9001,
        title: 'Test: High Priority',
        body: 'This is a high priority test notification',
        channelId: _urgentChannelId,
        payload: 'test_urgent',
      );
      results['tests']['urgent'] = {
        'sent': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await Future.delayed(const Duration(seconds: 2));

      // Test goal notification
      await _showTestNotification(
        id: 9002,
        title: 'Test: Goal Achievement',
        body: 'This is a goal achievement test notification',
        channelId: _goalChannelId,
        payload: 'test_goal',
      );
      results['tests']['goal'] = {
        'sent': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      results['testCompleted'] = DateTime.now().toIso8601String();
      results['success'] = true;

      // Save test results
      await _storageService.saveJson('notification_delivery_test', results);
    } catch (e) {
      results['error'] = e.toString();
      results['success'] = false;
      debugPrint('Error testing notification delivery: $e');
    }

    return results;
  }

  /// Show test notification with specific channel
  Future<void> _showTestNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelNameForId(channelId),
        channelDescription: _getChannelDescriptionForId(channelId),
        importance: _getImportanceForChannel(channelId),
        priority: _getPriorityForChannel(channelId),
        enableLights: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
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

      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  /// Get channel name for ID
  String _getChannelNameForId(String channelId) {
    switch (channelId) {
      case _urgentChannelId:
        return _urgentChannelName;
      case _goalChannelId:
        return _goalChannelName;
      case _systemChannelId:
        return _systemChannelName;
      default:
        return _defaultChannelName;
    }
  }

  /// Get channel description for ID
  String _getChannelDescriptionForId(String channelId) {
    switch (channelId) {
      case _urgentChannelId:
        return _urgentChannelDescription;
      case _goalChannelId:
        return _goalChannelDescription;
      case _systemChannelId:
        return _systemChannelDescription;
      default:
        return _defaultChannelDescription;
    }
  }

  /// Get importance for channel
  Importance _getImportanceForChannel(String channelId) {
    switch (channelId) {
      case _urgentChannelId:
        return Importance.max;
      case _goalChannelId:
        return Importance.high;
      case _systemChannelId:
        return Importance.defaultImportance;
      default:
        return Importance.high;
    }
  }

  /// Get priority for channel
  Priority _getPriorityForChannel(String channelId) {
    switch (channelId) {
      case _urgentChannelId:
        return Priority.max;
      case _goalChannelId:
        return Priority.high;
      case _systemChannelId:
        return Priority.defaultPriority;
      default:
        return Priority.high;
    }
  }

  /// Test notification persistence across app lifecycle
  Future<Map<String, dynamic>> testNotificationPersistence() async {
    final testId = DateTime.now().millisecondsSinceEpoch;
    final scheduledTime = DateTime.now().add(const Duration(minutes: 1));

    try {
      // Schedule a notification for 1 minute from now
      await _scheduleNotification(
        id: testId,
        title: 'Persistence Test',
        body: 'This notification should survive app restart and device reboot',
        scheduledTime: scheduledTime,
        payload: 'persistence_test_$testId',
      );

      final testData = {
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': 'scheduled',
        'instructions': [
          'Close the app completely',
          'Wait for the notification to appear',
          'Reopen the app to verify the test',
        ],
        'expectedDelivery': scheduledTime.toIso8601String(),
      };

      await _storageService.saveJson('persistence_test_$testId', testData);

      return {
        'success': true,
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'message': 'Persistence test scheduled successfully',
        'instructions': testData['instructions'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to schedule persistence test',
      };
    }
  }

  /// Verify notification delivery (to be called when app reopens)
  Future<Map<String, dynamic>> verifyNotificationDelivery(int testId) async {
    try {
      final testData = await _storageService.getJson(
        'persistence_test_$testId',
      );
      if (testData == null) {
        return {'success': false, 'message': 'Test data not found'};
      }

      final scheduledTime = DateTime.tryParse(testData['scheduledTime'] ?? '');
      final now = DateTime.now();

      if (scheduledTime != null && now.isAfter(scheduledTime)) {
        // Test should have completed
        return {
          'success': true,
          'testId': testId,
          'scheduledTime': testData['scheduledTime'],
          'verifiedAt': now.toIso8601String(),
          'message': 'Test completed. Did you receive the notification?',
          'status': 'awaiting_user_confirmation',
        };
      } else {
        return {
          'success': false,
          'testId': testId,
          'message': 'Test is still pending',
          'status': 'pending',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error verifying notification delivery',
      };
    }
  }

  /// Get notification reliability statistics
  Future<Map<String, dynamic>> getReliabilityStatistics() async {
    try {
      final permissionLogs = await _getPermissionLogs();
      final deliveryTracking = await _getDeliveryTracking();
      final testResults = await _storageService.getJson(
        'notification_delivery_test',
      );

      // Calculate permission success rate
      final totalPermissionRequests = permissionLogs.length;
      final grantedPermissions =
          permissionLogs
              .where(
                (log) =>
                    log['status'] == 'granted' ||
                    log['status'] == 'already_granted',
              )
              .length;
      final permissionSuccessRate =
          totalPermissionRequests > 0
              ? grantedPermissions / totalPermissionRequests
              : 0.0;

      // Calculate delivery success rate
      final totalDeliveries = deliveryTracking.length;
      final successfulDeliveries =
          deliveryTracking
              .where((entry) => entry['status'] == 'delivered')
              .length;
      final deliverySuccessRate =
          totalDeliveries > 0 ? successfulDeliveries / totalDeliveries : 0.0;

      return {
        'permissionStatistics': {
          'totalRequests': totalPermissionRequests,
          'granted': grantedPermissions,
          'successRate': permissionSuccessRate,
        },
        'deliveryStatistics': {
          'totalDeliveries': totalDeliveries,
          'successful': successfulDeliveries,
          'successRate': deliverySuccessRate,
        },
        'lastTestResults': testResults,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'message': 'Error generating reliability statistics',
      };
    }
  }

  // MARK: - Permission Logging

  /// Log permission events
  Future<void> _logPermissionEvent(String status, String details) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'status': status,
        'details': details,
        'platform': Platform.operatingSystem,
      };

      final existingLogs = await _getPermissionLogs();
      existingLogs.add(logEntry);

      // Keep only last 50 entries
      if (existingLogs.length > 50) {
        existingLogs.removeRange(0, existingLogs.length - 50);
      }

      await _storageService.saveJson('permission_event_log', {
        'logs': existingLogs,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        debugPrint('PermissionEvent [$status]: $details');
      }
    } catch (e) {
      debugPrint('Error logging permission event: $e');
    }
  }

  /// Get permission logs
  Future<List<Map<String, dynamic>>> _getPermissionLogs() async {
    try {
      final logData = await _storageService.getJson('permission_event_log');
      if (logData == null) return [];

      final logs = logData['logs'] as List<dynamic>?;
      return logs?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      debugPrint('Error getting permission logs: $e');
      return [];
    }
  }

  /// Clear all debug data
  Future<void> clearAllDebugData() async {
    try {
      await _storageService.saveJson('permission_event_log', {'logs': []});
      await _storageService.saveJson('notification_delivery_test', {});
      await _storageService.saveJson(_deliveryTrackingKey, {'tracking': []});

      // Clear persistence test data
      final allData = await _storageService.getJson('') ?? {};
      for (final key in allData.keys) {
        if (key.toString().startsWith('persistence_test_')) {
          await _storageService.saveJson(key.toString(), {});
        }
      }

      debugPrint('All notification debug data cleared');
    } catch (e) {
      debugPrint('Error clearing debug data: $e');
    }
  }

  /// Get delivery tracking data
  Future<Map<String, dynamic>> _getDeliveryTracking() async {
    try {
      final data = await _storageService.getJson(_deliveryTrackingKey);
      return data ?? {'tracking': []};
    } catch (e) {
      debugPrint('Error getting delivery tracking: $e');
      return {'tracking': []};
    }
  }
}
