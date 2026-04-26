import 'dart:developer' as developer;

import '../models/docker_volume.dart';
import 'docker_service.dart';

class VolumeService {
  VolumeService(this._dockerService);

  final DockerService _dockerService;
  static const String _logPrefix = 'orca';

  Future<List<DockerVolume>> getVolumes() async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>(
        '/volumes',
      );
      if (response.statusCode == 200 && response.data != null) {
        final volumes = response.data!['Volumes'] as List;
        return volumes
            .map((item) => DockerVolume.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch volumes: ${response.statusCode}');
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching volumes: $e',
        name: 'VolumeService',
      );
      rethrow;
    }
  }

  Future<bool> createVolume(
    String name, {
    String driver = 'local',
    Map<String, String>? driverOpts,
    Map<String, String>? labels,
  }) async {
    try {
      final data = <String, dynamic>{'Name': name, 'Driver': driver};
      if (driverOpts != null && driverOpts.isNotEmpty) {
        data['DriverOpts'] = driverOpts;
      }
      if (labels != null && labels.isNotEmpty) {
        data['Labels'] = labels;
      }

      final response = await _dockerService.post('/volumes/create', data: data);
      return response.statusCode == 201;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error creating volume $name: $e',
        name: 'VolumeService',
      );
      return false;
    }
  }

  Future<bool> removeVolume(String name) async {
    try {
      final response = await _dockerService.delete('/volumes/$name');
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error removing volume $name: $e',
        name: 'VolumeService',
      );
      return false;
    }
  }
}
