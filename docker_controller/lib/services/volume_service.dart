import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import 'docker_service.dart';
import '../models/app_error.dart';

class VolumeResult {
  final bool success;
  final AppError? error;
  VolumeResult({required this.success, this.error});
}

class VolumeService {
  static const String _logPrefix = 'myapp';

  static Future<(List<Map<String, dynamic>>?, AppError?)> getVolumes(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/volumes');
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['Volumes'] as List;
        developer.log('$_logPrefix: Successfully fetched \${data.length} volumes', name: 'VolumeService');
        return (data.cast<Map<String, dynamic>>(), null);
      } else {
        final error = AppError(message: 'Failed to fetch volumes', type: 'http', stackTrace: StackTrace.current);
        developer.log('$_logPrefix: Failed to fetch volumes - Status: \${response.statusCode}', name: 'VolumeService');
        return (null, error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error fetching volumes: $e', type: 'exception', stackTrace: st);
      developer.log('$_logPrefix: Error fetching volumes: $e', name: 'VolumeService');
      return (null, error);
    }
  }

  static Future<VolumeResult> createVolume(
    ConnectionConfig config,
    String name, {
    String driver = 'local',
    Map<String, String>? driverOpts,
    Map<String, String>? labels,
  }) async {
    try {
      final body = <String, dynamic>{'Name': name, 'Driver': driver};
      if (driverOpts != null && driverOpts.isNotEmpty) body['DriverOpts'] = driverOpts;
      if (labels != null && labels.isNotEmpty) body['Labels'] = labels;
      final response = await DockerService.makePostRequest(
        config,
        '/volumes/create',
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        developer.log('\u001b[32m\u001b[1m\u001b[4m$_logPrefix: Successfully created volume $name', name: 'VolumeService');
        return VolumeResult(success: true);
      } else {
        final error = AppError(message: 'Failed to create volume $name', type: 'http', stackTrace: StackTrace.current);
        developer.log('\u001b[31m$_logPrefix: Failed to create volume $name - Status: \u001b[0m${response.statusCode}, Body: ${response.body}', name: 'VolumeService');
        return VolumeResult(success: false, error: error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error creating volume $name: $e', type: 'exception', stackTrace: st);
      developer.log('\u001b[31m$_logPrefix: Error creating volume $name: $e', name: 'VolumeService');
      return VolumeResult(success: false, error: error);
    }
  }

  static Future<VolumeResult> removeVolume(ConnectionConfig config, String name) async {
    try {
      final response = await DockerService.makeDeleteRequest(config, '/volumes/$name');
      if (response.statusCode == 204) {
        developer.log('\u001b[32m$_logPrefix: Successfully removed volume $name', name: 'VolumeService');
        return VolumeResult(success: true);
      } else {
        final error = AppError(message: 'Failed to remove volume $name', type: 'http', stackTrace: StackTrace.current);
        developer.log('\u001b[31m$_logPrefix: Failed to remove volume $name - Status: ${response.statusCode}, Body: ${response.body}', name: 'VolumeService');
        return VolumeResult(success: false, error: error);
      }
    } catch (e, st) {
      final error = AppError(message: 'Error removing volume $name: $e', type: 'exception', stackTrace: st);
      developer.log('\u001b[31m$_logPrefix: Error removing volume $name: $e', name: 'VolumeService');
      return VolumeResult(success: false, error: error);
    }
  }
} 