import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:watertracker/core/services/device_service.dart';

/// Service for managing premium features and donation unlock system
class PremiumService {
  factory PremiumService() => _instance;
  PremiumService._internal();
  static final PremiumService _instance = PremiumService._internal();

  static const String _premiumStatusKey = 'premium_status';
  static const String _deviceCodeKey = 'device_code';
  static const String _unlockCodeKey = 'unlock_code';
  static const String _unlockTimestampKey = 'unlock_timestamp';
  
  // Developer email for donation proof submission
  static const String _developerEmail = 'developer@watertracker.com';
  
  // Secret key for unlock code validation (in production, this should be more secure)
  static const String _secretKey = 'WaterTracker2024Premium';

  final DeviceService _deviceService = DeviceService();
  
  bool? _cachedPremiumStatus;
  String? _cachedDeviceCode;

  /// Checks if premium features are unlocked
  Future<bool> isPremiumUnlocked() async {
    if (_cachedPremiumStatus != null) {
      return _cachedPremiumStatus!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool(_premiumStatusKey) ?? false;
      
      if (isPremium) {
        // Verify the unlock is still valid by checking the stored unlock code
        final storedUnlockCode = prefs.getString(_unlockCodeKey);
        if (storedUnlockCode != null) {
          final isValid = await _validateStoredUnlockCode(storedUnlockCode);
          if (!isValid) {
            // Invalid unlock code, reset premium status
            await _resetPremiumStatus();
            _cachedPremiumStatus = false;
            return false;
          }
        }
      }
      
      _cachedPremiumStatus = isPremium;
      return isPremium;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      _cachedPremiumStatus = false;
      return false;
    }
  }

  /// Generates a unique device code for the user
  Future<String> generateDeviceCode() async {
    if (_cachedDeviceCode != null) {
      return _cachedDeviceCode!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var deviceCode = prefs.getString(_deviceCodeKey);
      
      if (deviceCode == null) {
        // Generate new device code
        deviceCode = await _deviceService.generateUniqueCode();
        await prefs.setString(_deviceCodeKey, deviceCode);
      }
      
      _cachedDeviceCode = deviceCode;
      return deviceCode;
    } catch (e) {
      debugPrint('Error generating device code: $e');
      // Fallback to generating a temporary code
      return _deviceService.generateUniqueCode();
    }
  }

  /// Validates an unlock code against the device
  Future<bool> validateUnlockCode(String unlockCode) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final deviceCode = await generateDeviceCode();
      
      // Generate expected unlock code
      final expectedCode = await _generateUnlockCode(deviceId, deviceCode);
      
