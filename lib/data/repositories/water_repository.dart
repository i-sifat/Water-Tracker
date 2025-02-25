import 'package:rxdart/rxdart.dart';
import 'package:watertracker/core/constants/app_constants.dart';
import 'package:watertracker/core/utils/error_utils.dart';
import 'package:watertracker/data/services/platform_service.dart';
import 'package:watertracker/domain/models/water_settings.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';

class WaterRepository implements IWaterRepository {
  WaterRepository() {
    PlatformService.setMethodCallHandler((call) async {
      try {
        if (call.method == AppConstants.methodWaterSettingsChanged) {
          final args = call.arguments as Map<String, dynamic>;
          _waterSettings.add(WaterSettings.fromMap(args));
        }
      } catch (e) {
        _waterSettings.addError(
          WaterTrackerException('Failed to process water settings update', e),
        );
      }
      return null;
    });
  }

  final _waterSettings = BehaviorSubject<WaterSettings>.seeded(WaterSettings.initial());

  @override
  Stream<WaterSettings> get waterSettings => _waterSettings.stream;

  @override
  Future<void> drinkWater(int milliliters) async {
    try {
      if (milliliters <= 0) {
        throw WaterTrackerException('Water amount must be greater than 0');
      }
      await PlatformService.invokeMethod(AppConstants.methodDrinkWater, milliliters);
    } catch (e) {
      throw WaterTrackerException('Failed to record water intake', e);
    }
  }

  @override
  Future<void> changeAlarmEnabled(bool enabled) async {
    try {
      await PlatformService.invokeMethod(
        AppConstants.methodChangeNotificationEnabled,
        enabled,
      );
    } catch (e) {
      throw WaterTrackerException('Failed to update notification settings', e);
    }
  }

  @override
  Future<void> subscribeToDataStore() async {
    try {
      await PlatformService.invokeMethod(AppConstants.methodSubscribeToDataStore);
    } catch (e) {
      throw WaterTrackerException('Failed to initialize data store', e);
    }
  }

  @override
  Future<void> setRecommendedMilliliters(int milliliters) async {
    try {
      if (milliliters < 2000) {
        throw WaterTrackerException('Recommended water intake must be at least 2000ml');
      }
      await PlatformService.invokeMethod(
        AppConstants.methodSetRecommendedMilliliters,
        milliliters,
      );
    } catch (e) {
      throw WaterTrackerException('Failed to update recommended water intake', e);
    }
  }

  @override
  Future<void> clearDataStore() async {
    try {
      await PlatformService.invokeMethod(AppConstants.methodClearDataStore);
    } catch (e) {
      throw WaterTrackerException('Failed to reset data', e);
    }
  }

  @override
  void close() {
    _waterSettings.close();
  }
}