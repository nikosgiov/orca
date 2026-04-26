import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/di/service_locator.dart';
import '../models/app_notification.dart';
import '../models/connection_config.dart';
import '../models/log_entry.dart';
import '../models/log_level.dart';
import '../services/container_service.dart';
import '../services/notification_service.dart';
import '../utils/log_filter_utils.dart';
import 'auth_provider.dart';

class LogsNotificationsProvider extends ChangeNotifier {
  LogsNotificationsProvider(this.authProvider) {
    _currentUrl = authProvider.connectionConfig?.uri;
    if (_currentUrl != null) {
      _loadNotifications(_currentUrl!);
    }
    fetchContainers();

    // Listen to push notifications in real-time
    _notificationSubscription = getIt<NotificationService>()
        .onNotificationReceived
        .listen((notificationMap) {
      final notification = AppNotification.fromJson(notificationMap);
      _notifications.insert(0, notification);
      notifyListeners();
      if (_currentUrl != null) {
        _saveNotifications(_currentUrl!);
      }
    });
  }
  final AuthProvider authProvider;
  late final StreamSubscription _notificationSubscription;

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  bool _followLogs = false;
  LogLevel _selectedLogLevel = LogLevel.all;
  String _selectedContainer = 'All';
  List<String> _containers = [];
  bool _isLoadingContainers = false;
  bool _isLoadingLogs = false;

  final List<LogEntry> _logs = [];
  final List<AppNotification> _notifications = [];
  String? _currentUrl;

  void updateConnectionConfig(ConnectionConfig? config) {
    if (config == null) {
      return;
    }
    final url = config.uri;
    if (_currentUrl != url) {
      _currentUrl = url;
      _logs.clear();
      _notifications.clear();
      _loadNotifications(url);
      fetchContainers();
      notifyListeners();
    }
  }

  Future<void> _loadNotifications(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final jsonStr = prefs.getString('notifications_$cleanUrl');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _notifications.clear();
      _notifications.addAll(
        decoded.map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
      notifyListeners();
    }
  }

  Future<void> _saveNotifications(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await prefs.setString(
      'notifications_$cleanUrl',
      jsonEncode(_notifications.map((e) => e.toJson()).toList()),
    );
  }

  bool get isLoadingContainers => _isLoadingContainers;
  bool get isLoadingLogs => _isLoadingLogs;
  List<String> get containers => _containers;

  Future<void> fetchContainers() async {
    final config = authProvider.connectionConfig;
    if (config == null) {
      return;
    }
    _isLoadingContainers = true;
    notifyListeners();
    try {
      final containersList = await getIt<ContainerService>().getContainers();
      _containers = containersList
          .map(
            (c) => c.names.isNotEmpty
                ? c.names.first.replaceAll('/', '')
                : 'Unknown',
          )
          .toList();
    } finally {
      _isLoadingContainers = false;
      notifyListeners();
    }
  }

  Future<void> fetchLogs(String containerId) async {
    final config = authProvider.connectionConfig;
    if (config == null) {
      return;
    }
    _isLoadingLogs = true;
    notifyListeners();
    try {
      final logsStr = await getIt<ContainerService>().getContainerLogs(
        containerId,
      );
      if (logsStr != null) {
        _logs.clear();
        final lines = logsStr.split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) {
            continue;
          }

          LogLevel level = LogLevel.info;
          String message = line;

          // Docker logs sometimes have headers we might want to skip or parse
          if (line.length > 8 && line.codeUnitAt(0) < 3) {
            // Skip Docker framing header (8 bytes) if multiplexed
            message = line.substring(8);
          }

          final lower = message.toLowerCase();
          if (lower.contains('error') ||
              lower.contains('critical') ||
              lower.contains('fail')) {
            level = LogLevel.error;
          } else if (lower.contains('warn')) {
            level = LogLevel.warn;
          } else if (lower.contains('debug')) {
            level = LogLevel.debug;
          }

          _logs.add(LogEntry(
            timestamp: DateTime.now()
                .toString()
                .split('.')
                .first
                .split(' ')
                .last, // Just time
            level: level,
            container: _selectedContainer,
            message: message.trim(),
          ));
        }
      }
    } finally {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  bool get followLogs => _followLogs;
  LogLevel get selectedLogLevel => _selectedLogLevel;
  String get selectedContainer => _selectedContainer;
  List<LogEntry> get logs => List.unmodifiable(_logs);
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);
  bool get hasUnreadNotifications =>
      _notifications.any((n) => !n.read);

  set followLogs(bool value) {
    _followLogs = value;
    notifyListeners();
  }

  set selectedLogLevel(LogLevel value) {
    _selectedLogLevel = value;
    notifyListeners();
  }

  set selectedContainer(String value) {
    if (_selectedContainer != value) {
      _selectedContainer = value;
      notifyListeners();
      if (value != 'All') {
        fetchLogs(value);
      }
    }
  }

  List<LogEntry> getFilteredLogs() {
    return LogFilterUtils.filterLogs(
      logs: _logs,
      selectedLogLevel: _selectedLogLevel,
      selectedContainer: _selectedContainer,
    );
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void markNotificationAsRead(AppNotification notification) {
    final index = _notifications.indexOf(notification);
    if (index != -1) {
      _notifications[index] = notification.copyWith(read: !notification.read);
      notifyListeners();
      if (_currentUrl != null) {
        _saveNotifications(_currentUrl!);
      }
    }
  }

  void deleteNotification(AppNotification notification) {
    _notifications.remove(notification);
    notifyListeners();
    if (_currentUrl != null) {
      _saveNotifications(_currentUrl!);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    notifyListeners();
    if (_currentUrl != null) {
      _saveNotifications(_currentUrl!);
    }
  }
}
