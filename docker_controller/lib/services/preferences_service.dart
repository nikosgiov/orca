import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing local key-value preferences.
/// Wraps [SharedPreferences] to provide a clean, injectable interface.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  /// Returns the value for the given [key], or [defaultValue] if not found.
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Sets the [value] for the given [key].
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  /// Returns the value for the given [key], or [defaultValue] if not found.
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  /// Sets the [value] for the given [key].
  Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  /// Returns the value for the given [key], or [defaultValue] if not found.
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Sets the [value] for the given [key].
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Returns a list of strings for the given [key], or [defaultValue] if not found.
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  /// Sets the list of strings for the given [key].
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  /// Removes the value for the given [key].
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }
}
