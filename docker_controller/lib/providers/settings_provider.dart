import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider responsible for managing application-wide settings and persistence.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _loadAll();
  }
  // ── Keys ─────────────────────────────────────────────────────────────────
  static const _keyThemeMode = 'themeMode';
  static const _keyNotifications = 'notificationsEnabled';
  static const _keyAutoRefresh = 'autoRefresh';
  static const _keyRefreshInterval = 'refreshInterval';
  static const _keyBiometricAuth = 'biometricAuth';
  static const _keySelectedTimeRange = 'selectedTimeRange';

  // ── State ─────────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _autoRefresh = true;
  int _refreshInterval = 30;
  bool _biometricAuth = false;
  String _selectedTimeRange = '30m';

  // ── Getters ───────────────────────────────────────────────────────────────
  /// The current theme mode of the application.
  ThemeMode get themeMode => _themeMode;

  /// Whether push notifications are enabled globally in the app.
  bool get notificationsEnabled => _notificationsEnabled;

  /// Whether real-time data should automatically refresh.
  bool get autoRefresh => _autoRefresh;

  /// The interval in seconds for automatic data refreshes.
  int get refreshInterval => _refreshInterval;

  /// Whether biometric authentication is enabled for app access.
  bool get biometricAuth => _biometricAuth;

  /// The selected time range for resource monitoring graphs (e.g., '30m', '1h').
  String get selectedTimeRange => _selectedTimeRange;

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0];
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _autoRefresh = prefs.getBool(_keyAutoRefresh) ?? true;
    _refreshInterval = prefs.getInt(_keyRefreshInterval) ?? 30;
    _biometricAuth = prefs.getBool(_keyBiometricAuth) ?? false;
    _selectedTimeRange = prefs.getString(_keySelectedTimeRange) ?? '30m';
    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  /// Updates the theme mode and persists it to local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  /// Updates the notification preference and persists it.
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }

  /// Updates the auto-refresh preference and persists it.
  Future<void> setAutoRefresh(bool value) async {
    _autoRefresh = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRefresh, value);
    notifyListeners();
  }

  /// Updates the refresh interval and persists it.
  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRefreshInterval, seconds);
    notifyListeners();
  }

  /// Updates the biometric authentication preference and persists it.
  Future<void> setBiometricAuth(bool value) async {
    _biometricAuth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricAuth, value);
    notifyListeners();
  }

  /// Updates the selected time range for graphs and persists it.
  Future<void> setSelectedTimeRange(String value) async {
    _selectedTimeRange = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTimeRange, value);
    notifyListeners();
  }
}
