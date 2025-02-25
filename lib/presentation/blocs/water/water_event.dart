import 'package:watertracker/domain/models/water_settings.dart';

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
  final bool enabled;
  const ChangeAlarmEnabled(this.enabled);
}

class SetRecommendedMilliliters extends WaterEvent {
  final int milliliters;
  const SetRecommendedMilliliters(this.milliliters);
}

class ClearDataStore extends WaterEvent {
  const ClearDataStore();
}
