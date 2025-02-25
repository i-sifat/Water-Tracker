import 'package:watertracker/domain/models/water_settings.dart';

abstract class IWaterRepository {
  Stream<WaterSettings> get waterSettings;

  Future<void> drinkWater(int milliliters);
  Future<void> changeAlarmEnabled(bool enabled);
  Future<void> subscribeToDataStore();
  Future<void> setRecommendedMilliliters(int milliliters);
  Future<void> clearDataStore();
  void close();
}
