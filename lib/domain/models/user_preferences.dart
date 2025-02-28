class UserPreferences {
  const UserPreferences({
    required this.isMale,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isMale: map['isMale'] as bool,
    );
  }

  factory UserPreferences.initial() => const UserPreferences(
        isMale: true, // Default to male avatar
      );

  final bool isMale;

  UserPreferences copyWith({
    bool? isMale,
  }) {
    return UserPreferences(
      isMale: isMale ?? this.isMale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isMale': isMale,
    };
  }
}