import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/docker_network.dart';
import 'docker_service.dart';

class NetworkService {
  NetworkService(this._dockerService);

  final DockerService _dockerService;

  Future<Result<List<DockerNetwork>, AppError>> getNetworks() async {
    final result = await _dockerService.get<List<dynamic>>('/networks');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final networks = response.data!
              .map((item) => DockerNetwork.fromJson(item as Map<String, dynamic>))
              .toList();
          return Success(networks);
        }
        return Failure(AppError(message: 'Failed to fetch networks: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> createNetwork(
    String name, {
    String driver = 'bridge',
    Map<String, String>? options,
    Map<String, String>? labels,
    Map<String, dynamic>? ipam,
  }) async {
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

    final result = await _dockerService.post(
      '/networks/create',
      data: data,
    );
    return result.fold(
      (response) {
        if (response.statusCode == 201) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to create network: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> removeNetwork(String name) async {
    final result = await _dockerService.delete('/networks/$name');
    return result.fold(
      (response) {
        if (response.statusCode == 204) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to remove network: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<DockerNetwork, AppError>> inspectNetwork(String idOrName) async {
    final result = await _dockerService.get<Map<String, dynamic>>(
      '/networks/$idOrName',
    );
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(DockerNetwork.fromJson(response.data!));
        }
        return Failure(AppError(message: 'Network not found: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }
}
