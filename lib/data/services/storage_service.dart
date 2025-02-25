import 'dart:convert';
import 'package:shared_preferences.dart';
import 'package:watertracker/domain/models/water_settings.dart';

class StorageService {
  static const _settingsKey = 'water_settings';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveWaterSettings(WaterSettings settings) async {
    final json = jsonEncode(settings.toMap());
    await _prefs.setString(_settingsKey, json);
  }

  Future<WaterSettings?> loadWaterSettings() async {
    final json = _prefs.getString(_settingsKey);
    if (json == null) return null;
    
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return WaterSettings.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearStorage() async {
    await _prefs.clear();
  }
}