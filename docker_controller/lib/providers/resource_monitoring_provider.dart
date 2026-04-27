import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/models/resource_data_point.dart';
import 'package:docker_controller/models/resource_metrics.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:docker_controller/utils/resource_chart_utils.dart';
import 'package:docker_controller/utils/resource_stats_utils.dart';
import 'package:flutter/material.dart';

/// Provider responsible for monitoring system resources and historical metrics.
class ResourceMonitoringProvider extends ChangeNotifier {
  ResourceMonitoringProvider(this._systemService);

  final SystemService? _systemService;
  ConnectionConfig? _connectionConfig;

  AppState<ResourceMetrics> _state = const AppInitial();
  String _selectedTimeRange = '30m';
  String _selectedContainer = 'All Containers';
  bool _isRefreshing = false;

  /// Returns the current state of the resource metrics.
  AppState<ResourceMetrics> get state => _state;

  /// The currently selected time range for the metrics graphs.
  String get selectedTimeRange => _selectedTimeRange;

  /// The currently selected container for detailed resource monitoring.
  String get selectedContainer => _selectedContainer;

  /// Whether a data refresh is in progress.
  bool get isRefreshing => _isRefreshing;

  /// Returns the parsed metrics if the state is success.
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

  /// Returns a list of all available container names for selection.
  List<String> get containerNames {
    final containers = metrics?.containers ?? [];
    final names = containers
        .map((c) => c.names.isNotEmpty ? c.names.first.replaceAll('/', '') : '')
        .where((name) => name.isNotEmpty)
        .toList();
    return ['All Containers', ...names];
  }

  /// Updates the connection configuration and triggers an initial data fetch.
  void updateConnectionConfig(ConnectionConfig? config) {
    _connectionConfig = config;
    if (config != null && _state is AppInitial) {
      fetchData();
    }
  }

  /// Fetches system metrics, containers, and images from the Docker host.
  ///
  /// If [silent] is true, the UI state will not transition to [AppLoading].
  Future<void> fetchData({bool silent = false}) async {
    if (_connectionConfig == null && _systemService == null) {
      return;
    }

    if (!silent && _state is! AppSuccess) {
      _state = const AppLoading();
      notifyListeners();
    }

    final systemService = _systemService ?? getIt<SystemService>();
    final containerService = getIt<ContainerService>();
    final imageService = getIt<ImageService>();

    final results = await Future.wait([
      systemService.getSystemInfo(),
      containerService.getContainers(),
      imageService.getImages(),
      systemService.getSystemMetrics(_selectedTimeRange),
    ]);

    final infoResult = results[0] as Result<Map<String, dynamic>, AppError>;
    final systemInfo = infoResult.valueOrNull ?? {};
    
    final containersResult = results[1] as Result<List<DockerContainer>, AppError>;
    final imagesResult = results[2] as Result<List<DockerImage>, AppError>;
    final metricsResult = results[3] as Result<Map<String, dynamic>, AppError>;

    if (containersResult.isFailure) {
      _state = AppStateError(containersResult.exceptionOrNull!);
      notifyListeners();
      return;
    }
    if (imagesResult.isFailure) {
      _state = AppStateError(imagesResult.exceptionOrNull!);
      notifyListeners();
      return;
    }
    if (metricsResult.isFailure) {
      _state = AppStateError(metricsResult.exceptionOrNull!);
      notifyListeners();
      return;
    }

    final containers = containersResult.valueOrNull ?? [];
    final images = imagesResult.valueOrNull ?? [];
    final responseData = metricsResult.valueOrNull ?? {};

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
    _isRefreshing = false;
    notifyListeners();
  }

  /// Refreshes the resource data silently.
  Future<void> refreshData() async {
    _isRefreshing = true;
    notifyListeners();
    await fetchData(silent: true);
  }
}
