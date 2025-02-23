import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:watertracker/constant/constant.dart';
import 'package:watertracker/data/platform/platform_messenger.dart';
import 'package:watertracker/domain/model/water_settings.dart';

class WaterRepository {
  WaterRepository() {
    PlatformMessenger.setMethodCallHandler((call) async {
      if (call.method == Constant.methodWaterSettingsChanged) {
        final args = call.arguments as Map<String, dynamic>;
        _waterSettings.add(WaterSettings.fromMap(args));
      }
      return null;
    });
  }

  final _waterSettings =
      BehaviorSubject<WaterSettings>.seeded(WaterSettings.initial());

  Stream<WaterSettings> get waterSettings => _waterSettings.stream;

  Future<void> drinkWater(int milliliters) async {
    await PlatformMessenger.invokeMethod(
        Constant.methodDrinkWater, milliliters);
  }

  Future<void> changeAlarmEnabled(bool enabled) async {
    await PlatformMessenger.invokeMethod(
      Constant.methodChangeNotificationEnabled,
      enabled,
    );
  }

  Future<void> subscribeToDataStore() async {
    await PlatformMessenger.invokeMethod(Constant.methodSubscribeToDataStore);
  }

  Future<void> setRecommendedMilliliters(int milliliters) async {
    await PlatformMessenger.invokeMethod(
      Constant.methodSetRecommendedMilliliters,
      milliliters,
    );
  }

  Future<void> clearDataStore() async {
    await PlatformMessenger.invokeMethod(Constant.methodClearDataStore);
  }

  void dispose() {
    _waterSettings.close();
  }
}
