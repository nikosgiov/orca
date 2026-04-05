import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
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
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoRefresh => _autoRefresh;
  int get refreshInterval => _refreshInterval;
  bool get biometricAuth => _biometricAuth;
  String get selectedTimeRange => _selectedTimeRange;

  SettingsProvider() {
    _loadAll();
  }

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
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }

  Future<void> setAutoRefresh(bool value) async {
    _autoRefresh = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRefresh, value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRefreshInterval, seconds);
    notifyListeners();
  }

  Future<void> setBiometricAuth(bool value) async {
    _biometricAuth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricAuth, value);
    notifyListeners();
  }

  Future<void> setSelectedTimeRange(String value) async {
    _selectedTimeRange = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTimeRange, value);
    notifyListeners();
  }
}