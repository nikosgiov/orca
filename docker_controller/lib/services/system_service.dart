import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'docker_service.dart';

/// Service responsible for fetching system-wide information and metrics from the Docker daemon.
class SystemService {
  SystemService(this._dockerService);

  final DockerService _dockerService;

  /// Fetches general information about the Docker daemon and the host system.
  Future<Result<Map<String, dynamic>, AppError>> getSystemInfo() async {
    final result = await _dockerService.get<Map<String, dynamic>>('/info');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(response.data!);
        }
        return Failure(AppError(message: 'Failed to fetch system info: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Tests the connection to the Docker daemon by fetching its version.
  Future<Result<bool, AppError>> testConnection() async {
    final result = await _dockerService.get('/version');
    return result.fold(
      (response) => Success(response.statusCode == 200),
      (failure) => Failure(failure),
    );
  }

  /// Fetches Firebase configuration from the Docker daemon if available.
  Future<Result<Map<String, dynamic>, AppError>> getFirebaseConfig() async {
    final result = await _dockerService.get<Map<String, dynamic>>('/config/firebase');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(response.data!);
        }
        return Failure(AppError(message: 'Failed to fetch firebase config: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  /// Fetches system metrics (CPU, Memory, etc.) for a given time [window].
  Future<Result<Map<String, dynamic>, AppError>> getSystemMetrics([String window = '30m']) async {
    final result = await _dockerService.get<Map<String, dynamic>>(
      '/system/metrics',
      queryParameters: {'window': window},
    );
    
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          return Success(response.data!);
        }
        return Failure(AppError(message: 'Failed to fetch system metrics: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }
}
