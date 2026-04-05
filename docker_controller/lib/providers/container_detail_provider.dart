import 'package:flutter/material.dart';
import '../services/container_service.dart';
import '../models/connection_config.dart';
import '../providers/app_provider.dart';
import '../models/app_error.dart';

class ContainerDetailProvider extends ChangeNotifier {
  final AppProvider appProvider;
  final String containerId;
  final String containerName;
  late TabController tabController;
  int currentTabIndex = 0;
  bool isLoading = false;
  bool isFollowingLogs = false;
  String? logs;
  Map<String, dynamic>? containerInfo;
  Map<String, dynamic>? containerStats;
  AppError? error;

  String logSearch = '';
  int logTail = 100;
  String? logSince;

  String? get filteredLogs {
    if (logs == null) return null;
    if (logSearch.isEmpty) return logs;
    
    final query = logSearch.toLowerCase();
    final lines = logs!.split('\n');
    return lines.where((line) => line.toLowerCase().contains(query)).join('\n');
  }

  void setLogSearch(String query) {
    logSearch = query;
    notifyListeners();
  }

  void setLogTail(int tail) {
    if (logTail != tail) {
      logTail = tail;
      loadContainerData(); // Reload logs from server with new tail
    }
  }

  void setLogSince(String? since) {
    if (logSince != since) {
      logSince = since;
      loadContainerData(); // Reload logs from server with new since filter
    }
  }

  ContainerDetailProvider({
    required this.appProvider,
    required this.containerId,
    required this.containerName,
  });

  void setTabController(TabController controller) {
    tabController = controller;
    tabController.addListener(() {
      currentTabIndex = tabController.index;
      notifyListeners();
    });
  }

  Future<void> loadContainerData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (appProvider.connectionConfig == null) {
        throw Exception('Not connected to Docker daemon');
      }
      final results = await Future.wait([
        _loadContainerInfo(appProvider.connectionConfig!),
        _loadContainerLogs(appProvider.connectionConfig!),
        _loadContainerStats(appProvider.connectionConfig!),
      ]);
      containerInfo = results[0] as Map<String, dynamic>?;
      logs = results[1] as String?;
      containerStats = results[2] as Map<String, dynamic>?;
    } catch (e) {
      error = AppError(message: 'Error loading container data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _loadContainerInfo(ConnectionConfig config) async {
    return await ContainerService.getContainerInfo(config, containerId);
  }

  Future<String?> _loadContainerLogs(ConnectionConfig config) async {
    return await ContainerService.getContainerLogs(
      config, 
      containerId,
      tail: logTail,
      since: logSince,
    );
  }

  Future<Map<String, dynamic>?> _loadContainerStats(ConnectionConfig config) async {
    return await ContainerService.getContainerStats(config, containerId);
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
    // This would require WebSocket connection or polling
  }

  // Container action methods
  Future<(bool, String?)> startContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.startContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to start container $containerName');
      }
    } catch (e) {
      return (false, 'Error starting container: $e');
    }
  }

  Future<(bool, String?)> stopContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.stopContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to stop container $containerName');
      }
    } catch (e) {
      return (false, 'Error stopping container: $e');
    }
  }

  Future<(bool, String?)> restartContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.restartContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to restart container $containerName');
      }
    } catch (e) {
      return (false, 'Error restarting container: $e');
    }
  }

  Future<(bool, String?)> killContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.killContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to kill container $containerName');
      }
    } catch (e) {
      return (false, 'Error killing container: $e');
    }
  }

  Future<(bool, String?)> pauseContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.pauseContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to pause container $containerName');
      }
    } catch (e) {
      return (false, 'Error pausing container: $e');
    }
  }

  Future<(bool, String?)> resumeContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.resumeContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        await loadContainerData();
        return (true, null);
      } else {
        return (false, 'Failed to resume container $containerName');
      }
    } catch (e) {
      return (false, 'Error resuming container: $e');
    }
  }

  // Rename and remove container methods should also be called from the UI, as they require dialogs
  Future<(bool, String?)> renameContainer(String newName) async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.renameContainer(appProvider.connectionConfig!, containerId, newName);
      if (success) {
        return (true, 'Renamed container to $newName');
      } else {
        return (false, 'Failed to rename container. The name might already be in use.');
      }
    } catch (e) {
      return (false, 'Error renaming container: $e');
    }
  }

  Future<(bool, String?)> removeContainer() async {
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ContainerService.removeContainer(appProvider.connectionConfig!, containerId);
      if (success) {
        return (true, 'Removed container $containerName');
      } else {
        return (false, 'Failed to remove container $containerName');
      }
    } catch (e) {
      return (false, 'Error removing container: $e');
    }
  }
} 
