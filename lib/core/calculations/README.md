# Water Calculation System

This directory contains the refactored water calculation system that replaces the complex `WaterIntakeCalculator` with a modular, testable approach.

## Overview

The new calculation system is divided into three main components:

1. **WaterGoalCalculator** - Simplified basic calculations
2. **AdjustmentFactors** - Modular adjustment factor system
3. **AdvancedWaterCalculator** - Advanced calculations using modular factors

## Migration Guide

### From Old System

The old `WaterIntakeCalculator` had a complex 500+ line `calculateAdvancedIntake` method that was difficult to test and maintain. The new system breaks this down into:

#### Old Way (Complex)
```dart
// Old complex method with many parameters
int result = WaterIntakeCalculator.calculateAdvancedIntake(
  profile,
  bodyFatPercentage: 15.0,
  muscleMass: 35.0,
  sleepHours: 7,
  stressLevel: 6,
  environmentalTemperature: 30.0,
  humidity: 70.0,
  altitude: 1000,
  isPreWorkout: false,
  isPostWorkout: true,
  caffeineIntake: 200,
  alcoholIntake: 1,
  medications: ['diuretic'],
  climateZone: 'temperate',
  sweatRate: 500,
);
```

#### New Way (Modular)
```dart
// New modular approach with clear separation
final environmentalFactors = [
  TemperatureFactor(30.0),
  HumidityFactor(70.0),
  AltitudeFactor(1000),
];

final lifestyleFactors = [
  SleepFactor(7),
  StressFactor(6),
  CaffeineFactor(200),
  AlcoholFactor(1),
];

final healthFactors = [
  MedicationFactor([MedicationType.diuretic]),
];

int result = AdvancedWaterCalculator.calculateAdvancedIntake(
  profile,
  environmentalFactors: environmentalFactors,
  lifestyleFactors: lifestyleFactors,
  healthFactors: healthFactors,
);
```

## Components

### 1. WaterGoalCalculator

Provides simplified, testable calculation methods:

- `calculateBasicGoal(profile)` - Basic weight-based calculation
- `calculateAgeAdjustedGoal(profile)` - Includes age adjustments
- `calculateComprehensiveGoal(profile)` - Full calculation with all basic factors
- `getEffectiveGoal(profile)` - Returns custom or calculated goal

### 2. AdjustmentFactors

Modular adjustment factors that can be combined:

- `ActivityAdjustment` - Activity level multipliers
- `AgeAdjustment` - Age-based adjustments
- `HealthAdjustment` - Pregnancy/health status
- `GoalAdjustment` - User goal-based adjustments
- `DietaryAdjustment` - Diet-based adjustments
- `EnvironmentalAdjustment` - Weather-based adjustments

### 3. AdvancedWaterCalculator

Advanced calculations using modular factors:

- `calculateAdvancedIntake()` - Main advanced calculation method
- `calculateActivityHydration()` - Activity-specific hydration needs
- `calculateOptimalReminderTimes()` - Personalized reminder scheduling

## Usage Examples

### Basic Calculation
```dart
final profile = UserProfile.create()
    .copyWith(weight: 70.0, age: 30, activityLevel: ActivityLevel.moderatelyActive);

final basicGoal = WaterGoalCalculator.calculateBasicGoal(profile);
final comprehensiveGoal = WaterGoalCalculator.calculateComprehensiveGoal(profile);
```

### Using Adjustment Factors
```dart
final factors = AdjustmentFactorCombiner.standardFactors;
final multiplier = AdjustmentFactorCombiner.calculateCombinedMultiplier(profile);
final breakdown = AdjustmentFactorCombiner.getAdjustmentBreakdown(profile);
```

### Advanced Calculations
```dart
final environmentalFactors = [
  TemperatureFactor(35.0), // Hot weather
  HumidityFactor(80.0),    // High humidity
];

final result = AdvancedWaterCalculator.calculateAdvancedIntake(
  profile,
  environmentalFactors: environmentalFactors,
);
```

### Activity Hydration
```dart
final activityHydration = AdvancedWaterCalculator.calculateActivityHydration(
  activityType: ActivityType.running,
  durationMinutes: 60,
  bodyWeight: 70.0,
  intensityLevel: 8,
);
```

## Benefits of New System

1. **Testability** - Each component can be tested independently
2. **Modularity** - Factors can be combined in different ways
3. **Maintainability** - Clear separation of concerns
4. **Extensibility** - Easy to add new adjustment factors
5. **Readability** - Clear, self-documenting code
6. **Performance** - More efficient calculations with boundary checking

## Testing

All components have comprehensive unit tests:

- `water_goal_calculator_test.dart` - Tests for basic calculations
- `adjustment_factors_test.dart` - Tests for all adjustment factors
- `advanced_water_calculator_test.dart` - Tests for advanced calculations
- `calculation_suite_test.dart` - Comprehensive test suite

Run all calculation tests:
```bash
flutter test test/core/calculations/
```

## Safety Features

The new system includes several safety features:

1. **Input Validation** - All inputs are validated before processing
2. **Boundary Checking** - Results are bounded between safe limits (1500-5000ml)
3. **Default Values** - Sensible defaults when data is missing
4. **Error Handling** - Graceful handling of invalid inputs

## Performance Considerations

The new system is more efficient than the old complex method:

- Reduced computational complexity
- Early validation and bounds checking
- Modular calculations only when needed
- Clear separation reduces unnecessary calculations

## Future Enhancements

The modular design makes it easy to add:

- New adjustment factors (e.g., medical conditions, supplements)
- Different calculation algorithms
- Machine learning-based personalization
- Real-time environmental data integration