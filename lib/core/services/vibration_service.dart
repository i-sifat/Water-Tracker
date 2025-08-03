import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import 'package:watertracker/core/services/storage_service.dart';

/// Service for managing vibration and haptic feedback
class VibrationService {
  factory VibrationService() => _instance;
  VibrationService._internal();
  static final VibrationService _instance = VibrationService._internal();

  final StorageService _storageService = StorageService();

  static const String _vibrationSettingsKey = 'vibration_settings';
  static const String _vibrationTestResultsKey = 'vibration_test_results';

  bool _isInitialized = false;
  bool? _hasVibrator;
  bool? _hasAmplitudeControl;
  bool? _hasCustomVibrationsSupport;

  /// Initialize the vibration service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.initialize();
      await _checkVibrationCapabilities();
      _isInitialized = true;
      debugPrint('VibrationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing VibrationService: $e');
      _isInitialized = false;
    }
  }

  /// Check device vibration capabilities
  Future<void> _checkVibrationCapabilities() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      _hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();

      debugPrint('Vibration capabilities:');
      debugPrint('  Has vibrator: $_hasVibrator');
      debugPrint('  Has amplitude control: $_hasAmplitudeControl');
      debugPrint('  Has custom vibrations: $_hasCustomVibrationsSupport');

      // Save capabilities for testing
      await _storageService.saveJson('vibration_capabilities', {
        'hasVibrator': _hasVibrator,
        'hasAmplitudeControl': _hasAmplitudeControl,
        'hasCustomVibrationsSupport': _hasCustomVibrationsSupport,
        'platform': Platform.operatingSystem,
        'checkedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error checking vibration capabilities: $e');
      _hasVibrator = false;
      _hasAmplitudeControl = false;
      _hasCustomVibrationsSupport = false;
    }
  }

  /// Get vibration capabilities
  Map<String, bool?> getCapabilities() {
    return {
      'hasVibrator': _hasVibrator,
      'hasAmplitudeControl': _hasAmplitudeControl,
      'hasCustomVibrationsSupport': _hasCustomVibrationsSupport,
    };
  }

  /// Perform light haptic feedback
  Future<bool> lightHaptic() async {
    try {
      if (!_isInitialized) await initialize();

      final settings = await getVibrationSettings();
      if (!settings['enabled']) {
        debugPrint('Vibration disabled in settings');
        return false;
      }

      if (Platform.isIOS) {
        await HapticFeedback.lightImpact();
        await _logVibrationEvent(
          'light_haptic',
          'success',
          'iOS HapticFeedback',
        );
        return true;
      } else if (_hasVibrator == true) {
        await Vibration.vibrate(duration: 50);
        await _logVibrationEvent(
          'light_haptic',
          'success',
          'Android vibration 50ms',
        );
        return true;
      } else {
        await _logVibrationEvent(
          'light_haptic',
          'failed',
          'No vibrator available',
        );
        return false;
      }
    } catch (e) {
      await _logVibrationEvent('light_haptic', 'error', e.toString());
      debugPrint('Error performing light haptic: $e');
      return false;
    }
  }

  /// Perform medium haptic feedback
  Future<bool> mediumHaptic() async {
    try {
      if (!_isInitialized) await initialize();

      final settings = await getVibrationSettings();
      if (!settings['enabled']) {
        debugPrint('Vibration disabled in settings');
        return false;
      }

      if (Platform.isIOS) {
        await HapticFeedback.mediumImpact();
        await _logVibrationEvent(
          'medium_haptic',
          'success',
          'iOS HapticFeedback',
        );
        return true;
      } else if (_hasVibrator == true) {
        await Vibration.vibrate(duration: 100);
        await _logVibrationEvent(
          'medium_haptic',
          'success',
          'Android vibration 100ms',
        );
        return true;
      } else {
        await _logVibrationEvent(
          'medium_haptic',
          'failed',
          'No vibrator available',
        );
        return false;
      }
    } catch (e) {
      await _logVibrationEvent('medium_haptic', 'error', e.toString());
      debugPrint('Error performing medium haptic: $e');
      return false;
    }
  }

  /// Perform heavy haptic feedback
  Future<bool> heavyHaptic() async {
    try {
      if (!_isInitialized) await initialize();

      final settings = await getVibrationSettings();
      if (!settings['enabled']) {
        debugPrint('Vibration disabled in settings');
        return false;
      }

      if (Platform.isIOS) {
        await HapticFeedback.heavyImpact();
        await _logVibrationEvent(
          'heavy_haptic',
          'success',
          'iOS HapticFeedback',
        );
        return true;
      } else if (_hasVibrator == true) {
        await Vibration.vibrate(duration: 200);
        await _logVibrationEvent(
          'heavy_haptic',
          'success',
          'Android vibration 200ms',
        );
        return true;
      } else {
        await _logVibrationEvent(
          'heavy_haptic',
          'failed',
          'No vibrator available',
        );
        return false;
      }
    } catch (e) {
      await _logVibrationEvent('heavy_haptic', 'error', e.toString());
      debugPrint('Error performing heavy haptic: $e');
      return false;
    }
  }

  /// Perform selection haptic feedback
  Future<bool> selectionHaptic() async {
    try {
      if (!_isInitialized) await initialize();

      final settings = await getVibrationSettings();
      if (!settings['enabled']) {
        debugPrint('Vibration disabled in settings');
        return false;
      }

      if (Platform.isIOS) {
        await HapticFeedback.selectionClick();
        await _logVibrationEvent(
          'selection_haptic',
          'success',
          'iOS HapticFeedback',
        );
        return true;
      } else if (_hasVibrator == true) {
        await Vibration.vibrate(duration: 25);
        await _logVibrationEvent(
          'selection_haptic',
          'success',
          'Android vibration 25ms',
        );
        return true;
      } else {
        await _logVibrationEvent(
          'selection_haptic',
          'failed',
          'No vibrator available',
        );
        return false;
      }
    } catch (e) {
      await _logVibrationEvent('selection_haptic', 'error', e.toString());
      debugPrint('Error performing selection haptic: $e');
      return false;
    }
  }

  /// Perform custom vibration pattern
  Future<bool> customVibration({
    required List<int> pattern,
    int repeat = -1,
    List<int>? intensities,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final settings = await getVibrationSettings();
      if (!settings['enabled']) {
        debugPrint('Vibration disabled in settings');
        return false;
      }

      if (_hasCustomVibrationsSupport == true) {
        await Vibration.vibrate(
          pattern: pattern,
          repeat: repeat,
          intensities: intensities ?? [],
        );
        await _logVibrationEvent(
          'custom_vibration',
          'success',
          'Pattern: $pattern, Repeat: $repeat, Intensities: $intensities',
        );
        return true;
      } else if (_hasVibrator == true) {
        // Fallback to simple vibration
        final totalDuration = pattern.fold<int>(
          0,
          (sum, duration) => sum + duration,
        );
        await Vibration.vibrate(duration: totalDuration);
        await _logVibrationEvent(
          'custom_vibration',
          'fallback',
          'Simple vibration ${totalDuration}ms (custom patterns not supported)',
        );
        return true;
      } else {
        await _logVibrationEvent(
          'custom_vibration',
          'failed',
          'No vibrator available',
        );
        return false;
      }
    } catch (e) {
      await _logVibrationEvent('custom_vibration', 'error', e.toString());
      debugPrint('Error performing custom vibration: $e');
      return false;
    }
  }

  /// Perform notification vibration pattern
  Future<bool> notificationVibration() async {
    return customVibration(
      pattern: [0, 250, 250, 250], // Wait, vibrate, pause, vibrate
      intensities: _hasAmplitudeControl == true ? [0, 128, 0, 255] : null,
    );
  }

  /// Perform success vibration pattern
  Future<bool> successVibration() async {
    return customVibration(
      pattern: [0, 100, 50, 100], // Quick double vibration
      intensities: _hasAmplitudeControl == true ? [0, 200, 0, 200] : null,
    );
  }

  /// Perform error vibration pattern
  Future<bool> errorVibration() async {
    return customVibration(
      pattern: [0, 300, 100, 300, 100, 300], // Three strong vibrations
      intensities:
          _hasAmplitudeControl == true ? [0, 255, 0, 255, 0, 255] : null,
    );
  }

  /// Cancel all vibrations
  Future<void> cancelVibration() async {
    try {
      await Vibration.cancel();
      await _logVibrationEvent(
        'cancel_vibration',
        'success',
        'All vibrations cancelled',
      );
    } catch (e) {
      await _logVibrationEvent('cancel_vibration', 'error', e.toString());
      debugPrint('Error cancelling vibration: $e');
    }
  }

  /// Test all vibration types
  Future<Map<String, dynamic>> testAllVibrationTypes() async {
    final results = <String, dynamic>{
      'testStarted': DateTime.now().toIso8601String(),
      'capabilities': getCapabilities(),
      'tests': <String, dynamic>{},
    };

    // Test light haptic
    await Future.delayed(const Duration(milliseconds: 500));
    results['tests']['light'] = await lightHaptic();

    // Test medium haptic
    await Future.delayed(const Duration(milliseconds: 1000));
    results['tests']['medium'] = await mediumHaptic();

    // Test heavy haptic
    await Future.delayed(const Duration(milliseconds: 1000));
    results['tests']['heavy'] = await heavyHaptic();

    // Test selection haptic
    await Future.delayed(const Duration(milliseconds: 1000));
    results['tests']['selection'] = await selectionHaptic();

    // Test notification pattern
    await Future.delayed(const Duration(milliseconds: 1000));
    results['tests']['notification'] = await notificationVibration();

    // Test success pattern
    await Future.delayed(const Duration(milliseconds: 2000));
    results['tests']['success'] = await successVibration();

    // Test error pattern
    await Future.delayed(const Duration(milliseconds: 2000));
    results['tests']['error'] = await errorVibration();

    results['testCompleted'] = DateTime.now().toIso8601String();

    // Save test results
    await _storageService.saveJson(_vibrationTestResultsKey, results);

    return results;
  }

  /// Test vibration patterns across different devices
  Future<Map<String, dynamic>> testDeviceCompatibility() async {
    final results = <String, dynamic>{
      'testStarted': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'capabilities': getCapabilities(),
      'compatibilityTests': <String, dynamic>{},
    };

    // Test basic vibration
    try {
      await Vibration.vibrate(duration: 100);
      results['compatibilityTests']['basicVibration'] = {
        'success': true,
        'duration': 100,
      };
    } catch (e) {
      results['compatibilityTests']['basicVibration'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Test pattern vibration
    try {
      await Vibration.vibrate(pattern: [0, 100, 100, 100]);
      results['compatibilityTests']['patternVibration'] = {
        'success': true,
        'pattern': [0, 100, 100, 100],
      };
    } catch (e) {
      results['compatibilityTests']['patternVibration'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // Test amplitude control (Android only)
    if (Platform.isAndroid && _hasAmplitudeControl == true) {
      try {
        await Vibration.vibrate(pattern: [0, 200], intensities: [0, 128]);
        results['compatibilityTests']['amplitudeControl'] = {
          'success': true,
          'pattern': [0, 200],
          'intensities': [0, 128],
        };
      } catch (e) {
        results['compatibilityTests']['amplitudeControl'] = {
          'success': false,
          'error': e.toString(),
        };
      }
    } else {
      results['compatibilityTests']['amplitudeControl'] = {
        'success': false,
        'reason': 'Not supported on this platform/device',
      };
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // Test iOS haptic feedback
    if (Platform.isIOS) {
      try {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.selectionClick();

        results['compatibilityTests']['iOSHapticFeedback'] = {
          'success': true,
          'types': ['light', 'medium', 'heavy', 'selection'],
        };
      } catch (e) {
        results['compatibilityTests']['iOSHapticFeedback'] = {
          'success': false,
          'error': e.toString(),
        };
      }
    } else {
      results['compatibilityTests']['iOSHapticFeedback'] = {
        'success': false,
        'reason': 'Not iOS platform',
      };
    }

    results['testCompleted'] = DateTime.now().toIso8601String();

    // Save compatibility test results
    await _storageService.saveJson('vibration_compatibility_test', results);

    return results;
  }

  /// Get vibration settings
  Future<Map<String, dynamic>> getVibrationSettings() async {
    try {
      final settings = await _storageService.getJson(_vibrationSettingsKey);
      return settings ??
          {
            'enabled': true,
            'intensity': 'medium', // light, medium, heavy
            'notificationVibration': true,
            'buttonFeedback': true,
            'successFeedback': true,
            'errorFeedback': true,
          };
    } catch (e) {
      debugPrint('Error getting vibration settings: $e');
      return {
        'enabled': true,
        'intensity': 'medium',
        'notificationVibration': true,
        'buttonFeedback': true,
        'successFeedback': true,
        'errorFeedback': true,
      };
    }
  }

  /// Update vibration settings
  Future<void> updateVibrationSettings({
    bool? enabled,
    String? intensity,
    bool? notificationVibration,
    bool? buttonFeedback,
    bool? successFeedback,
    bool? errorFeedback,
  }) async {
    try {
      final currentSettings = await getVibrationSettings();

      if (enabled != null) currentSettings['enabled'] = enabled;
      if (intensity != null) currentSettings['intensity'] = intensity;
      if (notificationVibration != null) {
        currentSettings['notificationVibration'] = notificationVibration;
      }
      if (buttonFeedback != null)
        currentSettings['buttonFeedback'] = buttonFeedback;
      if (successFeedback != null)
        currentSettings['successFeedback'] = successFeedback;
      if (errorFeedback != null)
        currentSettings['errorFeedback'] = errorFeedback;

      await _storageService.saveJson(_vibrationSettingsKey, currentSettings);
    } catch (e) {
      debugPrint('Error updating vibration settings: $e');
    }
  }

  /// Get vibration test results
  Future<Map<String, dynamic>?> getTestResults() async {
    try {
      return await _storageService.getJson(_vibrationTestResultsKey);
    } catch (e) {
      debugPrint('Error getting vibration test results: $e');
      return null;
    }
  }

  /// Clear test results
  Future<void> clearTestResults() async {
    try {
      await _storageService.saveJson(_vibrationTestResultsKey, {});
    } catch (e) {
      debugPrint('Error clearing vibration test results: $e');
    }
  }

  /// Log vibration events for debugging
  Future<void> _logVibrationEvent(
    String eventType,
    String status,
    String details,
  ) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'eventType': eventType,
        'status': status,
        'details': details,
        'platform': Platform.operatingSystem,
        'capabilities': getCapabilities(),
      };

      // Get existing logs
      final existingLogs =
          await _storageService.getJson('vibration_event_log') ?? {'logs': []};
      final logs = existingLogs['logs'] as List<dynamic>;

      logs.add(logEntry);

      // Keep only last 100 entries
      if (logs.length > 100) {
        logs.removeRange(0, logs.length - 100);
      }

      await _storageService.saveJson('vibration_event_log', {
        'logs': logs,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        debugPrint('VibrationEvent [$eventType]: $status - $details');
      }
    } catch (e) {
      debugPrint('Error logging vibration event: $e');
    }
  }

  /// Get vibration event logs
  Future<List<Map<String, dynamic>>> getEventLogs({int? limit}) async {
    try {
      final logData = await _storageService.getJson('vibration_event_log');
      if (logData == null) return [];

      final logs = logData['logs'] as List<dynamic>;
      final typedLogs = logs.cast<Map<String, dynamic>>();

      if (limit != null && typedLogs.length > limit) {
        return typedLogs.sublist(typedLogs.length - limit);
      }

      return typedLogs;
    } catch (e) {
      debugPrint('Error getting vibration event logs: $e');
      return [];
    }
  }

  /// Clear event logs
  Future<void> clearEventLogs() async {
    try {
      await _storageService.saveJson('vibration_event_log', {
        'logs': [],
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error clearing vibration event logs: $e');
    }
  }

  /// Perform contextual haptic feedback based on action type
  Future<bool> contextualHaptic(String actionType) async {
    final settings = await getVibrationSettings();

    switch (actionType) {
      case 'button_press':
        if (settings['buttonFeedback'] == true) {
          return await selectionHaptic();
        }
        break;
      case 'success':
        if (settings['successFeedback'] == true) {
          return await successVibration();
        }
        break;
      case 'error':
        if (settings['errorFeedback'] == true) {
          return await errorVibration();
        }
        break;
      case 'notification':
        if (settings['notificationVibration'] == true) {
          return await notificationVibration();
        }
        break;
      case 'water_added':
        if (settings['buttonFeedback'] == true) {
          return await mediumHaptic();
        }
        break;
      case 'goal_reached':
        if (settings['successFeedback'] == true) {
          return await successVibration();
        }
        break;
      default:
        return await lightHaptic();
    }

    return false;
  }
}
