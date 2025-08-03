import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/calculations/advanced_water_calculator.dart';
import 'package:watertracker/core/models/user_profile.dart';

void main() {
  group('AdvancedWaterCalculator', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile.create(id: 'test').copyWith(
        weight: 70.0,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        pregnancyStatus: PregnancyStatus.notPregnant,
        goals: [Goal.generalHealth],
        vegetableIntake: 3,
        sugarDrinkIntake: 1,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        sleepTime: const TimeOfDay(hour: 22, minute: 0),
      );
    });

    group('calculateAdvancedIntake', () {
      test('calculates advanced intake with environmental factors', () {
        final environmentalFactors = [
          const TemperatureFactor(35.0), // Hot weather: 1.2x
          const HumidityFactor(80.0), // High humidity: 1.1x
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          environmentalFactors: environmentalFactors,
        );

        // Base comprehensive goal: 2940ml
        // Environmental: 2940 * 1.2 * 1.1 = 3880.8 ≈ 3881ml
        expect(result, equals(3881));
      });

      test('calculates advanced intake with lifestyle factors', () {
        final lifestyleFactors = [
          const SleepFactor(5), // Poor sleep: +10% of base
          const CaffeineFactor(200), // 200mg caffeine: +400ml
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          lifestyleFactors: lifestyleFactors,
        );

        // Base: 2940ml
        // Sleep: +294ml (10% of 2940)
        // Caffeine: +400ml
        // Total: 2940 + 294 + 400 = 3634ml
        expect(result, equals(3634));
      });

      test('calculates advanced intake with health factors', () {
        final healthFactors = [
          const MedicationFactor([MedicationType.diuretic]), // 1.2x
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          healthFactors: healthFactors,
        );

        // Base: 2940ml
        // Health: 2940 * 1.2 = 3528ml
        expect(result, equals(3528));
      });

      test('calculates advanced intake with all factor types', () {
        final environmentalFactors = [
          const TemperatureFactor(30.0), // Warm: 1.1x
        ];
        final lifestyleFactors = [
          const AlcoholFactor(2), // 2 drinks: +600ml
        ];
        final healthFactors = [
          const MedicationFactor([MedicationType.bloodPressure]), // 1.1x
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          environmentalFactors: environmentalFactors,
          lifestyleFactors: lifestyleFactors,
          healthFactors: healthFactors,
        );

        // Base: 2940ml
        // Environmental: 2940 * 1.1 = 3234ml
        // Lifestyle: 3234 + 600 = 3834ml
        // Health: 3834 * 1.1 = 4217.4 ≈ 4217ml
        expect(result, equals(4217));
      });

      test('applies safety bounds to extreme calculations', () {
        final extremeFactors = [
          const TemperatureFactor(50.0), // Extreme heat
          const HumidityFactor(95.0), // Extreme humidity
          const AltitudeFactor(5000), // High altitude
        ];
        final extremeLifestyle = [
          const CaffeineFactor(1000), // Extreme caffeine
          const AlcoholFactor(10), // Extreme alcohol
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          environmentalFactors: extremeFactors,
          lifestyleFactors: extremeLifestyle,
        );

        // Should not exceed maximum daily intake
        expect(result, lessThanOrEqualTo(5000)); // Maximum bound
      });
    });

    group('calculateActivityHydration', () {
      test('calculates hydration for running activity', () {
        final result = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.running,
          durationMinutes: 60,
          bodyWeight: 70.0,
        );

        // Running: 8ml/hour/kg * 70kg * 1 hour = 560ml
        expect(result, equals(560));
      });

      test('calculates hydration with intensity adjustment', () {
        final result = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.cycling,
          durationMinutes: 90,
          bodyWeight: 70.0,
          intensityLevel: 8,
        );

        // Cycling: 6ml/hour/kg * 70kg = 420ml/hour
        // Intensity 8: 0.7 + (8 * 0.05) = 1.1x
        // Duration 90min = 1.5 hours
        // Total: 420 * 1.1 * 1.5 = 693ml
        expect(result, equals(693));
      });

      test('calculates hydration with environmental conditions', () {
        const conditions = EnvironmentalConditions(
          temperature: 35.0,
          humidity: 80.0,
          altitude: 3000,
        );

        final result = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.hiking,
          durationMinutes: 120,
          bodyWeight: 70.0,
          conditions: conditions,
        );

        // Hiking: 7ml/hour/kg * 70kg = 490ml/hour
        // Temperature 35°C: 1 + ((35-25) * 0.02) = 1.2x
        // Humidity 80%: 1 + ((80-60) * 0.005) = 1.1x
        // Altitude 3000m: 1.15x
        // Duration 2 hours
        // Total: 490 * 1.2 * 1.1 * 1.15 * 2 = 1488.06 ≈ 1488ml
        expect(result, equals(1488));
      });

      test('returns 0 for invalid inputs', () {
        final result1 = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.running,
          durationMinutes: 0,
          bodyWeight: 70.0,
        );

        final result2 = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.running,
          durationMinutes: 60,
          bodyWeight: 0.0,
        );

        expect(result1, equals(0));
        expect(result2, equals(0));
      });

      test('applies safety bounds to activity hydration', () {
        final result = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.soccer,
          durationMinutes: 30,
          bodyWeight: 200.0, // Very heavy
          intensityLevel: 10,
        );

        // Should not exceed 2000ml safety bound
        expect(result, lessThanOrEqualTo(2000));
      });
    });

    group('calculateOptimalReminderTimes', () {
      test('calculates basic reminder schedule', () {
        final reminders = AdvancedWaterCalculator.calculateOptimalReminderTimes(
          testProfile,
        );

        expect(reminders, isNotEmpty);

        // Should have reminders between wake and sleep times
        for (final reminder in reminders) {
          expect(reminder.hour, greaterThanOrEqualTo(7)); // After wake time
          expect(reminder.hour, lessThan(22)); // Before sleep time
        }
      });

      test('calculates reminders with custom preferences', () {
        final preferences = ReminderPreferences(
          defaultWakeTime: const TimeOfDay(hour: 6, minute: 0),
          defaultSleepTime: const TimeOfDay(hour: 23, minute: 0),
          busyHours: [12, 13], // Lunch break
        );

        final reminders = AdvancedWaterCalculator.calculateOptimalReminderTimes(
          testProfile,
          preferences: preferences,
        );

        expect(reminders, isNotEmpty);

        // Should avoid busy hours
        for (final reminder in reminders) {
          expect(reminder.hour, isNot(anyOf(12, 13)));
        }
      });

      test('handles profiles without wake/sleep times', () {
        final profileWithoutTimes = testProfile.copyWith(
          wakeUpTime: null,
          sleepTime: null,
        );

        final reminders = AdvancedWaterCalculator.calculateOptimalReminderTimes(
          profileWithoutTimes,
        );

        expect(reminders, isNotEmpty);
        // Should use default times (7:00 - 22:00)
      });
    });

    group('Environmental Factors', () {
      group('TemperatureFactor', () {
        test('returns correct multipliers for different temperatures', () {
          const coldFactor = TemperatureFactor(5.0);
          const normalFactor = TemperatureFactor(20.0);
          const warmFactor = TemperatureFactor(28.0);
          const hotFactor = TemperatureFactor(35.0);

          expect(coldFactor.getMultiplier(), equals(0.95));
          expect(normalFactor.getMultiplier(), equals(1.0));
          expect(warmFactor.getMultiplier(), equals(1.1));
          expect(hotFactor.getMultiplier(), equals(1.2));
        });

        test('provides correct description', () {
          const factor = TemperatureFactor(25.5);
          expect(factor.getDescription(), equals('Temperature: 25.5°C'));
        });
      });

      group('HumidityFactor', () {
        test('returns correct multipliers for different humidity levels', () {
          const lowFactor = HumidityFactor(50.0);
          const highFactor = HumidityFactor(80.0);

          expect(lowFactor.getMultiplier(), equals(1.0));
          expect(highFactor.getMultiplier(), equals(1.1));
        });

        test('provides correct description', () {
          const factor = HumidityFactor(75.5);
          expect(factor.getDescription(), equals('Humidity: 75.5%'));
        });
      });

      group('AltitudeFactor', () {
        test('returns correct multipliers for different altitudes', () {
          const lowFactor = AltitudeFactor(1000);
          const highFactor = AltitudeFactor(3000);

          expect(lowFactor.getMultiplier(), equals(1.0));
          expect(highFactor.getMultiplier(), equals(1.15));
        });

        test('provides correct description', () {
          const factor = AltitudeFactor(2500);
          expect(factor.getDescription(), equals('Altitude: 2500m'));
        });
      });
    });

    group('Lifestyle Factors', () {
      group('SleepFactor', () {
        test('returns correct adjustments for different sleep amounts', () {
          const poorSleep = SleepFactor(5);
          const normalSleep = SleepFactor(8);
          const excessiveSleep = SleepFactor(10);

          const baseIntake = 2000;

          expect(poorSleep.getAdjustment(baseIntake), equals(200)); // +10%
          expect(normalSleep.getAdjustment(baseIntake), equals(0));
          expect(excessiveSleep.getAdjustment(baseIntake), equals(-100)); // -5%
        });

        test('provides correct description', () {
          const factor = SleepFactor(7);
          expect(factor.getDescription(), equals('Sleep: 7h per night'));
        });
      });

      group('StressFactor', () {
        test('returns correct adjustments for different stress levels', () {
          const lowStress = StressFactor(5);
          const highStress = StressFactor(9);

          const baseIntake = 2000;

          expect(lowStress.getAdjustment(baseIntake), equals(0));
          expect(highStress.getAdjustment(baseIntake), equals(200)); // +10%
        });

        test('provides correct description', () {
          const factor = StressFactor(8);
          expect(factor.getDescription(), equals('Stress level: 8/10'));
        });
      });

      group('CaffeineFactor', () {
        test('returns correct adjustments for caffeine intake', () {
          const lowCaffeine = CaffeineFactor(100);
          const highCaffeine = CaffeineFactor(300);

          expect(
            lowCaffeine.getAdjustment(2000),
            equals(200),
          ); // 200ml per 100mg
          expect(
            highCaffeine.getAdjustment(2000),
            equals(600),
          ); // 600ml for 300mg
        });

        test('provides correct description', () {
          const factor = CaffeineFactor(250);
          expect(factor.getDescription(), equals('Caffeine: 250mg per day'));
        });
      });

      group('AlcoholFactor', () {
        test('returns correct adjustments for alcohol intake', () {
          const moderate = AlcoholFactor(2);
          const heavy = AlcoholFactor(5);

          expect(moderate.getAdjustment(2000), equals(600)); // 300ml per drink
          expect(
            heavy.getAdjustment(2000),
            equals(1500),
          ); // 1500ml for 5 drinks
        });

        test('provides correct description', () {
          const factor = AlcoholFactor(3);
          expect(factor.getDescription(), equals('Alcohol: 3 drinks per day'));
        });
      });
    });

    group('Health Factors', () {
      group('MedicationFactor', () {
        test('returns correct multipliers for different medications', () {
          const noMeds = MedicationFactor([]);
          const diuretic = MedicationFactor([MedicationType.diuretic]);
          const multiple = MedicationFactor([
            MedicationType.diuretic,
            MedicationType.bloodPressure,
          ]);

          expect(noMeds.getMultiplier(), equals(1.0));
          expect(diuretic.getMultiplier(), equals(1.2));
          expect(multiple.getMultiplier(), equals(1.32)); // 1.2 * 1.1
        });

        test('provides correct description', () {
          const noMeds = MedicationFactor([]);
          const withMeds = MedicationFactor([MedicationType.diuretic]);

          expect(noMeds.getDescription(), equals('No medications'));
          expect(withMeds.getDescription(), contains('diuretic'));
        });
      });
    });

    group('ReminderPreferences', () {
      test('creates default preferences correctly', () {
        final prefs = ReminderPreferences.defaultPreferences();

        expect(prefs.defaultWakeTime.hour, equals(7));
        expect(prefs.defaultSleepTime.hour, equals(22));
        expect(prefs.busyHours, isEmpty);
      });

      test('handles custom preferences', () {
        const prefs = ReminderPreferences(
          defaultWakeTime: TimeOfDay(hour: 6, minute: 30),
          defaultSleepTime: TimeOfDay(hour: 23, minute: 30),
          busyHours: [12, 13, 18],
        );

        expect(prefs.defaultWakeTime.hour, equals(6));
        expect(prefs.defaultWakeTime.minute, equals(30));
        expect(prefs.busyHours, hasLength(3));
      });
    });

    group('Edge Cases', () {
      test('handles extreme environmental conditions', () {
        final extremeFactors = [
          const TemperatureFactor(-20.0), // Extreme cold
          const HumidityFactor(0.0), // No humidity
          const AltitudeFactor(0), // Sea level
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          environmentalFactors: extremeFactors,
        );

        // Should still return a reasonable value
        expect(result, greaterThan(1500));
        expect(result, lessThan(5000));
      });

      test('handles empty factor lists', () {
        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
          environmentalFactors: [],
          lifestyleFactors: [],
          healthFactors: [],
        );

        // Should return basic comprehensive goal
        expect(result, equals(2940));
      });

      test('handles null factor lists', () {
        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          testProfile,
        );

        // Should return basic comprehensive goal
        expect(result, equals(2940));
      });
    });
  });
}
