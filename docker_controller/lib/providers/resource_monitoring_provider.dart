import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/connection_config.dart';
import '../models/docker_container.dart';
import '../models/docker_image.dart';
import '../models/resource_data_point.dart';
import '../models/resource_metrics.dart';
import '../services/container_service.dart';
import '../services/image_service.dart';
import '../services/system_service.dart';
import '../utils/resource_chart_utils.dart';
import '../utils/resource_stats_utils.dart';

class ResourceMonitoringProvider extends ChangeNotifier {
  ResourceMonitoringProvider(this._systemService);

  final SystemService? _systemService;
  ConnectionConfig? _connectionConfig;

  AppState<ResourceMetrics> _state = const AppInitial();
  String _selectedTimeRange = '30m';
  String _selectedContainer = 'All Containers';
  bool _isRefreshing = false;

  AppState<ResourceMetrics> get state => _state;
  String get selectedTimeRange => _selectedTimeRange;
  String get selectedContainer => _selectedContainer;
  bool get isRefreshing => _isRefreshing;

  ResourceMetrics? get metrics {
    if (_state is AppSuccess<ResourceMetrics>) {
      return (_state as AppSuccess<ResourceMetrics>).data;
    }
    return null;
  }

  set selectedTimeRange(String value) {
    if (_selectedTimeRange != value) {
      _selectedTimeRange = value;
      notifyListeners();
      fetchData();
    }
  }

  set selectedContainer(String value) {
    if (_selectedContainer != value) {
      _selectedContainer = value;
      notifyListeners();
    }
  }

  List<String> get containerNames {
    final containers = metrics?.containers ?? [];
    final names = containers
        .map((c) => c.names.isNotEmpty ? c.names.first.replaceAll('/', '') : '')
        .where((name) => name.isNotEmpty)
        .toList();
    return ['All Containers', ...names];
  }

  void updateConnectionConfig(ConnectionConfig? config) {
    _connectionConfig = config;
    if (config != null && _state is AppInitial) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (_connectionConfig == null && _systemService == null) {
      return;
    }

    if (_state is! AppSuccess) {
      _state = const AppLoading();
      notifyListeners();
    }

    try {
      final systemService = _systemService ?? getIt<SystemService>();
      final containerService = getIt<ContainerService>();
      final imageService = getIt<ImageService>();

      final results = await Future.wait([
        systemService.getSystemInfo(),
        containerService.getContainers(),
        imageService.getImages(),
        systemService.getSystemMetrics(_selectedTimeRange),
      ]);

      final systemInfo = results[0] as Map<String, dynamic>? ?? {};
      final containers = results[1] as List<DockerContainer>? ?? [];
      final images = results[2] as List<DockerImage>? ?? [];
      final responseData = results[3] as Map<String, dynamic>? ?? {};

      // Automatically unwrap if nested under 'metrics' or 'data'
      final rawMetrics = (responseData['metrics'] ??
              responseData['data'] ??
              responseData) as Map<String, dynamic>;

      // Parse history based on format (list of objects or parallel arrays)
      List<ResourceDataPoint> history;
      if (rawMetrics.containsKey('history')) {
        history = (rawMetrics['history'] as List? ?? [])
            .map((item) =>
                ResourceDataPoint.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback to parsing parallel arrays
        history = ResourceChartUtils.fromMetricsArrays(
          rawMetrics,
          _selectedTimeRange,
        );
      }

      final basicStats =
          ResourceStatsUtils.calculateBasicResourceStatsFromContainers(
        containers,
      );

      _state = AppSuccess(ResourceMetrics(
        containers: containers,
        images: images,
        systemInfo: systemInfo,
        history: history,
        basicStats: basicStats,
        rawMetrics: rawMetrics,
      ));
    } catch (e, st) {
      _state = AppError(
        message: 'Failed to fetch monitoring data: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _isRefreshing = true;
    notifyListeners();
    await fetchData();
  }
}
