import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/docker_container.dart';
import '../providers/auth_provider.dart';
import '../services/container_service.dart';

class ContainerDetailData {
  const ContainerDetailData({
    required this.containerInfo,
    this.logs,
    this.stats,
  });
  final DockerContainer containerInfo;
  final String? logs;
  final Map<String, dynamic>? stats;
}

class ContainerDetailProvider extends ChangeNotifier {
  ContainerDetailProvider({
    required this.authProvider,
    required this.containerId,
    required this.containerName,
  });
  final AuthProvider authProvider;
  final String containerId;
  final String containerName;

  late TabController tabController;
  int currentTabIndex = 0;
  bool isFollowingLogs = false;

  AppState<ContainerDetailData> _state = const AppInitial();
  AppState<ContainerDetailData> get state => _state;

  String logSearch = '';
  int logTail = 100;
  String? logSince;

  String? get logs {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.logs : null;
  }

  DockerContainer? get containerInfo {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.containerInfo : null;
  }

  Map<String, dynamic>? get containerStats {
    final s = _state;
    return s is AppSuccess<ContainerDetailData> ? s.data.stats : null;
  }

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

  void setLogSearch(String query) {
    logSearch = query;
    notifyListeners();
  }

  void setLogTail(int tail) {
    if (logTail != tail) {
      logTail = tail;
      loadContainerData();
    }
  }

  void setLogSince(String? since) {
    if (logSince != since) {
      logSince = since;
      loadContainerData();
    }
  }

  void setTabController(TabController controller) {
    tabController = controller;
    tabController.addListener(() {
      currentTabIndex = tabController.index;
      notifyListeners();
    });
  }

  Future<void> loadContainerData() async {
    if (!authProvider.isConnected) {
      return;
    }

    _state = const AppLoading();
    notifyListeners();

    try {
      final results = await Future.wait([
        getIt<ContainerService>().getContainerInfo(containerId),
        getIt<ContainerService>().getContainerLogs(
          containerId,
          tail: logTail,
          since: logSince,
        ),
        getIt<ContainerService>().getContainerStats(containerId),
      ]);

      final info = results[0] as DockerContainer?;
      if (info == null) {
        _state = const AppError(message: 'Container not found');
      } else {
        _state = AppSuccess(
          ContainerDetailData(
            containerInfo: info,
            logs: results[1] as String?,
            stats: results[2] as Map<String, dynamic>?,
          ),
        );
      }
    } catch (e, st) {
      _state = AppError(
        message: 'Error loading container data: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  void setFollowingLogs(bool value) {
    isFollowingLogs = value;
    notifyListeners();
    if (isFollowingLogs) {
      startFollowingLogs();
    }
  }

  void startFollowingLogs() {
    // TODO: Implement real-time log following
  }

  // Container action methods
  Future<(bool, String?)> startContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().startContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to start container $containerName');
    } catch (e) {
      return (false, 'Error starting container: $e');
    }
  }

  Future<(bool, String?)> stopContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().stopContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to stop container $containerName');
    } catch (e) {
      return (false, 'Error stopping container: $e');
    }
  }

  Future<(bool, String?)> restartContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().restartContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to restart container $containerName');
    } catch (e) {
      return (false, 'Error restarting container: $e');
    }
  }

  Future<(bool, String?)> killContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().killContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to kill container $containerName');
    } catch (e) {
      return (false, 'Error killing container: $e');
    }
  }

  Future<(bool, String?)> pauseContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().pauseContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to pause container $containerName');
    } catch (e) {
      return (false, 'Error pausing container: $e');
    }
  }

  Future<(bool, String?)> resumeContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().resumeContainer(
        containerId,
      );
      if (success) {
        await loadContainerData();
        return (true, null);
      }
      return (false, 'Failed to resume container $containerName');
    } catch (e) {
      return (false, 'Error resuming container: $e');
    }
  }

  Future<(bool, String?)> renameContainer(String newName) async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().renameContainer(
        containerId,
        newName,
      );
      if (success) {
        return (true, 'Renamed container to $newName');
      }
      return (
        false,
        'Failed to rename container. The name might already be in use.',
      );
    } catch (e) {
      return (false, 'Error renaming container: $e');
    }
  }

  Future<(bool, String?)> removeContainer() async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected');
    }
    try {
      final success = await getIt<ContainerService>().removeContainer(
        containerId,
      );
      if (success) {
        return (true, 'Removed container $containerName');
      }
      return (false, 'Failed to remove container $containerName');
    } catch (e) {
      return (false, 'Error removing container: $e');
    }
  }
}
