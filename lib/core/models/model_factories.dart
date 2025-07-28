import 'dart:math';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/premium_models.dart';
import 'package:watertracker/core/models/user_profile.dart';

/// Factory class for creating test data and model instances
class ModelFactories {
  static final Random _random = Random();

  /// Create a sample HydrationData instance
  static HydrationData createHydrationData({
    String? id,
    int? amount,
    DateTime? timestamp,
    DrinkType? type,
    bool? isSynced,
    String? notes,
  }) {
    return HydrationData(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount ?? _randomAmount(),
      timestamp: timestamp ?? _randomTimestamp(),
      type: type ?? _randomDrinkType(),
      isSynced: isSynced ?? _random.nextBool(),
      notes: notes,
    );
  }

  /// Create multiple HydrationData instances for testing
  static List<HydrationData> createHydrationDataList({
    int count = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    return List.generate(count, (index) {
      final timestamp = _randomTimestampBetween(start, end);
      return createHydrationData(id: 'test_$index', timestamp: timestamp);
    });
  }

  /// Create daily hydration data for a specific date
  static List<HydrationData> createDailyHydrationData({
    required DateTime date,
    int entryCount = 8,
    int totalAmount = 2000,
  }) {
    final entries = <HydrationData>[];
    final amountPerEntry = totalAmount ~/ entryCount;

    for (var i = 0; i < entryCount; i++) {
      final hour = 8 + (i * 2); // Spread throughout the day
      final timestamp = DateTime(date.year, date.month, date.day, hour);

      entries.add(
        createHydrationData(
          id: '${date.millisecondsSinceEpoch}_$i',
          amount:
              amountPerEntry + _random.nextInt(100) - 50, // Add some variation
          timestamp: timestamp,
          type: i == 0 ? DrinkType.water : _randomDrinkType(),
        ),
      );
    }

    return entries;
  }

  /// Create a sample UserProfile instance
  static UserProfile createUserProfile({
    String? id,
    double? weight,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    WeatherPreference? weatherPreference,
    List<Goal>? goals,
    PregnancyStatus? pregnancyStatus,
    int? vegetableIntake,
    int? sugarDrinkIntake,
    int? dailyGoal,
    bool? notificationsEnabled,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id ?? 'test_user_${now.millisecondsSinceEpoch}',
      weight: weight ?? (60.0 + _random.nextDouble() * 40), // 60-100 kg
      age: age ?? (18 + _random.nextInt(50)), // 18-68 years
      gender: gender ?? _randomGender(),
      activityLevel: activityLevel ?? _randomActivityLevel(),
      weatherPreference: weatherPreference ?? _randomWeatherPreference(),
      goals: goals ?? _randomGoals(),
      pregnancyStatus: pregnancyStatus ?? PregnancyStatus.notPregnant,
      vegetableIntake: vegetableIntake ?? _random.nextInt(6), // 0-5 servings
      sugarDrinkIntake: sugarDrinkIntake ?? _random.nextInt(4), // 0-3 servings
      dailyGoal: dailyGoal ?? (1500 + _random.nextInt(1000)), // 1500-2500 ml
      notificationsEnabled: notificationsEnabled ?? true,
      createdAt: now.subtract(Duration(days: _random.nextInt(30))),
      updatedAt: now,
    );
  }

  /// Create a complete UserProfile for testing
  static UserProfile createCompleteUserProfile() {
    return createUserProfile(
      weight: 70,
      age: 30,
      gender: Gender.male,
      activityLevel: ActivityLevel.moderatelyActive,
      weatherPreference: WeatherPreference.moderate,
      goals: [Goal.generalHealth, Goal.athleticPerformance],
      dailyGoal: 2200,
    );
  }

  /// Create an incomplete UserProfile for testing
  static UserProfile createIncompleteUserProfile() {
    return UserProfile.create();
  }

  /// Create a sample PremiumStatus instance
  static PremiumStatus createPremiumStatus({
    bool? isPremium,
    String? deviceCode,
    String? unlockCode,
    DateTime? unlockedAt,
    DateTime? expiresAt,
    List<PremiumFeature>? unlockedFeatures,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? false,
      deviceCode: deviceCode ?? _generateTestDeviceCode(),
      unlockCode: unlockCode,
      unlockedAt: unlockedAt,
      expiresAt: expiresAt,
      unlockedFeatures: unlockedFeatures ?? [],
    );
  }

  /// Create a premium status for testing
  static PremiumStatus createPremiumStatusActive() {
    return createPremiumStatus(
      isPremium: true,
      unlockCode: 'TEST123456789ABC',
      unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
      unlockedFeatures: PremiumFeature.values,
    );
  }

  /// Create a free status for testing
  static PremiumStatus createPremiumStatusFree() {
    return createPremiumStatus(isPremium: false);
  }

  /// Create a sample DonationProof instance
  static DonationProof createDonationProof({
    String? id,
    String? deviceCode,
    String? imagePath,
    DateTime? submittedAt,
    double? amount,
    String? transactionId,
    String? notes,
    DonationProofStatus? status,
  }) {
    return DonationProof(
      id: id ?? 'proof_${DateTime.now().millisecondsSinceEpoch}',
      deviceCode: deviceCode ?? _generateTestDeviceCode(),
      imagePath: imagePath ?? '/test/path/donation_proof.jpg',
      submittedAt: submittedAt ?? DateTime.now(),
      amount: amount ?? (10.0 + _random.nextDouble() * 90), // $10-100
      transactionId: transactionId ?? 'TXN${_random.nextInt(999999999)}',
      notes: notes,
      status: status ?? DonationProofStatus.pending,
    );
  }

  /// Create an UnlockCodeValidation for testing
  static UnlockCodeValidation createUnlockCodeValidation({
    bool? isValid,
    String? deviceCode,
    String? unlockCode,
    List<PremiumFeature>? features,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    if (isValid == false) {
      return UnlockCodeValidation.failure(
        deviceCode: deviceCode ?? _generateTestDeviceCode(),
        errorMessage: errorMessage ?? 'Invalid unlock code',
      );
    }

    return UnlockCodeValidation.success(
      deviceCode: deviceCode ?? _generateTestDeviceCode(),
      unlockCode: unlockCode ?? 'TEST123456789ABC',
      features: features ?? PremiumFeature.values,
      expiresAt: expiresAt,
    );
  }

  // Private helper methods

  static int _randomAmount() {
    final amounts = [100, 150, 200, 250, 300, 350, 400, 500];
    return amounts[_random.nextInt(amounts.length)];
  }

  static DateTime _randomTimestamp() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(30);
    final hoursAgo = _random.nextInt(24);
    return now.subtract(Duration(days: daysAgo, hours: hoursAgo));
  }

  static DateTime _randomTimestampBetween(DateTime start, DateTime end) {
    final difference = end.difference(start).inMilliseconds;
    final randomMillis = _random.nextInt(difference);
    return start.add(Duration(milliseconds: randomMillis));
  }

  static DrinkType _randomDrinkType() {
    return DrinkType.values[_random.nextInt(DrinkType.values.length)];
  }

  static Gender _randomGender() {
    return Gender.values[_random.nextInt(Gender.values.length)];
  }

  static ActivityLevel _randomActivityLevel() {
    return ActivityLevel.values[_random.nextInt(ActivityLevel.values.length)];
  }

  static WeatherPreference _randomWeatherPreference() {
    return WeatherPreference.values[_random.nextInt(
      WeatherPreference.values.length,
    )];
  }

  static List<Goal> _randomGoals() {
    final goalCount = 1 + _random.nextInt(3); // 1-3 goals
    final allGoals = Goal.values.toList()..shuffle(_random);
    return allGoals.take(goalCount).toList();
  }

  static String _generateTestDeviceCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      16,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}

/// Builder pattern for creating complex test scenarios
class HydrationDataBuilder {
  String? _id;
  int? _amount;
  DateTime? _timestamp;
  DrinkType? _type;
  bool? _isSynced;
  String? _notes;

