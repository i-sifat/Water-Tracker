import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/domain/models/user_preferences.dart';
import 'package:watertracker/domain/models/water_settings.dart';

class StorageService {
  const StorageService(this._prefs);
  static const _settingsKey = 'water_settings';
  static const _userPrefsKey = 'user_preferences';

  final SharedPreferences _prefs;

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

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    final json = jsonEncode(prefs.toMap());
    await _prefs.setString(_userPrefsKey, json);
  }

  Future<UserPreferences?> loadUserPreferences() async {
    final json = _prefs.getString(_userPrefsKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserPreferences.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearStorage() async {
    await _prefs.clear();
  }
}