import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../models/connection_config.dart';
import '../models/resource_data_point.dart';
import '../services/system_service.dart';
import '../models/app_error.dart';
import '../utils/resource_stats_utils.dart';
import '../services/connection_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/container_service.dart';
import '../services/volume_service.dart';
import '../services/network_service.dart';
import '../constants/app_strings.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  static const String _logPrefix = 'myapp';

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isInitializing = true;
  bool _isFirstRun = true; // Track if first run
  ConnectionConfig? _connectionConfig;
  List<String> _connectionHistory = [];
  ThemeMode _themeMode = ThemeMode.system;
  AppError? _error;

  // System data
  Map<String, dynamic>? _systemInfo;
  Map<String, dynamic>? _resourceStats;
  bool _isLoadingData = false;

  // Real-time data collection
  final List<ResourceDataPoint> _resourceHistory = [];

  // New fields for system metrics
  Map<String, dynamic>? _systemMetrics;
  List<Map<String, dynamic>> _metricsHistory = [];

  // Infrastructure counts
  int _volumeCount = 0;
  int _networkCount = 0;

  // Track consecutive connection failures
  int _consecutiveFailures = 0;
  static const int maxFailuresBeforeLogout = 3;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isInitializing => _isInitializing;
  bool get isFirstRun => _isFirstRun; // Getter for first run
  ConnectionConfig? get connectionConfig => _connectionConfig;
  List<String> get connectionHistory => _connectionHistory;
  ThemeMode get themeMode => _themeMode;
  AppError? get error => _error;
  Map<String, dynamic>? get systemInfo => _systemInfo;
  Map<String, dynamic>? get resourceStats => _resourceStats;
  bool get isLoadingData => _isLoadingData;
  List<ResourceDataPoint> get resourceHistory => _resourceHistory;
  Map<String, dynamic>? get systemMetrics => _systemMetrics;
  List<Map<String, dynamic>> get metricsHistory => _metricsHistory;
  int get volumeCount => _volumeCount;
  int get networkCount => _networkCount;

  AppProvider() {
    developer.log('$_logPrefix: AppProvider constructor called', name: 'AppProvider');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    developer.log('$_logPrefix: _loadSettings started', name: 'AppProvider');
    final prefs = await SharedPreferences.getInstance();
    
    // Load first run status
    _isFirstRun = prefs.getBool('isFirstRun') ?? true;
    developer.log('$_logPrefix: isFirstRun: $_isFirstRun', name: 'AppProvider');

    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load connection history
    _connectionHistory = await ConnectionStorageService.loadConnectionHistory();

    // Load saved connection config
    _connectionConfig = await ConnectionStorageService.loadConnectionConfig();
    if (_connectionConfig != null &&
        _connectionConfig!.token != null &&
        _connectionConfig!.token!.isNotEmpty) {
      _isConnected = true;
      _error = null;
      developer.log('$_logPrefix: Loaded valid token from storage, user is connected',
          name: 'AppProvider');
      await Future.wait([
        fetchSystemData(),
        fetchContainersAndResourceStats(),
        fetchSystemMetrics(),
      ]);
      _autoRegisterNotifications(_connectionConfig!);
    }
    // If no token, remain on login screen
    _isInitializing = false;
    developer.log(
        '$_logPrefix: _loadSettings completed - isInitializing: $_isInitializing, isConnected: $_isConnected',
        name: 'AppProvider');
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

  Future<void> saveConnectionConfig(ConnectionConfig config) async {
    _connectionConfig = config;
    await ConnectionStorageService.saveConnectionConfig(config);
    developer.log('$_logPrefix: Saved connection config - AuthType: ${config.authType}',
        name: 'AppProvider');
    notifyListeners();
  }

  // ── Auth-error helper ──────────────────────────────────────────────────────
  /// Checks if [e] is an authentication error (403/Forbidden/Unauthorized),
  /// increments [_consecutiveFailures], sets [_error], and triggers auto-logout
  /// if the threshold is exceeded. Returns `true` if it was an auth error.
  bool _handleAuthError(Object e, {String context = ''}) {
    final msg = e.toString();
    if (msg.contains('403') || msg.contains('Forbidden') || msg.contains('Unauthorized')) {
      _consecutiveFailures++;
      _error = AppError(
        message: 'Authentication failed. Your session may have expired. Please reconnect.',
      );
      _checkAutoLogout();
      developer.log(
        '$_logPrefix: Auth error${context.isEmpty ? '' : ' in $context'}: $e (failure #$_consecutiveFailures)',
        name: 'AppProvider',
      );
      return true;
    }
    return false;
  }

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
      developer.log('$_logPrefix: Testing connection to ${config.uri}', name: 'AppProvider');
      String? token;
      if (config.authType == AuthType.basic) {
        final protocol = config.useTls ? 'https://' : 'http://';
        final loginUri = Uri.parse('$protocol${config.uri}/login');
        final response = await http.post(
          loginUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          token = data['token'];
        } else {
          _isConnected = false;
          _consecutiveFailures++;
          _error = AppError(message: 'Login failed: ${response.body}');
          _checkAutoLogout();
          notifyListeners();
          return;
        }
      }
      final updatedConfig = config.copyWith(token: token);
      final isConnected = await SystemService.testConnection(updatedConfig).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          developer.log('$_logPrefix: Connection test timed out', name: 'AppProvider');
          return false;
        },
      );
      if (isConnected) {
        var finalConfig = updatedConfig;
        final firebaseConfig = await SystemService.getFirebaseConfig(updatedConfig);
        if (firebaseConfig != null) {
          finalConfig = updatedConfig.copyWith(firebaseConfig: firebaseConfig);
          developer.log('$_logPrefix: Loaded dynamic Firebase config from server', name: 'AppProvider');
          
          try {
            // Dynamically initialize Firebase if not already initialized
            if (Firebase.apps.isEmpty) {
              await Firebase.initializeApp(
                options: FirebaseOptions(
                  apiKey: firebaseConfig['apiKey'] ?? '',
                  appId: firebaseConfig['appId'] ?? '',
                  messagingSenderId: firebaseConfig['messagingSenderId'] ?? '',
                  projectId: firebaseConfig['projectId'] ?? '',
                  storageBucket: firebaseConfig['storageBucket'] ?? '',
                ),
              );
              developer.log('$_logPrefix: Dynamically initialized Firebase', name: 'AppProvider');
            }
          } catch (e) {
            developer.log('$_logPrefix: Firebase dynamic initialization info: $e', name: 'AppProvider');
          }
        }
        _connectionConfig = finalConfig;
        _isConnected = true;
        _consecutiveFailures = 0;
        _error = null;
        developer.log('$_logPrefix: Successfully connected to Docker daemon', name: 'AppProvider');
        await Future.wait([
          fetchSystemData(),
          fetchContainersAndResourceStats(),
          fetchSystemMetrics(),
        ]);
        
        _autoRegisterNotifications(_connectionConfig!);

        if (persist) {
          await saveConnectionConfig(_connectionConfig!);
        }

        // Add to history if not already present
        if (!_connectionHistory.contains(config.uri)) {
          _connectionHistory.insert(0, config.uri);
          if (_connectionHistory.length > 10) {
            _connectionHistory.removeLast();
          }
          await ConnectionStorageService.saveConnectionHistory(_connectionHistory);
        } else {
          // Move to front
          _connectionHistory.remove(config.uri);
          _connectionHistory.insert(0, config.uri);
          await ConnectionStorageService.saveConnectionHistory(_connectionHistory);
        }

      } else {
        _isConnected = false;
        _consecutiveFailures++;
        _error = AppError(
          message:
              'Failed to connect to Docker daemon. Please check your connection settings and ensure the Docker daemon is running.',
        );
        _checkAutoLogout();
        developer.log('$_logPrefix: Connection test failed', name: 'AppProvider');
      }
    } catch (e) {
      _isConnected = false;
      _consecutiveFailures++;
      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Cannot reach the Docker daemon. Please check:\n• The URI is correct\n• The Docker daemon is running\n• Network connectivity';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Connection timed out. Please check:\n• The URI is correct\n• Network connectivity\n• Firewall settings';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage =
            'Connection refused. Please check:\n• The Docker daemon is running\n• The port is correct\n• Authentication settings';
      } else {
        errorMessage = 'Connection error: $e';
      }
      _error = AppError(message: errorMessage);
      _checkAutoLogout();
      developer.log('$_logPrefix: Connection error: $e', name: 'AppProvider');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _checkAutoLogout() {
    if (_consecutiveFailures >= maxFailuresBeforeLogout) {
      logout();
      _error = AppError(message: AppStrings.autoLogoutMessage);
      _consecutiveFailures = 0;
      notifyListeners();
    }
  }

  Future<void> fetchSystemData() async {
    if (_connectionConfig == null || !_isConnected) {
      developer.log('$_logPrefix: Cannot fetch data - not connected', name: 'AppProvider');
      return;
    }
    if (_systemInfo == null && _resourceStats == null) {
      _isLoadingData = true;
      notifyListeners();
    }
    try {
      developer.log('$_logPrefix: Fetching system data', name: 'AppProvider');
      _systemInfo = await SystemService.getSystemInfo(_connectionConfig!);
      developer.log('$_logPrefix: Successfully fetched system data', name: 'AppProvider');
    } catch (e) {
      developer.log('$_logPrefix: Error fetching system data: $e', name: 'AppProvider');
      if (!_handleAuthError(e, context: 'fetchSystemData')) {
        _error = AppError(message: 'Failed to fetch system data: $e');
      }
      _isLoadingData = false;
      notifyListeners();
    } finally {
      if (_isLoadingData) {
        _isLoadingData = false;
        notifyListeners();
      }
    }
    // Fetch infra counts in background
    _fetchInfraCounts();
  }

  Future<void> _fetchInfraCounts() async {
    if (_connectionConfig == null || !_isConnected) return;
    try {
      final (vols, _) = await VolumeService.getVolumes(_connectionConfig!);
      if (vols != null) {
        _volumeCount = vols.length;
        notifyListeners();
      }
    } catch (_) {}
    try {
      final (nets, _) = await NetworkService.getNetworks(_connectionConfig!);
      if (nets != null) {
        _networkCount = nets.length;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshDetailedStats() async {
    if (_connectionConfig == null || !_isConnected || _resourceStats == null) return;
    try {
      final newStats = await ResourceStatsUtils.refreshDetailedStats(_resourceStats, _connectionConfig);
      _resourceStats = newStats;
      developer.log('$_logPrefix: Refreshed detailed stats', name: 'AppProvider');
      notifyListeners();
    } catch (e) {
      developer.log('$_logPrefix: Error refreshing detailed stats: $e', name: 'AppProvider');
    }
  }

  void disconnect() {
    _isConnected = false;
    _connectionConfig = null;
    _error = null;
    _systemInfo = null;
    _resourceStats = null;
    _systemMetrics = null;
    _metricsHistory = [];
    developer.log('$_logPrefix: Disconnected from Docker daemon', name: 'AppProvider');
    notifyListeners();
  }

  Future<void> logout() async {
    await ConnectionStorageService.deleteConnectionConfig();
    disconnect();
    _connectionConfig = null;
    developer.log('$_logPrefix: Logged out and cleared saved configuration', name: 'AppProvider');
    
    // Clear Firebase app instance to allow dynamic config on next server connection with different credentials/options
    try {
      if (Firebase.apps.isNotEmpty) {
        await Firebase.app().delete();
        developer.log('$_logPrefix: Cleared Firebase app instance for secure logout', name: 'AppProvider');
      }
    } catch (e) {
      developer.log('$_logPrefix: Firebase deletion info: $e', name: 'AppProvider');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> testAndReconnect() async {
    if (_connectionConfig == null) {
      _error = AppError(message: 'No saved connection configuration found.');
      notifyListeners();
      return;
    }

    developer.log('$_logPrefix: Testing connection and attempting to reconnect',
        name: 'AppProvider');

    try {
      final isConnected = await SystemService.testConnection(_connectionConfig!).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          developer.log('$_logPrefix: Reconnection test timed out', name: 'AppProvider');
          return false;
        },
      );

      if (isConnected) {
        _isConnected = true;
        _error = null;
        developer.log('$_logPrefix: Reconnection successful', name: 'AppProvider');
        await Future.wait([
          fetchSystemData(),
          fetchContainersAndResourceStats(),
          fetchSystemMetrics(),
        ]);
        _autoRegisterNotifications(_connectionConfig!);
        notifyListeners();
      } else {
        _error = AppError(message: 'Reconnection failed. The Docker daemon is still unreachable.');
        notifyListeners();
      }
    } catch (e) {
      developer.log('$_logPrefix: Reconnection error: $e', name: 'AppProvider');
      if (!_handleAuthError(e, context: 'testAndReconnect')) {
        _error = AppError(message: 'Reconnection failed: $e');
      }
      notifyListeners();
    }
  }

  Future<void> connectAndPersist(ConnectionConfig config,
      {String? username, String? password}) async {
    await connect(config, username: username, password: password, persist: true);
  }

  Future<void> connectWithoutPersistence(ConnectionConfig config,
      {String? username, String? password}) async {
    await connect(config, username: username, password: password, persist: false);
  }

  Future<void> fetchContainersAndResourceStats() async {
    if (_connectionConfig == null || !_isConnected) return;
    try {
      final containers = await ContainerService.getContainers(_connectionConfig!);
      _resourceStats = ResourceStatsUtils.calculateBasicResourceStatsFromContainers(containers);
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching containers/resource stats: $e', name: 'AppProvider');
      if (!_handleAuthError(e, context: 'fetchContainersAndResourceStats')) {
        _error = AppError(message: 'Failed to fetch container stats: $e');
      }
    }
  }

  Future<void> fetchSystemMetrics() async {
    if (_connectionConfig == null || !_isConnected) return;
    try {
      final metrics = await SystemService.getSystemMetrics(_connectionConfig!);
      _systemMetrics = metrics;
      _metricsHistory = List<Map<String, dynamic>>.from(metrics['history'] ?? []);
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching system metrics: $e', name: 'AppProvider');
      _handleAuthError(e, context: 'fetchSystemMetrics');
    }
  }
  Future<void> _autoRegisterNotifications(ConnectionConfig config) async {
    try {
      developer.log('$_logPrefix: Auto-registering notifications for ${config.uri}', name: 'AppProvider');
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      final protocol = config.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${config.uri}';
      
      // Load saved preferences before registering
      await notificationService.loadPreferences(baseUrl);
      
      final prefs = await SharedPreferences.getInstance();
      final masterEnabled = prefs.getBool('notificationsEnabled') ?? true;
      
      if (!masterEnabled) {
         developer.log('$_logPrefix: Notifications disabled globally, unregistering on startup', name: 'AppProvider');
         await notificationService.unregisterFromNotifications(
           baseUrl: baseUrl,
           token: config.token ?? '',
         );
         return;
      }
      
      await notificationService.registerForNotifications(
        baseUrl: baseUrl,
        token: config.token ?? '',
      );
      developer.log('$_logPrefix: Auto-registered for notifications successfully', name: 'AppProvider');
    } catch (e) {
      developer.log('$_logPrefix: Failed to auto-register for notifications: $e', name: 'AppProvider');
    }
  }

  Future<void> removeHistoryEntry(String uri) async {
    _connectionHistory.remove(uri);
    await ConnectionStorageService.saveConnectionHistory(_connectionHistory);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _connectionHistory.clear();
    await ConnectionStorageService.deleteConnectionHistory();
    notifyListeners();
  }
}