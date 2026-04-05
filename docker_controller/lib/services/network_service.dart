import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import 'docker_service.dart';
import '../models/app_error.dart';

class NetworkResult {
  final bool success;
  final AppError? error;
  NetworkResult({required this.success, this.error});
}

class NetworkService {
  static const String _logPrefix = 'myapp';

  static Future<(List<Map<String, dynamic>>?, AppError?)> getNetworks(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/networks');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        developer.log('$_logPrefix: Successfully fetched \${data.length} networks', name: 'NetworkService');
        return (data.cast<Map<String, dynamic>>(), null);
      } else {
        final error = AppError(message: 'Failed to fetch networks', type: 'http', stackTrace: StackTrace.current);
        developer.log('$_logPrefix: Failed to fetch networks - Status: \${response.statusCode}', name: 'NetworkService');
        return (null, error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error fetching networks: $e', type: 'exception', stackTrace: st);
      developer.log('$_logPrefix: Error fetching networks: $e', name: 'NetworkService');
      return (null, error);
    }
  }

  static Future<NetworkResult> createNetwork(
    ConnectionConfig config,
    String name, {
    String driver = 'bridge',
    Map<String, String>? options,
    Map<String, String>? labels,
    Map<String, dynamic>? ipam,
  }) async {
    try {
      final body = <String, dynamic>{'Name': name, 'Driver': driver};
      if (options != null && options.isNotEmpty) body['Options'] = options;
      if (labels != null && labels.isNotEmpty) body['Labels'] = labels;
      if (ipam != null && ipam.isNotEmpty) body['IPAM'] = ipam;
      final response = await DockerService.makePostRequest(
        config,
        '/networks/create',
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        developer.log('\u001b[32m$_logPrefix: Successfully created network $name', name: 'NetworkService');
        return NetworkResult(success: true);
      } else {
        final error = AppError(message: 'Failed to create network $name', type: 'http', stackTrace: StackTrace.current);
        developer.log('\u001b[31m$_logPrefix: Failed to create network $name - Status: ${response.statusCode}, Body: ${response.body}', name: 'NetworkService');
        return NetworkResult(success: false, error: error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error creating network $name: $e', type: 'exception', stackTrace: st);
      developer.log('\u001b[31m$_logPrefix: Error creating network $name: $e', name: 'NetworkService');
      return NetworkResult(success: false, error: error);
    }
  }

  static Future<NetworkResult> removeNetwork(ConnectionConfig config, String name) async {
    try {
      final response = await DockerService.makeDeleteRequest(config, '/networks/$name');
      if (response.statusCode == 204) {
        developer.log('\u001b[32m$_logPrefix: Successfully removed network $name', name: 'NetworkService');
        return NetworkResult(success: true);
      } else {
        final error = AppError(message: 'Failed to remove network $name', type: 'http', stackTrace: StackTrace.current);
        developer.log('\u001b[31m$_logPrefix: Failed to remove network $name - Status: ${response.statusCode}, Body: ${response.body}', name: 'NetworkService');
        return NetworkResult(success: false, error: error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error removing network $name: $e', type: 'exception', stackTrace: st);
      developer.log('\u001b[31m$_logPrefix: Error removing network $name: $e', name: 'NetworkService');
      return NetworkResult(success: false, error: error);
    }
  }

  static Future<Map<String, dynamic>?> inspectNetwork(ConnectionConfig config, String idOrName) async {
    try {
      final response = await DockerService.makeRequest(config, '/networks/$idOrName');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        developer.log('$_logPrefix: Successfully fetched network details for $idOrName', name: 'NetworkService');
        return data;
      } else {
        developer.log('$_logPrefix: Failed to fetch network details for $idOrName - Status: ${response.statusCode}', name: 'NetworkService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching network details for $idOrName: $e', name: 'NetworkService');
      return null;
    }
  }
} 