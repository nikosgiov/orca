import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/providers/containers_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late ContainersProvider provider;
  late MockAuthProvider mockAuthProvider;
  late MockContainerService mockContainerService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockContainerService = MockContainerService();

    // Register mockContainerService in GetIt for DI
    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<ContainerService>(mockContainerService);

    provider = ContainersProvider(mockAuthProvider);
  });

  group('ContainersProvider TDD - AppState Integration', () {
    test('Initial state should be AppInitial', () {
      expect(provider.state, isA<AppInitial<List<DockerContainer>>>());
    });

    test(
      'fetchContainers should transition to AppLoading then AppSuccess',
      () async {
        final containers = [
          const DockerContainer(
            id: '1',
            image: 'nginx',
            state: 'running',
            created: 12345,
          ),
        ];

        when(mockAuthProvider.isConnected).thenReturn(true);
        when(
          mockContainerService.getContainers(),
        ).thenAnswer((_) async => containers);

        final future = provider.fetchContainers();

        // Check loading state
        expect(provider.state, isA<AppLoading<List<DockerContainer>>>());

        await future;

        // Check success state
        expect(provider.state, isA<AppSuccess<List<DockerContainer>>>());
        final successState =
            provider.state as AppSuccess<List<DockerContainer>>;
        expect(successState.data, containers);
      },
    );

    test('fetchContainers should transition to AppError on failure', () async {
      when(mockAuthProvider.isConnected).thenReturn(true);
      when(
        mockContainerService.getContainers(),
      ).thenThrow(Exception('Network Error'));

      await provider.fetchContainers();

      expect(provider.state, isA<AppError<List<DockerContainer>>>());
      final errorState = provider.state as AppError<List<DockerContainer>>;
      expect(errorState.message, contains('Network Error'));
    });
  });
}
