import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/analytics/models/analytics_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Provider for analytics data and export functionality
class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider({
    required HydrationProvider hydrationProvider,
    required PremiumProvider premiumProvider,
  }) : _hydrationProvider = hydrationProvider,
       _premiumProvider = premiumProvider;

  final HydrationProvider _hydrationProvider;
  final PremiumProvider _premiumProvider;

  // State
  bool _isLoading = false;
  bool _isExporting = false;
  AppError? _lastError;

  // Analytics data cache
  WeeklyAnalytics? _currentWeekAnalytics;
  MonthlyAnalytics? _currentMonthAnalytics;
  StreakData? _streakData;
  DetailedStatistics? _detailedStats;

  // Getters
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  AppError? get lastError => _lastError;
  WeeklyAnalytics? get currentWeekAnalytics => _currentWeekAnalytics;
  MonthlyAnalytics? get currentMonthAnalytics => _currentMonthAnalytics;
  StreakData? get streakData => _streakData;
  DetailedStatistics? get detailedStats => _detailedStats;

  /// Check if analytics features are available
  bool get isAnalyticsAvailable =>
      _premiumProvider.isFeatureUnlocked(PremiumFeature.advancedAnalytics);

  /// Load analytics data for current week
  Future<void> loadCurrentWeekAnalytics() async {
    if (!isAnalyticsAvailable) {
      _lastError = PremiumError.featureLocked('Advanced Analytics');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);

      _currentWeekAnalytics = await _calculateWeeklyAnalytics(weekStart);
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : AnalyticsError.calculationFailed(e.toString());
      debugPrint('Failed to load weekly analytics: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load analytics data for current month
  Future<void> loadCurrentMonthAnalytics() async {
    if (!isAnalyticsAvailable) {
      _lastError = PremiumError.featureLocked('Advanced Analytics');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      _currentMonthAnalytics = await _calculateMonthlyAnalytics(
        now.year,
        now.month,
      );
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : AnalyticsError.calculationFailed(e.toString());
      debugPrint('Failed to load monthly analytics: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load streak data
  Future<void> loadStreakData() async {
    if (!isAnalyticsAvailable) {
      _lastError = PremiumError.featureLocked('Advanced Analytics');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _streakData = await _calculateStreakData();
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : AnalyticsError.calculationFailed(e.toString());
      debugPrint('Failed to load streak data: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load detailed statistics
  Future<void> loadDetailedStatistics() async {
    if (!isAnalyticsAvailable) {
      _lastError = PremiumError.featureLocked('Advanced Analytics');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _detailedStats = await _calculateDetailedStatistics();
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : AnalyticsError.calculationFailed(e.toString());
      debugPrint('Failed to load detailed statistics: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all analytics data
  Future<void> loadAllAnalytics() async {
    await Future.wait([
      loadCurrentWeekAnalytics(),
      loadCurrentMonthAnalytics(),
      loadStreakData(),
      loadDetailedStatistics(),
    ]);
  }

  /// Calculate weekly analytics
  Future<WeeklyAnalytics> _calculateWeeklyAnalytics(DateTime weekStart) async {
    final dailyIntakes = <DateTime, int>{};
    final dailyGoals = <DateTime, int>{};
    var totalIntake = 0;
    var goalAchievedDays = 0;

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayEntries = _hydrationProvider.getEntriesForDate(date);
      final dayIntake = dayEntries.totalWaterIntake;
      final dayGoal = _hydrationProvider.dailyGoal;

      dailyIntakes[date] = dayIntake;
      dailyGoals[date] = dayGoal;
      totalIntake += dayIntake;

      if (dayIntake >= dayGoal) {
        goalAchievedDays++;
      }
    }

    final averageIntake = totalIntake / 7.0;
    final goalAchievementRate = goalAchievedDays / 7.0;
    final streak = _calculateWeekStreak(weekStart);

    return WeeklyAnalytics(
      weekStart: weekStart,
      dailyIntakes: dailyIntakes,
      dailyGoals: dailyGoals,
      averageIntake: averageIntake,
      goalAchievementRate: goalAchievementRate,
      totalIntake: totalIntake,
      streak: streak,
    );
  }

  /// Calculate monthly analytics
  Future<MonthlyAnalytics> _calculateMonthlyAnalytics(
    int year,
    int month,
  ) async {
    final monthEnd = DateTime(year, month + 1, 0);
    final daysInMonth = monthEnd.day;

    final dailyIntakes = <DateTime, int>{};
    final weeklyAverages = <int, double>{};
    var totalIntake = 0;
    var goalAchievedDays = 0;

    // Calculate daily intakes
    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final dayEntries = _hydrationProvider.getEntriesForDate(date);
      final dayIntake = dayEntries.totalWaterIntake;

      dailyIntakes[date] = dayIntake;
      totalIntake += dayIntake;

      if (dayIntake >= _hydrationProvider.dailyGoal) {
        goalAchievedDays++;
      }
    }

    // Calculate weekly averages
    var currentWeek = 1;
    var weekTotal = 0;
    var weekDays = 0;

    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      weekTotal += dailyIntakes[date] ?? 0;
      weekDays++;

      // Check if week ended or month ended
      if (date.weekday == 7 || i == daysInMonth) {
        weeklyAverages[currentWeek] = weekDays > 0 ? weekTotal / weekDays : 0;
        currentWeek++;
        weekTotal = 0;
        weekDays = 0;
      }
    }

    final averageIntake = daysInMonth > 0 ? totalIntake / daysInMonth : 0.0;
    final goalAchievementRate =
        daysInMonth > 0 ? goalAchievedDays / daysInMonth : 0.0;
    final bestStreak = _calculateBestStreakInMonth(year, month);
    final currentStreak = _hydrationProvider.currentStreak;

    return MonthlyAnalytics(
      month: month,
      year: year,
      dailyIntakes: dailyIntakes,
      weeklyAverages: weeklyAverages,
      goalAchievementRate: goalAchievementRate,
      totalIntake: totalIntake,
      averageIntake: averageIntake,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
    );
  }

  /// Calculate streak data
  Future<StreakData> _calculateStreakData() async {
    final currentStreak = _hydrationProvider.currentStreak;
    final longestStreak = _hydrationProvider.longestStreak;
    final lastGoalAchievedDate = _hydrationProvider.lastGoalAchievedDate;

    // Calculate streak history (simplified version)
    final streakHistory = <StreakPeriod>[];
    // This would require more complex logic to track historical streaks
    // For now, we'll just add the current streak if it exists
    if (currentStreak > 0 && lastGoalAchievedDate != null) {
      final startDate = lastGoalAchievedDate.subtract(
        Duration(days: currentStreak - 1),
      );
      streakHistory.add(
        StreakPeriod(
          startDate: startDate,
          endDate: lastGoalAchievedDate,
          length: currentStreak,
        ),
      );
    }

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakHistory: streakHistory,
      lastGoalAchievedDate: lastGoalAchievedDate,
    );
  }

  /// Calculate detailed statistics
  Future<DetailedStatistics> _calculateDetailedStatistics() async {
    final history = _hydrationProvider.hydrationHistory;

    if (history.isEmpty) {
      return const DetailedStatistics(
        totalDaysTracked: 0,
        totalWaterConsumed: 0,
        averageDailyIntake: 0,
        goalAchievementRate: 0,
        currentStreak: 0,
        longestStreak: 0,
        favoriteHour: 12,
        drinkTypeBreakdown: {},
        weeklyTrend: 0,
        monthlyTrend: 0,
      );
    }

    // Calculate basic stats
    final totalWaterConsumed = history.fold(
      0,
      (sum, entry) => sum + entry.waterContent,
    );
    final uniqueDays = history.map((e) => e.date).toSet().length;
    final averageDailyIntake =
        uniqueDays > 0 ? totalWaterConsumed / uniqueDays : 0.0;

    // Calculate goal achievement rate
    var goalAchievedDays = 0;
    final dailyTotals = <DateTime, int>{};

    for (final entry in history) {
      final date = entry.date;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + entry.waterContent;
    }

    for (final total in dailyTotals.values) {
      if (total >= _hydrationProvider.dailyGoal) {
        goalAchievedDays++;
      }
    }

    final goalAchievementRate =
        uniqueDays > 0 ? goalAchievedDays / uniqueDays : 0.0;

    // Calculate favorite hour
    final hourCounts = <int, int>{};
    for (final entry in history) {
      final hour = entry.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final favoriteHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Calculate drink type breakdown
    final drinkTypeBreakdown = <String, int>{};
    for (final entry in history) {
      final type = entry.type.displayName;
      drinkTypeBreakdown[type] =
          (drinkTypeBreakdown[type] ?? 0) + entry.waterContent;
    }

    // Calculate trends (simplified)
    final weeklyTrend = _calculateWeeklyTrend();
    final monthlyTrend = _calculateMonthlyTrend();

    return DetailedStatistics(
      totalDaysTracked: uniqueDays,
      totalWaterConsumed: totalWaterConsumed,
      averageDailyIntake: averageDailyIntake,
      goalAchievementRate: goalAchievementRate,
      currentStreak: _hydrationProvider.currentStreak,
      longestStreak: _hydrationProvider.longestStreak,
      favoriteHour: favoriteHour,
      drinkTypeBreakdown: drinkTypeBreakdown,
      weeklyTrend: weeklyTrend,
      monthlyTrend: monthlyTrend,
    );
  }

  /// Export data to CSV
  Future<String?> exportToCsv({DateTime? startDate, DateTime? endDate}) async {
    if (!_premiumProvider.isFeatureUnlocked(PremiumFeature.dataExport)) {
      _lastError = PremiumError.featureLocked('Data Export');
      notifyListeners();
      return null;
    }

    _isExporting = true;
    _lastError = null;
    notifyListeners();

    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final entries = _hydrationProvider.getEntriesForDateRange(start, end);
      final csvContent = _generateCsvContent(entries);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'water_tracker_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvContent);
      return file.path;
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : DataExportError.exportFailed(e.toString());
      debugPrint('Failed to export CSV: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Export data to PDF (placeholder - would need pdf package)
  Future<String?> exportToPdf({DateTime? startDate, DateTime? endDate}) async {
    if (!_premiumProvider.isFeatureUnlocked(PremiumFeature.dataExport)) {
      _lastError = PremiumError.featureLocked('Data Export');
      notifyListeners();
      return null;
    }

    _isExporting = true;
    _lastError = null;
    notifyListeners();

    try {
      // This would require implementing PDF generation
      // For now, we'll just return a placeholder
      await Future<void>.delayed(const Duration(seconds: 2));

      _lastError = DataExportError.exportFailed(
        'PDF export not yet implemented',
      );
      return null;
    } catch (e, stackTrace) {
      _lastError =
          e is AppError ? e : DataExportError.exportFailed(e.toString());
      debugPrint('Failed to export PDF: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Generate CSV content
  String _generateCsvContent(List<HydrationData> entries) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Time,Amount (ml),Drink Type,Water Content (ml),Notes');

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

  /// Helper methods
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  int _calculateWeekStreak(DateTime weekStart) {
    var streak = 0;
    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayEntries = _hydrationProvider.getEntriesForDate(date);
      if (dayEntries.totalWaterIntake >= _hydrationProvider.dailyGoal) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateBestStreakInMonth(int year, int month) {
    final monthEnd = DateTime(year, month + 1, 0);

    var bestStreak = 0;
    var currentStreak = 0;

    for (var i = 1; i <= monthEnd.day; i++) {
      final date = DateTime(year, month, i);
      final dayEntries = _hydrationProvider.getEntriesForDate(date);

      if (dayEntries.totalWaterIntake >= _hydrationProvider.dailyGoal) {
        currentStreak++;
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  double _calculateWeeklyTrend() {
    final now = DateTime.now();
    final thisWeekStart = _getWeekStart(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeekData = _hydrationProvider.getWeeklyData(thisWeekStart);
    final lastWeekData = _hydrationProvider.getWeeklyData(lastWeekStart);

    final thisWeekTotal = thisWeekData.values.fold(
      0,
      (sum, value) => sum + value,
    );
    final lastWeekTotal = lastWeekData.values.fold(
      0,
      (sum, value) => sum + value,
    );

    if (lastWeekTotal == 0) return 0;

    return ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
  }

  double _calculateMonthlyTrend() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final thisMonthData = _hydrationProvider.getMonthlyData(thisMonth);
    final lastMonthData = _hydrationProvider.getMonthlyData(lastMonth);

    final thisMonthTotal = thisMonthData.values.fold(
      0,
      (sum, value) => sum + value,
    );
    final lastMonthTotal = lastMonthData.values.fold(
      0,
      (sum, value) => sum + value,
    );

    if (lastMonthTotal == 0) return 0;

    return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
  }

  /// Get weekly data for a specific week
  Map<DateTime, int> getWeeklyData(DateTime weekStart) {
    final weeklyData = <DateTime, int>{};

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayEntries = _hydrationProvider.getEntriesForDate(date);
      weeklyData[date] = dayEntries.totalWaterIntake;
    }

    return weeklyData;
  }

  /// Get monthly data for a specific month
  Map<DateTime, int> getMonthlyData(DateTime monthStart) {
    final monthlyData = <DateTime, int>{};
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    for (var i = 1; i <= monthEnd.day; i++) {
      final date = DateTime(monthStart.year, monthStart.month, i);
      final dayEntries = _hydrationProvider.getEntriesForDate(date);
      monthlyData[date] = dayEntries.totalWaterIntake;
    }

    return monthlyData;
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
