import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> scheduleWaterReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'water_reminder',
      'Water Reminder',
      channelDescription: 'Reminds you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 0, 150, 255),
      ledOnMs: 1000,
      ledOffMs: 500,
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

    // Schedule notifications for every 2 hours between 8 AM and 10 PM
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    for (int i = 0; i < 8; i++) {
      final notificationTime = scheduledTime.add(Duration(hours: i * 2));
      if (notificationTime.hour <= 22) {
        // Only schedule until 10 PM
        try {
          await _notifications.zonedSchedule(
            i,
            'Time to Hydrate!',
            'Don\'t forget to drink water and stay hydrated.',
            tz.TZDateTime.local(
              notificationTime.year,
              notificationTime.month,
              notificationTime.day,
              notificationTime.hour,
              notificationTime.minute,
            ),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
          // Continue with other notifications even if one fails
        }
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
