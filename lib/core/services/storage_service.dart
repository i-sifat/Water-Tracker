import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced storage service with encryption, backup, migration, and performance optimizations
class StorageService {
  factory StorageService() => _instance;
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();

  static const String _currentVersion = '1.0.0';
  static const String _versionKey = 'storage_version';

  static const String _migrationLogKey = 'migration_log';

  late EncryptedSharedPreferences? _encryptedPrefs;
  late SharedPreferences? _regularPrefs;
  bool _isInitialized = false;
  
  // Performance optimizations
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  final List<_BatchOperation> _pendingOperations = [];
  Timer? _batchTimer;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _encryptedPrefs = EncryptedSharedPreferences();
      _regularPrefs = await SharedPreferences.getInstance();
      
      // Check if migration is needed
      await _checkAndPerformMigration();
      
      _isInitialized = true;
      debugPrint('StorageService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing StorageService: $e');
      // Fallback to regular SharedPreferences only
      _regularPrefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // MARK: - Basic Storage Operations

  /// Save a string value securely
  Future<bool> saveString(String key, String value, {bool encrypted = true}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        await _encryptedPrefs!.setString(key, value);
        return true;
      } else {
        return await _regularPrefs!.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving string for key $key: $e');
      return false;
    }
  }

  /// Get a string value
  Future<String?> getString(String key, {bool encrypted = true}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        return await _encryptedPrefs!.getString(key);
      } else {
        return _regularPrefs!.getString(key);
      }
    } catch (e) {
      debugPrint('Error getting string for key $key: $e');
      return null;
    }
  }

  /// Save an integer value
  Future<bool> saveInt(String key, int value, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        await _encryptedPrefs!.setString(key, value.toString());
        return true;
      } else {
        return await _regularPrefs!.setInt(key, value);
      }
    } catch (e) {
      debugPrint('Error saving int for key $key: $e');
      return false;
    }
  }

  /// Get an integer value
  Future<int?> getInt(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted) {
        final stringValue = await _encryptedPrefs!.getString(key);
        return int.tryParse(stringValue ?? '');
      } else {
        return _regularPrefs!.getInt(key);
      }
    } catch (e) {
      debugPrint('Error getting int for key $key: $e');
      return null;
    }
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        await _encryptedPrefs!.setString(key, value.toString());
        return true;
      } else {
        return await _regularPrefs!.setBool(key, value);
      }
    } catch (e) {
      debugPrint('Error saving bool for key $key: $e');
      return false;
    }
  }

  /// Get a boolean value
  Future<bool?> getBool(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted) {
        final stringValue = await _encryptedPrefs!.getString(key);
        return stringValue?.toLowerCase() == 'true';
      } else {
        return _regularPrefs!.getBool(key);
      }
    } catch (e) {
      debugPrint('Error getting bool for key $key: $e');
      return null;
    }
  }

  /// Save a double value
  Future<bool> saveDouble(String key, double value, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        await _encryptedPrefs!.setString(key, value.toString());
        return true;
      } else {
        return await _regularPrefs!.setDouble(key, value);
      }
    } catch (e) {
      debugPrint('Error saving double for key $key: $e');
      return false;
    }
  }

  /// Get a double value
  Future<double?> getDouble(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted) {
        final stringValue = await _encryptedPrefs!.getString(key);
        return double.tryParse(stringValue ?? '');
      } else {
        return _regularPrefs!.getDouble(key);
      }
    } catch (e) {
      debugPrint('Error getting double for key $key: $e');
      return null;
    }
  }

  /// Save a list of strings
  Future<bool> saveStringList(String key, List<String> value, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        final jsonString = jsonEncode(value);
        await _encryptedPrefs!.setString(key, jsonString);
        return true;
      } else {
        return await _regularPrefs!.setStringList(key, value);
      }
    } catch (e) {
      debugPrint('Error saving string list for key $key: $e');
      return false;
    }
  }

  /// Get a list of strings
  Future<List<String>?> getStringList(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted) {
        final jsonString = await _encryptedPrefs!.getString(key);
        if (jsonString == null) return null;
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          return decoded.cast<String>();
        }
        return null;
      } else {
        return _regularPrefs!.getStringList(key);
      }
    } catch (e) {
      debugPrint('Error getting string list for key $key: $e');
      return null;
    }
  }

  /// Remove a key
  Future<bool> remove(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted && _encryptedPrefs != null) {
        await _encryptedPrefs!.remove(key);
        return true;
      } else {
        return await _regularPrefs!.remove(key);
      }
    } catch (e) {
      debugPrint('Error removing key $key: $e');
      return false;
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key, {bool encrypted = false}) async {
    await _ensureInitialized();
    
    try {
      if (encrypted) {
        final value = await _encryptedPrefs!.getString(key);
        return value != null;
      } else {
        return _regularPrefs!.containsKey(key);
      }
    } catch (e) {
      debugPrint('Error checking key $key: $e');
      return false;
    }
  }

  // MARK: - JSON Serialization

  /// Save a JSON serializable object
  Future<bool> saveJson(String key, Map<String, dynamic> data, {bool encrypted = true}) async {
    try {
      final jsonString = jsonEncode(data);
      return await saveString(key, jsonString, encrypted: encrypted);
    } catch (e) {
      debugPrint('Error saving JSON for key $key: $e');
      return false;
    }
  }

  /// Get a JSON object
  Future<Map<String, dynamic>?> getJson(String key, {bool encrypted = true}) async {
    try {
      final jsonString = await getString(key, encrypted: encrypted);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting JSON for key $key: $e');
      return null;
    }
  }

  // MARK: - Backup and Restore

  /// Create a backup of all data
  Future<bool> createBackup({String? customPath}) async {
    await _ensureInitialized();
    
    try {
      final backupData = <String, dynamic>{};
      
      // Backup regular preferences
      final regularKeys = _regularPrefs!.getKeys();
      for (final key in regularKeys) {
        final value = _regularPrefs!.get(key);
        backupData['regular_$key'] = value;
      }
      
      // Backup encrypted preferences (if available)
      if (_encryptedPrefs != null) {
        // Note: We can't directly iterate over encrypted preferences
        // This would need to be implemented based on known keys
        // For now, we'll backup known encrypted keys
        final encryptedKeys = await _getKnownEncryptedKeys();
        for (final key in encryptedKeys) {
          final value = await _encryptedPrefs!.getString(key);
          backupData['encrypted_$key'] = value;
                }
      }
      
      // Add metadata
      backupData['backup_timestamp'] = DateTime.now().millisecondsSinceEpoch;
      backupData['backup_version'] = _currentVersion;
      
      // Save backup
      final backupJson = jsonEncode(backupData);
      
      if (customPath != null) {
        final file = File(customPath);
        await file.writeAsString(backupJson);
      } else {
        // Save to app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File('${directory.path}/water_tracker_backup_$timestamp.json');
        await backupFile.writeAsString(backupJson);
      }
      
      debugPrint('Backup created successfully');
      return true;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }

  /// Restore data from backup
  Future<bool> restoreFromBackup(String backupPath) async {
    await _ensureInitialized();
    
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        debugPrint('Backup file does not exist: $backupPath');
        return false;
      }
      
      final backupJson = await file.readAsString();
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      
      // Validate backup
      if (!backupData.containsKey('backup_timestamp') || 
          !backupData.containsKey('backup_version')) {
        debugPrint('Invalid backup file format');
        return false;
      }
      
      // Restore regular preferences
      for (final entry in backupData.entries) {
        if (entry.key.startsWith('regular_')) {
          final originalKey = entry.key.substring(8); // Remove 'regular_' prefix
          final value = entry.value;
          
          if (value is String) {
            await _regularPrefs!.setString(originalKey, value);
          } else if (value is int) {
            await _regularPrefs!.setInt(originalKey, value);
          } else if (value is double) {
            await _regularPrefs!.setDouble(originalKey, value);
          } else if (value is bool) {
            await _regularPrefs!.setBool(originalKey, value);
          } else if (value is List<String>) {
            await _regularPrefs!.setStringList(originalKey, value);
          }
        } else if (entry.key.startsWith('encrypted_') && _encryptedPrefs != null) {
          final originalKey = entry.key.substring(10); // Remove 'encrypted_' prefix
          final value = entry.value as String;
          await _encryptedPrefs!.setString(originalKey, value);
        }
      }
      
      debugPrint('Data restored from backup successfully');
      return true;
    } catch (e) {
      debugPrint('Error restoring from backup: $e');
      return false;
    }
  }

  /// Get list of available backups
  Future<List<String>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupFiles = <String>[];
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.contains('water_tracker_backup_')) {
          backupFiles.add(entity.path);
        }
      }
      
      // Sort by creation time (newest first)
      backupFiles.sort((a, b) => b.compareTo(a));
      
      return backupFiles;
    } catch (e) {
      debugPrint('Error getting available backups: $e');
      return [];
    }
  }

  // MARK: - Data Migration

  /// Check and perform data migration if needed
  Future<void> _checkAndPerformMigration() async {
    try {
      final currentVersion = _regularPrefs!.getString(_versionKey);
      
      if (currentVersion == null) {
        // First time setup
        await _regularPrefs!.setString(_versionKey, _currentVersion);
        await _logMigration('Initial setup', _currentVersion);
        return;
      }
      
      if (currentVersion != _currentVersion) {
        debugPrint('Migration needed from $currentVersion to $_currentVersion');
        await _performMigration(currentVersion, _currentVersion);
        await _regularPrefs!.setString(_versionKey, _currentVersion);
      }
    } catch (e) {
      debugPrint('Error during migration check: $e');
    }
  }

  /// Perform data migration between versions
  Future<void> _performMigration(String fromVersion, String toVersion) async {
    try {
      // Create backup before migration
      await createBackup();
      
      // Perform version-specific migrations
      if (fromVersion == '0.1.0' && toVersion == '1.0.0') {
        await _migrateFrom010To100();
      }
      
      await _logMigration('Migration from $fromVersion to $toVersion', toVersion);
      debugPrint('Migration completed successfully');
    } catch (e) {
      debugPrint('Error during migration: $e');
      throw Exception('Migration failed: $e');
    }
  }

  /// Migration from version 0.1.0 to 1.0.0
  Future<void> _migrateFrom010To100() async {
    // Example migration: Convert old data format to new format
    // This would contain actual migration logic based on data structure changes
    
    // Migrate hydration data format if needed
    final oldIntake = _regularPrefs!.getInt('currentIntake');
    if (oldIntake != null) {
      // Data is already in correct format, no migration needed
      debugPrint('Hydration data migration: No changes needed');
    }
    
    // Add any other migration logic here
  }

  /// Log migration events
  Future<void> _logMigration(String description, String version) async {
    try {
      final migrationLog = await getStringList(_migrationLogKey) ?? [];
      final logEntry = '${DateTime.now().toIso8601String()}: $description (v$version)';
      migrationLog.add(logEntry);
      
      // Keep only last 10 migration entries
      if (migrationLog.length > 10) {
        migrationLog.removeRange(0, migrationLog.length - 10);
      }
      
      await saveStringList(_migrationLogKey, migrationLog);
    } catch (e) {
      debugPrint('Error logging migration: $e');
    }
  }

  // MARK: - Data Synchronization

  /// Mark data as needing sync
  Future<void> markForSync(String key) async {
    try {
      final syncQueue = await getStringList('sync_queue') ?? [];
      if (!syncQueue.contains(key)) {
        syncQueue.add(key);
        await saveStringList('sync_queue', syncQueue);
      }
    } catch (e) {
      debugPrint('Error marking for sync: $e');
    }
  }

  /// Get items that need synchronization
  Future<List<String>> getSyncQueue() async {
    try {
      return await getStringList('sync_queue') ?? [];
    } catch (e) {
      debugPrint('Error getting sync queue: $e');
      return [];
    }
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(String key) async {
    try {
      final syncQueue = await getStringList('sync_queue') ?? [];
      syncQueue.remove(key);
      await saveStringList('sync_queue', syncQueue);
    } catch (e) {
      debugPrint('Error removing from sync queue: $e');
    }
  }

  /// Clear all sync queue items
  Future<void> clearSyncQueue() async {
    try {
      await remove('sync_queue');
    } catch (e) {
      debugPrint('Error clearing sync queue: $e');
    }
  }

  // MARK: - Utility Methods

  /// Clear all data (for testing or reset)
  Future<bool> clearAll() async {
    await _ensureInitialized();
    
    try {
      await _regularPrefs!.clear();
      if (_encryptedPrefs != null) {
        // Clear known encrypted keys
        final encryptedKeys = await _getKnownEncryptedKeys();
        for (final key in encryptedKeys) {
          await _encryptedPrefs!.remove(key);
        }
      }
      
      debugPrint('All storage data cleared');
      return true;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();
    
    try {
      final stats = <String, dynamic>{};
      
      // Regular preferences stats
      final regularKeys = _regularPrefs!.getKeys();
      stats['regular_keys_count'] = regularKeys.length;
      stats['regular_keys'] = regularKeys.toList();
      
      // Encrypted preferences stats
      if (_encryptedPrefs != null) {
        final encryptedKeys = await _getKnownEncryptedKeys();
        stats['encrypted_keys_count'] = encryptedKeys.length;
        stats['encrypted_keys'] = encryptedKeys;
      } else {
        stats['encrypted_keys_count'] = 0;
        stats['encrypted_keys'] = <String>[];
      }
      
      // Version info
      stats['storage_version'] = await getString(_versionKey, encrypted: false);
      stats['migration_log'] = await getStringList(_migrationLogKey);
      
      // Sync queue info
      stats['sync_queue'] = await getSyncQueue();
      
      return stats;
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }

  /// Get known encrypted keys (this would be maintained based on app usage)
  Future<List<String>> _getKnownEncryptedKeys() async {
    // This list should be maintained based on what keys the app uses for encrypted storage
    return [
      'premium_unlock_code',
      'user_sensitive_data',
      'backup_encryption_key',
      // Add other known encrypted keys here
    ];
  }

  // MARK: - Performance Optimizations

  /// Get value from memory cache if available and not expired
  T? _getFromCache<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
      return _memoryCache[key] as T?;
    }
    
    // Remove expired cache entry
    if (timestamp != null) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    return null;
  }

  /// Cache value in memory
  void _cacheValue(String key, dynamic value) {
    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
    
    // Limit cache size
    if (_memoryCache.length > 100) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }





  /// Optimized getString with caching
  Future<String?> getStringCached(String key, {bool encrypted = true}) async {
    // Check cache first
    final cached = _getFromCache<String>(key);
    if (cached != null) return cached;
    
    // Get from storage
    final value = await getString(key, encrypted: encrypted);
    
    // Cache the result
    if (value != null) {
      _cacheValue(key, value);
    }
    
    return value;
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cache_size': _memoryCache.length,
      'pending_operations': _pendingOperations.length,
      'cache_hit_ratio': _memoryCache.isNotEmpty ? 
          _memoryCache.length / (_memoryCache.length + _pendingOperations.length) : 0.0,
    };
  }

  /// Check if storage service is healthy
  Future<bool> isHealthy() async {
    try {
      await _ensureInitialized();
      
      // Test basic operations
      const testKey = 'health_check_test';
      const testValue = 'test_value';
      
      // Test regular storage
      final regularSaveResult = await saveString(testKey, testValue, encrypted: false);
      final regularGetResult = await getString(testKey, encrypted: false);
      await remove(testKey);
      
      if (!regularSaveResult || regularGetResult != testValue) {
        return false;
      }
      
      // Test encrypted storage if available
      if (_encryptedPrefs != null) {
        final encryptedSaveResult = await saveString(testKey, testValue);
        final encryptedGetResult = await getString(testKey);
        await remove(testKey, encrypted: true);
        
        if (!encryptedSaveResult || encryptedGetResult != testValue) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Storage health check failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _pendingOperations.clear();
    clearMemoryCache();
  }
}

/// Batch operation for performance optimization
class _BatchOperation {
  final String key;
  final dynamic value;
  final bool encrypted;
  final _OperationType type;

  _BatchOperation({
    required this.key,
    required this.value,
    required this.encrypted,
    required this.type,
  });

  Future<void> execute(SharedPreferences? regularPrefs, EncryptedSharedPreferences? encryptedPrefs) async {
    switch (type) {
      case _OperationType.setString:
        if (encrypted && encryptedPrefs != null) {
          await encryptedPrefs.setString(key, value as String);
        } else if (!encrypted && regularPrefs != null) {
          await regularPrefs.setString(key, value as String);
        }
      case _OperationType.setInt:
        if (encrypted && encryptedPrefs != null) {
          await encryptedPrefs.setString(key, (value as int).toString());
        } else if (!encrypted && regularPrefs != null) {
          await regularPrefs.setInt(key, value as int);
        }
      case _OperationType.setBool:
        if (encrypted && encryptedPrefs != null) {
          await encryptedPrefs.setString(key, (value as bool).toString());
        } else if (!encrypted && regularPrefs != null) {
          await regularPrefs.setBool(key, value as bool);
        }
      case _OperationType.remove:
        if (encrypted && encryptedPrefs != null) {
          await encryptedPrefs.remove(key);
        } else if (!encrypted && regularPrefs != null) {
          await regularPrefs.remove(key);
        }
    }
  }
}

enum _OperationType {
  setString,
  setInt,
  setBool,
  remove,
}
