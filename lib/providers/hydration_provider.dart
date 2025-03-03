// lib/providers/hydration_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AvatarOption { male, female }

class HydrationProvider extends ChangeNotifier {
  int _currentIntake = 0;
  int _dailyGoal = 2000; // Default goal (can be customized)
  AvatarOption _selectedAvatar = AvatarOption.male;

  // Getters
  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  int get remainingIntake => _dailyGoal - _currentIntake;
  double get intakePercentage => _currentIntake / _dailyGoal;
  AvatarOption get selectedAvatar => _selectedAvatar;

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
  }

  // Add water intake (renamed from addIntake to addHydration to match your AddHydrationScreen)
  void addHydration(int amount) {
    _currentIntake += amount;
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
    _saveData();
    notifyListeners();
  }
}
