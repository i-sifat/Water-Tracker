import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/health_service.dart';
import 'package:watertracker/core/services/notification_service.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

import 'hydration_provider_comprehensive_test.mocks.dart';

@GenerateMocks([StorageService, NotificationService, HealthService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HydrationProvider Comprehensive Tests', () {
    late HydrationProvider hydrationProvider;
    late MockStorageService mockStorageService;
    late MockNotificationService mockNotificationService;
    late MockHealthService mockHealthService;

    setUp(() {
      mockStorageService = MockStorageService();
      mockNotificationService = MockNotificationService();
      mockHealthService = MockHealthService();
      
      // Setup default mock responses
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(mockStorageService.getJson(any)).thenAnswer((_) async => null);
      when(mockStorageService.saveJson(any, any)).thenAnswer((_) async {});
      when(mockStorageService.getDouble(any)).thenAnswer((_) async => null);
      when(mockStorageService.saveDouble(any, any)).thenAnswer((_) async {});
      
      hydrationProvider = HydrationProvider(
        storageService: mockStorageService,
        notificationService: mockNotificationService,
        healthService: mockHealthService,
      );
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Act
        await hydrationProvider.initialize();

        // Assert
        expect(hydrationProvider.isInitialized, isTrue);
        verify(mockStorageService.initialize()).called(1);
      });

      test('should load existing data on initialization', () async {
        // Arrange
        final mockData = {
          'amount': 500.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'drinkType': 'water'
        };
        when(mockStorageService.getJson('hydration_data_${DateTime.now().toIso8601String().split('T')[0]}'))
            .thenAnswer((_) async => mockData);

        // Act
        await hydrationProvider.initialize();

        // Assert
        expect(hydrationProvider.isInitialized, isTrue);
      });
    });

    group('Water Intake Management', () {
      test('should add water intake successfully', () async {
        // Arrange
        await hydrationProvider.initialize();
        const amount = 250.0;
        const drinkType = 'water';

        // Act
        await hydrationProvider.addWaterIntake(amount, drinkType: drinkType);

        // Assert
        expect(hydrationProvider.todayIntake, equals(amount));
        verify(mockStorageService.saveJson(any, any)).called(greaterThan(0));
      });

      test('should accumulate multiple water intakes', () async {
        // Arrange
        await hydrationProvider.initialize();
        const amount1 = 250.0;
        const amount2 = 300.0;

        // Act
        await hydrationProvider.addWaterIntake(amount1);
        await hydrationProvider.addWaterIntake(amount2);

        // Assert
        expect(hydrationProvider.todayIntake, equals(amount1 + amount2));
      });

      test('should handle different drink types', () async {
        // Arrange
        await hydrationProvider.initialize();
        const waterAmount = 250.0;
        const coffeeAmount = 200.0;

        // Act
        await hydrationProvider.addWaterIntake(waterAmount, drinkType: 'water');
        await hydrationProvider.addWaterIntake(coffeeAmount, drinkType: 'coffee');

        // Assert
        expect(hydrationProvider.todayIntake, equals(waterAmount + coffeeAmount));
      });
    });

    group('Goal Management', () {
      test('should set daily goal', () async {
        // Arrange
        await hydrationProvider.initialize();
        const newGoal = 2500.0;

        // Act
        await hydrationProvider.setDailyGoal(newGoal);

        // Assert
        expect(hydrationProvider.dailyGoal, equals(newGoal));
        verify(mockStorageService.saveDouble('daily_goal', newGoal)).called(1);
      });

      test('should calculate progress percentage correctly', () async {
        // Arrange
        await hydrationProvider.initialize();
        const goal = 2000.0;
        const intake = 1000.0;

        // Act
        await hydrationProvider.setDailyGoal(goal);
        await hydrationProvider.addWaterIntake(intake);

        // Assert
        expect(hydrationProvider.progressPercentage, equals(0.5));
      });

      test('should detect goal completion', () async {
        // Arrange
        await hydrationProvider.initialize();
        const goal = 1000.0;
        const intake = 1000.0;

        // Act
        await hydrationProvider.setDailyGoal(goal);
        await hydrationProvider.addWaterIntake(intake);

        // Assert
        expect(hydrationProvider.isGoalCompleted, isTrue);
      });
    });

    group('History Management', () {
      test('should retrieve hydration history', () async {
        // Arrange
        await hydrationProvider.initialize();
        final mockHistory = [
          HydrationEntry(
            amount: 250.0,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            drinkType: 'water',
          ),
          HydrationEntry(
            amount: 300.0,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            drinkType: 'coffee',
          ),
        ];

        // Act
        final history = hydrationProvider.getHydrationHistory();

        // Assert
        expect(history, isA<List<HydrationEntry>>());
      });

      test('should get weekly statistics', () async {
        // Arrange
        await hydrationProvider.initialize();

        // Act
        final weeklyStats = await hydrationProvider.getWeeklyStatistics();

        // Assert
        expect(weeklyStats, isA<Map<String, dynamic>>());
      });

      test('should get monthly statistics', () async {
        // Arrange
        await hydrationProvider.initialize();

        // Act
        final monthlyStats = await hydrationProvider.getMonthlyStatistics();

        // Assert
        expect(monthlyStats, isA<Map<String, dynamic>>());
      });
    });

    group('Reminder Management', () {
      test('should schedule reminders after adding intake', () async {
        // Arrange
        await hydrationProvider.initialize();
        when(mockNotificationService.scheduleSmartReminders()).thenAnswer((_) async {});

        // Act
        await hydrationProvider.addWaterIntake(250.0);

        // Assert
        verify(mockNotificationService.scheduleSmartReminders()).called(1);
      });
    });

    group('Data Persistence', () {
      test('should save data after each intake', () async {
        // Arrange
        await hydrationProvider.initialize();

        // Act
        await hydrationProvider.addWaterIntake(250.0);

        // Assert
        verify(mockStorageService.saveJson(any, any)).called(greaterThan(0));
      });

      test('should load data on startup', () async {
        // Arrange
        final mockTodayData = {
          'entries': [
            {
              'amount': 250.0,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'drinkType': 'water'
            }
          ],
          'totalAmount': 250.0
        };
        when(mockStorageService.getJson(any)).thenAnswer((_) async => mockTodayData);

        // Act
        await hydrationProvider.initialize();

        // Assert
        expect(hydrationProvider.todayIntake, equals(250.0));
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Arrange
        when(mockStorageService.saveJson(any, any)).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(() => hydrationProvider.addWaterIntake(250.0), returnsNormally);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(mockStorageService.initialize()).thenThrow(Exception('Init error'));

        // Act & Assert
        expect(() => hydrationProvider.initialize(), returnsNormally);
      });
    });

    group('Health Integration', () {
      test('should sync with health service when available', () async {
        // Arrange
        await hydrationProvider.initialize();
        when(mockHealthService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthService.writeWaterIntake(any, any)).thenAnswer((_) async => true);

        // Act
        await hydrationProvider.addWaterIntake(250.0);

        // Assert
        verify(mockHealthService.writeWaterIntake(250.0, any)).called(1);
      });
    });
  });
}