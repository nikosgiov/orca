import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/connection_config.dart';
import '../models/docker_container.dart';
import '../models/docker_image.dart';
import '../models/resource_data_point.dart';
import '../services/container_service.dart';
import '../services/image_service.dart';
import '../services/system_service.dart';
import '../utils/docker_stats_utils.dart';
import '../utils/resource_stats_utils.dart';

class SystemInfoProvider extends ChangeNotifier {
  static const String _logPrefix = 'SystemInfoProvider';

  Map<String, dynamic>? _systemInfo;
  List<DockerContainer>? _containers;
  List<DockerImage>? _images;
  Map<String, dynamic>? _resourceStats;
  final List<ResourceDataPoint> _resourceHistory = [];
  bool _isLoadingData = false;

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

  Map<String, dynamic>? get systemInfo => _systemInfo;
  List<DockerContainer>? get containers => _containers;
  List<DockerImage>? get images => _images;
  Map<String, dynamic>? get resourceStats => _resourceStats;
  List<ResourceDataPoint> get resourceHistory => _resourceHistory;
  bool get isLoadingData => _isLoadingData;
  List<Map<String, dynamic>> get networks => _networks;
  List<Map<String, dynamic>> get volumes => _volumes;

  Map<String, dynamic>? _staticInfo;
  Map<String, dynamic>? get staticInfo => _staticInfo;

  Future<void> fetchSystemData(ConnectionConfig config) async {
    _isLoadingData = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        getIt<SystemService>().getSystemInfo(),
        getIt<ContainerService>().getContainers(),
        getIt<ImageService>().getImages(),
      ]);
      _systemInfo = results[0] as Map<String, dynamic>?;
      _updateContainers(results[1] as List<DockerContainer>?);
      _updateImages(results[2] as List<DockerImage>?);
      await _calculateBasicResourceStats();
      final metrics = await getIt<SystemService>().getSystemMetrics();
      _staticInfo = metrics['static'] as Map<String, dynamic>?;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching system data: $e',
        name: 'SystemInfoProvider',
      );
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _calculateBasicResourceStats() async {
    _resourceStats =
        ResourceStatsUtils.calculateBasicResourceStatsFromContainers(
          _containers,
        );
  }

  Future<void> refreshDetailedStats(ConnectionConfig config) async {
    if (_containers == null) {
      return;
    }
    double totalCpu = 0.0;
    double totalMemory = 0.0;
    int activeCount = 0;
    final runningContainers = _containers!.where((container) {
      return container.state == 'running';
    }).toList();
    const int maxConcurrent = 3;
    for (int i = 0; i < runningContainers.length; i += maxConcurrent) {
      final batch = runningContainers.skip(i).take(maxConcurrent);
      final batchResults = await Future.wait(
        batch.map((container) async {
          final containerId = container.id;
          try {
            final stats = await getIt<ContainerService>()
                .getContainerStats(containerId)
                .timeout(const Duration(seconds: 2));
            if (stats != null) {
              return {
                'cpu': DockerStatsUtils.calculateCpuUsage(stats),
                'memory': DockerStatsUtils.calculateMemoryUsage(stats),
              };
            }
          } catch (e) {
            developer.log(
              '$_logPrefix: Error getting stats for container $containerId: $e',
              name: 'SystemInfoProvider',
            );
          }
          return null;
        }),
      );
      for (final result in batchResults) {
        if (result != null) {
          final cpu = result['cpu'] ?? 0.0;
          final memory = result['memory'] ?? 0.0;
          totalCpu += cpu;
          totalMemory += memory;
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

  void _updateContainers(List<DockerContainer>? newContainers) {
    if (newContainers == null) {
      return;
    }
    _containers = newContainers;
    notifyListeners();
  }

  void _updateImages(List<DockerImage>? newImages) {
    if (newImages == null) {
      return;
    }
    _images = newImages;
    notifyListeners();
  }

  String getSystemInfoValue(String key, String defaultValue) {
    if (_systemInfo == null) {
      return defaultValue;
    }
    return _systemInfo![key]?.toString() ?? defaultValue;
  }

  String getDockerVersion() {
    return getSystemInfoValue('ServerVersion', 'Unknown');
  }

  String getOsInfo() {
    final os = getSystemInfoValue('OperatingSystem', 'Unknown');
    final arch = getSystemInfoValue('Architecture', '');
    return '$os $arch'.trim();
  }

  String getHostname() {
    return getHostnameInternal();
  }

  String getHostnameInternal() {
    return getSystemInfoValue('Name', 'Unknown');
  }

  String getMemoryInfo() {
    if (_systemInfo == null) {
      return 'Unknown';
    }
    final memTotal = _systemInfo!['MemTotal'] ?? 0;
    final memTotalGB = (memTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '$memTotalGB GB';
  }

  String getCpuInfo() {
    if (_systemInfo == null) {
      return 'Unknown';
    }
    final ncpu = _systemInfo!['NCPU'] ?? 0;
    return ncpu.toString();
  }

  void refreshSystemInfo(ConnectionConfig config) {
    fetchSystemData(config);
  }
}
