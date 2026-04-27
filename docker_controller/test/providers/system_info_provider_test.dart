import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/providers/system_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late SystemInfoProvider provider;
  late MockSystemService mockSystemService;
  late MockContainerService mockContainerService;
  late MockImageService mockImageService;

  const testConfig = ConnectionConfig(
    uri: 'localhost',
    authType: AuthType.none,
  );

  setUp(() {
    registerTestDummies();
    mockSystemService = MockSystemService();
    mockContainerService = MockContainerService();
    mockImageService = MockImageService();
    provider = SystemInfoProvider(
      systemService: mockSystemService,
      containerService: mockContainerService,
      imageService: mockImageService,
    );
  });

  group('SystemInfoProvider', () {
    test('fetchSystemData should fetch and update state', () async {
      final mockInfo = <String, dynamic>{'ServerVersion': '1.0'};
      final mockContainers = [
        const DockerContainer(id: '1', image: 'i1', state: 'running', created: 0),
      ];
      final mockImages = [
        const DockerImage(id: 'i1', repoTags: ['t1'], size: 0, created: 0),
      ];
      final mockMetrics = <String, dynamic>{'static': {'cpu': 'intel'}};

      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => Result.success(mockInfo));
      when(mockContainerService.getContainers()).thenAnswer((_) async => Result.success(mockContainers));
      when(mockImageService.getImages()).thenAnswer((_) async => Result.success(mockImages));
      when(mockSystemService.getSystemMetrics()).thenAnswer((_) async => Result.success(mockMetrics));

      await provider.fetchSystemData(testConfig);

      expect(provider.systemInfo, mockInfo);
      expect(provider.containers, mockContainers);
      expect(provider.images, mockImages);
      expect(provider.staticInfo, mockMetrics['static']);
    });

    test('getDockerVersion should return correct version', () async {
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => Result.success(<String, dynamic>{'ServerVersion': '20.10'}));
      when(mockContainerService.getContainers()).thenAnswer((_) async => Result.success(<DockerContainer>[]));
      when(mockImageService.getImages()).thenAnswer((_) async => Result.success(<DockerImage>[]));
      when(mockSystemService.getSystemMetrics()).thenAnswer((_) async => Result.success(<String, dynamic>{}));

      await provider.fetchSystemData(testConfig);

      expect(provider.getDockerVersion(), '20.10');
    });
  });
}
