import 'dart:developer' as developer;
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:flutter/material.dart';

/// Data model representing the detailed state of a Docker container,
/// including its base info, logs, and real-time statistics.
class ContainerDetailData {
  const ContainerDetailData({
    required this.containerInfo,
    this.logs,
    this.stats,
  });
  final DockerContainer containerInfo;
  final String? logs;
  final Map<String, dynamic>? stats;

  ContainerDetailData copyWith({
    DockerContainer? containerInfo,
    String? logs,
    Map<String, dynamic>? stats,
  }) {
    return ContainerDetailData(
      containerInfo: containerInfo ?? this.containerInfo,
      logs: logs ?? this.logs,
      stats: stats ?? this.stats,
    );
  }
}

/// Provider responsible for managing the detailed view of a specific container.
///
/// It handles fetching logs, real-time statistics, and performing lifecycle
/// actions (start, stop, etc.) on the container.
class ContainerDetailProvider extends ChangeNotifier {
  ContainerDetailProvider({
    required this.authProvider,
    required this.containerId,
    required this.containerName,
  });
  final AuthProvider authProvider;
  final String containerId;
  final String containerName;

  /// The controller for the tab view in the UI.
  late TabController tabController;

  /// The index of the currently active tab.
  int currentTabIndex = 0;

  /// Whether the UI is currently "following" (auto-scrolling) the logs.
  bool isFollowingLogs = false;

  /// The current UI state of the container details.
  AppState<ContainerDetailData> _state = const AppInitial();
  AppState<ContainerDetailData> get state => _state;

  /// The current search query for filtering logs.
  String logSearch = '';

  /// The number of log lines to fetch from the end.
  int logTail = 100;

  /// The timestamp or relative time from which to fetch logs.
  String? logSince;

  /// Returns the raw log string from the current state.
  String? get logs {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.logs : null;
  }

  /// Returns the container base information from the current state.
  DockerContainer? get containerInfo {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.containerInfo : null;
  }

  /// Returns the container real-time statistics from the current state.
  Map<String, dynamic>? get containerStats {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.stats : null;
  }

  /// Returns the logs filtered by the current [logSearch] query.
  String? get filteredLogs {
    final currentLogs = logs;
    if (currentLogs == null) {
      return null;
    }
    if (logSearch.isEmpty) {
      return currentLogs;
    }

    final query = logSearch.toLowerCase();
    final lines = currentLogs.split('\n');
    return lines.where((line) => line.toLowerCase().contains(query)).join('\n');
  }

  /// Sets the log search query and notifies listeners.
  void setLogSearch(String query) {
    logSearch = query;
    notifyListeners();
  }

  /// Sets the number of log lines to tail and triggers a refresh.
  void setLogTail(int tail) {
    if (logTail != tail) {
      logTail = tail;
      fetchLogs();
    }
  }

  /// Sets the time from which to fetch logs and triggers a refresh.
  void setLogSince(String? since) {
    if (logSince != since) {
      logSince = since;
      fetchLogs();
    }
  }

  /// Fetches the latest logs from the Docker daemon.
  Future<void> fetchLogs() async {
    if (!authProvider.isConnected) {
      return;
    }

    final result = await getIt<ContainerService>().getContainerLogs(
      containerId,
      tail: logTail,
      since: logSince,
    );

    result.fold(
      (newLogs) {
        final currentState = _state;
        if (currentState is AppSuccess<ContainerDetailData>) {
          _state = AppSuccess(
            currentState.data.copyWith(logs: newLogs),
          );
          notifyListeners();
        }
      },
      (failure) {
        developer.log('Error fetching logs: ${failure.message}', name: 'ContainerDetailProvider');
      },
    );
  }

  /// Attaches a [TabController] to the provider to track the active tab.
  void setTabController(TabController controller) {
    tabController = controller;
    tabController.addListener(() {
      currentTabIndex = tabController.index;
      notifyListeners();
    });
  }

  /// Loads all container data (info, logs, stats) in parallel.
  ///
  /// If [silent] is true, the UI state will not be set to [AppLoading].
  Future<void> loadContainerData({bool silent = false}) async {
    if (!authProvider.isConnected) {
      return;
    }

    if (!silent) {
      _state = const AppLoading();
      notifyListeners();
    }

    final containerService = getIt<ContainerService>();
    final results = await Future.wait([
      containerService.getContainerInfo(containerId),
      containerService.getContainerLogs(
        containerId,
        tail: logTail,
        since: logSince,
      ),
      containerService.getContainerStats(containerId),
    ]);

    final infoResult = results[0] as Result<DockerContainer, AppError>;
    final logsResult = results[1] as Result<String, AppError>;
    final statsResult = results[2] as Result<Map<String, dynamic>, AppError>;

    if (infoResult.isFailure) {
      _state = AppStateError(infoResult.exceptionOrNull!);
    } else {
      _state = AppSuccess(
        ContainerDetailData(
          containerInfo: infoResult.valueOrNull!,
          logs: logsResult.valueOrNull,
          stats: statsResult.valueOrNull,
        ),
      );
    }
    notifyListeners();
  }

  /// Sets whether the logs should be followed and triggers auto-refresh.
  void setFollowingLogs(bool value) {
    isFollowingLogs = value;
    notifyListeners();
    if (isFollowingLogs) {
      startFollowingLogs();
    }
  }

  /// Starts the log following mechanism.
  void startFollowingLogs() {
    // TODO: Implement real-time log following
  }

  // Container action methods
  /// Starts the container.
  ///
  /// Returns a tuple containing success status and an optional error message.
  Future<(bool, String?)> startContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().startContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to start container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  /// Stops the container.
  ///
  /// Returns a tuple containing success status and an optional error message.
  Future<(bool, String?)> stopContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().stopContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to stop container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> restartContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().restartContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to restart container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> killContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().killContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to kill container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> pauseContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().pauseContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to pause container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> resumeContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().resumeContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await loadContainerData(silent: true);
          return (true, null);
        }
        return (false, 'Failed to resume container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> renameContainer(String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return (false, 'Name cannot be empty');
    }
    if (trimmedName == containerName) {
      return (false, 'Name is already the same');
    }

    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]*$').hasMatch(trimmedName)) {
      return (false, 'Invalid name. Use only letters, numbers, dots, underscores, hyphens.');
    }

    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().renameContainer(containerId, trimmedName);
    return result.fold(
      (success) async {
        if (success) {
          return (true, 'Renamed container to $trimmedName');
        }
        return (false, 'Failed to rename container. The name might already be in use.');
      },
      (failure) => (false, failure.message),
    );
  }

  Future<(bool, String?)> removeContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    
    final result = await getIt<ContainerService>().removeContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          return (true, 'Removed container $containerName');
        }
        return (false, 'Failed to remove container $containerName');
      },
      (failure) => (false, failure.message),
    );
  }
}
