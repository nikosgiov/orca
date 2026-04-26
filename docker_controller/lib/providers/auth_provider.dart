import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';
import '../core/di/service_locator.dart';
import '../models/app_error.dart';
import '../models/connection_config.dart';
import '../services/auth_service.dart';
import '../services/connection_storage_service.dart';
import '../services/dio_client.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/system_service.dart';

/// Provider responsible for managing the authentication state and connection lifecycle
/// with the Docker daemon.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  static const String _logPrefix = 'AuthProvider';

  bool _isConnected = false;
  bool _isConnecting = false;
  ConnectionConfig? _connectionConfig;
  List<String> _connectionHistory = [];
  AppError? _error;
  int _consecutiveFailures = 0;

  /// Maximum number of consecutive failures allowed before an automatic logout is triggered.
  static const int maxFailuresBeforeLogout = 3;

  /// Whether the app is currently connected to a Docker daemon.
  bool get isConnected => _isConnected;

  /// Whether a connection attempt is currently in progress.
  bool get isConnecting => _isConnecting;

  /// The current active connection configuration.
  ConnectionConfig? get connectionConfig => _connectionConfig;

  /// A history of previously used connection URIs.
  List<String> get connectionHistory => _connectionHistory;

  /// The last error encountered during connection or authentication.
  AppError? get error => _error;

  /// Initializes the provider by loading stored configuration and history.
  Future<void> _init() async {
    _connectionHistory = await ConnectionStorageService.loadConnectionHistory();
    _connectionConfig = await ConnectionStorageService.loadConnectionConfig();

    if (_connectionConfig != null) {
      getIt<DioClient>().updateConfig(_connectionConfig!);
      if (_connectionConfig!.token != null &&
          _connectionConfig!.token!.isNotEmpty) {
        _isConnected = true;
        developer.log(
          '$_logPrefix: Loaded valid token from storage',
          name: _logPrefix,
        );
        await _autoRegisterNotifications(_connectionConfig!);
      }
    }
    notifyListeners();
  }

  /// Attempts to connect to a Docker daemon using the provided [config].
  ///
  /// [username] and [password] are required if the authentication type is [AuthType.basic].
  /// If [persist] is true, the configuration will be saved to secure storage upon success.
  Future<void> connect(
    ConnectionConfig config, {
    String? username,
    String? password,
    bool persist = false,
  }) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      getIt<DioClient>().updateConfig(config);

      // 1. Authentication
      final token = await _performLoginIfNeeded(config, username, password);
      if (_error != null) {
        return;
      }

      final updatedConfig = config.copyWith(token: token);
      getIt<DioClient>().updateConfig(updatedConfig);

      // 2. Connectivity Test
      final isConnected = await _verifyConnection();
      if (!isConnected) {
        _handleFailure('Failed to connect to Docker daemon.');
        return;
      }

      // 3. System Initialization
      final finalConfig = await _initializeSystem(updatedConfig);
      if (_error != null) {
        return;
      }

      // 4. Finalize Connection
      await _finalizeConnection(finalConfig, persist);
    } catch (e) {
      _handleFailure('Connection error: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<String?> _performLoginIfNeeded(
    ConnectionConfig config,
    String? username,
    String? password,
  ) async {
    if (config.authType != AuthType.basic) {
      return config.token;
    }

    final token = await getIt<AuthService>().login(
      username ?? '',
      password ?? '',
    );

    if (token == null) {
      _handleFailure('Login failed. Please check your credentials.');
    }
    return token;
  }

  Future<bool> _verifyConnection() async {
    return await getIt<SystemService>().testConnection().timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
  }

  Future<ConnectionConfig> _initializeSystem(ConnectionConfig config) async {
    final info = await getIt<SystemService>().getSystemInfo();
    if (info == null) {
      _handleFailure('Connected to host, but access to Docker API was denied.');
      return config;
    }

    var finalConfig = config;

    // Initialize Firebase if available
    final firebaseConfig = await getIt<SystemService>().getFirebaseConfig();
    if (firebaseConfig != null) {
      finalConfig = config.copyWith(firebaseConfig: firebaseConfig);
      await FirebaseService.initialize(firebaseConfig);
    }

    return finalConfig;
  }

  Future<void> _finalizeConnection(ConnectionConfig config, bool persist) async {
    _connectionConfig = config;
    _isConnected = true;
    _consecutiveFailures = 0;
    _error = null;

    await _autoRegisterNotifications(config);

    if (persist) {
      await ConnectionStorageService.saveConnectionConfig(config);
    }

    _updateHistory(config.uri);
  }

  /// Handles a connection failure by updating state and checking for auto-logout.
  void _handleFailure(String message) {
    _isConnected = false;
    _consecutiveFailures++;
    _error = AppError(message: message);
    _checkAutoLogout();
    notifyListeners();
  }

  void _checkAutoLogout() {
    if (_consecutiveFailures >= maxFailuresBeforeLogout) {
      logout();
      _error = AppError(message: AppStrings.autoLogoutMessage);
      _consecutiveFailures = 0;
    }
  }

  /// Logs out the user, clearing stored configuration and terminating Firebase.
  Future<void> logout() async {
    await ConnectionStorageService.deleteConnectionConfig();
    _isConnected = false;
    _connectionConfig = null;

    await FirebaseService.terminate();
    notifyListeners();
  }

  void _updateHistory(String uri) async {
    if (!_connectionHistory.contains(uri)) {
      _connectionHistory.insert(0, uri);
      if (_connectionHistory.length > 10) {
        _connectionHistory.removeLast();
      }
    } else {
      _connectionHistory.remove(uri);
      _connectionHistory.insert(0, uri);
    }
    await ConnectionStorageService.saveConnectionHistory(_connectionHistory);
  }

  Future<void> _autoRegisterNotifications(ConnectionConfig config) async {
    try {
      final service = getIt<NotificationService>();
      await service.initialize();

      final prefs = await SharedPreferences.getInstance();
      final masterEnabled = prefs.getBool('notificationsEnabled') ?? true;

      final baseUrl = '${config.useTls ? 'https://' : 'http://'}${config.uri}';

      if (!masterEnabled) {
        developer.log(
          '$_logPrefix: Notifications disabled globally, unregistering',
          name: _logPrefix,
        );
        await service.unregisterFromNotifications();
        return;
      }

      await service.loadPreferences(baseUrl);
      await service.registerForNotifications();
    } catch (e) {
      developer.log(
        '$_logPrefix: Notification registration error: $e',
        name: _logPrefix,
      );
    }
  }

  /// Clears the current error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