  HydrationDataBuilder withId(String id) {
    _id = id;
    return this;
  }

  HydrationDataBuilder withAmount(int amount) {
    _amount = amount;
    return this;
  }

  HydrationDataBuilder withTimestamp(DateTime timestamp) {
    _timestamp = timestamp;
    return this;
  }

  HydrationDataBuilder withType(DrinkType type) {
    _type = type;
    return this;
  }

  HydrationDataBuilder withSyncStatus({required bool isSynced}) {
    _isSynced = isSynced;
    return this;
  }

  HydrationDataBuilder withNotes(String notes) {
    _notes = notes;
    return this;
  }

  HydrationDataBuilder asWater() => withType(DrinkType.water);
  HydrationDataBuilder asCoffee() => withType(DrinkType.coffee);
  HydrationDataBuilder asTea() => withType(DrinkType.tea);

  HydrationDataBuilder synced() => withSyncStatus(isSynced: true);
  HydrationDataBuilder unsynced() => withSyncStatus(isSynced: false);

  HydrationDataBuilder today() => withTimestamp(DateTime.now());
  HydrationDataBuilder yesterday() =>
      withTimestamp(DateTime.now().subtract(const Duration(days: 1)));

  HydrationData build() {
    return ModelFactories.createHydrationData(
      id: _id,
      amount: _amount,
      timestamp: _timestamp,
      type: _type,
      isSynced: _isSynced,
      notes: _notes,
    );
  }
}

/// Builder pattern for UserProfile
class UserProfileBuilder {
  String? _id;
  double? _weight;
  int? _age;
  Gender? _gender;
  ActivityLevel? _activityLevel;
  WeatherPreference? _weatherPreference;
  List<Goal>? _goals;
  PregnancyStatus? _pregnancyStatus;
  int? _vegetableIntake;
  int? _sugarDrinkIntake;
  int? _dailyGoal;
  bool? _notificationsEnabled;

