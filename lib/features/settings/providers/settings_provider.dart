import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/services/notification_service.dart';
import 'package:watertracker/core/services/premium_service.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/core/services/sync_service.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/settings/models/settings_models.dart';

/// Provider for managing app settings and user preferences
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _initialize();
  }

  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final PremiumService _premiumService = PremiumService();
  final SyncService _syncService = SyncService();

  // Storage keys
  static const String _userProfileKey = 'user_profile';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _appPreferencesKey = 'app_preferences';
  static const String _dataManagementKey = 'data_management';

  // State
  UserProfile? _userProfile;
  NotificationSettings _notificationSettings = const NotificationSettings();
  AppPreferences _appPreferences = const AppPreferences();
  DataManagementOptions _dataManagement = const DataManagementOptions();
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  NotificationSettings get notificationSettings => _notificationSettings;
  AppPreferences get appPreferences => _appPreferences;
  DataManagementOptions get dataManagement => _dataManagement;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Initialize the settings provider
  Future<void> _initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.initialize();
      await _loadAllSettings();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing SettingsProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all settings from storage
  Future<void> _loadAllSettings() async {
    try {
      // Load user profile
      final profileJson = await _storageService.getJson(_userProfileKey);
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(profileJson);
      }

      // Load notification settings
      final notificationJson = await _storageService.getJson(
        _notificationSettingsKey,
      );
      if (notificationJson != null) {
        _notificationSettings = NotificationSettings.fromJson(notificationJson);
      }

      // Load app preferences
      final preferencesJson = await _storageService.getJson(_appPreferencesKey);
      if (preferencesJson != null) {
        _appPreferences = AppPreferences.fromJson(preferencesJson);
      }

      // Load data management options
      final dataManagementJson = await _storageService.getJson(
        _dataManagementKey,
      );
      if (dataManagementJson != null) {
        _dataManagement = DataManagementOptions.fromJson(dataManagementJson);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Reload all settings
  Future<void> reloadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadAllSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - User Profile Management

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      _userProfile = profile;
      await _storageService.saveJson(_userProfileKey, profile.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  /// Update avatar selection
  Future<bool> updateAvatar(AvatarOption avatar) async {
    try {
      _appPreferences = _appPreferences.copyWith(selectedAvatar: avatar);
      await _storageService.saveJson(
        _appPreferencesKey,
        _appPreferences.toJson(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      return false;
    }
  }

  /// Update daily goal
  Future<bool> updateDailyGoal(int goal) async {
    try {
      _appPreferences = _appPreferences.copyWith(dailyGoal: goal);
      await _storageService.saveJson(
        _appPreferencesKey,
        _appPreferences.toJson(),
      );

      // Also update user profile if it exists
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(customDailyGoal: goal);
        await _storageService.saveJson(_userProfileKey, _userProfile!.toJson());
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating daily goal: $e');
      return false;
    }
  }

  // MARK: - Notification Settings

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      _notificationSettings = settings;
      await _storageService.saveJson(
        _notificationSettingsKey,
        settings.toJson(),
      );

      // Update notification service settings
      await _notificationService.updateNotificationSettings(
        startHour: settings.startHour,
        endHour: settings.endHour,
        interval: settings.interval,
        enabled: settings.enabled,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return false;
    }
  }

  /// Toggle notifications
  Future<bool> toggleNotifications({required bool enabled}) async {
    final updatedSettings = _notificationSettings.copyWith(enabled: enabled);
    return updateNotificationSettings(updatedSettings);
  }

  /// Update notification time range
  Future<bool> updateNotificationTimeRange(int startHour, int endHour) async {
    final updatedSettings = _notificationSettings.copyWith(
      startHour: startHour,
      endHour: endHour,
    );
    return updateNotificationSettings(updatedSettings);
  }

  /// Update notification interval
  Future<bool> updateNotificationInterval(int interval) async {
    final updatedSettings = _notificationSettings.copyWith(interval: interval);
    return updateNotificationSettings(updatedSettings);
  }

  /// Add custom reminder (Premium feature)
  Future<bool> addCustomReminder(CustomReminder reminder) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) {
      debugPrint('Custom reminders require premium unlock');
      return false;
    }

    try {
      final updatedReminders = List<CustomReminder>.from(
        _notificationSettings.customReminders,
      )..add(reminder);

      final updatedSettings = _notificationSettings.copyWith(
        customReminders: updatedReminders,
      );

      final success = await updateNotificationSettings(updatedSettings);
      if (success) {
        // Add to notification service
        await _notificationService.addCustomReminder(
          hour: reminder.hour,
          minute: reminder.minute,
          title: reminder.title,
          body: reminder.body,
          days: reminder.days,
          enabled: reminder.enabled,
        );
      }

      return success;
    } catch (e) {
      debugPrint('Error adding custom reminder: $e');
      return false;
    }
  }

  /// Update custom reminder (Premium feature)
  Future<bool> updateCustomReminder(CustomReminder reminder) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) return false;

    try {
      final updatedReminders =
          _notificationSettings.customReminders
              .map((r) => r.id == reminder.id ? reminder : r)
              .toList();

      final updatedSettings = _notificationSettings.copyWith(
        customReminders: updatedReminders,
      );

      final success = await updateNotificationSettings(updatedSettings);
      if (success) {
        // Update in notification service
        await _notificationService.updateCustomReminder(
          id: reminder.id,
          hour: reminder.hour,
          minute: reminder.minute,
          title: reminder.title,
          body: reminder.body,
          days: reminder.days,
          enabled: reminder.enabled,
        );
      }

      return success;
    } catch (e) {
      debugPrint('Error updating custom reminder: $e');
      return false;
    }
  }

  /// Delete custom reminder (Premium feature)
  Future<bool> deleteCustomReminder(int reminderId) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) return false;

    try {
      final updatedReminders =
          _notificationSettings.customReminders
              .where((r) => r.id != reminderId)
              .toList();

      final updatedSettings = _notificationSettings.copyWith(
        customReminders: updatedReminders,
      );

      final success = await updateNotificationSettings(updatedSettings);
      if (success) {
        // Delete from notification service
        await _notificationService.deleteCustomReminder(reminderId);
      }

      return success;
    } catch (e) {
      debugPrint('Error deleting custom reminder: $e');
      return false;
    }
  }

  // MARK: - App Preferences

  /// Update app preferences
  Future<bool> updateAppPreferences(AppPreferences preferences) async {
    try {
      _appPreferences = preferences;
      await _storageService.saveJson(_appPreferencesKey, preferences.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating app preferences: $e');
      return false;
    }
  }

  /// Update water units
  Future<bool> updateWaterUnits(WaterUnits units) async {
    final updatedPreferences = _appPreferences.copyWith(units: units);
    return updateAppPreferences(updatedPreferences);
  }

  /// Toggle sound
  Future<bool> toggleSound({required bool enabled}) async {
    final updatedPreferences = _appPreferences.copyWith(soundEnabled: enabled);
    return updateAppPreferences(updatedPreferences);
  }

  /// Toggle haptic feedback
  Future<bool> toggleHapticFeedback({required bool enabled}) async {
    final updatedPreferences = _appPreferences.copyWith(
      hapticFeedbackEnabled: enabled,
    );
    return updateAppPreferences(updatedPreferences);
  }

  /// Toggle progress in notifications
  Future<bool> toggleProgressInNotifications({required bool enabled}) async {
    final updatedPreferences = _appPreferences.copyWith(
      showProgressInNotifications: enabled,
    );
    return updateAppPreferences(updatedPreferences);
  }

  // MARK: - Data Management

  /// Update data management options
  Future<bool> updateDataManagement(DataManagementOptions options) async {
    try {
      _dataManagement = options;
      await _storageService.saveJson(_dataManagementKey, options.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating data management options: $e');
      return false;
    }
  }

  /// Toggle auto backup
  Future<bool> toggleAutoBackup({required bool enabled}) async {
    final updatedOptions = _dataManagement.copyWith(autoBackupEnabled: enabled);
    return updateDataManagement(updatedOptions);
  }

  /// Update backup frequency
  Future<bool> updateBackupFrequency(BackupFrequency frequency) async {
    final updatedOptions = _dataManagement.copyWith(backupFrequency: frequency);
    return updateDataManagement(updatedOptions);
  }

  /// Toggle cloud sync (Premium feature)
  Future<bool> toggleCloudSync({required bool enabled}) async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium && enabled) {
      debugPrint('Cloud sync requires premium unlock');
      return false;
    }

    final updatedOptions = _dataManagement.copyWith(cloudSyncEnabled: enabled);
    return updateDataManagement(updatedOptions);
  }

  /// Update data retention period
  Future<bool> updateDataRetention(int days) async {
    final updatedOptions = _dataManagement.copyWith(dataRetentionDays: days);
    return updateDataManagement(updatedOptions);
  }

  // MARK: - Data Operations

  /// Create manual backup
  Future<bool> createBackup() async {
    try {
      return await _storageService.createBackup();
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }

  /// Get available backups
  Future<List<String>> getAvailableBackups() async {
    try {
      return await _storageService.getAvailableBackups();
    } catch (e) {
      debugPrint('Error getting available backups: $e');
      return [];
    }
  }

  /// Restore from backup
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      final success = await _storageService.restoreFromBackup(backupPath);
      if (success) {
        await reloadSettings();
      }
      return success;
    } catch (e) {
      debugPrint('Error restoring from backup: $e');
      return false;
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    try {
      final success = await _storageService.clearAll();
      if (success) {
        _userProfile = null;
        _notificationSettings = const NotificationSettings();
        _appPreferences = const AppPreferences();
        _dataManagement = const DataManagementOptions();
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  /// Export user data (Premium feature)
  Future<Map<String, dynamic>?> exportUserData() async {
    final isPremium = await _premiumService.isPremiumUnlocked();
    if (!isPremium) {
      debugPrint('Data export requires premium unlock');
      return null;
    }

    try {
      return {
        'userProfile': _userProfile?.toJson(),
        'notificationSettings': _notificationSettings.toJson(),
        'appPreferences': _appPreferences.toJson(),
        'dataManagement': _dataManagement.toJson(),
        'exportTimestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      debugPrint('Error exporting user data: $e');
      return null;
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      return await _storageService.getStorageStats();
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }

  /// Check storage health
  Future<bool> checkStorageHealth() async {
    try {
      return await _storageService.isHealthy();
    } catch (e) {
      debugPrint('Error checking storage health: $e');
      return false;
    }
  }

  // MARK: - Utility Methods

  /// Reset settings to defaults
  Future<bool> resetToDefaults() async {
    try {
      _notificationSettings = const NotificationSettings();
      _appPreferences = const AppPreferences();
      _dataManagement = const DataManagementOptions();

      await _storageService.saveJson(
        _notificationSettingsKey,
        _notificationSettings.toJson(),
      );
      await _storageService.saveJson(
        _appPreferencesKey,
        _appPreferences.toJson(),
      );
      await _storageService.saveJson(
        _dataManagementKey,
        _dataManagement.toJson(),
      );

      // Reset notification service settings
      await _notificationService.updateNotificationSettings(
        startHour: 8,
        endHour: 22,
        interval: 2,
        enabled: true,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
      return false;
    }
  }

  /// Get formatted daily goal with units
  String getFormattedDailyGoal() {
    final goal = _appPreferences.dailyGoal;
    final units = _appPreferences.units;
    final convertedGoal = units.fromMilliliters(goal);

    if (units == WaterUnits.milliliters) {
      return '${convertedGoal.toInt()} ${units.shortName}';
    } else {
      return '${convertedGoal.toStringAsFixed(1)} ${units.shortName}';
    }
  }

  /// Check if premium features are available
  Future<bool> isPremiumUnlocked() async {
    return _premiumService.isPremiumUnlocked();
  }

  /// Get premium info
  Future<Map<String, dynamic>> getPremiumInfo() async {
    return _premiumService.getPremiumInfo();
  }

  // MARK: - Sync and Backup Methods

  /// Initialize sync service
  Future<void> initializeSync() async {
    try {
      await _syncService.initialize();
    } catch (e) {
      debugPrint('Error initializing sync service: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      return await _syncService.getSyncStatus();
    } catch (e) {
      debugPrint('Error getting sync status: $e');
      return {
        'isCloudSyncAvailable': false,
        'isSyncing': false,
        'autoSyncEnabled': false,
        'lastSyncTimestamp': null,
        'pendingChanges': 0,
        'lastSyncDate': null,
      };
    }
  }

  /// Get sync settings
  Future<Map<String, dynamic>> getSyncSettings() async {
    try {
      return await _syncService.getSyncSettings();
    } catch (e) {
      debugPrint('Error getting sync settings: $e');
      return {
        'autoSyncEnabled': false,
        'syncFrequency': 'daily',
        'wifiOnly': true,
        'lastSyncTimestamp': null,
        'conflictResolution': 'ask',
      };
    }
  }

  /// Update sync settings
  Future<bool> updateSyncSettings(Map<String, dynamic> settings) async {
    try {
      final success = await _syncService.updateSyncSettings(settings);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating sync settings: $e');
      return false;
    }
  }

  /// Perform manual sync
  Future<SyncResult> performManualSync() async {
    try {
      final result = await _syncService.syncWithCloud();
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error performing manual sync: $e');
      return SyncResult.error('Sync failed: $e');
    }
  }

  /// Create local backup with custom name
  Future<String?> createNamedBackup(String name) async {
    try {
      return await _syncService.createLocalBackup(customName: name);
    } catch (e) {
      debugPrint('Error creating named backup: $e');
      return null;
    }
  }

  /// Export data in specified format
  Future<String?> exportDataWithFormat({
    required List<String> dataTypes,
    required String format,
  }) async {
    try {
      return await _syncService.exportData(
        dataTypes: dataTypes,
        format: format,
      );
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from file
  Future<bool> importDataFromFile(String filePath) async {
    try {
      final success = await _syncService.importData(filePath);
      if (success) {
        await reloadSettings();
      }
      return success;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Restore from local backup
  Future<bool> restoreFromLocalBackup(String backupPath) async {
    try {
      final success = await _syncService.restoreFromLocalBackup(backupPath);
      if (success) {
        await reloadSettings();
      }
      return success;
    } catch (e) {
      debugPrint('Error restoring from backup: $e');
      return false;
    }
  }

  /// Get available data types for export
  List<String> getAvailableDataTypes() {
    return [
      'hydration_data',
      'user_profile',
      'app_preferences',
      'notification_settings',
    ];
  }

  /// Get available export formats
  List<String> getAvailableExportFormats() {
    return ['json', 'csv'];
  }

  /// Perform auto sync if enabled
  Future<void> performAutoSyncIfEnabled() async {
    try {
      await _syncService.performAutoSync();
    } catch (e) {
      debugPrint('Error performing auto sync: $e');
    }
  }
}
