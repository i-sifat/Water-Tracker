import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/models/user_profile.dart';

/// Provider to manage onboarding flow state and data persistence
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider() {
    _loadExistingData();
  }

  // Current onboarding step (0-based index)
  int _currentStep = 0;

  // Total number of onboarding steps
  static const int totalSteps = 10;

  // User profile being built during onboarding
  UserProfile _userProfile = UserProfile.create();

  // Track which steps are optional and can be skipped
  final Set<int> _optionalSteps = {
    2,
    6,
    7,
    8,
  }; // pregnancy, vegetable, sugary drinks, weather

  // Track completed steps
  final Set<int> _completedSteps = {};

  // Loading states
  bool _isLoading = false;
  bool _isSaving = false;

  // Error handling
  String? _error;

  // Getters
  int get currentStep => _currentStep;
  int get totalStepsCount => totalSteps;
  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get canGoNext => _isStepValid(_currentStep);
  bool get canSkipCurrent => _optionalSteps.contains(_currentStep);
  double get progress => (_currentStep + 1) / totalSteps;
  bool get isLastStep => _currentStep == totalSteps - 1;

  /// Check if current step has valid data
  bool _isStepValid(int step) {
    switch (step) {
      case 0: // Welcome - always valid
        return true;
      case 1: // Goals - at least one goal selected
        return _userProfile.goals.isNotEmpty;
      case 2: // Gender - always valid (can be skipped)
        return true;
      case 3: // Sugary drinks - always valid
        return true;
      case 4: // Age - must have age
        return _userProfile.age != null;
      case 5: // Weight - must have weight
        return _userProfile.weight != null;
      case 6: // Pregnancy - always valid (can be skipped)
        return true;
      case 7: // Exercise frequency - always valid
        return true;
      case 8: // Vegetable intake - always valid (can be skipped)
        return true;
      case 9: // Weather preference - always valid (can be skipped)
        return true;
      case 10: // Notifications - always valid
        return true;
      default:
        return false;
    }
  }

  /// Move to next step
  Future<void> nextStep() async {
    if (!canGoNext) return;

    _completedSteps.add(_currentStep);

    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      await _saveProgress();
      notifyListeners();
    } else {
      // Complete onboarding
      await completeOnboarding();
    }
  }

  /// Move to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Skip current step (only if optional)
  Future<void> skipStep() async {
    if (!canSkipCurrent) return;

    // Set default values for skipped steps
    _setDefaultForStep(_currentStep);
    await nextStep();
  }

  /// Jump to specific step
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Update user profile data
  void updateProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  /// Update specific profile fields
  void updateGoals(List<Goal> goals) {
    _userProfile = _userProfile.copyWith(goals: goals);
    notifyListeners();
  }

  void updateGender(Gender gender) {
    _userProfile = _userProfile.copyWith(gender: gender);
    notifyListeners();
  }

  void updateAge(int age) {
    _userProfile = _userProfile.copyWith(age: age);
    notifyListeners();
  }

  void updateWeight(double weight) {
    _userProfile = _userProfile.copyWith(weight: weight);
    notifyListeners();
  }

  void updateActivityLevel(ActivityLevel activityLevel) {
    _userProfile = _userProfile.copyWith(activityLevel: activityLevel);
    notifyListeners();
  }

  void updatePregnancyStatus(PregnancyStatus status) {
    _userProfile = _userProfile.copyWith(pregnancyStatus: status);
    notifyListeners();
  }

  void updateVegetableIntake(int intake) {
    _userProfile = _userProfile.copyWith(vegetableIntake: intake);
    notifyListeners();
  }

  void updateSugarDrinkIntake(int intake) {
    _userProfile = _userProfile.copyWith(sugarDrinkIntake: intake);
    notifyListeners();
  }

  void updateWeatherPreference(WeatherPreference preference) {
    _userProfile = _userProfile.copyWith(weatherPreference: preference);
    notifyListeners();
  }

  void updateNotificationsEnabled({required bool enabled}) {
    _userProfile = _userProfile.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  /// Set default values for skipped steps
  void _setDefaultForStep(int step) {
    switch (step) {
      case 2: // Gender
        _userProfile = _userProfile.copyWith(gender: Gender.notSpecified);
      case 6: // Pregnancy
        _userProfile = _userProfile.copyWith(
          pregnancyStatus: PregnancyStatus.preferNotToSay,
        );
      case 7: // Exercise
        _userProfile = _userProfile.copyWith(
          activityLevel: ActivityLevel.moderatelyActive,
        );
      case 8: // Vegetables
        _userProfile = _userProfile.copyWith(vegetableIntake: 3); // Average
      case 9: // Weather
        _userProfile = _userProfile.copyWith(
          weatherPreference: WeatherPreference.moderate,
        );
    }
  }

  /// Complete the onboarding process
  Future<void> completeOnboarding() async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate daily water goal
      final calculatedGoal = _userProfile.calculateWaterIntake();
      _userProfile = _userProfile.copyWith(dailyGoal: calculatedGoal);

      // Save user profile
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(_userProfile.toJson()));

      // Mark onboarding as completed
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('user_profile_id', _userProfile.id);

      // Clear temporary onboarding data
      await _clearOnboardingProgress();
    } catch (e) {
      _error = 'Failed to complete onboarding: $e';
      debugPrint(_error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Save current progress
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onboarding_current_step', _currentStep);
      await prefs.setString(
        'onboarding_user_data',
        _userProfile.toJson().toString(),
      );
    } catch (e) {
      debugPrint('Error saving onboarding progress: $e');
    }
  }

  /// Load existing onboarding data
  Future<void> _loadExistingData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if onboarding is already completed
      final isCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (isCompleted) {
        // Load existing user profile
        final profileData = prefs.getString('user_profile');
        if (profileData != null) {
          try {
            final profileJson = jsonDecode(profileData) as Map<String, dynamic>;
            _userProfile = UserProfile.fromJson(profileJson);
          } catch (e) {
            debugPrint('Error loading user profile: $e');
          }
        }
      } else {
        // Load in-progress onboarding data
        _currentStep = prefs.getInt('onboarding_current_step') ?? 0;

        // Try to load partial user data
        final userData = prefs.getString('onboarding_user_data');
        if (userData != null) {
          try {
            // Note: This is a simplified approach. In production, you'd want proper JSON parsing
            // For now, we'll load individual fields from SharedPreferences
            _loadIndividualFields(prefs);
          } catch (e) {
            debugPrint('Error parsing user data: $e');
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load onboarding data: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load individual fields from SharedPreferences (legacy support)
  void _loadIndividualFields(SharedPreferences prefs) {
    final goals = prefs.getStringList('selected_goals') ?? [];
    final goalEnums =
        goals.map((g) {
          switch (g) {
            case 'Drink More Water':
              return Goal.generalHealth;
            case 'Improve digestions':
              return Goal.generalHealth;
            case 'Lead a Healty Lifestyle':
              return Goal.generalHealth;
            case 'Lose weight':
              return Goal.weightLoss;
            case 'Just trying out the app, mate!':
              return Goal.generalHealth;
            default:
              return Goal.generalHealth;
          }
        }).toList();

    final genderString = prefs.getString('selected_gender');
    var gender = Gender.notSpecified;
    if (genderString == 'male') gender = Gender.male;
    if (genderString == 'female') gender = Gender.female;

    final age = prefs.getInt('user_age');
    final weight = prefs.getDouble('user_weight');

    _userProfile = _userProfile.copyWith(
      goals: goalEnums,
      gender: gender,
      age: age,
      weight: weight,
    );
  }

  /// Clear onboarding progress data
  Future<void> _clearOnboardingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_current_step');
      await prefs.remove('onboarding_user_data');

      // Clear legacy individual fields
      await prefs.remove('selected_goals');
      await prefs.remove('selected_gender');
      await prefs.remove('user_age');
      await prefs.remove('user_weight');
    } catch (e) {
      debugPrint('Error clearing onboarding progress: $e');
    }
  }

  /// Reset onboarding (for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    _currentStep = 0;
    _userProfile = UserProfile.create();
    _completedSteps.clear();
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);
    await _clearOnboardingProgress();

    notifyListeners();
  }

  /// Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Get step title for display
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Select Your Goals';
      case 2:
        return 'Select Your Gender';
      case 3:
        return 'Sugary Beverages';
      case 4:
        return "What's Your Age?";
      case 5:
        return "What's Your Weight?";
      case 6:
        return 'Pregnancy Status';
      case 7:
        return 'Exercise Frequency';
      case 8:
        return 'Vegetable Intake';
      case 9:
        return 'Weather Preference';
      case 10:
        return 'Notification Setup';
      default:
        return 'Step ${step + 1}';
    }
  }

  /// Get step description for display
  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Welcome to your hydration journey';
      case 1:
        return 'Choose what you want to achieve';
      case 2:
        return 'Help us personalize your experience';
      case 3:
        return 'Tell us about your drink preferences';
      case 4:
        return 'We need this to calculate your water needs';
      case 5:
        return 'This helps us determine your hydration goal';
      case 6:
        return 'This affects your hydration needs';
      case 7:
        return 'Your activity level affects water requirements';
      case 8:
        return 'Vegetables provide natural hydration';
      case 9:
        return 'Climate affects your hydration needs';
      case 10:
        return 'Stay on track with reminders';
      default:
        return '';
    }
  }

  /// Get validation error message for current step
  String? getValidationError(int step) {
    switch (step) {
      case 1: // Goals
        if (_userProfile.goals.isEmpty) {
          return 'Please select at least one goal to continue';
        }
        return null;
      case 4: // Age
        if (_userProfile.age == null) {
          return 'Please select your age to continue';
        }
        if (_userProfile.age! < 1 || _userProfile.age! > 120) {
          return 'Please enter a valid age between 1 and 120';
        }
        return null;
      case 5: // Weight
        if (_userProfile.weight == null) {
          return 'Please enter your weight to continue';
        }
        if (_userProfile.weight! < 20 || _userProfile.weight! > 300) {
          return 'Please enter a valid weight between 20 and 300 kg';
        }
        return null;
      default:
        return null;
    }
  }

  /// Navigate to next step with proper validation
  Future<bool> navigateNext() async {
    final validationError = getValidationError(_currentStep);
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _error = null;
    await nextStep();
    return true;
  }

  /// Navigate to previous step
  void navigatePrevious() {
    _error = null;
    previousStep();
  }

  /// Clear current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if user can modify onboarding data after completion
  Future<bool> canModifyOnboardingData() async {
    return isOnboardingCompleted();
  }

  /// Reopen onboarding for editing (preserving existing data)
  Future<void> reopenOnboardingForEditing() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing user profile
      final profileData = prefs.getString('user_profile');
      if (profileData != null) {
        final profileJson = jsonDecode(profileData) as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(profileJson);
      }

      // Set onboarding as not completed to allow editing
      await prefs.setBool('onboarding_completed', false);

      // Start from first step
      _currentStep = 0;
      _completedSteps.clear();
      _error = null;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to reopen onboarding: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Get completion percentage
  double get completionPercentage {
    final requiredSteps = totalSteps - _optionalSteps.length;
    final completedRequiredSteps =
        _completedSteps.where((step) => !_optionalSteps.contains(step)).length;
    return completedRequiredSteps / requiredSteps;
  }

  /// Get list of completed steps for progress visualization
  Set<int> get completedSteps => Set.from(_completedSteps);

  /// Check if all required steps are completed
  bool get areRequiredStepsCompleted {
    final requiredSteps = List.generate(
      totalSteps,
      (i) => i,
    ).where((step) => !_optionalSteps.contains(step));
    return requiredSteps.every(
      (step) => _completedSteps.contains(step) || step == _currentStep,
    );
  }
}
