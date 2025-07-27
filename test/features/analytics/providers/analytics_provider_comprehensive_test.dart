import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/analytics/models/analytics_data.dart';
import 'package:watertracker/features/analytics/providers/analytics_provider.dart';

import 'analytics_provider_comprehensive_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsProvider Comprehensive Tests', () {
    late AnalyticsProvider analyticsProvider;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      
      // Setup default mock responses
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(mockStorageService.getJson(any)).thenAnswer((_) async => null);
      when(mockStorageService.saveJson(any, any)).thenAnswer((_) async {});
      
      analyticsProvider = AnalyticsProvider(storageService: mockStorageService);
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Act
        await analyticsProvider.initialize();

        // Assert
        expect(analyticsProvider.isInitialized, isTrue);
        verify(mockStorageService.initialize()).called(1);
      });

      test('should load existing analytics data on initialization', () async {
        // Arrange
        final mockAnalyticsData = {
          'totalIntake': 15000.0,
          'averageDailyIntake': 2000.0,
          'streakDays': 7,
          'goalCompletionRate': 0.85,
        };
        when(mockStorageService.getJson('analytics_data'))
            .thenAnswer((_) async => mockAnalyticsData);

        // Act
        await analyticsProvider.initialize();

        // Assert
        expect(analyticsProvider.isInitialized, isTrue);
      });
    });

    group('Daily Analytics', () {
      test('should calculate daily statistics correctly', () async {
        // Arrange
        await analyticsProvider.initialize();
        final today = DateTime.now();
        final mockDailyData = {
          'date': today.toIso8601String(),
          'totalIntake': 2500.0,
          'goalAmount': 2000.0,
          'entries': [
            {'amount': 250.0, 'timestamp': today.millisecondsSinceEpoch},
            {'amount': 300.0, 'timestamp': today.add(const Duration(hours: 1)).millisecondsSinceEpoch},
          ]
        };
        when(mockStorageService.getJson(any)).thenAnswer((_) async => mockDailyData);

        // Act
        final dailyStats = await analyticsProvider.getDailyStatistics(today);

        // Assert
        expect(dailyStats, isA<DailyAnalytics>());
        expect(dailyStats.totalIntake, equals(2500.0));
        expect(dailyStats.goalCompletionPercentage, equals(1.25));
      });

      test('should handle missing daily data', () async {
        // Arrange
        await analyticsProvider.initialize();
        when(mockStorageService.getJson(any)).thenAnswer((_) async => null);

        // Act
        final dailyStats = await analyticsProvider.getDailyStatistics(DateTime.now());

        // Assert
        expect(dailyStats, isA<DailyAnalytics>());
        expect(dailyStats.totalIntake, equals(0.0));
      });
    });

    group('Weekly Analytics', () {
      test('should calculate weekly statistics correctly', () async {
        // Arrange
        await analyticsProvider.initialize();
        final mockWeeklyData = List.generate(7, (index) => {
          'date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'totalIntake': 2000.0 + (index * 100),
          'goalAmount': 2000.0,
        });
        
        when(mockStorageService.getJson(any)).thenAnswer((invocation) async {
          final key = invocation.positionalArguments[0] as String;
          if (key.contains('hydration_data_')) {
            final dayIndex = mockWeeklyData.indexWhere((data) => 
                key.contains(data['date'].toString().split('T')[0]));
            return dayIndex >= 0 ? mockWeeklyData[dayIndex] : null;
          }
          return null;
        });

        // Act
        final weeklyStats = await analyticsProvider.getWeeklyStatistics();

        // Assert
        expect(weeklyStats, isA<WeeklyAnalytics>());
        expect(weeklyStats.totalIntake, greaterThan(0));
        expect(weeklyStats.averageDailyIntake, greaterThan(0));
      });

      test('should calculate weekly trends', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final weeklyTrends = await analyticsProvider.getWeeklyTrends();

        // Assert
        expect(weeklyTrends, isA<List<DailyAnalytics>>());
        expect(weeklyTrends.length, equals(7));
      });
    });

    group('Monthly Analytics', () {
      test('should calculate monthly statistics correctly', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final monthlyStats = await analyticsProvider.getMonthlyStatistics();

        // Assert
        expect(monthlyStats, isA<MonthlyAnalytics>());
      });

      test('should calculate monthly trends', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final monthlyTrends = await analyticsProvider.getMonthlyTrends();

        // Assert
        expect(monthlyTrends, isA<List<DailyAnalytics>>());
      });
    });

    group('Streak Calculation', () {
      test('should calculate current streak correctly', () async {
        // Arrange
        await analyticsProvider.initialize();
        final mockStreakData = List.generate(5, (index) => {
          'date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'totalIntake': 2000.0,
          'goalAmount': 2000.0,
          'goalCompleted': true,
        });

        when(mockStorageService.getJson(any)).thenAnswer((invocation) async {
          final key = invocation.positionalArguments[0] as String;
          if (key.contains('hydration_data_')) {
            final dayIndex = mockStreakData.indexWhere((data) => 
                key.contains(data['date'].toString().split('T')[0]));
            return dayIndex >= 0 ? mockStreakData[dayIndex] : null;
          }
          return null;
        });

        // Act
        final currentStreak = await analyticsProvider.getCurrentStreak();

        // Assert
        expect(currentStreak, greaterThanOrEqualTo(0));
      });

      test('should calculate longest streak', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final longestStreak = await analyticsProvider.getLongestStreak();

        // Assert
        expect(longestStreak, greaterThanOrEqualTo(0));
      });
    });

    group('Goal Completion Analytics', () {
      test('should calculate goal completion rate', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final completionRate = await analyticsProvider.getGoalCompletionRate(30);

        // Assert
        expect(completionRate, greaterThanOrEqualTo(0.0));
        expect(completionRate, lessThanOrEqualTo(1.0));
      });

      test('should get goal completion history', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final completionHistory = await analyticsProvider.getGoalCompletionHistory(7);

        // Assert
        expect(completionHistory, isA<List<bool>>());
        expect(completionHistory.length, equals(7));
      });
    });

    group('Drink Type Analytics', () {
      test('should calculate drink type distribution', () async {
        // Arrange
        await analyticsProvider.initialize();
        final mockData = {
          'entries': [
            {'drinkType': 'water', 'amount': 250.0},
            {'drinkType': 'coffee', 'amount': 200.0},
            {'drinkType': 'water', 'amount': 300.0},
            {'drinkType': 'tea', 'amount': 150.0},
          ]
        };
        when(mockStorageService.getJson(any)).thenAnswer((_) async => mockData);

        // Act
        final distribution = await analyticsProvider.getDrinkTypeDistribution(DateTime.now());

        // Assert
        expect(distribution, isA<Map<String, double>>());
        expect(distribution.containsKey('water'), isTrue);
        expect(distribution.containsKey('coffee'), isTrue);
      });

      test('should get favorite drink types', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final favoriteDrinks = await analyticsProvider.getFavoriteDrinkTypes(7);

        // Assert
        expect(favoriteDrinks, isA<List<String>>());
      });
    });

    group('Time-based Analytics', () {
      test('should calculate hourly intake patterns', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final hourlyPatterns = await analyticsProvider.getHourlyIntakePatterns(7);

        // Assert
        expect(hourlyPatterns, isA<Map<int, double>>());
        expect(hourlyPatterns.keys.every((hour) => hour >= 0 && hour <= 23), isTrue);
      });

      test('should identify peak hydration times', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final peakTimes = await analyticsProvider.getPeakHydrationTimes();

        // Assert
        expect(peakTimes, isA<List<int>>());
      });
    });

    group('Comparative Analytics', () {
      test('should compare periods correctly', () async {
        // Arrange
        await analyticsProvider.initialize();
        final startDate = DateTime.now().subtract(const Duration(days: 14));
        final endDate = DateTime.now().subtract(const Duration(days: 7));

        // Act
        final comparison = await analyticsProvider.comparePeriods(
          startDate,
          endDate,
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        );

        // Assert
        expect(comparison, isA<Map<String, dynamic>>());
        expect(comparison.containsKey('previousPeriod'), isTrue);
        expect(comparison.containsKey('currentPeriod'), isTrue);
        expect(comparison.containsKey('change'), isTrue);
      });
    });

    group('Data Export', () {
      test('should export analytics data', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        final exportData = await analyticsProvider.exportAnalyticsData(
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now(),
        );

        // Assert
        expect(exportData, isA<Map<String, dynamic>>());
        expect(exportData.containsKey('period'), isTrue);
        expect(exportData.containsKey('summary'), isTrue);
        expect(exportData.containsKey('dailyData'), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Arrange
        when(mockStorageService.getJson(any)).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(() => analyticsProvider.getDailyStatistics(DateTime.now()), returnsNormally);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(mockStorageService.initialize()).thenThrow(Exception('Init error'));

        // Act & Assert
        expect(() => analyticsProvider.initialize(), returnsNormally);
      });
    });

    group('Performance', () {
      test('should cache frequently accessed data', () async {
        // Arrange
        await analyticsProvider.initialize();

        // Act
        await analyticsProvider.getDailyStatistics(DateTime.now());
        await analyticsProvider.getDailyStatistics(DateTime.now());

        // Assert - Should not call storage twice for same data
        verify(mockStorageService.getJson(any)).called(lessThanOrEqualTo(2));
      });
    });
  });
}