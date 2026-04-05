import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import '../models/resource_data_point.dart';
import '../services/system_service.dart';
import '../services/container_service.dart';
import '../services/image_service.dart';
import '../services/docker_service.dart';
import '../utils/resource_stats_utils.dart';

class SystemInfoProvider extends ChangeNotifier {
  static const String _logPrefix = 'myapp';

  Map<String, dynamic>? _systemInfo;
  List<Map<String, dynamic>>? _containers;
  List<Map<String, dynamic>>? _images;
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
  List<Map<String, dynamic>>? get containers => _containers;
  List<Map<String, dynamic>>? get images => _images;
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
        SystemService.getSystemInfo(config),
        ContainerService.getContainers(config),
        ImageService.getImages(config),
      ]);
      _systemInfo = results[0] as Map<String, dynamic>?;
      _updateContainers(results[1] as List<Map<String, dynamic>>?);
      _updateImages(results[2] as List<Map<String, dynamic>>?);
      await _calculateBasicResourceStats();
      final metrics = await SystemService.getSystemMetrics(config);
      _staticInfo = metrics['static'] as Map<String, dynamic>?;
    } catch (e) {
      developer.log('$_logPrefix: Error fetching system data: $e', name: 'SystemInfoProvider');
      
      // Check if this is an authentication error (403 Forbidden)
      if (e.toString().contains('403') || e.toString().contains('Forbidden') || e.toString().contains('Unauthorized')) {
        // Note: This provider doesn't have direct access to AppProvider, so we'll just log the auth error
        developer.log('$_logPrefix: Authentication error detected in system info fetch: $e', name: 'SystemInfoProvider');
      }
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _calculateBasicResourceStats() async {
    _resourceStats = ResourceStatsUtils.calculateBasicResourceStatsFromContainers(_containers);
  }

  Future<void> refreshDetailedStats(ConnectionConfig config) async {
    if (_containers == null) return;
    double totalCpu = 0.0;
    double totalMemory = 0.0;
    int activeCount = 0;
    final runningContainers = _containers!.where((container) {
      return (container['State'] as String? ?? '') == 'running';
    }).toList();
    const int maxConcurrent = 3;
    for (int i = 0; i < runningContainers.length; i += maxConcurrent) {
      final batch = runningContainers.skip(i).take(maxConcurrent);
      final batchResults = await Future.wait(
        batch.map((container) async {
          final containerId = container['Id'] as String?;
          if (containerId != null) {
            try {
              final stats = await ContainerService.getContainerStats(config, containerId)
                  .timeout(const Duration(seconds: 2));
              if (stats != null) {
                return {
                  'cpu': DockerService.calculateCpuUsage(stats),
                  'memory': DockerService.calculateMemoryUsage(stats),
                };
              }
            } catch (e) {
              developer.log('$_logPrefix: Error getting stats for container $containerId: $e', name: 'SystemInfoProvider');
            }
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

  void _updateContainers(List<Map<String, dynamic>>? newContainers) {
    if (newContainers == null) return;
    _containers = newContainers;
    notifyListeners();
  }

  void _updateImages(List<Map<String, dynamic>>? newImages) {
    if (newImages == null) return;
    _images = newImages;
    notifyListeners();
  }

  // Helper methods for system info
  String getSystemInfoValue(String key, String defaultValue) {
    if (_systemInfo == null) return defaultValue;
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
    return getSystemInfoValue('Name', 'Unknown');
  }

  String getMemoryInfo() {
    if (_systemInfo == null) return 'Unknown';
    final memTotal = _systemInfo!['MemTotal'] ?? 0;
    final memTotalGB = (memTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '$memTotalGB GB';
  }

  String getCpuInfo() {
    if (_systemInfo == null) return 'Unknown';
    final ncpu = _systemInfo!['NCPU'] ?? 0;
    return ncpu.toString();
  }

  void refreshSystemInfo(ConnectionConfig config) {
    fetchSystemData(config);
  }
} 