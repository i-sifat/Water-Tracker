abstract class WaterEvent {
  const WaterEvent();
}

class WaterSettingsUpdated extends WaterEvent {
  final WaterSettings settings;
  const WaterSettingsUpdated(this.settings);
}

class DrinkWater extends WaterEvent {
  final int milliliters;
  const DrinkWater(this.milliliters);
}

class ChangeAlarmEnabled extends WaterEvent {
  final bool value;
  const ChangeAlarmEnabled(this.value);
}

class SetRecommendedMilliliters extends WaterEvent {
  final int milliliters;
  const SetRecommendedMilliliters(this.milliliters);
}

class ClearDataStore extends WaterEvent {
  const ClearDataStore();
}