  UserProfileBuilder withId(String id) {
    _id = id;
    return this;
  }

  UserProfileBuilder withWeight(double weight) {
    _weight = weight;
    return this;
  }

  UserProfileBuilder withAge(int age) {
    _age = age;
    return this;
  }

  UserProfileBuilder withGender(Gender gender) {
    _gender = gender;
    return this;
  }

  UserProfileBuilder withActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    return this;
  }

  UserProfileBuilder withGoals(List<Goal> goals) {
    _goals = goals;
    return this;
  }

  UserProfileBuilder withDailyGoal(int goal) {
    _dailyGoal = goal;
    return this;
  }

  UserProfileBuilder male() => withGender(Gender.male);
  UserProfileBuilder female() => withGender(Gender.female);

  UserProfileBuilder sedentary() => withActivityLevel(ActivityLevel.sedentary);
  UserProfileBuilder active() =>
      withActivityLevel(ActivityLevel.moderatelyActive);
  UserProfileBuilder veryActive() =>
      withActivityLevel(ActivityLevel.veryActive);

  UserProfileBuilder complete() {
    return withWeight(70)
        .withAge(30)
        .withGender(Gender.male)
        .withActivityLevel(ActivityLevel.moderatelyActive)
        .withGoals([Goal.generalHealth])
        .withDailyGoal(2200);
  }

  UserProfile build() {
    return ModelFactories.createUserProfile(
      id: _id,
      weight: _weight,
      age: _age,
      gender: _gender,
      activityLevel: _activityLevel,
      weatherPreference: _weatherPreference,
      goals: _goals,
      pregnancyStatus: _pregnancyStatus,
      vegetableIntake: _vegetableIntake,
      sugarDrinkIntake: _sugarDrinkIntake,
      dailyGoal: _dailyGoal,
      notificationsEnabled: _notificationsEnabled,
    );
  }
}
