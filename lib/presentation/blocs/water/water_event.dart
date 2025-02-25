import 'package:watertracker/domain/models/water_settings.dart';

abstract class WaterEvent {
  const WaterEvent();
}

class WaterSettingsUpdated extends WaterEvent {
  const WaterSettingsUpdated(this.settings);
  final WaterSettings settings;
}

class DrinkWater extends WaterEvent {
  const DrinkWater(this.milliliters);
  final int milliliters;
}

class ChangeAlarmEnabled extends WaterEvent {
  const ChangeAlarmEnabled(this.enabled);
  final bool enabled;
}

class SetRecommendedMilliliters extends WaterEvent {
  const SetRecommendedMilliliters(this.milliliters);
  final int milliliters;
}

class ClearDataStore extends WaterEvent {
  const ClearDataStore();
}
