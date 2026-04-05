import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import 'docker_service.dart';

class SystemService {
  static const String _logPrefix = 'myapp';

  static Future<Map<String, dynamic>?> getSystemInfo(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/info');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('$_logPrefix: Successfully fetched system info', name: 'SystemService');
        return data;
      } else {
        developer.log('$_logPrefix: Failed to fetch system info - Status: ${response.statusCode}', name: 'SystemService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching system info: $e', name: 'SystemService');
      return null;
    }
  }

  static Future<bool> testConnection(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/version');
      if (response.statusCode == 200) {
        developer.log('$_logPrefix: Connection test successful', name: 'SystemService');
        return true;
      } else {
        developer.log('$_logPrefix: Connection test failed - Status: ${response.statusCode}', name: 'SystemService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Connection test error: $e', name: 'SystemService');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getFirebaseConfig(ConnectionConfig config) async {
    try {

      final response = await DockerService.makeRequest(config, '/config/firebase');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        developer.log('$_logPrefix: Successfully fetched Firebase config', name: 'SystemService');
        return data;
      } else {
        developer.log('$_logPrefix: Failed to fetch Firebase config - Status: ${response.statusCode}', name: 'SystemService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching Firebase config: $e', name: 'SystemService');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getSystemMetrics(ConnectionConfig config, [String window = '30m']) async {

    final response = await DockerService.makeRequest(config, '/system/metrics?window=$window');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: Failed to fetch system metrics: ${response.body}');
    }
  }
} 