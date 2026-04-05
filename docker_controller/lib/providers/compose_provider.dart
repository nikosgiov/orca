import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/compose_project.dart';
import '../providers/app_provider.dart';
import '../services/compose_service.dart';

class ComposeProvider extends ChangeNotifier {
  final AppProvider appProvider;
  
  bool isLoading = false;
  String? error;
  List<ComposeProject> projects = [];

  // Per-project streaming output state
  final Map<String, List<String>> _projectLogs = {};
  final Map<String, bool> _projectIsRunning = {};

  ComposeProvider({required this.appProvider});

  List<String> getLogsForProject(String projectName) => _projectLogs[projectName] ?? [];
  bool isProjectCommandRunning(String projectName) => _projectIsRunning[projectName] ?? false;

  Future<void> loadProjects() async {
    final config = appProvider.connectionConfig;
    if (config == null) {
      error = 'Not connected';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ComposeService.getProjects(config);
      if (res != null) {
        projects = res;
        // Sort alphabetically
        projects.sort((a, b) => a.name.compareTo(b.name));
      } else {
        error = 'Failed to load Compose projects. Check server connection.';
      }
    } catch (e) {
      error = 'Error loading projects: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearLogs(String projectName) {
    _projectLogs[projectName] = [];
    notifyListeners();
  }

  Future<void> runCommand(String projectName, String workingDir, String command) async {
    final config = appProvider.connectionConfig;
    if (config == null) return;

    _projectIsRunning[projectName] = true;
    _projectLogs[projectName] = ['> docker compose $command'];
    notifyListeners();

    try {
      final request = await ComposeService.runCommandStream(config, projectName, workingDir, command);
      
      // Use await for so execution suspends here until the stream is fully consumed
      final stream = request.stream.transform(utf8.decoder).transform(const LineSplitter());
      
      try {
        await for (final line in stream) {
          if (line.isEmpty) continue;
          try {
            final data = jsonDecode(line);
            if (data['type'] == 'stdout' || data['type'] == 'stderr' || data['type'] == 'error') {
              _projectLogs[projectName]!.add(data['data']?.toString() ?? '');
              notifyListeners();
            } else if (data['type'] == 'done') {
              _projectLogs[projectName]!.add('> Exited with code ${data['exit_code']}');
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
      loadProjects(); // refresh container statuses
      notifyListeners();

    } catch (e) {
      _projectLogs[projectName]!.add('> Error: $e');
      _projectIsRunning[projectName] = false;
      notifyListeners();
    }
  }

  Future<bool> registerProject(String name, String workingDir, List<String> configFiles) async {
    final config = appProvider.connectionConfig;
    if (config == null) {
      error = 'Not connected';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await ComposeService.registerProject(config, name, workingDir, configFiles);
      if (success) {
        await loadProjects(); // reload to show new project
      } else {
        error = 'Failed to register project';
      }
      return success;
    } catch (e) {
      error = 'Error registering project: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unregisterProject(String name) async {
    final config = appProvider.connectionConfig;
    if (config == null) {
      error = 'Not connected';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await ComposeService.unregisterProject(config, name);
      if (success) {
        await loadProjects(); // reload to remove project
      } else {
        error = 'Failed to unregister project';
      }
      return success;
    } catch (e) {
      error = 'Error unregistering project: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
