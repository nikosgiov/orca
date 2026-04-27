import 'dart:async';
import 'dart:developer' as developer;

import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/models/resource_data_point.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:docker_controller/utils/docker_stats_utils.dart';
import 'package:docker_controller/utils/resource_stats_utils.dart';
import 'package:flutter/material.dart';

/// Provider responsible for aggregated system information, including global stats,
/// networking, and volumes.
class SystemInfoProvider extends ChangeNotifier {
  SystemInfoProvider({
    SystemService? systemService,
    ContainerService? containerService,
    ImageService? imageService,
  }) : _systemService = systemService ?? getIt<SystemService>(),
       _containerService = containerService ?? getIt<ContainerService>(),
       _imageService = imageService ?? getIt<ImageService>();

  final SystemService _systemService;
  final ContainerService _containerService;
  final ImageService _imageService;

  static const String _logPrefix = 'SystemInfoProvider';

  Map<String, dynamic>? _systemInfo;
  List<DockerContainer>? _containers;
  List<DockerImage>? _images;
  Map<String, dynamic>? _resourceStats;
  final List<ResourceDataPoint> _resourceHistory = [];
  bool _isLoadingData = false;
  Map<String, dynamic>? _staticInfo;

  final List<Map<String, dynamic>> _networks = [
    {'name': 'bridge', 'driver': 'bridge', 'scope': 'local'},
    {'name': 'host', 'driver': 'host', 'scope': 'local'},
    {'name': 'none', 'driver': 'null', 'scope': 'local'},
    {'name': 'web-network', 'driver': 'bridge', 'scope': 'local'},
  ];
  final List<Map<String, dynamic>> _volumes = [
    {'name': 'postgres_data', 'driver': 'local'},
    {'name': 'redis_data', 'driver': 'local'},
    {'name': 'nginx_logs', 'driver': 'local'},
  ];

  /// Returns the global system information (from /info).
  Map<String, dynamic>? get systemInfo => _systemInfo;

  /// Returns the current list of containers.
  List<DockerContainer>? get containers => _containers;

  /// Returns the current list of images.
  List<DockerImage>? get images => _images;

  /// Returns the aggregated resource statistics.
  Map<String, dynamic>? get resourceStats => _resourceStats;

  /// Returns a history of resource usage data points.
  List<ResourceDataPoint> get resourceHistory => _resourceHistory;

  /// Whether data is currently being fetched.
  bool get isLoadingData => _isLoadingData;

  /// Returns the list of Docker networks.
  List<Map<String, dynamic>> get networks => _networks;

  /// Returns the list of Docker volumes.
  List<Map<String, dynamic>> get volumes => _volumes;

  /// Returns static system information (e.g., OS, kernel version).
  Map<String, dynamic>? get staticInfo => _staticInfo;

  /// Fetches all system data (info, containers, images, metrics) in parallel.
  Future<void> fetchSystemData(ConnectionConfig config) async {
    _isLoadingData = true;
    notifyListeners();
    
    final results = await Future.wait([
      _systemService.getSystemInfo(),
      _containerService.getContainers(),
      _imageService.getImages(),
      _systemService.getSystemMetrics(),
    ]);

    final infoResult = results[0] as Result<Map<String, dynamic>, AppError>;
    infoResult.fold(
      (data) => _systemInfo = data,
      (failure) => developer.log('$_logPrefix: Error fetching system info: ${failure.message}', name: _logPrefix),
    );

    final containersResult = results[1] as Result<List<DockerContainer>, AppError>;
    containersResult.fold(
      (data) => _containers = data,
      (failure) => developer.log('$_logPrefix: Error fetching containers: ${failure.message}', name: _logPrefix),
    );

    final imagesResult = results[2] as Result<List<DockerImage>, AppError>;
    imagesResult.fold(
      (data) => _images = data,
      (failure) => developer.log('$_logPrefix: Error fetching images: ${failure.message}', name: _logPrefix),
    );

    final metricsResult = results[3] as Result<Map<String, dynamic>, AppError>;
    metricsResult.fold(
      (data) => _staticInfo = data['static'] as Map<String, dynamic>?,
      (failure) => developer.log('$_logPrefix: Error fetching metrics: ${failure.message}', name: _logPrefix),
    );

    await _calculateBasicResourceStats();
    
    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> _calculateBasicResourceStats() async {
    _resourceStats = ResourceStatsUtils.calculateBasicResourceStatsFromContainers(_containers);
  }

  Future<void> refreshDetailedStats(ConnectionConfig config) async {
    if (_containers == null) {
      return;
    }

    double totalCpu = 0.0;
    double totalMemory = 0.0;
    int activeCount = 0;

    final runningContainers = _containers!.where((container) => container.state == 'running').toList();
    const int maxConcurrent = 3;

    for (int i = 0; i < runningContainers.length; i += maxConcurrent) {
      final batch = runningContainers.skip(i).take(maxConcurrent);
      final batchResults = await Future.wait(
        batch.map((container) async {
          final result = await _containerService.getContainerStats(container.id);
          return result.fold(
            (stats) => {
              'cpu': DockerStatsUtils.calculateCpuUsage(stats),
              'memory': DockerStatsUtils.calculateMemoryUsage(stats),
            },
            (failure) {
              developer.log('$_logPrefix: Error getting stats for container ${container.id}: ${failure.message}', name: _logPrefix);
              return null;
            },
          );
        }),
      );

      for (final result in batchResults) {
        if (result != null) {
          totalCpu += result['cpu'] ?? 0.0;
          totalMemory += result['memory'] ?? 0.0;
          activeCount++;
        }
      }
    }

    if (activeCount > 0) {
      final avgCpu = totalCpu / activeCount;
      final avgMemory = totalMemory / activeCount;
      _resourceStats = {
        'cpu': avgCpu,
        'memory': avgMemory,
        'running': _resourceStats?['running'] ?? 0,
        'stopped': _resourceStats?['stopped'] ?? 0,
        'exited': _resourceStats?['exited'] ?? 0,
      };
      notifyListeners();
    }
  }

  /// Refreshes the system information.
  void refreshSystemInfo(ConnectionConfig config) {
    fetchSystemData(config);
  }

  String getSystemInfoValue(String key, String defaultValue) {
    return _systemInfo?[key]?.toString() ?? defaultValue;
  }

  /// Returns the Docker server version.
  String getDockerVersion() => getSystemInfoValue('ServerVersion', 'Unknown');

  String getOsInfo() {
    final os = getSystemInfoValue('OperatingSystem', 'Unknown');
    final arch = getSystemInfoValue('Architecture', '');
    return '$os $arch'.trim();
  }

  String getHostname() => getSystemInfoValue('Name', 'Unknown');

  String getMemoryInfo() {
    if (_systemInfo == null) {
      return 'Unknown';
    }
    final memTotal = _systemInfo!['MemTotal'] ?? 0;
    final memTotalGB = (memTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '$memTotalGB GB';
  }

  String getCpuInfo() => _systemInfo?['NCPU']?.toString() ?? 'Unknown';
}
