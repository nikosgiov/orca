import 'package:docker_controller/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial values should be defaults', () async {
      final provider = SettingsProvider();
      // Wait for _loadAll to complete (it's called in constructor)
      await Future.delayed(Duration.zero);

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.notificationsEnabled, true);
      expect(provider.autoRefresh, true);
      expect(provider.refreshInterval, 30);
    });

    test('setThemeMode should update state and persistence', () async {
      final provider = SettingsProvider();
      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('themeMode'), ThemeMode.dark.index);
    });

    test('setNotificationsEnabled should update state', () async {
      final provider = SettingsProvider();
      await provider.setNotificationsEnabled(false);

      expect(provider.notificationsEnabled, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notificationsEnabled'), false);
    });

    test('setRefreshInterval should update state', () async {
      final provider = SettingsProvider();
      await provider.setRefreshInterval(60);

      expect(provider.refreshInterval, 60);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('refreshInterval'), 60);
    });
  });
}
