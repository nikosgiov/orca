import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for application-wide configuration and preferences.
class AppConfigProvider extends ChangeNotifier {
  AppConfigProvider() {
    _loadSettings();
  }
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstRun = true;
  bool _isInitializing = true;

  /// The current theme mode of the application.
  ThemeMode get themeMode => _themeMode;

  /// Whether this is the first time the application is being run.
  bool get isFirstRun => _isFirstRun;

  /// Whether the provider is still loading settings from local storage.
  bool get isInitializing => _isInitializing;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isFirstRun = prefs.getBool('isFirstRun') ?? true;
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _isInitializing = false;
    notifyListeners();
  }

  /// Updates the theme mode and persists it to local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  /// Marks the onboarding/first-run process as complete.
  Future<void> setFirstRunComplete() async {
    _isFirstRun = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    notifyListeners();
  }
}
