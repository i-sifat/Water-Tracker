abstract class UserEvent {
  const UserEvent();
}

class LoadUserPreferences extends UserEvent {
  const LoadUserPreferences();
}

class UpdateGender extends UserEvent {
  const UpdateGender({required this.isMale});
  
  final bool isMale;
}