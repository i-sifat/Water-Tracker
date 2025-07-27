import 'package:equatable/equatable.dart';

/// Model for weekly analytics data
class WeeklyAnalytics extends Equatable {
  const WeeklyAnalytics({
    required this.weekStart,
    required this.dailyIntakes,
    required this.dailyGoals,
    required this.averageIntake,
    required this.goalAchievementRate,
    required this.totalIntake,
    required this.streak,
  });

  final DateTime weekStart;
  final Map<DateTime, int> dailyIntakes;
  final Map<DateTime, int> dailyGoals;
  final double averageIntake;
  final double goalAchievementRate;
  final int totalIntake;
  final int streak;

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  @override
  List<Object?> get props => [
        weekStart,
        dailyIntakes,
        dailyGoals,
        averageIntake,
        goalAchievementRate,
        totalIntake,
        streak,
      ];
}

/// Model for monthly analytics data
class MonthlyAnalytics extends Equatable {
  const MonthlyAnalytics({
    required this.month,
    required this.year,
    required this.dailyIntakes,
    required this.weeklyAverages,
    required this.goalAchievementRate,
    required this.totalIntake,
    required this.averageIntake,
    required this.bestStreak,
    required this.currentStreak,
  });

  final int month;
  final int year;
  final Map<DateTime, int> dailyIntakes;
  final Map<int, double> weeklyAverages; // Week number -> average
  final double goalAchievementRate;
  final int totalIntake;
  final double averageIntake;
  final int bestStreak;
  final int currentStreak;

  DateTime get monthStart => DateTime(year, month, 1);
  DateTime get monthEnd => DateTime(year, month + 1, 0);

  @override
  List<Object?> get props => [
        month,
        year,
        dailyIntakes,
        weeklyAverages,
        goalAchievementRate,
        totalIntake,
        averageIntake,
        bestStreak,
        currentStreak,
      ];
}

/// Model for streak data
class StreakData extends Equatable {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakHistory,
    required this.lastGoalAchievedDate,
  });

  final int currentStreak;
  final int longestStreak;
  final List<StreakPeriod> streakHistory;
  final DateTime? lastGoalAchievedDate;

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        streakHistory,
        lastGoalAchievedDate,
      ];
}

/// Model for a streak period
class StreakPeriod extends Equatable {
  const StreakPeriod({
    required this.startDate,
    required this.endDate,
    required this.length,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int length;

  @override
  List<Object?> get props => [startDate, endDate, length];
}

/// Model for detailed statistics
class DetailedStatistics extends Equatable {
  const DetailedStatistics({
    required this.totalDaysTracked,
    required this.totalWaterConsumed,
    required this.averageDailyIntake,
    required this.goalAchievementRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.favoriteHour,
    required this.drinkTypeBreakdown,
    required this.weeklyTrend,
    required this.monthlyTrend,
  });

  final int totalDaysTracked;
  final int totalWaterConsumed;
  final double averageDailyIntake;
  final double goalAchievementRate;
  final int currentStreak;
  final int longestStreak;
  final int favoriteHour; // Hour of day (0-23)
  final Map<String, int> drinkTypeBreakdown;
  final double weeklyTrend; // Percentage change
  final double monthlyTrend; // Percentage change

  @override
  List<Object?> get props => [
        totalDaysTracked,
        totalWaterConsumed,
        averageDailyIntake,
        goalAchievementRate,
        currentStreak,
        longestStreak,
        favoriteHour,
        drinkTypeBreakdown,
        weeklyTrend,
        monthlyTrend,
      ];
}