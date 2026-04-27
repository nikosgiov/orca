import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'docker_service.dart';
import 'fcm_service.dart';
import 'local_notification_service.dart';
import 'notification_storage_service.dart';

class NotificationService {
  NotificationService(
    this._dockerService,
    this._fcmService,
    this._localNotificationService,
    this._storageService,
  );

  final DockerService _dockerService;
  final FCMService _fcmService;
  final LocalNotificationService _localNotificationService;
  final NotificationStorageService _storageService;

  final _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationReceived =>
      _notificationStreamController.stream;

  String? _deviceToken;
  bool _isInitialized = false;

  // Notification settings
  bool _dockerMonitoringEnabled = true;
  bool _resourceMonitoringEnabled = true;
  final Map<String, double> _thresholds = {
    'cpu': 80.0,
    'memory': 85.0,
    'gpu_load': 80.0,
    'gpu_memory': 85.0,
  };

  // Getters
  String? get deviceToken => _deviceToken;
  bool get isInitialized => _isInitialized;
  bool get dockerMonitoringEnabled => _dockerMonitoringEnabled;
  bool get resourceMonitoringEnabled => _resourceMonitoringEnabled;
  Map<String, double> get thresholds => Map.from(_thresholds);

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _deviceToken = await _fcmService.getDeviceToken();
      if (_deviceToken == null) {
        debugPrint('NotificationService: Device token not available.');
        return;
      }

      await _localNotificationService.initialize(
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      _fcmService.configureHandlers(
        onMessage: _handleForegroundMessage,
        onMessageOpenedApp: (msg) => _handleNotificationData(msg.data),
      );

      _isInitialized = true;
      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Initialization error: $e');
      rethrow;
    }
  }

  Future<void> registerForNotifications() async {
    if (_deviceToken == null) {
      throw Exception('Device token not available');
    }

    final result = await _dockerService.post(
      '/register',
      data: {
        'token': _deviceToken,
        'enable_docker_monitoring': _dockerMonitoringEnabled,
        'enable_resource_monitoring': _resourceMonitoringEnabled,
      },
    );

    result.fold(
      (response) {
        if (response.statusCode != 200) {
          throw Exception('Failed to register: ${response.statusCode}');
        }
      },
      (failure) => throw Exception(failure.message),
    );
  }

  Future<void> unregisterFromNotifications({String? baseUrl}) async {
    if (_deviceToken == null) {
      return;
    }

    final result = await _dockerService.post(
      '/unregister',
      data: {'token': _deviceToken},
    );

    result.fold(
      (response) {
        if (response.statusCode != 200) {
          debugPrint('NotificationService: Unregister failed: ${response.statusCode}');
        }
      },
      (failure) => debugPrint('NotificationService: Unregister error: ${failure.message}'),
    );
  }

  Future<void> updateThresholds({
    double? cpuThreshold,
    double? memoryThreshold,
    double? gpuLoadThreshold,
    double? gpuMemoryThreshold,
    String? baseUrl,
  }) async {
    final result = await _dockerService.post(
      '/thresholds',
      data: {
        if (cpuThreshold != null) 'cpu_threshold': cpuThreshold,
        if (memoryThreshold != null) 'memory_threshold': memoryThreshold,
        if (gpuLoadThreshold != null) 'gpu_load_threshold': gpuLoadThreshold,
        if (gpuMemoryThreshold != null) 'gpu_memory_threshold': gpuMemoryThreshold,
      },
    );

    await result.fold(
      (response) async {
        if (response.statusCode == 200 && response.data != null) {
          final thresholdsData = Map<String, dynamic>.from(response.data!['thresholds']);
          thresholdsData.forEach((key, value) {
            _thresholds[key] = (value as num).toDouble();
          });
          if (baseUrl != null) {
            await savePreferences(baseUrl);
          }
        } else {
          throw Exception('Failed to update thresholds: ${response.statusCode}');
        }
      },
      (failure) => throw Exception(failure.message),
    );
  }

  Future<Map<String, dynamic>> getMonitoringStatus() async {
    final result = await _dockerService.get<Map<String, dynamic>>('/status');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return response.data!;
        }
        throw Exception('Failed to get status: ${response.statusCode}');
      },
      (failure) => throw Exception(failure.message),
    );
  }

  Future<void> sendTestNotification(String notificationType) async {
    if (_deviceToken == null) {
      throw Exception('Device token not available');
    }

    final result = await _dockerService.post(
      '/test',
      data: {'token': _deviceToken, 'notification_type': notificationType},
    );

    result.fold(
      (response) {
        if (response.statusCode != 200) {
          throw Exception('Failed to send test: ${response.statusCode}');
        }
      },
      (failure) => throw Exception(failure.message),
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final now = DateTime.now().toLocal();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final timestamp =
        '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final payload = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Notification',
      'message': message.notification?.body ?? '',
      'type': message.data['type'] ?? 'info',
      'read': false,
      'timestamp': timestamp,
    };

    _notificationStreamController.add(payload);

    _localNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _handleNotificationData(jsonDecode(response.payload!));
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    // Navigation logic handled by UI listeners
  }

  Future<void> setNotificationPreferences({
    bool? dockerMonitoring,
    bool? resourceMonitoring,
    String? url,
  }) async {
    if (dockerMonitoring != null) {
      _dockerMonitoringEnabled = dockerMonitoring;
    }
    if (resourceMonitoring != null) {
      _resourceMonitoringEnabled = resourceMonitoring;
    }
    if (url != null) {
      await savePreferences(url);
    }
  }

  Future<void> loadPreferences(String url) async {
    final prefs = await _storageService.loadPreferences(url);
    _dockerMonitoringEnabled = prefs['docker_monitoring'];
    _resourceMonitoringEnabled = prefs['resource_monitoring'];
    
    final savedThresholds = prefs['thresholds'] as Map<String, double>;
    _thresholds.addAll(savedThresholds);
  }

  Future<void> savePreferences(String url) async {
    await _storageService.savePreferences(
      url,
      dockerMonitoring: _dockerMonitoringEnabled,
      resourceMonitoring: _resourceMonitoringEnabled,
      thresholds: _thresholds,
    );
  }

  Future<void> dispose() async {
    await _fcmService.deleteToken();
    await _notificationStreamController.close();
  }
}
