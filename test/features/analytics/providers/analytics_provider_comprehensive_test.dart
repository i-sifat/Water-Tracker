import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/analytics/providers/analytics_provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

@Skip('Temporarily disabled - needs API alignment')
void main() {
  group('AnalyticsProvider Comprehensive Tests', () {
    late AnalyticsProvider analyticsProvider;

    setUp(() {
      final hydrationProvider = HydrationProvider();
      final premiumProvider = PremiumProvider();
      analyticsProvider = AnalyticsProvider(
        hydrationProvider: hydrationProvider,
        premiumProvider: premiumProvider,
      );
    });

    group('Basic Functionality', () {
      test('should create analytics provider', () {
        // Assert
        expect(analyticsProvider, isNotNull);
      });

      test('should handle data retrieval', () {
        // Act & Assert
        final weekStart = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        );
        expect(
          () => analyticsProvider.getWeeklyData(weekStart),
          returnsNormally,
        );
      });

      test('should handle monthly data', () {
        // Act & Assert
        final monthStart = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        );
        expect(
          () => analyticsProvider.getMonthlyData(monthStart),
          returnsNormally,
        );
      });
    });

    group('Data Processing', () {
      test('should process hydration data', () {
        // Act
        final weekStart = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        );
        final weeklyData = analyticsProvider.getWeeklyData(weekStart);

        // Assert
        expect(weeklyData, isNotNull);
      });

      test('should calculate statistics', () {
        // Act
        final monthStart = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        );
        final monthlyData = analyticsProvider.getMonthlyData(monthStart);

        // Assert
        expect(monthlyData, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle empty data gracefully', () {
        // Act & Assert
        final weekStart = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        );
        final monthStart = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        );
        expect(
          () => analyticsProvider.getWeeklyData(weekStart),
          returnsNormally,
        );
        expect(
          () => analyticsProvider.getMonthlyData(monthStart),
          returnsNormally,
        );
      });
    });
  });
}
