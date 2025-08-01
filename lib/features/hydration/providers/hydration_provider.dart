import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/custom_drink_type.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/health_service.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/hydration/screens/goal_completion_screen.dart';

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}

enum AvatarOption { male, female }

/// Enhanced hydration provider with comprehensive tracking and analytics
class HydrationProvider extends ChangeNotifier {
  HydrationProvider({StorageService? storageService})
    : _storageService = storageService ?? StorageService(),
      _healthService = HealthService() {
    _initialize();
  }

  final StorageService _storageService;
  final HealthService _healthService;

  // Current state
  int _currentIntake = 0;
  int _dailyGoal = 2000;
  AvatarOption _selectedAvatar = AvatarOption.male;
  bool _goalReachedToday = false;
  DateTime? _lastUpdated;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSyncing = false;

  // Historical data
  final List<HydrationData> _hydrationHistory = [];
  final Map<DateTime, List<HydrationData>> _dailyDataCache = {};

  // Streak tracking
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastGoalAchievedDate;

  // Premium features
  List<CustomDrinkType> _customDrinkTypes = [];
  bool _healthSyncEnabled = false;

  // Error handling
  AppError? _lastError;

  // Getters - Current state
  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  int get remainingIntake => (_dailyGoal - _currentIntake).clamp(0, _dailyGoal);
  double get intakePercentage => (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
  AvatarOption get selectedAvatar => _selectedAvatar;
  bool get goalReachedToday => _goalReachedToday;
  bool get isInitialized => _isInitialized;
  bool get hasReachedDailyGoal => _currentIntake >= _dailyGoal;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  AppError? get lastError => _lastError;

  // Getters - Historical data
  List<HydrationData> get hydrationHistory =>
      List.unmodifiable(_hydrationHistory);
  List<HydrationData> get todaysEntries => getEntriesForDate(DateTime.now());
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastGoalAchievedDate => _lastGoalAchievedDate;

  // Getters - Premium features
  List<CustomDrinkType> get customDrinkTypes =>
      List.unmodifiable(_customDrinkTypes);
  bool get healthSyncEnabled => _healthSyncEnabled;

  /// Initialize the provider
  Future<void> _initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadData();
      await _loadHistoricalData();
      await loadCustomDrinkTypes();
      await loadHealthSyncSettings();
      _calculateStreaks();
      _updateCurrentDayData();
      _isInitialized = true;
      _lastError = null;
    } catch (e, stackTrace) {
      _lastError = StorageError.readFailed(e.toString());
      debugPrint('Failed to initialize HydrationProvider: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load basic data from storage
  Future<void> _loadData() async {
    try {
      // Load current state
      final currentIntakeValue = await _storageService.getInt('currentIntake');
      _currentIntake = currentIntakeValue ?? 0;

      final dailyGoalValue = await _storageService.getInt('dailyGoal');
      _dailyGoal = dailyGoalValue ?? 2000;

      final goalReachedValue = await _storageService.getBool(
        'goalReachedToday',
      );
      _goalReachedToday = goalReachedValue ?? false;

      final currentStreakValue = await _storageService.getInt('currentStreak');
      _currentStreak = currentStreakValue ?? 0;

      final longestStreakValue = await _storageService.getInt('longestStreak');
      _longestStreak = longestStreakValue ?? 0;

      final avatarString = await _storageService.getString(
        'avatar',
        encrypted: false,
      );
      _selectedAvatar =
          avatarString == 'female' ? AvatarOption.female : AvatarOption.male;

      final lastUpdatedMillis = await _storageService.getInt('lastUpdated');
      _lastUpdated =
          lastUpdatedMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis)
              : null;

      final lastGoalAchievedMillis = await _storageService.getInt(
        'lastGoalAchievedDate',
      );
      _lastGoalAchievedDate =
          lastGoalAchievedMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(lastGoalAchievedMillis)
              : null;
    } catch (e) {
      throw StorageError.readFailed('Failed to load basic data: $e');
    }
  }

  /// Load historical hydration data with pagination for better performance
  Future<void> _loadHistoricalData() async {
    try {
      final historyJson = await _storageService.getString(
        'hydrationHistory',
        encrypted: false,
      );
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;

        // Load data in chunks to avoid blocking UI
        const chunkSize = 100;
        _hydrationHistory.clear();

        for (var i = 0; i < historyList.length; i += chunkSize) {
          final chunk = historyList.skip(i).take(chunkSize);
          final chunkData =
              chunk
                  .map(
                    (json) =>
                        HydrationData.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

          _hydrationHistory.addAll(chunkData);

          // Allow UI to update between chunks
          if (i + chunkSize < historyList.length) {
            await Future<void>.delayed(const Duration(milliseconds: 1));
          }
        }

        // Sort by timestamp (newest first)
        _hydrationHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Build daily cache
        _buildDailyCache();
      }
    } catch (e) {
      throw StorageError.readFailed('Failed to load historical data: $e');
    }
  }

  /// Build daily data cache for faster access
  void _buildDailyCache() {
    _dailyDataCache.clear();
    for (final entry in _hydrationHistory) {
      final date = entry.date;
      _dailyDataCache[date] = (_dailyDataCache[date] ?? [])..add(entry);
    }

    // Sort each day's entries by timestamp
    for (final entries in _dailyDataCache.values) {
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  /// Update current day data based on today's entries
  void _updateCurrentDayData() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if we need to reset for a new day
    if (_lastUpdated == null || _lastUpdated!.isBefore(todayDate)) {
      _resetForNewDay();
    }

    // Calculate current intake from today's entries
    final todaysEntries = getEntriesForDate(today);
    _currentIntake = todaysEntries.totalWaterIntake;
    _goalReachedToday = _currentIntake >= _dailyGoal;
  }

  /// Reset data for a new day
  void _resetForNewDay() {
    _currentIntake = 0;
    _goalReachedToday = false;
    _lastUpdated = DateTime.now();
    _saveBasicData(); // Save the reset
  }

  /// Calculate streak information
  void _calculateStreaks() {
    if (_hydrationHistory.isEmpty) {
      _currentStreak = 0;
      return;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Calculate current streak
    _currentStreak = 0;
    var checkDate = todayDate;

    // Check if today's goal is achieved
    final todaysEntries = getEntriesForDate(today);
    if (todaysEntries.totalWaterIntake >= _dailyGoal) {
      _currentStreak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // If today's goal isn't achieved, check yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Count consecutive days with achieved goals
    while (true) {
      final dayEntries = getEntriesForDate(checkDate);
      if (dayEntries.totalWaterIntake >= _dailyGoal) {
        _currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Update longest streak if current is higher
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
  }

  /// Save basic data to storage
  Future<void> _saveBasicData() async {
    try {
      await _storageService.saveInt('currentIntake', _currentIntake);
      await _storageService.saveInt('dailyGoal', _dailyGoal);
      await _storageService.saveBool('goalReachedToday', value: _goalReachedToday);
      await _storageService.saveInt('currentStreak', _currentStreak);
      await _storageService.saveInt('longestStreak', _longestStreak);
      await _storageService.saveString(
        'avatar',
        _selectedAvatar == AvatarOption.female ? 'female' : 'male',
        encrypted: false,
      );
      await _storageService.saveInt(
        'lastUpdated',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (_lastGoalAchievedDate != null) {
        await _storageService.saveInt(
          'lastGoalAchievedDate',
          _lastGoalAchievedDate!.millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      throw StorageError.writeFailed('Failed to save basic data: $e');
    }
  }

  /// Save historical data to storage
  Future<void> _saveHistoricalData() async {
    try {
      final historyJson = jsonEncode(
        _hydrationHistory.map((e) => e.toJson()).toList(),
      );
      await _storageService.saveString(
        'hydrationHistory',
        historyJson,
        encrypted: false,
      );
    } catch (e) {
      throw StorageError.writeFailed('Failed to save historical data: $e');
    }
  }

  /// Add hydration entry with enhanced tracking
  Future<void> addHydration(
    int amount, {
    DrinkType type = DrinkType.water,
    String? notes,
    BuildContext? context,
  }) async {
    try {
      if (amount <= 0) {
        throw ValidationError.invalidInput(
          'amount',
          'Amount must be greater than 0',
        );
      }

      // Create new hydration entry
      final entry = HydrationData.create(
        amount: amount,
        type: type,
        notes: notes,
      );

      // Add to history
      _hydrationHistory.insert(0, entry); // Add to beginning (newest first)

      // Update daily cache
      final date = entry.date;
      _dailyDataCache[date] = (_dailyDataCache[date] ?? [])..add(entry);
      _dailyDataCache[date]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update current intake
      final waterContent = entry.waterContent;
      _currentIntake += waterContent;

      // Check if goal is reached
      final wasGoalReached = _goalReachedToday;
      _goalReachedToday = _currentIntake >= _dailyGoal;

      // Update streak if goal just reached
      if (!wasGoalReached && _goalReachedToday) {
        _lastGoalAchievedDate = DateTime.now();
        _calculateStreaks();

        // Show celebration if context provided
        if (context != null) {
          unawaited(
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const GoalCompletionScreen(),
              ),
            ),
          );
        }
      }

      // Sync to health app if enabled
      if (_healthSyncEnabled) {
        unawaited(_healthService.syncSingleEntry(entry));
      }

      // Save data
      await _saveBasicData();
      await _saveHistoricalData();

      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : HydrationError.saveFailed();
      debugPrint('Failed to add hydration: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Edit existing hydration entry
  Future<void> editHydrationEntry(
    String entryId, {
    int? amount,
    DrinkType? type,
    String? notes,
  }) async {
    try {
      final entryIndex = _hydrationHistory.indexWhere((e) => e.id == entryId);
      if (entryIndex == -1) {
        throw ValidationError.invalidInput('entryId', 'Entry not found');
      }

      final oldEntry = _hydrationHistory[entryIndex];
      final newEntry = oldEntry.copyWith(
        amount: amount ?? oldEntry.amount,
        type: type ?? oldEntry.type,
        notes: notes ?? oldEntry.notes,
      );

      // Update history
      _hydrationHistory[entryIndex] = newEntry;

      // Update daily cache
      final date = newEntry.date;
      final dayEntries = _dailyDataCache[date] ?? [];
      final dayEntryIndex = dayEntries.indexWhere((e) => e.id == entryId);
      if (dayEntryIndex != -1) {
        dayEntries[dayEntryIndex] = newEntry;
      }

      // Recalculate current intake if it's today's entry
      final today = DateTime.now();
      if (newEntry.date == DateTime(today.year, today.month, today.day)) {
        _updateCurrentDayData();
        _calculateStreaks();
      }

      await _saveBasicData();
      await _saveHistoricalData();

      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : HydrationError.saveFailed();
      debugPrint('Failed to edit hydration entry: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete hydration entry
  Future<void> deleteHydrationEntry(String entryId) async {
    try {
      final entryIndex = _hydrationHistory.indexWhere((e) => e.id == entryId);
      if (entryIndex == -1) {
        throw ValidationError.invalidInput('entryId', 'Entry not found');
      }

      final entry = _hydrationHistory[entryIndex];

      // Remove from history
      _hydrationHistory.removeAt(entryIndex);

      // Remove from daily cache
      final date = entry.date;
      _dailyDataCache[date]?.removeWhere((e) => e.id == entryId);
      if (_dailyDataCache[date]?.isEmpty ?? false) {
        _dailyDataCache.remove(date);
      }

      // Recalculate current intake if it's today's entry
      final today = DateTime.now();
      if (entry.date == DateTime(today.year, today.month, today.day)) {
        _updateCurrentDayData();
        _calculateStreaks();
      }

      await _saveBasicData();
      await _saveHistoricalData();

      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : HydrationError.saveFailed();
      debugPrint('Failed to delete hydration entry: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Get entries for a specific date
  List<HydrationData> getEntriesForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return List.from(_dailyDataCache[dateKey] ?? []);
  }

  /// Get entries for a date range
  List<HydrationData> getEntriesForDateRange(DateTime start, DateTime end) {
    return _hydrationHistory.forDateRange(start, end);
  }

  /// Get weekly data aggregation
  Map<DateTime, int> getWeeklyData(DateTime weekStart) {
    final weekData = <DateTime, int>{};

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayEntries = getEntriesForDate(date);
      weekData[date] = dayEntries.totalWaterIntake;
    }

    return weekData;
  }

  /// Get monthly data aggregation
  Map<DateTime, int> getMonthlyData(DateTime month) {
    final monthData = <DateTime, int>{};
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(month.year, month.month, i);
      final dayEntries = getEntriesForDate(date);
      monthData[date] = dayEntries.totalWaterIntake;
    }

    return monthData;
  }

  /// Get goal achievement rate for a period
  double getGoalAchievementRate(DateTime start, DateTime end) {
    final totalDays = end.difference(start).inDays + 1;
    var achievedDays = 0;

    for (var i = 0; i < totalDays; i++) {
      final date = start.add(Duration(days: i));
      final dayEntries = getEntriesForDate(date);
      if (dayEntries.totalWaterIntake >= _dailyGoal) {
        achievedDays++;
      }
    }

    return totalDays > 0 ? achievedDays / totalDays : 0.0;
  }

  /// Export data for premium users
  Future<String> exportData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      final entries = getEntriesForDateRange(start, end);

      if (format.toLowerCase() == 'csv') {
        return _exportToCsv(entries);
      } else {
        throw ValidationError.invalidInput(
          'format',
          'Unsupported export format',
        );
      }
    } catch (e) {
      throw HydrationError.saveFailed();
    }
  }

  /// Export data to CSV format
  String _exportToCsv(List<HydrationData> entries) {
    final buffer = StringBuffer()
      ..writeln('Date,Time,Amount (ml),Drink Type,Water Content (ml),Notes');

    // Data rows
    for (final entry in entries) {
      final date =
          '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';
      final time =
          '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
      final notes = entry.notes?.replaceAll(',', ';') ?? '';

      buffer.writeln(
        '$date,$time,${entry.amount},${entry.type.displayName},${entry.waterContent},$notes',
      );
    }

    return buffer.toString();
  }

  /// Sync data with external services (placeholder for premium feature)
  Future<void> syncData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // Mark unsynced entries as synced
      for (var i = 0; i < _hydrationHistory.length; i++) {
        if (!_hydrationHistory[i].isSynced) {
          _hydrationHistory[i] = _hydrationHistory[i].copyWith(isSynced: true);
        }
      }

      // Rebuild cache
      _buildDailyCache();

      await _saveHistoricalData();
      _lastError = null;
    } catch (e, stackTrace) {
      _lastError = HydrationError.syncFailed(e.toString());
      debugPrint('Failed to sync data: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Set daily goal
  Future<void> setDailyGoal(int goal) async {
    try {
      if (goal <= 0) {
        throw ValidationError.invalidInput(
          'goal',
          'Goal must be greater than 0',
        );
      }

      _dailyGoal = goal;

      // Recalculate goal status and streaks
      _updateCurrentDayData();
      _calculateStreaks();

      await _saveBasicData();
      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : HydrationError.saveFailed();
      debugPrint('Failed to set daily goal: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Set avatar
  Future<void> setAvatar(AvatarOption avatar) async {
    try {
      _selectedAvatar = avatar;
      await _saveBasicData();
      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = StorageError.writeFailed('Failed to save avatar');
      debugPrint('Failed to set avatar: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Reset intake for current day
  Future<void> resetIntake() async {
    try {
      // Remove today's entries
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      _hydrationHistory.removeWhere((entry) => entry.date == todayDate);
      _dailyDataCache.remove(todayDate);

      _currentIntake = 0;
      _goalReachedToday = false;

      // Recalculate streaks
      _calculateStreaks();

      await _saveBasicData();
      await _saveHistoricalData();

      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = HydrationError.saveFailed();
      debugPrint('Failed to reset intake: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Legacy methods for backward compatibility
  void addIntake(int amount) {
    addHydration(amount);
  }

  Future<void> loadData() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  // MARK: - Premium Features

  /// Load custom drink types (Premium feature)
  Future<void> loadCustomDrinkTypes() async {
    try {
      final customDrinkTypesJson = await _storageService.getString(
        'customDrinkTypes',
      );
      if (customDrinkTypesJson != null) {
        final drinkTypesList =
            jsonDecode(customDrinkTypesJson) as List<dynamic>;
        _customDrinkTypes =
            drinkTypesList
                .map(
                  (json) =>
                      CustomDrinkType.fromJson(json as Map<String, dynamic>),
                )
                .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load custom drink types: $e');
    }
  }

  /// Save custom drink types
  Future<void> saveCustomDrinkTypes() async {
    try {
      final drinkTypesJson = jsonEncode(
        _customDrinkTypes.map((e) => e.toJson()).toList(),
      );
      await _storageService.saveString('customDrinkTypes', drinkTypesJson);
    } catch (e) {
      debugPrint('Failed to save custom drink types: $e');
    }
  }

  /// Add custom drink type (Premium feature)
  Future<void> addCustomDrinkType(CustomDrinkType drinkType) async {
    try {
      _customDrinkTypes.add(drinkType);
      await saveCustomDrinkTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add custom drink type: $e');
      rethrow;
    }
  }

  /// Update custom drink type (Premium feature)
  Future<void> updateCustomDrinkType(CustomDrinkType drinkType) async {
    try {
      final index = _customDrinkTypes.indexWhere((dt) => dt.id == drinkType.id);
      if (index != -1) {
        _customDrinkTypes[index] = drinkType;
        await saveCustomDrinkTypes();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update custom drink type: $e');
      rethrow;
    }
  }

  /// Delete custom drink type (Premium feature)
  Future<void> deleteCustomDrinkType(String drinkTypeId) async {
    try {
      _customDrinkTypes.removeWhere((dt) => dt.id == drinkTypeId);
      await saveCustomDrinkTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete custom drink type: $e');
      rethrow;
    }
  }

  /// Get all available drink types (built-in + custom)
  List<dynamic> getAllDrinkTypes() {
    const builtInTypes = DrinkType.values;
    final customTypes = _customDrinkTypes.where((dt) => dt.isActive).toList();
    return [...builtInTypes, ...customTypes];
  }

  /// Add hydration with custom drink type
  Future<void> addHydrationWithCustomType(
    int amount, {
    CustomDrinkType? customType,
    DrinkType? builtInType,
    String? notes,
    BuildContext? context,
  }) async {
    if (customType != null) {
      // Create hydration data with custom water content calculation
      final waterContent = customType.getWaterContent(amount);
      final entry = HydrationData.create(
        amount: amount,
        type: DrinkType.other, // Use 'other' as base type
        notes: notes,
      );

      // Override water content calculation
      final customEntry = HydrationData(
        id: entry.id,
        amount: amount,
        timestamp: entry.timestamp,
        type: DrinkType.other,
        notes: '${customType.name}${notes != null ? ' - $notes' : ''}',
      );

      await _addCustomHydrationEntry(customEntry, waterContent, context);
    } else if (builtInType != null) {
      await addHydration(
        amount,
        type: builtInType,
        notes: notes,
        context: context,
      );
    } else {
      throw ValidationError.invalidInput(
        'drinkType',
        'Either custom or built-in drink type must be provided',
      );
    }
  }

  /// Add custom hydration entry with specific water content
  Future<void> _addCustomHydrationEntry(
    HydrationData entry,
    int waterContent,
    BuildContext? context,
  ) async {
    try {
      // Add to history
      _hydrationHistory.insert(0, entry);

      // Update daily cache
      final date = entry.date;
      _dailyDataCache[date] = (_dailyDataCache[date] ?? [])..add(entry);
      _dailyDataCache[date]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update current intake with custom water content
      _currentIntake += waterContent;

      // Check if goal is reached
      final wasGoalReached = _goalReachedToday;
      _goalReachedToday = _currentIntake >= _dailyGoal;

      // Update streak if goal just reached
      if (!wasGoalReached && _goalReachedToday) {
        _lastGoalAchievedDate = DateTime.now();
        _calculateStreaks();

        // Show celebration if context provided
        if (context != null) {
          unawaited(
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const GoalCompletionScreen(),
              ),
            ),
          );
        }
      }

      // Sync to health app if enabled
      if (_healthSyncEnabled) {
        unawaited(_healthService.syncSingleEntry(entry));
      }

      // Save data
      await _saveBasicData();
      await _saveHistoricalData();

      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : HydrationError.saveFailed();
      debugPrint('Failed to add custom hydration: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      rethrow;
    }
  }

  /// Enable/disable health sync (Premium feature)
  Future<void> setHealthSyncEnabled({required bool enabled}) async {
    try {
      await _healthService.initialize();

      if (enabled) {
        final success = await _healthService.setHealthSyncEnabled(
          enabled: true,
        );
        if (success) {
          _healthSyncEnabled = true;
          await _storageService.saveBool('healthSyncEnabled', value: true);

          // Perform initial sync
          await syncToHealthApp();
        } else {
          throw HydrationError.syncFailed('Failed to enable health sync');
        }
      } else {
        await _healthService.setHealthSyncEnabled(enabled: false);
        _healthSyncEnabled = false;
        await _storageService.saveBool('healthSyncEnabled', value: false);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set health sync: $e');
      rethrow;
    }
  }

  /// Sync hydration data to health app (Premium feature)
  Future<void> syncToHealthApp() async {
    if (!_healthSyncEnabled) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // Get unsynced entries
      final unsyncedEntries =
          _hydrationHistory.where((entry) => !entry.isSynced).toList();

      if (unsyncedEntries.isNotEmpty) {
        final success = await _healthService.syncToHealth(unsyncedEntries);

        if (success) {
          // Mark entries as synced
          for (var i = 0; i < _hydrationHistory.length; i++) {
            if (!_hydrationHistory[i].isSynced) {
              _hydrationHistory[i] = _hydrationHistory[i].copyWith(
                isSynced: true,
              );
            }
          }

          await _saveHistoricalData();
        }
      }
    } catch (e) {
      debugPrint('Failed to sync to health app: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Import hydration data from health app (Premium feature)
  Future<void> importFromHealthApp({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isSyncing = true;
      notifyListeners();

      final importedData = await _healthService.importFromHealth(
        startTime: startDate,
        endTime: endDate,
      );

      if (importedData.isNotEmpty) {
        // Add imported data to history (avoid duplicates)
        for (final entry in importedData) {
          final exists = _hydrationHistory.any(
            (existing) =>
                existing.timestamp.isAtSameMomentAs(entry.timestamp) &&
                existing.amount == entry.amount,
          );

          if (!exists) {
            _hydrationHistory.add(entry);
          }
        }

        // Sort and rebuild cache
        _hydrationHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _buildDailyCache();
        _updateCurrentDayData();
        _calculateStreaks();

        await _saveHistoricalData();
        await _saveBasicData();
      }
    } catch (e) {
      debugPrint('Failed to import from health app: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get health sync statistics (Premium feature)
  Future<Map<String, dynamic>> getHealthSyncStats() async {
    return _healthService.getHealthSyncStats();
  }

  /// Load health sync settings
  Future<void> loadHealthSyncSettings() async {
    try {
      await _healthService.initialize();
      final syncEnabled = await _storageService.getBool('healthSyncEnabled');
      _healthSyncEnabled = syncEnabled ?? false;

      if (_healthSyncEnabled) {
        // Perform auto sync if enabled
        unawaited(_healthService.performAutoSync());
      }
    } catch (e) {
      debugPrint('Failed to load health sync settings: $e');
    }
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