      return unlockCode.toUpperCase() == expectedCode.toUpperCase();
    } catch (e) {
      debugPrint('Error validating unlock code: $e');
      return false;
    }
  }

  /// Unlocks premium features with a valid unlock code
  Future<bool> unlockPremium(String unlockCode) async {
    try {
      final isValid = await validateUnlockCode(unlockCode);
      
      if (isValid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_premiumStatusKey, true);
        await prefs.setString(_unlockCodeKey, unlockCode.toUpperCase());
        await prefs.setInt(_unlockTimestampKey, DateTime.now().millisecondsSinceEpoch);
        
        _cachedPremiumStatus = true;
        
        debugPrint('Premium features unlocked successfully');
        return true;
      } else {
        debugPrint('Invalid unlock code provided');
        return false;
      }
    } catch (e) {
      debugPrint('Error unlocking premium: $e');
      return false;
    }
  }

  /// Composes and launches email for donation proof submission
  Future<bool> submitDonationProof({
    String? additionalMessage,
  }) async {
    try {
      final deviceCode = await generateDeviceCode();
      final deviceInfo = await _deviceService.getDeviceInfo();
      
      final subject = Uri.encodeComponent('Water Tracker Premium Unlock Request');
      
      final body = Uri.encodeComponent('''
Hello,

I would like to unlock premium features for Water Tracker app.

Device Code: $deviceCode

Device Information:
- Platform: ${deviceInfo['platform']}
- Model: ${deviceInfo['model'] ?? 'Unknown'}
- Version: ${deviceInfo['version'] ?? 'Unknown'}

${additionalMessage != null ? 'Additional Message:\n$additionalMessage\n\n' : ''}

I have made a donation via bKash and have attached the screenshot as proof.

Please provide the unlock code for my device.

Thank you!
''');

      final emailUri = Uri(
        scheme: 'mailto',
        path: _developerEmail,
        query: 'subject=$subject&body=$body',
      );

      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(emailUri);
      } else {
        debugPrint('Could not launch email client');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting donation proof: $e');
      return false;
    }
  }

  /// Gets the bKash payment information for donations
  Map<String, String> getBkashPaymentInfo() {
    return {
      'number': '+8801XXXXXXXXX', // Replace with actual bKash number
      'accountType': 'Personal',
      'accountName': 'Water Tracker Developer',
      'suggestedAmount': '100 BDT',
      'instructions': 'Send money to the above bKash number and take a screenshot of the transaction.',
    };
  }

  /// Resets premium status (for testing or troubleshooting)
  Future<void> resetPremiumStatus() async {
    await _resetPremiumStatus();
  }

  /// Gets premium unlock information for display
  Future<Map<String, dynamic>> getPremiumInfo() async {
    final deviceCode = await generateDeviceCode();
    final isPremium = await isPremiumUnlocked();
    
    String? unlockTimestamp;
    if (isPremium) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final timestamp = prefs.getInt(_unlockTimestampKey);
        if (timestamp != null) {
          unlockTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp).toString();
        }
      } catch (e) {
        debugPrint('Error getting unlock timestamp: $e');
      }
    }
    
    return {
      'isPremium': isPremium,
      'deviceCode': deviceCode,
      'unlockTimestamp': unlockTimestamp,
      'bkashInfo': getBkashPaymentInfo(),
    };
  }

  /// Clears cached values (useful for testing)
  void clearCache() {
    _cachedPremiumStatus = null;
    _cachedDeviceCode = null;
  }

  /// Private method to generate unlock code for a device
  Future<String> _generateUnlockCode(String deviceId, String deviceCode) async {
    try {
      // Combine device ID, device code, and secret key
      final combined = '$deviceId-$deviceCode-$_secretKey';
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      
      // Take first 16 characters and format as XXXX-XXXX-XXXX-XXXX
      final code = digest.toString().substring(0, 16).toUpperCase();
      return '${code.substring(0, 4)}-${code.substring(4, 8)}-${code.substring(8, 12)}-${code.substring(12, 16)}';
    } catch (e) {
      debugPrint('Error generating unlock code: $e');
      return '';
    }
  }

  /// Private method to validate stored unlock code
  Future<bool> _validateStoredUnlockCode(String storedCode) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final deviceCode = await generateDeviceCode();
      final expectedCode = await _generateUnlockCode(deviceId, deviceCode);
      
      return storedCode.toUpperCase() == expectedCode.toUpperCase();
    } catch (e) {
      debugPrint('Error validating stored unlock code: $e');
      return false;
    }
  }

  /// Private method to reset premium status
  Future<void> _resetPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_premiumStatusKey);
      await prefs.remove(_unlockCodeKey);
      await prefs.remove(_unlockTimestampKey);
      
      _cachedPremiumStatus = false;
      
      debugPrint('Premium status reset');
    } catch (e) {
      debugPrint('Error resetting premium status: $e');
    }
  }
}

/// Enum for premium features
enum PremiumFeature {
  advancedAnalytics,
  customReminders,
  dataExport,
  healthSync,
  unlimitedHistory,
  customGoals,
  weeklyReports,
  themeCustomization,
  backupRestore,
  prioritySupport,
}

/// Extension to check if a premium feature is available
extension PremiumFeatureExtension on PremiumFeature {
  String get displayName {
    switch (this) {
      case PremiumFeature.advancedAnalytics:
        return 'Advanced Analytics';
      case PremiumFeature.customReminders:
        return 'Custom Reminders';
      case PremiumFeature.dataExport:
        return 'Data Export';
      case PremiumFeature.healthSync:
        return 'Health App Sync';
      case PremiumFeature.unlimitedHistory:
        return 'Unlimited History';
      case PremiumFeature.customGoals:
        return 'Custom Goals';
      case PremiumFeature.weeklyReports:
        return 'Weekly Reports';
      case PremiumFeature.themeCustomization:
        return 'Theme Customization';
      case PremiumFeature.backupRestore:
        return 'Backup & Restore';
      case PremiumFeature.prioritySupport:
        return 'Priority Support';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.advancedAnalytics:
        return 'Detailed charts and insights about your hydration patterns';
      case PremiumFeature.customReminders:
        return 'Set personalized reminder schedules and messages';
      case PremiumFeature.dataExport:
        return 'Export your data to CSV or PDF formats';
      case PremiumFeature.healthSync:
        return 'Sync with Google Fit and Apple Health';
      case PremiumFeature.unlimitedHistory:
        return 'Access your complete hydration history';
      case PremiumFeature.customGoals:
        return 'Set custom daily goals based on advanced factors';
      case PremiumFeature.weeklyReports:
        return 'Receive detailed weekly progress reports';
      case PremiumFeature.themeCustomization:
        return 'Customize app themes and colors';
      case PremiumFeature.backupRestore:
        return 'Backup and restore your data across devices';
      case PremiumFeature.prioritySupport:
        return 'Get priority customer support';
    }
  }
}