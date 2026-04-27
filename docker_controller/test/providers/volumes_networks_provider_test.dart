import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/models/docker_network.dart';
import 'package:docker_controller/models/docker_volume.dart';
import 'package:docker_controller/providers/volumes_networks_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late VolumesNetworksProvider provider;
  late MockVolumeService mockVolumeService;
  late MockNetworkService mockNetworkService;

  const testConfig = ConnectionConfig(
    uri: 'localhost',
    authType: AuthType.none,
  );

  setUp(() {
    registerTestDummies();
    mockVolumeService = MockVolumeService();
    mockNetworkService = MockNetworkService();
    provider = VolumesNetworksProvider(
      volumeService: mockVolumeService,
      networkService: mockNetworkService,
    );
    provider.connectionConfig = testConfig;
  });

  group('VolumesNetworksProvider', () {
    test('fetchVolumes should transition to AppSuccess on success', () async {
      final mockVolumes = [
        const DockerVolume(name: 'v1', driver: 'local', mountpoint: '/p1', scope: 'local'),
      ];

      when(mockVolumeService.getVolumes()).thenAnswer((_) async => Result.success(mockVolumes));

      final future = provider.fetchVolumes();

      expect(provider.volumesState, isA<AppLoading>());
      await future;
      expect(provider.volumesState, isA<AppSuccess<List<DockerVolume>>>());
      expect(provider.volumes, mockVolumes);
    });

    test('fetchNetworks should transition to AppSuccess on success', () async {
      final mockNetworks = [
        const DockerNetwork(id: 'n1', name: 'net1', driver: 'bridge', scope: 'local', internal: false, enableIPv6: false),
      ];

      when(mockNetworkService.getNetworks()).thenAnswer((_) async => Result.success(mockNetworks));
      when(mockNetworkService.inspectNetwork('n1')).thenAnswer((_) async => Result.success(mockNetworks[0]));

      final future = provider.fetchNetworks();

      expect(provider.networksState, isA<AppLoading>());
      await future;
      expect(provider.networksState, isA<AppSuccess<List<DockerNetwork>>>());
      expect(provider.networks, mockNetworks);
    });

    test('removeVolume should call service and refresh', () async {
      when(mockVolumeService.removeVolume('v1')).thenAnswer((_) async => Result.success(true));
      when(mockVolumeService.getVolumes()).thenAnswer((_) async => Result.success(<DockerVolume>[]));

      final success = await provider.removeVolume('v1');

      expect(success, isTrue);
      verify(mockVolumeService.removeVolume('v1')).called(1);
      verify(mockVolumeService.getVolumes()).called(1);
    });
  });
}
