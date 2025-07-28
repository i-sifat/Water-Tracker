import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:watertracker/core/services/device_service.dart';
import 'package:watertracker/core/services/premium_service.dart';
import 'package:watertracker/core/services/storage_service.dart';

/// Service for handling data synchronization and cloud backup
class SyncService {
  factory SyncService() => _instance;
  SyncService._internal();
  static final SyncService _instance = SyncService._internal();

  final StorageService _storageService = StorageService();
  final PremiumService _premiumService = PremiumService();
  final DeviceService _deviceService = DeviceService();

  // Storage keys
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _syncQueueKey = 'sync_queue';
  static const String _syncSettingsKey = 'sync_settings';
  static const String _conflictResolutionKey = 'conflict_resolution';

  // Cloud sync endpoint (would be replaced with actual server in production)
  static const String _syncEndpoint = 'https://api.watertracker.com/sync';

  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Initialize the sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.initialize();
      _isInitialized = true;
      debugPrint('SyncService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing SyncService: $e');
    }
  }

  /// Check if cloud sync is available (premium feature)
  Future<bool> isCloudSyncAvailable() async {
    return _premiumService.isPremiumUnlocked();
  }

  /// Get sync settings
  Future<Map<String, dynamic>> getSyncSettings() async {
    await _ensureInitialized();
    
    final settings = await _storageService.getJson(_syncSettingsKey);
    return settings ?? {
      'autoSyncEnabled': false,
      'syncFrequency': 'daily', // daily, weekly, manual
      'wifiOnly': true,
      'lastSyncTimestamp': null,
      'conflictResolution': 'ask', // ask, local, remote, merge
    };
  }

  /// Update sync settings
  Future<bool> updateSyncSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    
    try {
      await _storageService.saveJson(_syncSettingsKey, settings);
      debugPrint('Sync settings updated');
      return true;
    } catch (e) {
      debugPrint('Error updating sync settings: $e');
      return false;
    }
  }

  /// Create local backup
  Future<String?> createLocalBackup({String? customName}) async {
    await _ensureInitialized();
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deviceId = await _deviceService.getDeviceId();
      final backupName = customName ?? 'backup_$timestamp';
      
      // Collect all data
      final backupData = await _collectAllData();
      
      // Add metadata
      backupData['backup_metadata'] = {
        'created_at': timestamp,
        'device_id': deviceId,
        'app_version': '1.0.0',
        'backup_version': '1.0',
        'backup_name': backupName,
        'data_types': backupData.keys.where((k) => k != 'backup_metadata').toList(),
      };
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/$backupName.json');
      await backupFile.writeAsString(jsonEncode(backupData));
      
      // Update last backup timestamp
      await _storageService.saveInt('last_backup_timestamp', timestamp);
      
      debugPrint('Local backup created: ${backupFile.path}');
      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating local backup: $e');
      return null;
    }
  }

  /// Restore from local backup
  Future<bool> restoreFromLocalBackup(String backupPath) async {
    await _ensureInitialized();
    
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        debugPrint('Backup file does not exist: $backupPath');
        return false;
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      // Validate backup
      if (!_validateBackupData(backupData)) {
        debugPrint('Invalid backup data format');
        return false;
      }
      
      // Create current state backup before restore
      await createLocalBackup(customName: 'pre_restore_${DateTime.now().millisecondsSinceEpoch}');
      
      // Restore data
      await _restoreAllData(backupData);
      
      debugPrint('Successfully restored from local backup');
      return true;
    } catch (e) {
      debugPrint('Error restoring from local backup: $e');
      return false;
    }
  }

  /// Sync with cloud (premium feature)
  Future<SyncResult> syncWithCloud() async {
    if (!await isCloudSyncAvailable()) {
      return SyncResult.error('Cloud sync requires premium unlock');
    }
    
    if (_isSyncing) {
      return SyncResult.error('Sync already in progress');
    }
    
    await _ensureInitialized();
    _isSyncing = true;
    
    try {
      final deviceId = await _deviceService.getDeviceId();
      final lastSyncTimestamp = await _getLastSyncTimestamp();
      
      // Get local changes since last sync
      final localChanges = await _getLocalChangesSince(lastSyncTimestamp);
      
      // Send changes to server and get remote changes
      final syncResponse = await _performCloudSync(deviceId, localChanges, lastSyncTimestamp);
      
      if (syncResponse.success) {
        // Apply remote changes
        await _applyRemoteChanges(syncResponse.remoteChanges);
        
        // Update last sync timestamp
        if (syncResponse.serverTimestamp != null) {
          await _updateLastSyncTimestamp(syncResponse.serverTimestamp!);
        }
        
        // Clear sync queue
        await _clearSyncQueue();
        
        debugPrint('Cloud sync completed successfully');
        return SyncResult.success(
          'Sync completed successfully',
          localChanges: localChanges.length,
          remoteChanges: syncResponse.remoteChanges.length,
        );
      } else {
        debugPrint('Cloud sync failed: ${syncResponse.error}');
        return SyncResult.error(syncResponse.error ?? 'Unknown sync error');
      }
    } catch (e) {
      debugPrint('Error during cloud sync: $e');
      return SyncResult.error('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Export data for sharing or backup
  Future<String?> exportData({
    required List<String> dataTypes,
    required String format, // json, csv
  }) async {
    if (!await isCloudSyncAvailable()) {
      debugPrint('Data export requires premium unlock');
      return null;
    }
    
    await _ensureInitialized();
    
    try {
      final exportData = await _collectSelectedData(dataTypes);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final directory = await getApplicationDocumentsDirectory();
      String fileName;
      String content;
      
      if (format.toLowerCase() == 'csv') {
        fileName = 'water_tracker_export_$timestamp.csv';
        content = _convertToCSV(exportData);
      } else {
        fileName = 'water_tracker_export_$timestamp.json';
        content = jsonEncode(exportData);
      }
      
      final exportFile = File('${directory.path}/$fileName');
      await exportFile.writeAsString(content);
      
      debugPrint('Data exported to: ${exportFile.path}');
      return exportFile.path;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from file
  Future<bool> importData(String filePath) async {
    await _ensureInitialized();
    
    try {
      final importFile = File(filePath);
      if (!await importFile.exists()) {
        debugPrint('Import file does not exist: $filePath');
        return false;
      }
      
      final content = await importFile.readAsString();
      Map<String, dynamic> importData;
      
      if (filePath.endsWith('.json')) {
        importData = jsonDecode(content) as Map<String, dynamic>;
      } else if (filePath.endsWith('.csv')) {
        importData = _convertFromCSV(content);
      } else {
        debugPrint('Unsupported file format');
        return false;
      }
      
      // Validate and merge data
      await _mergeImportedData(importData);
      
      debugPrint('Data imported successfully');
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    await _ensureInitialized();
    
    final settings = await getSyncSettings();
    final lastSyncTimestamp = await _getLastSyncTimestamp();
    final syncQueue = await _getSyncQueue();
    
    return {
      'isCloudSyncAvailable': await isCloudSyncAvailable(),
      'isSyncing': _isSyncing,
      'autoSyncEnabled': settings['autoSyncEnabled'] ?? false,
      'lastSyncTimestamp': lastSyncTimestamp,
      'pendingChanges': syncQueue.length,
      'lastSyncDate': lastSyncTimestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp).toIso8601String()
          : null,
    };
  }

  /// Add item to sync queue
  Future<void> addToSyncQueue(String dataType, String itemId, String action) async {
    await _ensureInitialized();
    
    try {
      final syncQueue = await _getSyncQueue();
      
      final queueItem = {
        'dataType': dataType,
        'itemId': itemId,
        'action': action, // create, update, delete
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Remove existing item with same dataType and itemId
      syncQueue.removeWhere((item) => 
          item['dataType'] == dataType && item['itemId'] == itemId);
      
      syncQueue.add(queueItem);
      
      await _storageService.saveJson(_syncQueueKey, {'queue': syncQueue});
    } catch (e) {
      debugPrint('Error adding to sync queue: $e');
    }
  }

  /// Perform automatic sync if enabled
  Future<void> performAutoSync() async {
    final settings = await getSyncSettings();
    
    if (!(settings['autoSyncEnabled'] as bool? ?? false) || !await isCloudSyncAvailable()) {
      return;
    }
    
    final lastSyncTimestamp = await _getLastSyncTimestamp();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check if sync is due based on frequency
    var shouldSync = false;
    final frequency = settings['syncFrequency'] ?? 'daily';
    
    if (lastSyncTimestamp == null) {
      shouldSync = true;
    } else {
      final timeSinceLastSync = now - lastSyncTimestamp;
      
      switch (frequency) {
        case 'daily':
          shouldSync = timeSinceLastSync > (24 * 60 * 60 * 1000); // 24 hours
        case 'weekly':
          shouldSync = timeSinceLastSync > (7 * 24 * 60 * 60 * 1000); // 7 days
        case 'manual':
          shouldSync = false;
      }
    }
    
    if (shouldSync) {
      await syncWithCloud();
    }
  }

  // MARK: - Private Methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<Map<String, dynamic>> _collectAllData() async {
    // This would collect all app data for backup
    return {
      'hydration_data': await _storageService.getJson('hydration_history') ?? {},
      'user_profile': await _storageService.getJson('user_profile') ?? {},
      'app_preferences': await _storageService.getJson('app_preferences') ?? {},
      'notification_settings': await _storageService.getJson('notification_settings') ?? {},
      'premium_status': await _storageService.getBool('premium_status') ?? false,
    };
  }

  Future<Map<String, dynamic>> _collectSelectedData(List<String> dataTypes) async {
    final allData = await _collectAllData();
    final selectedData = <String, dynamic>{};
    
    for (final dataType in dataTypes) {
      if (allData.containsKey(dataType)) {
        selectedData[dataType] = allData[dataType];
      }
    }
    
    return selectedData;
  }

  Future<void> _restoreAllData(Map<String, dynamic> backupData) async {
    for (final entry in backupData.entries) {
      if (entry.key == 'backup_metadata') continue;
      
      await _storageService.saveJson(entry.key, entry.value as Map<String, dynamic>);
    }
  }

  bool _validateBackupData(Map<String, dynamic> backupData) {
    // Check if backup has required metadata
    if (!backupData.containsKey('backup_metadata')) {
      return false;
    }
    
    final metadata = backupData['backup_metadata'] as Map<String, dynamic>?;
    if (metadata == null) return false;
    
    // Check required metadata fields
    return metadata.containsKey('created_at') &&
           metadata.containsKey('backup_version') &&
           metadata.containsKey('data_types');
  }

  Future<int?> _getLastSyncTimestamp() async {
    return _storageService.getInt(_lastSyncKey);
  }

  Future<void> _updateLastSyncTimestamp(int timestamp) async {
    await _storageService.saveInt(_lastSyncKey, timestamp);
  }

  Future<List<Map<String, dynamic>>> _getSyncQueue() async {
    final queueData = await _storageService.getJson(_syncQueueKey);
    if (queueData == null) return [];
    
    final queue = queueData['queue'] as List<dynamic>?;
    return queue?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> _clearSyncQueue() async {
    await _storageService.saveJson(_syncQueueKey, {'queue': []});
  }

  Future<List<Map<String, dynamic>>> _getLocalChangesSince(int? timestamp) async {
    final syncQueue = await _getSyncQueue();
    
    if (timestamp == null) {
      return syncQueue;
    }
    
    return syncQueue.where((item) => 
        (item['timestamp'] as int) > timestamp).toList();
  }

  Future<CloudSyncResponse> _performCloudSync(
    String deviceId,
    List<Map<String, dynamic>> localChanges,
    int? lastSyncTimestamp,
  ) async {
    try {
      final requestBody = {
        'device_id': deviceId,
        'last_sync_timestamp': lastSyncTimestamp,
        'local_changes': localChanges,
      };
      
      final response = await http.post(
        Uri.parse(_syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        return CloudSyncResponse(
          success: true,
          serverTimestamp: responseData['server_timestamp'] as int,
          remoteChanges: (responseData['remote_changes'] as List<dynamic>)
              .cast<Map<String, dynamic>>(),
        );
      } else {
        return CloudSyncResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return CloudSyncResponse(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  Future<void> _applyRemoteChanges(List<Map<String, dynamic>> remoteChanges) async {
    for (final change in remoteChanges) {
      final dataType = change['dataType'] as String;
      final itemId = change['itemId'] as String;
      final action = change['action'] as String;
      final data = change['data'];
      
      switch (action) {
        case 'create':
        case 'update':
          await _storageService.saveJson('${dataType}_$itemId', data as Map<String, dynamic>);
        case 'delete':
          await _storageService.remove('${dataType}_$itemId');
      }
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    // Simple CSV conversion for hydration data
    final buffer = StringBuffer();
    
    if (data.containsKey('hydration_data')) {
      buffer.writeln('Date,Time,Amount,Type,Notes');
      
      final hydrationData = data['hydration_data'] as Map<String, dynamic>;
      for (final entry in hydrationData.entries) {
        final entryData = entry.value as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(entryData['timestamp'] as int);
        
        buffer.writeln([
          timestamp.toIso8601String().substring(0, 10),
          timestamp.toIso8601String().substring(11, 19),
          entryData['amount'],
          entryData['type'] ?? 'water',
          entryData['notes'] ?? '',
        ].join(','));
      }
    }
    
    return buffer.toString();
  }

  Map<String, dynamic> _convertFromCSV(String csvContent) {
    // Simple CSV parsing for hydration data
    final lines = csvContent.split('\n');
    final hydrationData = <String, dynamic>{};
    
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final parts = line.split(',');
      if (parts.length >= 3) {
        final date = parts[0];
        final time = parts[1];
        final amount = int.tryParse(parts[2]) ?? 0;
        final type = parts.length > 3 ? parts[3] : 'water';
        final notes = parts.length > 4 ? parts[4] : '';
        
        final timestamp = DateTime.parse('${date}T$time').millisecondsSinceEpoch;
        
        hydrationData[timestamp.toString()] = {
          'timestamp': timestamp,
          'amount': amount,
          'type': type,
          'notes': notes,
        };
      }
    }
    
    return {'hydration_data': hydrationData};
  }

  Future<void> _mergeImportedData(Map<String, dynamic> importData) async {
    // Merge imported data with existing data
    for (final entry in importData.entries) {
      final existingData = await _storageService.getJson(entry.key) ?? {};
      
      if (entry.value is Map<String, dynamic>) {
        final mergedData = Map<String, dynamic>.from(existingData);
        mergedData.addAll(entry.value as Map<String, dynamic>);
        await _storageService.saveJson(entry.key, mergedData);
      } else {
        await _storageService.saveJson(entry.key, entry.value as Map<String, dynamic>);
      }
    }
  }
}

/// Result of a sync operation
class SyncResult {
  const SyncResult({
    required this.success,
    this.message,
    this.error,
    this.localChanges = 0,
    this.remoteChanges = 0,
  });

  factory SyncResult.success(
    String message, {
    int localChanges = 0,
    int remoteChanges = 0,
  }) {
    return SyncResult(
      success: true,
      message: message,
      localChanges: localChanges,
      remoteChanges: remoteChanges,
    );
  }

  factory SyncResult.error(String error) {
    return SyncResult(
      success: false,
      error: error,
    );
  }

  final bool success;
  final String? message;
  final String? error;
  final int localChanges;
  final int remoteChanges;
}

/// Response from cloud sync operation
class CloudSyncResponse {
  const CloudSyncResponse({
    required this.success,
    this.serverTimestamp,
    this.remoteChanges = const <Map<String, dynamic>>[],
    this.error,
  });

  final bool success;
  final int? serverTimestamp;
  final List<Map<String, dynamic>> remoteChanges;
  final String? error;
}