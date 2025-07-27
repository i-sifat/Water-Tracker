import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for handling device identification and unique code generation
class DeviceService {
  factory DeviceService() => _instance;
  DeviceService._internal();
  static final DeviceService _instance = DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;

  /// Gets a unique device identifier
  /// 
  /// Returns a platform-specific unique identifier that persists across app installs
  /// but may change if the device is factory reset or OS is reinstalled.
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      String deviceId;
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use Android ID as primary identifier
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor as primary identifier
        deviceId = iosInfo.identifierForVendor ?? 'unknown-ios-device';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'unknown-linux-device';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'unknown-macos-device';
      } else {
        // Fallback for unsupported platforms
        deviceId = 'unknown-platform-device';
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      // Fallback to a generated ID based on available info
      _cachedDeviceId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
      return _cachedDeviceId!;
    }
  }

  /// Generates a unique device code for premium unlock system
  /// 
  /// This code is used by users to identify their device when submitting
  /// donation proof. The code includes device ID, timestamp, and random component.
  Future<String> generateUniqueCode() async {
    try {
      final deviceId = await getDeviceId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(9999);
      
      // Create a unique code combining device ID, timestamp, and random number
      final codeString = '$deviceId-$timestamp-$random';
      
      // Hash the code to make it shorter and more user-friendly
      final bytes = utf8.encode(codeString);
      final digest = sha256.convert(bytes);
      
      // Take first 12 characters and format as XXX-XXX-XXX-XXX
      final shortCode = digest.toString().substring(0, 12).toUpperCase();
      return '${shortCode.substring(0, 3)}-${shortCode.substring(3, 6)}-${shortCode.substring(6, 9)}-${shortCode.substring(9, 12)}';
    } catch (e) {
      debugPrint('Error generating unique code: $e');
      // Fallback code generation
      final random = Random();
      final fallbackCode = List.generate(12, (index) => random.nextInt(16).toRadixString(16)).join().toUpperCase();
      return '${fallbackCode.substring(0, 3)}-${fallbackCode.substring(3, 6)}-${fallbackCode.substring(6, 9)}-${fallbackCode.substring(9, 12)}';
    }
  }

  /// Hashes a device ID with a secret for secure validation
  /// 
  /// This method is used to create secure hashes for premium unlock validation.
  /// The secret should be kept secure and not exposed in the client app.
  String hashDeviceId(String deviceId, String secret) {
    try {
      final combined = '$deviceId-$secret';
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('Error hashing device ID: $e');
      return '';
    }
  }

  /// Generates a deterministic hash from device ID for validation purposes
  /// 
  /// This creates a consistent hash that can be used to validate unlock codes
  /// without exposing the actual device ID.
  Future<String> generateValidationHash() async {
    try {
      final deviceId = await getDeviceId();
      final bytes = utf8.encode(deviceId);
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 16);
    } catch (e) {
      debugPrint('Error generating validation hash: $e');
      return '';
    }
  }

  /// Gets detailed device information for debugging purposes
  /// 
  /// Returns a map containing platform-specific device information.
  /// This should only be used for debugging and not stored permanently.
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'id': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else {
        return {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {
        'platform': 'Unknown',
        'error': e.toString(),
      };
    }
  }

  /// Clears cached device ID (useful for testing)
  void clearCache() {
    _cachedDeviceId = null;
  }
}