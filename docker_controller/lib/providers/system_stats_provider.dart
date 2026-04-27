import 'dart:developer' as developer;

import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:docker_controller/utils/resource_stats_utils.dart';
import 'package:flutter/material.dart';

import 'auth_provider.dart';

/// Provider for system-wide statistics and telemetry.
class SystemStatsProvider extends ChangeNotifier {
  SystemStatsProvider(this._authProvider) {
    if (_authProvider.isConnected) {
      refreshAll();
    }
  }
  static const String _logPrefix = 'SystemStatsProvider';

  AppState<void> _state = const AppInitial();

  /// Returns the current state of the system statistics fetch.
  AppState<void> get state => _state;

  Map<String, dynamic>? _systemInfo;
  Map<String, dynamic>? _resourceStats;
  Map<String, dynamic>? _systemMetrics;
  List<Map<String, dynamic>> _metricsHistory = [];
  int _volumeCount = 0;
  int _networkCount = 0;

  /// Returns the global system information.
  Map<String, dynamic>? get systemInfo => _systemInfo;

  /// Returns basic resource usage statistics (e.g., container counts).
  Map<String, dynamic>? get resourceStats => _resourceStats;

  /// Returns detailed system metrics (CPU, Memory).
  Map<String, dynamic>? get systemMetrics => _systemMetrics;

  /// Returns historical metrics for charting.
  List<Map<String, dynamic>> get metricsHistory => _metricsHistory;

  /// Whether the provider is currently fetching all data.
  bool get isLoading => _state is AppLoading;

  /// Returns the total count of Docker volumes.
  int get volumeCount => _volumeCount;

  /// Returns the total count of Docker networks.
  int get networkCount => _networkCount;

  final AuthProvider _authProvider;

  /// Triggers a full refresh of all system statistics.
  Future<void> refreshAll() async {
    if (!_authProvider.isConnected) {
      return;
    }

    _state = const AppLoading();
    notifyListeners();

    try {
      await Future.wait([
        fetchSystemInfo(),
        fetchContainersAndStats(),
        fetchSystemMetrics(),
        fetchInfraCounts(),
      ]);
      _state = const AppSuccess(null);
    } catch (e) {
      _state = AppStateError(AppError(message: e.toString()));
      developer.log('$_logPrefix: Error refreshing stats: $e', name: _logPrefix);
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchSystemInfo() async {
    final result = await getIt<SystemService>().getSystemInfo();
    result.fold(
      (info) => _systemInfo = info,
      (failure) => developer.log('$_logPrefix: Error fetching system info: ${failure.message}', name: _logPrefix),
    );
    notifyListeners();
  }

  Future<void> fetchContainersAndStats() async {
    final result = await getIt<ContainerService>().getContainers();
    result.fold(
      (containers) {
        _resourceStats = ResourceStatsUtils.calculateBasicResourceStatsFromContainers(containers);
        notifyListeners();
      },
      (failure) => developer.log('$_logPrefix: Error fetching container stats: ${failure.message}', name: _logPrefix),
    );
  }

  Future<void> fetchSystemMetrics() async {
    final result = await getIt<SystemService>().getSystemMetrics();
    result.fold(
      (metrics) {
        _systemMetrics = metrics;
        _metricsHistory = List<Map<String, dynamic>>.from(metrics['history'] ?? []);
        notifyListeners();
      },
      (failure) => developer.log('$_logPrefix: Error fetching system metrics: ${failure.message}', name: _logPrefix),
    );
  }

  Future<void> fetchInfraCounts() async {
    final volumesResult = await getIt<VolumeService>().getVolumes();
    volumesResult.fold(
      (vols) => _volumeCount = vols.length,
      (failure) => developer.log('$_logPrefix: Error fetching volume count: ${failure.message}', name: _logPrefix),
    );

    final networksResult = await getIt<NetworkService>().getNetworks();
    networksResult.fold(
      (nets) => _networkCount = nets.length,
      (failure) => developer.log('$_logPrefix: Error fetching network count: ${failure.message}', name: _logPrefix),
    );
    
    notifyListeners();
  }
}
