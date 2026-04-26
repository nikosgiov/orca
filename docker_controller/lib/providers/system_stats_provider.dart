import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/docker_container.dart';
import '../services/container_service.dart';
import '../services/network_service.dart';
import '../services/system_service.dart';
import '../services/volume_service.dart';
import '../utils/resource_stats_utils.dart';
import 'auth_provider.dart';

/// Provider for system-wide statistics and telemetry.
class SystemStatsProvider extends ChangeNotifier {
  SystemStatsProvider(this._authProvider) {
    if (_authProvider.isConnected) {
      refreshAll();
    }
  }
  static const String _logPrefix = 'SystemStatsProvider';

  Map<String, dynamic>? _systemInfo;
  Map<String, dynamic>? _resourceStats;
  Map<String, dynamic>? _systemMetrics;
  List<Map<String, dynamic>> _metricsHistory = [];
  bool _isLoading = false;

  int _volumeCount = 0;
  int _networkCount = 0;

  Map<String, dynamic>? get systemInfo => _systemInfo;
  Map<String, dynamic>? get resourceStats => _resourceStats;
  Map<String, dynamic>? get systemMetrics => _systemMetrics;
  List<Map<String, dynamic>> get metricsHistory => _metricsHistory;
  bool get isLoading => _isLoading;
  int get volumeCount => _volumeCount;
  int get networkCount => _networkCount;

  final AuthProvider _authProvider;

  Future<void> refreshAll() async {
    if (!_authProvider.isConnected) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchSystemInfo(),
        fetchContainersAndStats(),
        fetchSystemMetrics(),
        fetchInfraCounts(),
      ]);
    } catch (e) {
      developer.log(
        '$_logPrefix: Error refreshing stats: $e',
        name: _logPrefix,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSystemInfo() async {
    try {
      _systemInfo = await getIt<SystemService>().getSystemInfo();
      notifyListeners();
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching system info: $e',
        name: _logPrefix,
      );
    }
  }

  Future<void> fetchContainersAndStats() async {
    try {
      final List<DockerContainer> containers = await getIt<ContainerService>()
          .getContainers();
      _resourceStats =
          ResourceStatsUtils.calculateBasicResourceStatsFromContainers(
            containers,
          );
      notifyListeners();
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching container stats: $e',
        name: _logPrefix,
      );
    }
  }

  Future<void> fetchSystemMetrics() async {
    try {
      final metrics = await getIt<SystemService>().getSystemMetrics();
      _systemMetrics = metrics;
      _metricsHistory = List<Map<String, dynamic>>.from(
        metrics['history'] ?? [],
      );
      notifyListeners();
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching system metrics: $e',
        name: _logPrefix,
      );
    }
  }

  Future<void> fetchInfraCounts() async {
    try {
      final vols = await getIt<VolumeService>().getVolumes();
      _volumeCount = vols.length;
      final nets = await getIt<NetworkService>().getNetworks();
      _networkCount = nets.length;
      notifyListeners();
    } catch (_) {}
  }
}
