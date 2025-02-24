import 'package:rxdart/rxdart.dart';
import 'package:watertracker/core/constants/app_constants.dart';
import 'package:watertracker/data/services/platform_service.dart';
import 'package:watertracker/domain/models/water_settings.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';

class WaterRepository implements IWaterRepository {
  WaterRepository() {
    PlatformService.setMethodCallHandler((call) async {
      if (call.method == AppConstants.methodWaterSettingsChanged) {
        final args = call.arguments as Map<String, dynamic>;
        _waterSettings.add(WaterSettings.fromMap(args));
      }
      return null;
    });
  }

  final _waterSettings = BehaviorSubject<WaterSettings>.seeded(WaterSettings.initial());

  @override
  Stream<WaterSettings> get waterSettings => _waterSettings.stream;

  @override
  Future<void> drinkWater(int milliliters) async {
    await PlatformService.invokeMethod(AppConstants.methodDrinkWater, milliliters);
  }

  @override
  Future<void> changeAlarmEnabled(bool enabled) async {
    await PlatformService.invokeMethod(
      AppConstants.methodChangeNotificationEnabled,
      enabled,
    );
  }

  @override
  Future<void> subscribeToDataStore() async {
    await PlatformService.invokeMethod(AppConstants.methodSubscribeToDataStore);
  }

  @override
  Future<void> setRecommendedMilliliters(int milliliters) async {
    await PlatformService.invokeMethod(
      AppConstants.methodSetRecommendedMilliliters,
      milliliters,
    );
  }

  @override
  Future<void> clearDataStore() async {
    await PlatformService.invokeMethod(AppConstants.methodClearDataStore);
  }

  @override
  void close() {
    _waterSettings.close();
  }
}