import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/utils/water_intake_calculator.dart';
import 'package:watertracker/features/hydration/screens/goal_completion_screen.dart';

enum AvatarOption { male, female }

class HydrationProvider extends ChangeNotifier {
  // Initialize provider
  HydrationProvider() {
    loadData();
  }
  int _currentIntake = 0;
  int _dailyGoal = 2000; // Default goal (will be updated by calculator)
  AvatarOption _selectedAvatar = AvatarOption.male;
  bool _goalReachedToday = false;
  DateTime? _lastUpdated;
  bool _isInitialized = false;

  // Getters
  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  int get remainingIntake => _dailyGoal - _currentIntake;
  double get intakePercentage => (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
  AvatarOption get selectedAvatar => _selectedAvatar;
  bool get goalReachedToday => _goalReachedToday;
  bool get isInitialized => _isInitialized;

  // Load data from SharedPreferences
  Future<void> loadData() async {
    if (_isInitialized) return; // Prevent multiple initializations

    final prefs = await SharedPreferences.getInstance();

    // Calculate daily goal first
    _dailyGoal = await calculateDailyGoal();

    // Then load other data
    _currentIntake = prefs.getInt('currentIntake') ?? 0;
    _selectedAvatar =
        prefs.getString('avatar') == 'female'
            ? AvatarOption.female
            : AvatarOption.male;
    _goalReachedToday = prefs.getBool('goalReachedToday') ?? false;

    final lastUpdatedMillis = prefs.getInt('lastUpdated');
    _lastUpdated =
        lastUpdatedMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis)
            : null;

    // Reset goal status if it's a new day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastUpdated == null || _lastUpdated!.isBefore(today)) {
      _goalReachedToday = false;
      _currentIntake = 0; // Reset intake for the new day
      await _saveData(); // Save the reset values
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Calculate daily goal using the calculator
  Future<int> calculateDailyGoal() async {
    final calculatedGoal = await WaterIntakeCalculator.calculateWaterIntake();
    debugPrint('Calculated water intake goal: $calculatedGoal ml');
    return calculatedGoal;
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIntake', _currentIntake);
    await prefs.setInt('dailyGoal', _dailyGoal);
    await prefs.setString(
      'avatar',
      _selectedAvatar == AvatarOption.female ? 'female' : 'male',
    );
    await prefs.setBool('goalReachedToday', _goalReachedToday);
    await prefs.setInt('lastUpdated', DateTime.now().millisecondsSinceEpoch);
  }

  // Add water intake
  void addHydration(int amount) {
    // Calculate what the new total would be
    final newTotal = _currentIntake + amount;

    // Only add the amount if it wouldn't exceed the daily goal
    if (newTotal <= _dailyGoal) {
      _currentIntake = newTotal;
      checkGoalReached();
      _saveData();
      notifyListeners();
    } else {
      // Optionally, you could add the remaining amount up to the goal
      final remainingToGoal = _dailyGoal - _currentIntake;
      if (remainingToGoal > 0) {
        _currentIntake = _dailyGoal;
        checkGoalReached();
        _saveData();
        notifyListeners();
      }
    }
  }

  // Legacy method to maintain backward compatibility
  void addIntake(int amount) {
    addHydration(amount);
  }

  // Set daily goal
  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _saveData();
    notifyListeners();
  }

  // Set avatar
  void setAvatar(AvatarOption avatar) {
    _selectedAvatar = avatar;
    _saveData();
    notifyListeners();
  }

  // Reset intake
  void resetIntake() {
    _currentIntake = 0;
    _goalReachedToday = false;
    _saveData();
    notifyListeners();
  }

  // Check if goal is reached and navigate to GoalCompletionScreen
  void checkGoalReached([BuildContext? context]) {
    if (_currentIntake >= _dailyGoal && !_goalReachedToday) {
      _goalReachedToday = true;
      _saveData();
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const GoalCompletionScreen()),
        );
      }
    }
  }
}
