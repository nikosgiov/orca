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

  ThemeMode get themeMode => _themeMode;
  bool get isFirstRun => _isFirstRun;
  bool get isInitializing => _isInitializing;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isFirstRun = prefs.getBool('isFirstRun') ?? true;
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setFirstRunComplete() async {
    _isFirstRun = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    notifyListeners();
  }
}
