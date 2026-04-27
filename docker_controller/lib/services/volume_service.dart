import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/docker_volume.dart';
import 'docker_service.dart';

class VolumeService {
  VolumeService(this._dockerService);

  final DockerService _dockerService;

  Future<Result<List<DockerVolume>, AppError>> getVolumes() async {
    final result = await _dockerService.get<Map<String, dynamic>>('/volumes');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final volumesData = response.data!['Volumes'] as List;
          final volumes = volumesData
              .map((item) => DockerVolume.fromJson(item as Map<String, dynamic>))
              .toList();
          return Success(volumes);
        }
        return Failure(AppError(message: 'Failed to fetch volumes: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> createVolume(
    String name, {
    String driver = 'local',
    Map<String, String>? driverOpts,
    Map<String, String>? labels,
  }) async {
    final data = <String, dynamic>{'Name': name, 'Driver': driver};
    if (driverOpts != null && driverOpts.isNotEmpty) {
      data['DriverOpts'] = driverOpts;
    }
    if (labels != null && labels.isNotEmpty) {
      data['Labels'] = labels;
    }

    final result = await _dockerService.post('/volumes/create', data: data);
    return result.fold(
      (response) {
        if (response.statusCode == 201) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to create volume: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> removeVolume(String name) async {
    final result = await _dockerService.delete('/volumes/$name');
    return result.fold(
      (response) {
        if (response.statusCode == 204) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to remove volume: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }
}
