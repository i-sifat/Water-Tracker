import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AvatarOption { male, female }

class HydrationProvider with ChangeNotifier {
  HydrationProvider() {
    _loadData();
  }
  static const _dailyGoal = 2000; // ml
  int _currentIntake = 0; // ml
  final List<List<int>> _weeklyHistory = List.generate(
    7,
    (_) => [],
  ); // 7 weeks, each week is a list of daily intakes
  AvatarOption _selectedAvatar = AvatarOption.female;

  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  int get remainingIntake => _dailyGoal - _currentIntake;
  double get intakePercentage => _currentIntake / _dailyGoal;
  AvatarOption get selectedAvatar => _selectedAvatar;
  List<List<int>> get weeklyHistory => _weeklyHistory;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIntake = prefs.getInt('currentIntake') ?? 0;

    // Load weekly history
    for (int i = 0; i < 7; i++) {
      final weekData = prefs.getStringList('week$i');
      if (weekData != null) {
        _weeklyHistory[i] = weekData.map(int.parse).toList();
      }
    }

    _selectedAvatar =
        AvatarOption.values[prefs.getInt('avatar') ??
            AvatarOption.female.index];

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentIntake', _currentIntake);

    // Save weekly history
    for (int i = 0; i < 7; i++) {
      prefs.setStringList(
        'week$i',
        _weeklyHistory[i].map((e) => e.toString()).toList(),
      );
    }
    prefs.setInt('avatar', _selectedAvatar.index);
  }

  void addHydration(int amount) {
    _currentIntake += amount;
    if (_currentIntake > _dailyGoal) {
      _currentIntake = _dailyGoal; // Cap at the daily goal
    }

    // Add to weekly history (current day)
    final now = DateTime.now();
    final dayOfWeek = now.weekday - 1; // Monday = 0, Sunday = 6
    _weeklyHistory[0].add(
      _currentIntake,
    ); // Always add to the first week (current week)

    _saveData();
    notifyListeners();
  }

  void changeAvatar(AvatarOption avatar) {
    _selectedAvatar = avatar;
    _saveData();
    notifyListeners();
  }

  List<int> getWeeklyData(int weekIndex) {
    // Ensure weekIndex is within bounds
    if (weekIndex < 0 || weekIndex >= _weeklyHistory.length) {
      return []; // Or throw an error, depending on your needs
    }
    return _weeklyHistory[weekIndex];
  }

  double getAverageIntake(int weekIndex) {
    final weekData = getWeeklyData(weekIndex);
    if (weekData.isEmpty) {
      return 0;
    }
    return weekData.reduce((a, b) => a + b) / weekData.length;
  }
}
