import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/compose_project.dart';
import 'docker_service.dart';

class ComposeService {
  ComposeService(this._dockerService);

  final DockerService _dockerService;

  Future<Result<List<ComposeProject>, AppError>> getProjects() async {
    final result = await _dockerService.get<List<dynamic>>(
      '/compose/projects',
    );
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final projects = response.data!
              .map((json) => ComposeProject.fromJson(json as Map<String, dynamic>))
              .toList();
          return Success(projects);
        }
        return Failure(AppError(message: 'Failed to fetch compose projects: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> registerProject(
    String name,
    String workingDir,
    List<String> configFiles,
  ) async {
    final result = await _dockerService.post(
      '/compose/register',
      data: {
        'name': name,
        'working_dir': workingDir,
        'config_files': configFiles,
      },
    );
    return result.fold(
      (response) => Success(response.statusCode == 200),
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> unregisterProject(String name) async {
    final result = await _dockerService.delete('/compose/register/$name');
    return result.fold(
      (response) => Success(response.statusCode == 200),
      (failure) => Failure(failure),
    );
  }

  /// Runs a docker compose command on the server and returns a stream of bytes.
  Future<Result<Stream<List<int>>, AppError>> runCommandStream(
    String project,
    String workingDir,
    String command, {
    String? service,
  }) async {
    final result = await _dockerService.post<dynamic>(
      '/compose/command',
      data: {
        'project': project,
        'working_dir': workingDir,
        'command': command,
        if (service != null && service.isNotEmpty) 'service': service,
      },
    );

    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          // If response.data is ResponseBody or Stream
          if (response.data is Stream<List<int>>) {
            return Success(response.data as Stream<List<int>>);
          }
          // Handle case where it might be wrapped in ResponseBody
          return Success(response.data.stream as Stream<List<int>>);
        }
        return Failure(AppError(message: 'Failed to run compose command: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }
}
