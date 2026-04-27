import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'docker_service.dart';
import 'image_service.dart';

/// Service responsible for managing Docker containers.
class ContainerService {
  ContainerService({
    required DockerService dockerService,
    required ImageService imageService,
  })  : _dockerService = dockerService,
        _imageService = imageService;

  final DockerService _dockerService;
  final ImageService _imageService;

  /// Fetches all containers from the Docker daemon.
  Future<Result<List<DockerContainer>, AppError>> getContainers() async {
    final result = await _dockerService.get<List<dynamic>>(
      '/containers/json?all=true',
    );

    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final containers = response.data!
              .map((item) => DockerContainer.fromJson(item as Map<String, dynamic>))
              .toList();
          return Success(containers);
        }
        return Failure(AppError(message: 'Unexpected status code: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Fetches detailed information for a specific container.
  Future<Result<DockerContainer, AppError>> getContainerInfo(String containerId) async {
    final result = await _dockerService.get<Map<String, dynamic>>(
      '/containers/$containerId/json',
    );

    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(DockerContainer.fromJson(response.data!));
        }
        return Failure(AppError(message: 'Container not found or error: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Fetches real-time statistics for a specific container.
  Future<Result<Map<String, dynamic>, AppError>> getContainerStats(String containerId) async {
    final result = await _dockerService.get<Map<String, dynamic>>(
      '/containers/$containerId/stats?stream=false',
    );

    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(response.data!);
        }
        return Failure(AppError(message: 'Failed to fetch stats: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Fetches logs for a specific container.
  Future<Result<String, AppError>> getContainerLogs(
    String containerId, {
    int tail = 200,
    String? since,
  }) async {
    final Map<String, dynamic> queryParams = {
      'stdout': true,
      'stderr': true,
      'tail': tail > 0 ? tail : 'all',
    };
    
    if (since != null) {
      final secondsSince = int.tryParse(since);
      if (secondsSince != null) {
        final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - secondsSince;
        queryParams['since'] = timestamp;
      }
    }

    final result = await _dockerService.get<String>(
      '/containers/$containerId/logs',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.plain),
    );

    return result.fold(
      (response) => Success(response.data ?? ''),
      (failure) => Failure(failure),
    );
  }

  /// Starts a stopped container.
  Future<Result<bool, AppError>> startContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/start');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Stops a running container.
  Future<Result<bool, AppError>> stopContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/stop');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Pauses a running container.
  Future<Result<bool, AppError>> pauseContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/pause');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Resumes a paused container.
  Future<Result<bool, AppError>> resumeContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/unpause');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Restarts a container.
  Future<Result<bool, AppError>> restartContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/restart');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Kills a running container.
  Future<Result<bool, AppError>> killContainer(String containerId) async {
    final result = await _dockerService.post('/containers/$containerId/kill');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Removes a container.
  Future<Result<bool, AppError>> removeContainer(String containerId) async {
    final result = await _dockerService.delete('/containers/$containerId');
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Renames an existing container.
  Future<Result<bool, AppError>> renameContainer(String containerId, String newName) async {
    final result = await _dockerService.post(
      '/containers/$containerId/rename',
      queryParameters: {'name': newName},
    );
    return result.fold(
      (response) => Success(response.statusCode == 204),
      (failure) => Failure(failure),
    );
  }

  /// Creates a new container.
  Future<Result<String, AppError>> createContainer(Map<String, dynamic> containerConfig) async {
    final config = Map<String, dynamic>.from(containerConfig);
    String? containerName;
    if (config.containsKey('name')) {
      containerName = config['name'] as String?;
      config.remove('name');
    }

    final imageName = config['Image'] as String?;
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
        return Failure(AppError(message: 'Failed to ensure image $imageName exists.'));
      }
    }

    final result = await _dockerService.post(
      '/containers/create',
      queryParameters: containerName != null ? {'name': containerName} : null,
      data: config,
    );

    return result.fold(
      (response) {
        if (response.statusCode == 201 && response.data != null) {
          return Success(response.data['Id'] as String);
        }
        return Failure(AppError(message: 'Failed to create container: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Creates and starts a container.
  Future<Result<String, AppError>> createAndStartContainer(
    Map<String, dynamic> containerConfig,
  ) async {
    final createResult = await createContainer(containerConfig);
    
    return createResult.fold(
      (containerId) async {
        final startResult = await startContainer(containerId);
        return startResult.fold(
          (started) => started 
              ? Success(containerId) 
              : Failure(AppError(message: 'Container created but failed to start.')),
          (failure) => Failure(failure),
        );
      },
      (failure) => Failure(failure),
    );
  }
}
