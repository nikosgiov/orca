import 'dart:developer' as developer;

import '../models/docker_network.dart';
import 'docker_service.dart';

class NetworkService {
  NetworkService(this._dockerService);

  final DockerService _dockerService;
  static const String _logPrefix = 'orca';

  Future<List<DockerNetwork>> getNetworks() async {
    try {
      final response = await _dockerService.get<List<dynamic>>('/networks');
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((item) => DockerNetwork.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch networks: ${response.statusCode}');
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching networks: $e',
        name: 'NetworkService',
      );
      rethrow;
    }
  }

  Future<bool> createNetwork(
    String name, {
    String driver = 'bridge',
    Map<String, String>? options,
    Map<String, String>? labels,
    Map<String, dynamic>? ipam,
  }) async {
    try {
      final data = <String, dynamic>{'Name': name, 'Driver': driver};
      if (options != null && options.isNotEmpty) {
        data['Options'] = options;
      }
      if (labels != null && labels.isNotEmpty) {
        data['Labels'] = labels;
      }
      if (ipam != null && ipam.isNotEmpty) {
        data['IPAM'] = ipam;
      }

      final response = await _dockerService.post(
        '/networks/create',
        data: data,
      );
      return response.statusCode == 201;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error creating network $name: $e',
        name: 'NetworkService',
      );
      return false;
    }
  }

  Future<bool> removeNetwork(String name) async {
    try {
      final response = await _dockerService.delete('/networks/$name');
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error removing network $name: $e',
        name: 'NetworkService',
      );
      return false;
    }
  }

  Future<DockerNetwork?> inspectNetwork(String idOrName) async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>(
        '/networks/$idOrName',
      );
      if (response.statusCode == 200 && response.data != null) {
        return DockerNetwork.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching network details for $idOrName: $e',
        name: 'NetworkService',
      );
      return null;
    }
  }
}
