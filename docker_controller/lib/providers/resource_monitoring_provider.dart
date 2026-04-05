import 'package:flutter/material.dart';
import '../models/connection_config.dart';
import '../services/system_service.dart';
import '../services/container_service.dart';
import '../services/image_service.dart';
import '../utils/resource_stats_utils.dart';

class ResourceMonitoringProvider extends ChangeNotifier {
  ConnectionConfig? _connectionConfig;

  ResourceMonitoringProvider(this._connectionConfig);

  String _selectedTimeRange = '30m';
  String _selectedContainer = 'All Containers';
  bool _isRefreshing = false;

  Map<String, dynamic>? _systemInfo;
  List<Map<String, dynamic>>? _containers;
  Map<String, dynamic>? _resourceStats;
  List<Map<String, dynamic>>? _images;
  Map<String, dynamic>? _systemMetrics;
  List<Map<String, dynamic>> _metricsHistory = [];
  Map<String, dynamic> _metrics = {};

  List<Map<String, dynamic>> get containers => _containers ?? [];
  Map<String, dynamic>? get systemInfo => _systemInfo;
  Map<String, dynamic>? get resourceStats => _resourceStats;
  List<Map<String, dynamic>>? get images => _images;
  Map<String, dynamic>? get systemMetrics => _systemMetrics;
  List<Map<String, dynamic>> get metricsHistory => _metricsHistory;
  Map<String, dynamic> get metrics => _metrics;

  String get selectedTimeRange => _selectedTimeRange;
  String get selectedContainer => _selectedContainer;
  bool get isRefreshing => _isRefreshing;

  set selectedTimeRange(String value) {
    _selectedTimeRange = value;
    notifyListeners();
  }

  set selectedContainer(String value) {
    _selectedContainer = value;
    notifyListeners();
  }

  List<String> get containerNames {
    final names = (_containers ?? [])
        .map((c) => c['Names']?.first?.toString().replaceFirst('/', '') ?? '')
        .toList();
    return ['All Containers', ...names];
  }

  /// Called by [ProxyProvider] whenever [AppProvider] emits a new [ConnectionConfig].
  void updateConnectionConfig(ConnectionConfig? config) {
    _connectionConfig = config;
    // Auto-fetch when we get a valid config for the first time.
    if (config != null && _metrics.isEmpty) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (_connectionConfig == null) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        SystemService.getSystemInfo(_connectionConfig!),
        ContainerService.getContainers(_connectionConfig!),
        ImageService.getImages(_connectionConfig!),
        SystemService.getSystemMetrics(_connectionConfig!, _selectedTimeRange),
      ]);
      _systemInfo = results[0] as Map<String, dynamic>?;
      _containers = results[1] as List<Map<String, dynamic>>?;
      _images = results[2] as List<Map<String, dynamic>>?;
      final metrics = results[3] as Map<String, dynamic>?;
      _systemMetrics = metrics;
      _metricsHistory =
          metrics != null ? List<Map<String, dynamic>>.from(metrics['history'] ?? []) : [];
      _resourceStats =
          ResourceStatsUtils.calculateBasicResourceStatsFromContainers(_containers);
      _metrics = metrics ?? {};
    } catch (e) {
      debugPrint('ResourceMonitoringProvider: fetchData error: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async => fetchData();
}