import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../models/compose_project.dart';
import 'docker_service.dart';

class ComposeService {
  ComposeService(this._dockerService);

  final DockerService _dockerService;
  static const String _logPrefix = 'ComposeService';

  Future<List<ComposeProject>?> getProjects() async {
    try {
      final response = await _dockerService.get<List<dynamic>>(
        '/compose/projects',
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map(
              (json) => ComposeProject.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    } catch (e) {
      developer.log('$_logPrefix: Error fetching compose projects: $e');
      return null;
    }
  }

  Future<bool> registerProject(
    String name,
    String workingDir,
    List<String> configFiles,
  ) async {
    try {
      final response = await _dockerService.post(
        '/compose/register',
        data: {
          'name': name,
          'working_dir': workingDir,
          'config_files': configFiles,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      developer.log('$_logPrefix: Error registering compose project: $e');
      return false;
    }
  }

  Future<bool> unregisterProject(String name) async {
    try {
      final response = await _dockerService.delete('/compose/register/$name');
      return response.statusCode == 200;
    } catch (e) {
      developer.log('$_logPrefix: Error unregistering compose project: $e');
      return false;
    }
  }

  /// Runs a docker compose command on the server and returns a stream of bytes.
  Future<Stream<List<int>>> runCommandStream(
    String project,
    String workingDir,
    String command, {
    String? service,
  }) async {
    final response = await _dockerService.post<ResponseBody>(
      '/compose/command',
      data: {
        'project': project,
        'working_dir': workingDir,
        'command': command,
        if (service != null && service.isNotEmpty) 'service': service,
      },
      // options: Options(responseType: ResponseType.stream), // Handled by generic post type
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data!.stream;
    }
    throw Exception('Failed to run compose command: ${response.statusCode}');
  }
}
