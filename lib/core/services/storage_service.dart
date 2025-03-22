import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling local storage operations.
class StorageService {
  late SharedPreferences _prefs;

  /// Initialize the storage service.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a string value to storage.
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get a string value from storage.
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save an integer value to storage.
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get an integer value from storage.
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save a double value to storage.
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Get a double value from storage.
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Save a boolean value to storage.
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get a boolean value from storage.
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save a list of strings to storage.
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Get a list of strings from storage.
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Remove a value from storage.
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all values from storage.
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Check if a key exists in storage.
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Get all keys in storage.
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
