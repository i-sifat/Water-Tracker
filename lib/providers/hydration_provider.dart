// lib/providers/hydration_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/goal_completion_screen.dart';

enum AvatarOption { male, female }

class HydrationProvider extends ChangeNotifier {
  int _currentIntake = 0;
  int _dailyGoal = 2000; // Default goal (can be customized)
  AvatarOption _selectedAvatar = AvatarOption.male;
  bool _goalReachedToday = false;
  DateTime? _lastUpdated;

  // Getters
  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  int get remainingIntake => _dailyGoal - _currentIntake;
  double get intakePercentage => _currentIntake / _dailyGoal;
  AvatarOption get selectedAvatar => _selectedAvatar;
  bool get goalReachedToday => _goalReachedToday;

  // Initialize provider
  HydrationProvider() {
    loadData();
  }

  // Load data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIntake = prefs.getInt('currentIntake') ?? 0;
    _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
    _selectedAvatar =
        prefs.getString('avatar') == 'female'
            ? AvatarOption.female
            : AvatarOption.male;
    _goalReachedToday = prefs.getBool('goalReachedToday') ?? false;
    int? lastUpdatedMillis = prefs.getInt('lastUpdated');
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
    }

    notifyListeners();
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
    _currentIntake += amount;
    checkGoalReached();
    _saveData();
    notifyListeners();
  }

  // Legacy method to maintain backward compatibility
  void addIntake(int amount) {
    addHydration(amount);
  }

  // Set daily goal
  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _saveData();
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
