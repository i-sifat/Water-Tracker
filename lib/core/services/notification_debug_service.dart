import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:watertracker/core/services/storage_service.dart';

/// Debug service for comprehensive notification testing and logging
class NotificationDebugService {
  factory NotificationDebugService() => _instance;
  NotificationDebugService._internal();
  static final NotificationDebugService _instance =
      NotificationDebugService._internal();

  final StorageService _storageService = StorageService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _debugLogKey = 'notification_debug_log';
  static const String _testResultsKey = 'notification_test_results';
  static const String _deliveryTrackingKey = 'notification_delivery_tracking';

  /// Log notification events for debugging
  Future<void> logNotificationEvent({
    required String event,
    required Map<String, dynamic> data,
    String? error,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'event': event,
        'data': data,
        'error': error,
        'deviceInfo': await _getDeviceInfo(),
      };

      // Get existing logs
      final existingLogs = await _getDebugLogs();
      existingLogs.add(logEntry);

      // Keep only last 1000 entries to prevent storage bloat
      if (existingLogs.length > 1000) {
        existingLogs.removeRange(0, existingLogs.length - 1000);
      }

      await _storageService.saveJson(_debugLogKey, {
        'logs': existingLogs,
        'lastUpdated': timestamp,
      });

      // Also log to console in debug mode
      if (kDebugMode) {
        debugPrint('NotificationDebug [$event]: ${jsonEncode(data)}');
        if (error != null) {
          debugPrint('NotificationDebug Error: $error');
        }
      }
    } catch (e) {
      debugPrint('Error logging notification event: $e');
    }
  }

  /// Get debug logs
  Future<List<Map<String, dynamic>>> getDebugLogs({
    String? eventFilter,
    DateTime? since,
    int? limit,
  }) async {
    try {
      final logs = await _getDebugLogs();

      var filteredLogs = logs;

      // Apply event filter
      if (eventFilter != null) {
        filteredLogs =
            filteredLogs.where((log) => log['event'] == eventFilter).toList();
      }

      // Apply time filter
      if (since != null) {
        filteredLogs =
            filteredLogs.where((log) {
              final timestamp = DateTime.tryParse(log['timestamp'] ?? '');
              return timestamp != null && timestamp.isAfter(since);
            }).toList();
      }

      // Apply limit
      if (limit != null && filteredLogs.length > limit) {
        filteredLogs = filteredLogs.sublist(filteredLogs.length - limit);
      }

      return filteredLogs;
    } catch (e) {
      debugPrint('Error getting debug logs: $e');
      return [];
    }
  }

  /// Clear debug logs
  Future<void> clearDebugLogs() async {
    try {
      await _storageService.saveJson(_debugLogKey, {
        'logs': <Map<String, dynamic>>[],
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error clearing debug logs: $e');
    }
  }

  /// Export debug logs to file
  Future<String?> exportDebugLogs() async {
    try {
      final logs = await _getDebugLogs();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notification_debug_logs.json');

      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalLogs': logs.length,
        'logs': logs,
      };

      await file.writeAsString(jsonEncode(exportData));
      return file.path;
    } catch (e) {
      debugPrint('Error exporting debug logs: $e');
      return null;
    }
  }

  /// Test notification delivery timing
  Future<Map<String, dynamic>> testNotificationTiming({
    required int testDurationMinutes,
    int intervalMinutes = 1,
  }) async {
    try {
      final testId = DateTime.now().millisecondsSinceEpoch;
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(minutes: testDurationMinutes));

      await logNotificationEvent(
        event: 'timing_test_started',
        data: {
          'testId': testId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'intervalMinutes': intervalMinutes,
        },
      );

      final scheduledNotifications = <Map<String, dynamic>>[];
      var notificationId = testId;
      var currentTime = startTime;

      // Schedule test notifications
      while (currentTime.isBefore(endTime)) {
        currentTime = currentTime.add(Duration(minutes: intervalMinutes));

        final notificationData = {
          'id': notificationId,
          'scheduledTime': currentTime.toIso8601String(),
          'title': 'Timing Test ${notificationId - testId + 1}',
          'body': 'Test notification scheduled for ${currentTime.toString()}',
        };

        scheduledNotifications.add(notificationData);

        // Schedule the notification
        await _scheduleTestNotification(
          id: notificationId,
          title: notificationData['title']!,
          body: notificationData['body']!,
          scheduledTime: currentTime,
          payload: 'timing_test_$testId',
        );

        notificationId++;
      }

      // Save test data
      final testData = {
        'testId': testId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'scheduledNotifications': scheduledNotifications,
        'status': 'running',
      };

      await _saveTestResults(testId.toString(), testData);

      await logNotificationEvent(
        event: 'timing_test_scheduled',
        data: {
          'testId': testId,
          'notificationCount': scheduledNotifications.length,
        },
      );

      return {
        'success': true,
        'testId': testId,
        'scheduledCount': scheduledNotifications.length,
        'message': 'Timing test started successfully',
      };
    } catch (e) {
      await logNotificationEvent(
        event: 'timing_test_error',
        data: {'error': e.toString()},
        error: e.toString(),
      );

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to start timing test',
      };
    }
  }

  /// Test notification persistence across app restarts
  Future<Map<String, dynamic>> testNotificationPersistence() async {
    try {
      final testId = DateTime.now().millisecondsSinceEpoch;
      final scheduledTime = DateTime.now().add(const Duration(minutes: 2));

      await logNotificationEvent(
        event: 'persistence_test_started',
        data: {
          'testId': testId,
          'scheduledTime': scheduledTime.toIso8601String(),
        },
      );

      // Schedule a notification for 2 minutes from now
      await _scheduleTestNotification(
        id: testId,
        title: 'Persistence Test',
        body: 'This notification should survive app restart',
        scheduledTime: scheduledTime,
        payload: 'persistence_test_$testId',
      );

      // Save test data
      final testData = {
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': 'scheduled',
        'instructions': 'Close and reopen the app, then wait for notification',
      };

      await _saveTestResults('persistence_$testId', testData);

      return {
        'success': true,
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'message': 'Persistence test scheduled. Close and reopen the app.',
      };
    } catch (e) {
      await logNotificationEvent(
        event: 'persistence_test_error',
        data: {'error': e.toString()},
        error: e.toString(),
      );

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to start persistence test',
      };
    }
  }

  /// Test notification delivery across device reboot
  Future<Map<String, dynamic>> testRebootPersistence() async {
    try {
      final testId = DateTime.now().millisecondsSinceEpoch;
      final scheduledTime = DateTime.now().add(const Duration(hours: 1));

      await logNotificationEvent(
        event: 'reboot_test_started',
        data: {
          'testId': testId,
          'scheduledTime': scheduledTime.toIso8601String(),
        },
      );

      // Schedule a notification for 1 hour from now
      await _scheduleTestNotification(
        id: testId,
        title: 'Reboot Persistence Test',
        body: 'This notification should survive device reboot',
        scheduledTime: scheduledTime,
        payload: 'reboot_test_$testId',
      );

      // Save test data
      final testData = {
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': 'scheduled',
        'instructions': 'Reboot your device and wait for notification',
      };

      await _saveTestResults('reboot_$testId', testData);

      return {
        'success': true,
        'testId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'message': 'Reboot test scheduled. Reboot your device and wait.',
      };
    } catch (e) {
      await logNotificationEvent(
        event: 'reboot_test_error',
        data: {'error': e.toString()},
        error: e.toString(),
      );

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to start reboot test',
      };
    }
  }

  /// Get pending notifications (Android only)
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    try {
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();

      final notificationList =
          pendingNotifications
              .map(
                (notification) => {
                  'id': notification.id,
                  'title': notification.title,
                  'body': notification.body,
                  'payload': notification.payload,
                },
              )
              .toList();

      await logNotificationEvent(
        event: 'pending_notifications_retrieved',
        data: {
          'count': notificationList.length,
          'notifications': notificationList,
        },
      );

      return notificationList;
    } catch (e) {
      await logNotificationEvent(
        event: 'pending_notifications_error',
        data: {'error': e.toString()},
        error: e.toString(),
      );

      return [];
    }
  }

  /// Track notification delivery
  Future<void> trackNotificationDelivery({
    required String notificationId,
    required String status, // 'delivered', 'clicked', 'dismissed'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final trackingData = {
        'notificationId': notificationId,
        'status': status,
        'timestamp': timestamp,
        'additionalData': additionalData ?? {},
      };

      // Get existing tracking data
      final existingTracking = await _getDeliveryTracking();
      existingTracking.add(trackingData);

      // Keep only last 500 entries
      if (existingTracking.length > 500) {
        existingTracking.removeRange(0, existingTracking.length - 500);
      }

      await _storageService.saveJson(_deliveryTrackingKey, {
        'tracking': existingTracking,
        'lastUpdated': timestamp,
      });

      await logNotificationEvent(
        event: 'notification_delivery_tracked',
        data: trackingData,
      );
    } catch (e) {
      debugPrint('Error tracking notification delivery: $e');
    }
  }

  /// Get delivery statistics
  Future<Map<String, dynamic>> getDeliveryStatistics({DateTime? since}) async {
    try {
      final tracking = await _getDeliveryTracking();

      var filteredTracking = tracking;
      if (since != null) {
        filteredTracking =
            tracking.where((entry) {
              final timestamp = DateTime.tryParse(entry['timestamp'] ?? '');
              return timestamp != null && timestamp.isAfter(since);
            }).toList();
      }

      final totalNotifications = filteredTracking.length;
      final delivered =
          filteredTracking
              .where((entry) => entry['status'] == 'delivered')
              .length;
      final clicked =
          filteredTracking
              .where((entry) => entry['status'] == 'clicked')
              .length;
      final dismissed =
          filteredTracking
              .where((entry) => entry['status'] == 'dismissed')
              .length;

      final deliveryRate =
          totalNotifications > 0 ? delivered / totalNotifications : 0.0;
      final clickRate = delivered > 0 ? clicked / delivered : 0.0;

      return {
        'totalNotifications': totalNotifications,
        'delivered': delivered,
        'clicked': clicked,
        'dismissed': dismissed,
        'deliveryRate': deliveryRate,
        'clickRate': clickRate,
        'period': since?.toIso8601String() ?? 'all_time',
      };
    } catch (e) {
      debugPrint('Error getting delivery statistics: $e');
      return {
        'error': e.toString(),
        'totalNotifications': 0,
        'delivered': 0,
        'clicked': 0,
        'dismissed': 0,
        'deliveryRate': 0.0,
        'clickRate': 0.0,
      };
    }
  }

  /// Get test results
  Future<Map<String, dynamic>?> getTestResults(String testId) async {
    try {
      final allResults = await _storageService.getJson(_testResultsKey) ?? {};
      return allResults[testId] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting test results: $e');
      return null;
    }
  }

  /// Get all test results
  Future<Map<String, dynamic>> getAllTestResults() async {
    try {
      return await _storageService.getJson(_testResultsKey) ?? {};
    } catch (e) {
      debugPrint('Error getting all test results: $e');
      return {};
    }
  }

  /// Clear test results
  Future<void> clearTestResults() async {
    try {
      await _storageService.saveJson(_testResultsKey, {});
    } catch (e) {
      debugPrint('Error clearing test results: $e');
    }
  }

  // Private helper methods

  Future<List<Map<String, dynamic>>> _getDebugLogs() async {
    try {
      final logData = await _storageService.getJson(_debugLogKey);
      if (logData == null) return [];

      final logs = logData['logs'] as List<dynamic>?;
      return logs?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      debugPrint('Error getting debug logs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getDeliveryTracking() async {
    try {
      final trackingData = await _storageService.getJson(_deliveryTrackingKey);
      if (trackingData == null) return [];

      final tracking = trackingData['tracking'] as List<dynamic>?;
      return tracking?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      debugPrint('Error getting delivery tracking: $e');
      return [];
    }
  }

  Future<void> _saveTestResults(
    String testId,
    Map<String, dynamic> data,
  ) async {
    try {
      final allResults = await _storageService.getJson(_testResultsKey) ?? {};
      allResults[testId] = data;
      await _storageService.saveJson(_testResultsKey, allResults);
    } catch (e) {
      debugPrint('Error saving test results: $e');
    }
  }

  Future<void> _scheduleTestNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'test_notifications',
      'Test Notifications',
      channelDescription: 'Notifications for testing delivery and timing',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      ledColor: Color.fromARGB(
        255,
        255,
        165,
        0,
      ), // Orange for test notifications
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Convert DateTime to TZDateTime
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // This is a simplified conversion - in a real app you'd use timezone package
    return dateTime;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'isDebugMode': kDebugMode,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Could not get device info: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
