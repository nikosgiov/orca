import 'dart:developer' as developer;

import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/services/auth_service.dart';
import 'package:docker_controller/services/connection_storage_service.dart';
import 'package:docker_controller/services/dio_client.dart';
import 'package:docker_controller/services/firebase_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/services/preferences_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:flutter/material.dart';

/// Provider responsible for managing the authentication state and connection lifecycle.
class AuthProvider extends ChangeNotifier {
  AuthProvider();

  static const String _logPrefix = 'AuthProvider';

  bool _isConnected = false;
  bool _isConnecting = false;
  ConnectionConfig? _connectionConfig;
  List<String> _connectionHistory = [];
  AppError? _error;
  int _consecutiveFailures = 0;

  static const int maxFailuresBeforeLogout = 3;

  /// Whether the application is currently connected to a Docker host.
  bool get isConnected => _isConnected;

  /// Whether a connection attempt is currently in progress.
  bool get isConnecting => _isConnecting;

  /// The current connection configuration, if any.
  ConnectionConfig? get connectionConfig => _connectionConfig;

  /// A list of previously used connection URIs.
  List<String> get connectionHistory => _connectionHistory;

  /// The most recent error encountered during connection or authentication.
  AppError? get error => _error;

  /// Initializes the provider by loading saved connection configuration and history.
  Future<void> init() async {
    _connectionHistory = await getIt<ConnectionStorageService>().loadConnectionHistory();
    _connectionConfig = await getIt<ConnectionStorageService>().loadConnectionConfig();

    if (_connectionConfig != null) {
      getIt<DioClient>().updateConfig(_connectionConfig!);
      if (_connectionConfig!.token != null && _connectionConfig!.token!.isNotEmpty) {
        _isConnected = true;
        developer.log('$_logPrefix: Loaded valid token from storage', name: _logPrefix);
        await _autoRegisterNotifications(_connectionConfig!);
      }
    }
    notifyListeners();
  }

  /// Attempts to connect to a Docker host using the provided [config].
  ///
  /// [username] and [password] are required if the [config] specifies [AuthType.basic].
  /// If [persist] is true, the configuration will be saved to local storage upon success.
  Future<void> connect(
    ConnectionConfig config, {
    String? username,
    String? password,
    bool persist = false,
  }) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    final storage = getIt<ConnectionStorageService>();
    final systemService = getIt<SystemService>();
    try {
      getIt<DioClient>().updateConfig(config);

      // 1. Authentication
      final loginResult = await _performLoginIfNeeded(config, username, password);
      if (loginResult == null && config.authType != AuthType.none) {
        return; // Error handled inside
      }
      final updatedConfig = config.copyWith(token: loginResult);
      getIt<DioClient>().updateConfig(updatedConfig);

      // 2. Connectivity Test
      final connectionResult = await _verifyConnection(systemService);
      if (connectionResult.isFailure) {
        await _handleFailure(connectionResult.exceptionOrNull?.message ?? 'Failed to connect to Docker daemon.');
        return;
      }

      // 3. System Initialization
      final finalConfig = await _initializeSystem(updatedConfig, systemService);
      if (_error != null) {
        return;
      }

      // 4. Finalize Connection
      await _finalizeConnection(finalConfig, persist, storage);
    } catch (e) {
      await _handleFailure('Connection error: $e');
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

    final result = await getIt<AuthService>().login(
      username ?? '',
      password ?? '',
    );

    return result.fold(
      (token) => token,
      (failure) async {
        await _handleFailure(failure.message);
        return null;
      },
    );
  }

  Future<Result<bool, AppError>> _verifyConnection(SystemService service) async {
    return await service.testConnection().timeout(
      const Duration(seconds: 5),
      onTimeout: () => Result.failure(AppError(message: 'Connection timed out')),
    );
  }

  Future<ConnectionConfig> _initializeSystem(ConnectionConfig config, SystemService service) async {
    final infoResult = await service.getSystemInfo();
    return await infoResult.fold(
      (info) async {
        var finalConfig = config;
        final firebaseResult = await service.getFirebaseConfig();
        
        firebaseResult.fold(
          (firebaseConfig) {
            finalConfig = finalConfig.copyWith(firebaseConfig: firebaseConfig);
            getIt<FirebaseService>().initialize(firebaseConfig);
          },
          (_) => null, // Ignore firebase config errors for now
        );
        
        return finalConfig;
      },
      (failure) async {
        await _handleFailure('Connected to host, but access to Docker API was denied: ${failure.message}');
        return config;
      },
    );
  }

  Future<void> _finalizeConnection(ConnectionConfig config, bool persist, ConnectionStorageService storage) async {
    _isConnected = true;
    _connectionConfig = config;
    _consecutiveFailures = 0;
    _error = null;

    await _autoRegisterNotifications(config);

    if (persist) {
      await storage.saveConnectionConfig(config);
    }

    await _updateHistory(config.uri, storage);
  }

  Future<void> _handleFailure(String message) async {
    _isConnected = false;
    _consecutiveFailures++;
    _error = AppError(message: message);
    await _checkAutoLogout();
    notifyListeners();
  }

  Future<void> _checkAutoLogout() async {
    if (_consecutiveFailures >= maxFailuresBeforeLogout) {
      await logout();
      _error = AppError(message: 'Connection failed multiple times. Please re-enter your Docker host details.');
      _consecutiveFailures = 0;
    }
  }

  /// Logs out the current connection, clearing state and local storage.
  ///
  /// This also unregisters the device from server-side notifications and
  /// terminates the Firebase session.
  Future<void> logout() async {
    try {
      final notificationService = getIt<NotificationService>();
      // 1. Tell the server to stop sending notifications to this device
      await notificationService.unregisterFromNotifications();
      // 2. Clear the local FCM token to ensure a fresh one if we log in again
      await notificationService.dispose();
    } catch (e) {
      developer.log('$_logPrefix: Error during notification cleanup on logout: $e', name: _logPrefix);
    }

    // 3. Clear local storage and state
    await getIt<ConnectionStorageService>().deleteConnectionConfig();
    _isConnected = false;
    _connectionConfig = null;

    // 4. Log termination
    await getIt<FirebaseService>().terminate();
    notifyListeners();
  }

  Future<void> _updateHistory(String uri, ConnectionStorageService storage) async {
    if (!_connectionHistory.contains(uri)) {
      _connectionHistory.insert(0, uri);
      if (_connectionHistory.length > 10) {
        _connectionHistory.removeLast();
      }
    } else {
      _connectionHistory.remove(uri);
      _connectionHistory.insert(0, uri);
    }
    await storage.saveConnectionHistory(_connectionHistory);
  }

  Future<void> _autoRegisterNotifications(ConnectionConfig config) async {
    try {
      final service = getIt<NotificationService>();
      await service.initialize();

      final prefs = getIt<PreferencesService>();
      final masterEnabled = prefs.getBool('notificationsEnabled', defaultValue: true);

      final baseUrl = '${config.useTls ? 'https://' : 'http://'}${config.uri}';

      if (!masterEnabled) {
        developer.log('$_logPrefix: Notifications disabled globally, unregistering', name: _logPrefix);
        await service.unregisterFromNotifications();
        return;
      }

      await service.loadPreferences(baseUrl);
      await service.registerForNotifications();
    } catch (e) {
      developer.log('$_logPrefix: Notification registration error: $e', name: _logPrefix);
    }
  }

  /// Clears the current error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
