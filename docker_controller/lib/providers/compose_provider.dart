import 'dart:convert';

import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/compose_project.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/compose_service.dart';
import 'package:flutter/material.dart';

/// Provider responsible for managing Docker Compose projects and their lifecycle.
class ComposeProvider extends ChangeNotifier {
  ComposeProvider({required this.authProvider, ComposeService? composeService})
    : _composeService = composeService ?? getIt<ComposeService>();
  final AuthProvider authProvider;
  final ComposeService _composeService;

  AppState<List<ComposeProject>> _state = const AppInitial();
  // Per-project streaming output state
  final Map<String, List<String>> _projectLogs = {};
  final Map<String, bool> _projectIsRunning = {};

  /// Returns the current state of the compose projects list.
  AppState<List<ComposeProject>> get state => _state;

  /// Returns the streaming log output for a specific project.
  List<String> getLogsForProject(String projectName) =>
      _projectLogs[projectName] ?? [];

  /// Returns whether a compose command is currently running for a specific project.
  bool isProjectCommandRunning(String projectName) =>
      _projectIsRunning[projectName] ?? false;

  /// Whether the provider is currently loading the project list.
  bool get isLoading => _state is AppLoading;

  /// Returns the list of compose projects if the state is success.
  List<ComposeProject> get projects {
    if (_state is AppSuccess<List<ComposeProject>>) {
      return (_state as AppSuccess<List<ComposeProject>>).data;
    }
    return [];
  }

  /// Fetches the list of compose projects from the Docker daemon.
  ///
  /// If [silent] is true, the state remains unchanged (no loading spinner).
  Future<void> loadProjects({bool silent = false}) async {
    if (!authProvider.isConnected) {
      return;
    }

    if (!silent) {
      _state = const AppLoading();
      notifyListeners();
    }

    final result = await _composeService.getProjects();
    result.fold(
      (projectsList) {
        projectsList.sort((a, b) => a.name.compareTo(b.name));
        _state = AppSuccess(projectsList);
      },
      (failure) {
        _state = AppStateError(failure);
      },
    );
    notifyListeners();
  }

  /// Clears the log buffer for a specific project.
  void clearLogs(String projectName) {
    _projectLogs[projectName] = [];
    notifyListeners();
  }

  /// Runs a compose command (e.g., 'up', 'down') for a project and streams the output.
  Future<void> runCommand(
    String projectName,
    String workingDir,
    String command,
  ) async {
    if (!authProvider.isConnected) {
      return;
    }

    _projectIsRunning[projectName] = true;
    _projectLogs[projectName] = ['> docker compose $command'];
    notifyListeners();

    final result = await _composeService.runCommandStream(
      projectName,
      workingDir,
      command,
    );

    await result.fold(
      (stream) async {
        final lineStream = stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        try {
          await for (final line in lineStream) {
            if (line.isEmpty) {
              continue;
            }
            try {
              final data = jsonDecode(line);
              if (data['type'] == 'stdout' ||
                  data['type'] == 'stderr' ||
                  data['type'] == 'error') {
                _projectLogs[projectName]!.add(data['data']?.toString() ?? '');
                notifyListeners();
              } else if (data['type'] == 'done') {
                _projectLogs[projectName]!.add(
                  '> Exited with code ${data['exit_code']}',
                );
                notifyListeners();
              }
            } catch (_) {
              _projectLogs[projectName]!.add(line);
              notifyListeners();
            }
          }
        } catch (e) {
          _projectLogs[projectName]!.add('> Connection Error: $e');
        }
      },
      (failure) async {
        _projectLogs[projectName]!.add('> Error: ${failure.message}');
      },
    );

    _projectIsRunning[projectName] = false;
    await loadProjects(silent: true);
    notifyListeners();
  }

  Future<bool> registerProject(
    String name,
    String workingDir,
    List<String> configFiles,
  ) async {
    if (!authProvider.isConnected) {
      return false;
    }

    final result = await _composeService.registerProject(
      name,
      workingDir,
      configFiles,
    );
    return result.fold(
      (success) async {
        if (success) {
          await loadProjects(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }

  Future<bool> unregisterProject(String name) async {
    if (!authProvider.isConnected) {
      return false;
    }

    final result = await _composeService.unregisterProject(name);
    return result.fold(
      (success) async {
        if (success) {
          await loadProjects(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }
}
