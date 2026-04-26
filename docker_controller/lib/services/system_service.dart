import 'dart:developer' as developer;

import 'docker_service.dart';

/// Service responsible for fetching system-wide information and metrics from the Docker daemon.
class SystemService {
  SystemService(this._dockerService);

  final DockerService _dockerService;
  static const String _logPrefix = 'orca';

  /// Fetches general information about the Docker daemon and the host system.
  Future<Map<String, dynamic>?> getSystemInfo() async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>('/info');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching system info: $e',
        name: 'SystemService',
      );
      return null;
    }
  }

  /// Tests the connection to the Docker daemon by fetching its version.
  Future<bool> testConnection() async {
    try {
      final response = await _dockerService.get('/version');
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        '$_logPrefix: Connection test error: $e',
        name: 'SystemService',
      );
      return false;
    }
  }

  /// Fetches Firebase configuration from the Docker daemon if available.
  Future<Map<String, dynamic>?> getFirebaseConfig() async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>(
        '/config/firebase',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching Firebase config: $e',
        name: 'SystemService',
      );
      return null;
    }
  }

  /// Fetches system metrics (CPU, Memory, etc.) for a given time [window].
  Future<Map<String, dynamic>> getSystemMetrics([String window = '30m']) async {
    final response = await _dockerService.get<Map<String, dynamic>>(
      '/system/metrics',
      queryParameters: {'window': window},
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data!;
    }
    throw Exception('Failed to fetch system metrics: ${response.statusCode}');
  }
}
