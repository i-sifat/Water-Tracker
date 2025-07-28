import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';

import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/premium_service.dart';
import 'package:watertracker/core/services/storage_service.dart';

/// Service for integrating with health apps (Google Fit/Apple Health)
class HealthService {
  factory HealthService() => _instance;
  HealthService._internal();
  static final HealthService _instance = HealthService._internal();

  final PremiumService _premiumService = PremiumService();
  final StorageService _storageService = StorageService();
  
  Health? _health;
  bool _isInitialized = false;
  bool _hasPermissions = false;

  // Storage keys
  static const String _healthSyncEnabledKey = 'health_sync_enabled';
  static const String _lastSyncTimeKey = 'last_health_sync_time';
  static const String _syncedDataKey = 'synced_health_data';
  static const String _healthSettingsKey = 'health_settings';

  /// Initialize the health service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _health = Health();
      await _storageService.initialize();
      _isInitialized = true;
      debugPrint('HealthService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing HealthService: $e');
      _isInitialized = false;
    }
  }

  /// Check if health sync is available (premium feature)
  Future<bool> isHealthSyncAvailable() async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    return isPremium && _isInitialized;
  }

  /// Request health permissions
  Future<bool> requestPermissions() async {
    if (!await isHealthSyncAvailable()) {
      debugPrint('Health sync not available');
      return false;
    }

    try {
      final types = [
        HealthDataType.WATER,
      ];

      final permissions = [
        HealthDataAccess.READ_WRITE,
      ];

      final hasPermissions = await _health!.hasPermissions(types, permissions: permissions);
      
      if (hasPermissions == true) {
        _hasPermissions = true;
        return true;
      }

      final granted = await _health!.requestAuthorization(types, permissions: permissions);
      _hasPermissions = granted;
      
      if (granted) {
        await _storageService.saveBool(_healthSyncEnabledKey, true);
        debugPrint('Health permissions granted');
      } else {
        debugPrint('Health permissions denied');
      }

      return granted;
    } catch (e) {
      debugPrint('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Check if health sync is enabled
  Future<bool> isHealthSyncEnabled() async {
    if (!await isHealthSyncAvailable()) return false;
    return await _storageService.getBool(_healthSyncEnabledKey) ?? false;
  }

  /// Enable or disable health sync
  Future<bool> setHealthSyncEnabled(bool enabled) async {
    if (!await isHealthSyncAvailable()) return false;

    if (enabled && !_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) return false;
    }

    await _storageService.saveBool(_healthSyncEnabledKey, enabled);
    
    if (enabled) {
      // Perform initial sync
      await syncToHealth();
    }

    return true;
  }

  /// Sync hydration data to health app
  Future<bool> syncToHealth([List<HydrationData>? data]) async {
    if (!await isHealthSyncEnabled()) return false;

    try {
      final dataToSync = data ?? await _getUnsyncedData();
      if (dataToSync.isEmpty) return true;

      var successCount = 0;
      final syncedIds = <String>[];

      for (final hydrationData in dataToSync) {
        final success = await _writeHealthData(hydrationData);
        if (success) {
          successCount++;
          syncedIds.add(hydrationData.id);
        }
      }

      // Update sync status
      if (syncedIds.isNotEmpty) {
        await _markDataAsSynced(syncedIds);
        await _storageService.saveInt(_lastSyncTimeKey, DateTime.now().millisecondsSinceEpoch);
      }

      debugPrint('Synced $successCount/${dataToSync.length} hydration entries to health app');
      return successCount == dataToSync.length;
    } catch (e) {
      debugPrint('Error syncing to health app: $e');
      return false;
    }
  }

  /// Read hydration data from health app
  Future<List<HealthDataPoint>> readFromHealth({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!await isHealthSyncEnabled()) return [];

    try {
      final start = startTime ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endTime ?? DateTime.now();

      final types = [
        HealthDataType.WATER,
      ];

      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: start,
        endTime: end,
      );

      debugPrint('Read ${healthData.length} health data points');
      return healthData;
    } catch (e) {
      debugPrint('Error reading from health app: $e');
      return [];
    }
  }

  /// Import hydration data from health app
  Future<List<HydrationData>> importFromHealth({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!await isHealthSyncAvailable()) return [];

    try {
      final healthData = await readFromHealth(startTime: startTime, endTime: endTime);
      final importedData = <HydrationData>[];

      for (final dataPoint in healthData) {
        if (dataPoint.type == HealthDataType.WATER) {
          
          // Convert from liters to milliliters
          final amountInMl = (double.parse(dataPoint.value.toString()) * 1000).round();
          
          final hydrationData = HydrationData.create(
            amount: amountInMl,
          ).copyWith(
            timestamp: dataPoint.dateFrom,
            isSynced: true, // Mark as synced since it came from health app
          );

          importedData.add(hydrationData);
        }
      }

      debugPrint('Imported ${importedData.length} hydration entries from health app');
      return importedData;
    } catch (e) {
      debugPrint('Error importing from health app: $e');
      return [];
    }
  }

  /// Get health sync statistics
  Future<Map<String, dynamic>> getHealthSyncStats() async {
    if (!await isHealthSyncAvailable()) {
      return {
        'available': false,
        'enabled': false,
        'lastSync': null,
        'totalSynced': 0,
      };
    }

    try {
      final enabled = await isHealthSyncEnabled();
      final lastSync = await _storageService.getInt(_lastSyncTimeKey);
      final syncedData = await _storageService.getJson(_syncedDataKey) ?? {};
      
      return {
        'available': true,
        'enabled': enabled,
        'hasPermissions': _hasPermissions,
        'lastSync': lastSync != null ? DateTime.fromMillisecondsSinceEpoch(lastSync) : null,
        'totalSynced': (syncedData['syncedIds'] as List<dynamic>?)?.length ?? 0,
        'platform': Platform.isIOS ? 'Apple Health' : 'Google Fit',
      };
    } catch (e) {
      debugPrint('Error getting health sync stats: $e');
      return {
        'available': false,
        'enabled': false,
        'error': e.toString(),
      };
    }
  }

  /// Update health sync settings
  Future<void> updateHealthSettings({
    bool? autoSync,
    int? syncIntervalHours,
    bool? syncOnAdd,
    bool? importOnStart,
  }) async {
    if (!await isHealthSyncAvailable()) return;

    try {
      final settings = await _getHealthSettings();
      
      if (autoSync != null) settings['autoSync'] = autoSync;
      if (syncIntervalHours != null) settings['syncIntervalHours'] = syncIntervalHours;
      if (syncOnAdd != null) settings['syncOnAdd'] = syncOnAdd;
      if (importOnStart != null) settings['importOnStart'] = importOnStart;
      
      await _storageService.saveJson(_healthSettingsKey, settings);
    } catch (e) {
      debugPrint('Error updating health settings: $e');
    }
  }

  /// Get health sync settings
  Future<Map<String, dynamic>> getHealthSettings() async {
    if (!await isHealthSyncAvailable()) return {};
    return _getHealthSettings();
  }

  /// Perform automatic sync if enabled
  Future<void> performAutoSync() async {
    if (!await isHealthSyncEnabled()) return;

    try {
      final settings = await _getHealthSettings();
      final autoSync = settings['autoSync'] as bool? ?? true;
      
      if (!autoSync) return;

      final syncIntervalHours = settings['syncIntervalHours'] as int? ?? 6;
      final lastSync = await _storageService.getInt(_lastSyncTimeKey);
      
      if (lastSync != null) {
        final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
        final nextSyncTime = lastSyncTime.add(Duration(hours: syncIntervalHours));
        
        if (DateTime.now().isBefore(nextSyncTime)) {
          debugPrint('Auto sync not due yet');
          return;
        }
      }

      await syncToHealth();
    } catch (e) {
      debugPrint('Error performing auto sync: $e');
    }
  }

  /// Sync single hydration entry immediately (for real-time sync)
  Future<bool> syncSingleEntry(HydrationData data) async {
    if (!await isHealthSyncEnabled()) return false;

    final settings = await _getHealthSettings();
    final syncOnAdd = settings['syncOnAdd'] as bool? ?? false;
    
    if (!syncOnAdd) return false;

    return syncToHealth([data]);
  }

  // MARK: - Private Helper Methods

  /// Write hydration data to health app
  Future<bool> _writeHealthData(HydrationData data) async {
    try {
      // Convert milliliters to liters for health app
      final amountInLiters = data.waterContent / 1000.0;
      
      const healthDataType = HealthDataType.WATER;

      final success = await _health!.writeHealthData(
        value: amountInLiters,
        type: healthDataType,
        startTime: data.timestamp,
        endTime: data.timestamp,
      );

      return success;
    } catch (e) {
      debugPrint('Error writing health data for ${data.id}: $e');
      return false;
    }
  }

  /// Get unsynced hydration data
  Future<List<HydrationData>> _getUnsyncedData() async {
    // This would typically come from the hydration provider
    // For now, return empty list as this is a service method
    // The actual implementation would be called from the hydration provider
    return [];
  }

  /// Mark data as synced
  Future<void> _markDataAsSynced(List<String> ids) async {
    try {
      final syncedData = await _storageService.getJson(_syncedDataKey) ?? {};
      final syncedIds = (syncedData['syncedIds'] as List<dynamic>?)?.cast<String>() ?? <String>[];
      
      syncedIds.addAll(ids);
      syncedData['syncedIds'] = syncedIds.toSet().toList(); // Remove duplicates
      syncedData['lastUpdated'] = DateTime.now().toIso8601String();
      
      await _storageService.saveJson(_syncedDataKey, syncedData);
    } catch (e) {
      debugPrint('Error marking data as synced: $e');
    }
  }

  /// Get health settings with defaults
  Future<Map<String, dynamic>> _getHealthSettings() async {
    final settings = await _storageService.getJson(_healthSettingsKey);
    return settings ?? {
      'autoSync': true,
      'syncIntervalHours': 6,
      'syncOnAdd': false,
      'importOnStart': false,
    };
  }

  /// Reset health sync (for testing or troubleshooting)
  Future<void> resetHealthSync() async {
    try {
      await _storageService.remove(_healthSyncEnabledKey);
      await _storageService.remove(_lastSyncTimeKey);
      await _storageService.remove(_syncedDataKey);
      await _storageService.remove(_healthSettingsKey);
      
      _hasPermissions = false;
      debugPrint('Health sync reset completed');
    } catch (e) {
      debugPrint('Error resetting health sync: $e');
    }
  }
}