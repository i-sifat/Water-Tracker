import 'package:watertracker/domain/models/user_preferences.dart';

class UserState {
  const UserState({
    required this.preferences,
    this.isLoading = false,
    this.error,
  });
  
  factory UserState.initial() => UserState(
    preferences: UserPreferences.initial(),
  );
  
  final UserPreferences preferences;
  final bool isLoading;
  final String? error;
  
  bool get isMale => preferences.isMale;
  
  UserState copyWith({
    UserPreferences? preferences,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}