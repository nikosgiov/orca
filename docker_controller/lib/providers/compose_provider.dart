import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/compose_project.dart';
import '../providers/auth_provider.dart';
import '../services/compose_service.dart';

class ComposeProvider extends ChangeNotifier {
  ComposeProvider({required this.authProvider, ComposeService? composeService})
    : _composeService = composeService ?? getIt<ComposeService>();
  final AuthProvider authProvider;
  final ComposeService _composeService;

  AppState<List<ComposeProject>> _state = const AppInitial();
  AppState<List<ComposeProject>> get state => _state;

  // Per-project streaming output state
  final Map<String, List<String>> _projectLogs = {};
  final Map<String, bool> _projectIsRunning = {};

  List<String> getLogsForProject(String projectName) =>
      _projectLogs[projectName] ?? [];
  bool isProjectCommandRunning(String projectName) =>
      _projectIsRunning[projectName] ?? false;

  bool get isLoading => _state is AppLoading;
  List<ComposeProject> get projects {
    if (_state is AppSuccess<List<ComposeProject>>) {
      return (_state as AppSuccess<List<ComposeProject>>).data;
    }
    return [];
  }

  Future<void> loadProjects() async {
    if (!authProvider.isConnected) {
      return;
    }

    _state = const AppLoading();
    notifyListeners();

    try {
      final res = await _composeService.getProjects();
      if (res != null) {
        res.sort((a, b) => a.name.compareTo(b.name));
        _state = AppSuccess(res);
      } else {
        _state = const AppError(
          message: 'Failed to load Compose projects. Check server connection.',
        );
      }
    } catch (e, st) {
      _state = AppError(
        message: 'Error loading projects: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  void clearLogs(String projectName) {
    _projectLogs[projectName] = [];
    notifyListeners();
  }

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

    try {
      final stream = await _composeService.runCommandStream(
        projectName,
        workingDir,
        command,
      );

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

      _projectIsRunning[projectName] = false;
      await loadProjects();
      notifyListeners();
    } catch (e) {
      _projectLogs[projectName]!.add('> Error: $e');
      _projectIsRunning[projectName] = false;
      notifyListeners();
    }
  }

  Future<bool> registerProject(
    String name,
    String workingDir,
    List<String> configFiles,
  ) async {
    if (!authProvider.isConnected) {
      return false;
    }

    try {
      final success = await _composeService.registerProject(
        name,
        workingDir,
        configFiles,
      );
      if (success) {
        await loadProjects();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unregisterProject(String name) async {
    if (!authProvider.isConnected) {
      return false;
    }

    try {
      final success = await _composeService.unregisterProject(name);
      if (success) {
        await loadProjects();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
