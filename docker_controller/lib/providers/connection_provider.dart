import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import '../services/system_service.dart';
import '../models/app_error.dart';


class ConnectionProvider extends ChangeNotifier {
  static const String _logPrefix = 'myapp';

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isInitializing = true;
  ConnectionConfig? _connectionConfig;
  AppError? _error;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isInitializing => _isInitializing;
  ConnectionConfig? get connectionConfig => _connectionConfig;
  AppError? get error => _error;

  ConnectionProvider() {
    _loadConnectionConfig();
  }

  Future<void> _loadConnectionConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConfig = prefs.getString('connectionConfig');
    if (savedConfig != null) {
      try {
        final configMap = json.decode(savedConfig) as Map<String, dynamic>;
        _connectionConfig = ConnectionConfig.fromJson(configMap);

        if (_connectionConfig != null) {
          await connect(_connectionConfig!);
        }
      } catch (e) {
        developer.log('$_logPrefix: Error loading saved connection config: $e', name: 'ConnectionProvider');
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> setConnectionConfig(ConnectionConfig config) async {
    _connectionConfig = config;
    final prefs = await SharedPreferences.getInstance();
    final configString = json.encode(config.toJson());
    await prefs.setString('connectionConfig', configString);

    notifyListeners();
  }

  Future<void> connect(ConnectionConfig config) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();
    try {
      final isConnected = await SystemService.testConnection(config).timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (isConnected) {
        final firebaseConfig = await SystemService.getFirebaseConfig(config);
        if (firebaseConfig != null) {
          config = config.copyWith(firebaseConfig: firebaseConfig);
        }
        await setConnectionConfig(config);
        _isConnected = true;
      }
 else {
        _isConnected = false;
        _error = AppError(
          message: 'Failed to connect to Docker daemon. Please check your connection settings and ensure the Docker daemon is running.',
        );
      }
    } catch (e) {
      _isConnected = false;
      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot reach the Docker daemon. Please check:\n• The URI is correct\n• The Docker daemon is running\n• Network connectivity';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timed out. Please check:\n• The URI is correct\n• Network connectivity\n• Firewall settings';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Connection refused. Please check:\n• The Docker daemon is running\n• The port is correct\n• Authentication settings';
      } else {
        errorMessage = 'Connection error: $e';
      }
      _error = AppError(message: errorMessage);
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void disconnect() {
    _isConnected = false;
    _connectionConfig = null;
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connectionConfig');
    disconnect();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 