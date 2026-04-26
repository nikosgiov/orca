import 'dart:developer' as developer;

import '../core/di/service_locator.dart';
import '../models/docker_container.dart';
import 'docker_service.dart';
import 'image_service.dart';

/// Service responsible for managing Docker containers.
/// Handles operations such as listing, starting, stopping, and creating containers.
class ContainerService {
  ContainerService({
    DockerService? dockerService,
    ImageService? imageService,
  })  : _dockerService = dockerService ?? getIt<DockerService>(),
        _imageService = imageService ?? getIt<ImageService>();

  final DockerService _dockerService;
  final ImageService _imageService;
  static const String _logPrefix = 'orca';

  /// Fetches all containers (both running and stopped) from the Docker daemon.
  Future<List<DockerContainer>> getContainers() async {
    try {
      final response = await _dockerService.get<List<dynamic>>(
        '/containers/json?all=true',
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map(
              (item) => DockerContainer.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to fetch containers: ${response.statusCode}');
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching containers: $e',
        name: 'ContainerService',
      );
      rethrow;
    }
  }

  /// Fetches detailed information for a specific container by its ID or name.
  Future<DockerContainer?> getContainerInfo(String containerId) async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>(
        '/containers/$containerId/json',
      );
      if (response.statusCode == 200 && response.data != null) {
        return DockerContainer.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching container info: $e',
        name: 'ContainerService',
      );
      return null;
    }
  }

  /// Fetches real-time statistics for a specific container.
  Future<Map<String, dynamic>?> getContainerStats(String containerId) async {
    try {
      final response = await _dockerService.get<Map<String, dynamic>>(
        '/containers/$containerId/stats?stream=false',
      );
      return response.data;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching container stats: $e',
        name: 'ContainerService',
      );
      return null;
    }
  }

  /// Fetches logs for a specific container.
  /// [tail] specifies the number of lines to show from the end of the logs.
  /// [since] specifies a timestamp to show logs starting from that time.
  Future<String?> getContainerLogs(
    String containerId, {
    int tail = 200,
    String? since,
  }) async {
    try {
      String path = '/containers/$containerId/logs?stdout=true&stderr=true';
      if (tail > 0) {
        path += '&tail=$tail';
      } else {
        path += '&tail=all';
      }
      if (since != null) {
        path += '&since=$since';
      }

      final response = await _dockerService.get<String>(path);
      return response.data;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching container logs: $e',
        name: 'ContainerService',
      );
      return null;
    }
  }

  /// Starts a stopped container.
  Future<bool> startContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/start',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error starting container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Stops a running container.
  Future<bool> stopContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/stop',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error stopping container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Pauses a running container.
  Future<bool> pauseContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/pause',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error pausing container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Resumes a paused container.
  Future<bool> resumeContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/unpause',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error resuming container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Restarts a container.
  Future<bool> restartContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/restart',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error restarting container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Kills a running container (sends SIGKILL).
  Future<bool> killContainer(String containerId) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/kill',
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error killing container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Removes a container from the Docker daemon.
  Future<bool> removeContainer(String containerId) async {
    try {
      final response = await _dockerService.delete('/containers/$containerId');
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error removing container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Renames an existing container.
  Future<bool> renameContainer(String containerId, String newName) async {
    try {
      final response = await _dockerService.post(
        '/containers/$containerId/rename',
        queryParameters: {'name': newName},
      );
      return response.statusCode == 204;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error renaming container $containerId: $e',
        name: 'ContainerService',
      );
      return false;
    }
  }

  /// Creates a new container with the specified [containerConfig].
  /// Returns the ID of the created container, or null if creation failed.
  Future<String?> createContainer(Map<String, dynamic> containerConfig) async {
    try {
      String? containerName;
      if (containerConfig.containsKey('name')) {
        containerName = containerConfig['name'] as String?;
        containerConfig.remove('name');
      }

      final imageName = containerConfig['Image'] as String?;
      if (imageName != null) {
        String image, tag;
        if (imageName.contains(':')) {
          final parts = imageName.split(':');
          image = parts[0];
          tag = parts[1];
        } else {
          image = imageName;
          tag = 'latest';
        }

        final imageExists = await _imageService.ensureImageExists(image, tag);
        if (!imageExists) {
          return null;
        }
      }

      final response = await _dockerService.post(
        '/containers/create',
        queryParameters: containerName != null ? {'name': containerName} : null,
        data: containerConfig,
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data['Id'] as String?;
      }
      return null;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error creating container: $e',
        name: 'ContainerService',
      );
      return null;
    }
  }

  /// Creates and immediately starts a new container.
  Future<String?> createAndStartContainer(
    Map<String, dynamic> containerConfig,
  ) async {
    final containerId = await createContainer(containerConfig);
    if (containerId != null) {
      final started = await startContainer(containerId);
      if (started) {
        return containerId;
      }
    }
    return null;
  }
}
