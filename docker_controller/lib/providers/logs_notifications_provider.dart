import 'package:flutter/material.dart';
import '../models/connection_config.dart';
import '../utils/log_filter_utils.dart';
import 'app_provider.dart';
import '../services/container_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class LogsNotificationsProvider extends ChangeNotifier {
  final AppProvider appProvider;
  bool _followLogs = false;
  String _selectedLogLevel = 'All';
  String _selectedContainer = 'All';
  List<String> _containers = [];
  bool _isLoadingContainers = false;
  bool _isLoadingLogs = false;

  final List<Map<String, dynamic>> _logs = [];
  final List<Map<String, dynamic>> _notifications = []; // Kept empty or from disk
  String? _currentUrl;

  LogsNotificationsProvider(this.appProvider) {
    _currentUrl = appProvider.connectionConfig?.uri;
    if (_currentUrl != null) _loadNotifications(_currentUrl!);
    fetchContainers();

    // Listen to push notifications in real-time
    NotificationService().onNotificationReceived.listen((notification) {
      _notifications.insert(0, notification);
      notifyListeners();
      if (_currentUrl != null) _saveNotifications(_currentUrl!);
    });
  }

  void updateConnectionConfig(ConnectionConfig? config) {
    if (config == null) return;
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
      _notifications.addAll(decoded.map((e) => Map<String, dynamic>.from(e)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveNotifications(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await prefs.setString('notifications_$cleanUrl', jsonEncode(_notifications));
  }

  bool get isLoadingContainers => _isLoadingContainers;
  bool get isLoadingLogs => _isLoadingLogs;
  List<String> get containers => _containers;

  Future<void> fetchContainers() async {
    final config = appProvider.connectionConfig;
    if (config == null) return;
    _isLoadingContainers = true;
    notifyListeners();
    try {
      final containersList = await ContainerService.getContainers(config);
      if (containersList != null) {
        _containers = containersList
            .map((c) => (c['Names'] as List?)?.first?.toString().replaceAll('/', '') ?? 'Unknown')
            .toList();
      }
    } finally {
      _isLoadingContainers = false;
      notifyListeners();
    }
  }

  Future<void> fetchLogs(String containerId) async {
    final config = appProvider.connectionConfig;
    if (config == null) return;
    _isLoadingLogs = true;
    notifyListeners();
    try {
      final logsStr = await ContainerService.getContainerLogs(config, containerId);
      if (logsStr != null) {
        _logs.clear();
        final lines = logsStr.split('\n');
        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          
          Color levelColor = const Color(0xFF10B981); // Info
          String level = 'INFO';
          String message = line;
          
          // Docker logs sometimes have headers we might want to skip or parse
          // For now, just clean it
          if (line.length > 8 && line.codeUnitAt(0) < 3) {
             // Skip Docker framing header (8 bytes) if multiplexed
             message = line.substring(8);
          }

          final lower = message.toLowerCase();
          if (lower.contains('error') || lower.contains('critical') || lower.contains('fail')) {
            levelColor = const Color(0xFFEF4444);
            level = 'ERROR';
          } else if (lower.contains('warn')) {
            levelColor = const Color(0xFFF59E0B);
            level = 'WARN';
          } else if (lower.contains('debug')) {
            levelColor = const Color(0xFF6B7280);
            level = 'DEBUG';
          }

          _logs.add({
            'timestamp': DateTime.now().toString().split('.').first.split(' ').last, // Just time
            'level': level,
            'container': _selectedContainer,
            'message': message.trim(),
            'color': levelColor,
          });
        }
      }
    } finally {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  bool get followLogs => _followLogs;
  String get selectedLogLevel => _selectedLogLevel;
  String get selectedContainer => _selectedContainer;
  List<Map<String, dynamic>> get logs => List.unmodifiable(_logs);
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  bool get hasUnreadNotifications => _notifications.any((n) => !(n['read'] ?? false));

  set followLogs(bool value) {
    _followLogs = value;
    notifyListeners();
  }

  set selectedLogLevel(String value) {
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

  List<Map<String, dynamic>> getFilteredLogs() {
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

  void markNotificationAsRead(Map<String, dynamic> notification) {
    notification['read'] = !notification['read'];
    notifyListeners();
    if (_currentUrl != null) _saveNotifications(_currentUrl!);
  }

  void deleteNotification(Map<String, dynamic> notification) {
    _notifications.remove(notification);
    notifyListeners();
    if (_currentUrl != null) _saveNotifications(_currentUrl!);
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
    if (_currentUrl != null) _saveNotifications(_currentUrl!);
  }
} 