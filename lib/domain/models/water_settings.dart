// lib/domain/models/water_settings.dart
class WaterSettings {
  const WaterSettings({
    required this.currentMilliliters,
    required this.recommendedMilliliters,
    required this.alarmEnabled,
  });

  factory WaterSettings.fromMap(Map<String, dynamic> map) {
    return WaterSettings(
      currentMilliliters: map['currentMilliliters'] as int,
      recommendedMilliliters: map['recommendedMilliliters'] as int,
      alarmEnabled: map['alarmEnabled'] as bool,
    );
  }

  factory WaterSettings.initial() => const WaterSettings(
        currentMilliliters: 0,
        recommendedMilliliters: 2000,
        alarmEnabled: true,
      );
  final int currentMilliliters;
  final int recommendedMilliliters;
  final bool alarmEnabled;

  WaterSettings copyWith({
    int? currentMilliliters,
    int? recommendedMilliliters,
    bool? alarmEnabled,
  }) {
    return WaterSettings(
      currentMilliliters: currentMilliliters ?? this.currentMilliliters,
      recommendedMilliliters:
          recommendedMilliliters ?? this.recommendedMilliliters,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentMilliliters': currentMilliliters,
      'recommendedMilliliters': recommendedMilliliters,
      'alarmEnabled': alarmEnabled,
    };
  }
}
