import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/resource_metrics.dart';
import 'package:docker_controller/providers/resource_monitoring_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late ResourceMonitoringProvider provider;
  late MockSystemService mockSystemService;
  late MockContainerService mockContainerService;
  late MockImageService mockImageService;

  setUp(() {
    mockSystemService = MockSystemService();
    mockContainerService = MockContainerService();
    mockImageService = MockImageService();

    getIt.reset();
    getIt.registerSingleton<SystemService>(mockSystemService);
    getIt.registerSingleton<ContainerService>(mockContainerService);
    getIt.registerSingleton<ImageService>(mockImageService);

    provider = ResourceMonitoringProvider(mockSystemService);
    provider.updateConnectionConfig(null); // Just to satisfy check if needed
  });

  group('ResourceMonitoringProvider', () {
    test('initial state should be AppInitial', () {
      expect(provider.state, isA<AppInitial>());
    });

    test('fetchData sets state to AppSuccess on success', () async {
      // Setup connection config mock-like
      provider.updateConnectionConfig(null); // We bypass this by having a non-null systemService in the provider

      final mockData = {
        'metrics': {
          'cpu': [10.0, 15.0],
          'memory': [1024.0, 2048.0],
          'timestamps': [
            DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
            DateTime.now().toIso8601String(),
          ],
        }
      };

      when(mockSystemService.getSystemMetrics(any))
          .thenAnswer((_) async => mockData);
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => {});
      when(mockContainerService.getContainers()).thenAnswer((_) async => []);
      when(mockImageService.getImages()).thenAnswer((_) async => []);

      await provider.fetchData();

      expect(provider.state, isA<AppSuccess<ResourceMetrics>>());
      final successState = provider.state as AppSuccess<ResourceMetrics>;
      expect(successState.data.rawMetrics['cpu'], contains(10.0));
    });

    test('fetchData sets state to AppError on failure', () async {
      when(mockSystemService.getSystemMetrics(any))
          .thenThrow(Exception('API Error'));
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => {});
      when(mockContainerService.getContainers()).thenAnswer((_) async => []);
      when(mockImageService.getImages()).thenAnswer((_) async => []);

      await provider.fetchData();

      expect(provider.state, isA<AppError>());
      final errorState = provider.state as AppError;
      expect(errorState.message, contains('API Error'));
    });
  });
}
