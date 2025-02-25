import 'package:rxdart/rxdart.dart';
import 'package:watertracker/core/constants/app_constants.dart';
import 'package:watertracker/core/utils/error_utils.dart';
import 'package:watertracker/data/services/platform_service.dart';
import 'package:watertracker/data/services/storage_service.dart';
import 'package:watertracker/domain/models/water_settings.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';

class WaterRepository implements IWaterRepository {
  final StorageService _storage;
  
  WaterRepository(this._storage) {
    _initializeSettings();
    PlatformService.setMethodCallHandler((call) async {
      try {
        if (call.method == AppConstants.methodWaterSettingsChanged) {
          final args = call.arguments as Map<String, dynamic>;
          final settings = WaterSettings.fromMap(args);
          await _storage.saveWaterSettings(settings);
          _waterSettings.add(settings);
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

  Future<void> _initializeSettings() async {
    try {
      final settings = await _storage.loadWaterSettings();
      if (settings != null) {
        _waterSettings.add(settings);
      }
    } catch (e) {
      _waterSettings.addError(
        WaterTrackerException('Failed to load water settings', e),
      );
    }
  }

  @override
  Stream<WaterSettings> get waterSettings => _waterSettings.stream;

  @override
  Future<void> drinkWater(int milliliters) async {
    try {
      _validateMilliliters(milliliters);
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
      _validateRecommendedMilliliters(milliliters);
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
      await _storage.clearStorage();
      await PlatformService.invokeMethod(AppConstants.methodClearDataStore);
    } catch (e) {
      throw WaterTrackerException('Failed to reset data', e);
    }
  }

  void _validateMilliliters(int milliliters) {
    if (milliliters <= 0) {
      throw WaterTrackerException('Water amount must be greater than 0');
    }
    if (milliliters > 2000) {
      throw WaterTrackerException('Water amount cannot exceed 2000ml at once');
    }
  }

  void _validateRecommendedMilliliters(int milliliters) {
    if (milliliters < 2000) {
      throw WaterTrackerException('Recommended water intake must be at least 2000ml');
    }
    if (milliliters > 5000) {
      throw WaterTrackerException('Recommended water intake cannot exceed 5000ml');
    }
  }

  @override
  void close() {
    _waterSettings.close();
  }
}