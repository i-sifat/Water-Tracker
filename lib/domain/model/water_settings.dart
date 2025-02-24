class WaterSettings {
  final int currentMilliliters;
  final int recommendedMilliliters;
  final bool alarmEnabled;

  const WaterSettings({
    required this.currentMilliliters,
    required this.recommendedMilliliters,
    required this.alarmEnabled,
  });

  factory WaterSettings.initial() {
    return const WaterSettings(
      currentMilliliters: 0,
      recommendedMilliliters: 2000,
      alarmEnabled: true,
    );
  }

  factory WaterSettings.fromMap(Map<String, dynamic> map) {
    return WaterSettings(
      currentMilliliters: map["currentMilliliters"] as int,
      recommendedMilliliters: map["recommendedMilliliters"] as int,
      alarmEnabled: map["alarmEnabled"] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterSettings &&
        other.currentMilliliters == currentMilliliters &&
        other.recommendedMilliliters == recommendedMilliliters &&
        other.alarmEnabled == alarmEnabled;
  }

  @override
  int get hashCode =>
      currentMilliliters.hashCode ^
      recommendedMilliliters.hashCode ^
      alarmEnabled.hashCode;
}
