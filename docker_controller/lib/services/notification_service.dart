import 'package:flutter/material.dart';
// lib/services/notification_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_error.dart';
import 'firebase_background_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationReceived => _notificationStreamController.stream;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  bool _isInitialized = false;

  // Notification settings
  bool _dockerMonitoringEnabled = true;
  bool _resourceMonitoringEnabled = true;
  Map<String, double> _thresholds = {
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

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get device token
        _deviceToken = await _firebaseMessaging.getToken();
        debugPrint('Device token: ${_deviceToken?.substring(0, 20)}...');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        _isInitialized = true;
        debugPrint('Notification service initialized successfully');
      } else {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  /// Register for push notifications with the server
  Future<void> registerForNotifications({
    required String baseUrl,
    required String token,
  }) async {
    if (_deviceToken == null) {
      throw AppError(message: 'Device token not available');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': _deviceToken,
          'enable_docker_monitoring': _dockerMonitoringEnabled,
          'enable_resource_monitoring': _resourceMonitoringEnabled,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully registered for notifications');
      } else {
        throw AppError(message: 'Failed to register for notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering for notifications: $e');
      rethrow;
    }
  }

  /// Unregister from push notifications
  Future<void> unregisterFromNotifications({
    required String baseUrl,
    required String token,
  }) async {
    if (_deviceToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/unregister'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': _deviceToken,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully unregistered from notifications');
      } else {
        debugPrint('Failed to unregister from notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error unregistering from notifications: $e');
    }
  }

  /// Update notification thresholds
  Future<void> updateThresholds({
    required String baseUrl,
    required String token,
    double? cpuThreshold,
    double? memoryThreshold,
    double? gpuLoadThreshold,
    double? gpuMemoryThreshold,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/thresholds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (cpuThreshold != null) 'cpu_threshold': cpuThreshold,
          if (memoryThreshold != null) 'memory_threshold': memoryThreshold,
          if (gpuLoadThreshold != null) 'gpu_load_threshold': gpuLoadThreshold,
          if (gpuMemoryThreshold != null) 'gpu_memory_threshold': gpuMemoryThreshold,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _thresholds = Map<String, double>.from(data['thresholds']);
        await savePreferences(baseUrl); // Save thresholds to disk
        debugPrint('Thresholds updated successfully');
      } else {
        throw AppError(message: 'Failed to update thresholds: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating thresholds: $e');
      rethrow;
    }
  }

  /// Get monitoring status
  Future<Map<String, dynamic>> getMonitoringStatus({
    required String baseUrl,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AppError(message: 'Failed to get monitoring status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting monitoring status: $e');
      rethrow;
    }
  }

  /// Send test notification
  Future<void> sendTestNotification({
    required String baseUrl,
    required String token,
    required String notificationType,
  }) async {
    if (_deviceToken == null) {
      throw AppError(message: 'Device token not available');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': _deviceToken,
          'notification_type': notificationType,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Test notification sent successfully');
      } else {
        throw AppError(message: 'Failed to send test notification: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      rethrow;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.notification?.title}');
    
    final now = DateTime.now().toLocal();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timestamp = '$hour:${now.minute.toString().padLeft(2, '0')} $ampm';
    
    final payload = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Notification',
      'message': message.notification?.body ?? '',
      'type': message.data['type'] ?? 'info',
      'read': false,
      'timestamp': timestamp,
    };
    
    _notificationStreamController.add(payload); // Broadcast to UI listeners
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }



  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
    // Handle navigation based on notification data
    _handleNotificationData(message.data);
  }

  /// Handle local notification taps
  void _handleLocalNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationData(data);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final BigPictureStyleInformation bigPictureStyle = BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'docker_controller_channel',
      'Docker Controller Notifications',
      channelDescription: 'Notifications from Docker Controller app',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF24267D), // AppColors.primary
      styleInformation: bigPictureStyle,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Handle notification data for navigation
  void _handleNotificationData(Map<String, dynamic> data) {
    // Handle different notification types
    final type = data['type'] ?? '';
    
    switch (type) {
      case 'container_created':
      case 'container_deleted':
      case 'container_state_changed':
        // Navigate to containers screen
        break;
      case 'image_pulled':
      case 'image_deleted':
        // Navigate to images screen
        break;
      case 'high_cpu_usage':
      case 'high_memory_usage':
      case 'high_gpu_usage':
        // Navigate to resource monitoring screen
        break;
      default:
        // Navigate to home screen
        break;
    }
  }

  /// Set notification preferences
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
      await savePreferences(url); // Await the save
    }
  }

  /// Load notification preferences from local storage
  Future<void> loadPreferences(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    _dockerMonitoringEnabled = prefs.getBool('docker_monitoring_$cleanUrl') ?? true;
    _resourceMonitoringEnabled = prefs.getBool('resource_monitoring_$cleanUrl') ?? true;
    
    // Load thresholds
    _thresholds['cpu'] = prefs.getDouble('threshold_cpu_$cleanUrl') ?? 80.0;
    _thresholds['memory'] = prefs.getDouble('threshold_memory_$cleanUrl') ?? 85.0;
    _thresholds['gpu_load'] = prefs.getDouble('threshold_gpu_load_$cleanUrl') ?? 80.0;
    _thresholds['gpu_memory'] = prefs.getDouble('threshold_gpu_memory_$cleanUrl') ?? 85.0;
    
    debugPrint('Loaded preferences for $url');
  }

  /// Save notification preferences to local storage
  Future<void> savePreferences(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await prefs.setBool('docker_monitoring_$cleanUrl', _dockerMonitoringEnabled);
    await prefs.setBool('resource_monitoring_$cleanUrl', _resourceMonitoringEnabled);
    
    // Save thresholds
    await prefs.setDouble('threshold_cpu_$cleanUrl', _thresholds['cpu'] ?? 80.0);
    await prefs.setDouble('threshold_memory_$cleanUrl', _thresholds['memory'] ?? 85.0);
    await prefs.setDouble('threshold_gpu_load_$cleanUrl', _thresholds['gpu_load'] ?? 80.0);
    await prefs.setDouble('threshold_gpu_memory_$cleanUrl', _thresholds['gpu_memory'] ?? 85.0);
    
    debugPrint('Saved preferences for $url');
  }

  /// Dispose resources
  void dispose() {
    _firebaseMessaging.deleteToken();
  }
} 