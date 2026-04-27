import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/providers/containers_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late ContainersProvider provider;
  late MockAuthProvider mockAuthProvider;
  late MockContainerService mockContainerService;

  setUp(() {
    registerTestDummies();
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
        ).thenAnswer((_) async => Result.success(containers));

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

    test('fetchContainers should transition to AppStateError on failure', () async {
      when(mockAuthProvider.isConnected).thenReturn(true);
      when(
        mockContainerService.getContainers(),
      ).thenAnswer((_) async => Result.failure(AppError(message: 'Network Error')));

      await provider.fetchContainers();

      expect(provider.state, isA<AppStateError<List<DockerContainer>>>());
      final errorState = provider.state as AppStateError<List<DockerContainer>>;
      expect(errorState.failure.message, contains('Network Error'));
    });

    test('filteredContainers should correctly filter by search query', () async {
      final containers = [
        const DockerContainer(id: '1', image: 'nginx', state: 'running', names: ['/web-server'], created: 12345),
        const DockerContainer(id: '2', image: 'redis', state: 'running', names: ['/cache-db'], created: 12345),
      ];

      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockContainerService.getContainers()).thenAnswer((_) async => Result.success(containers));

      await provider.fetchContainers();
      
      provider.searchQuery = 'web';
      expect(provider.filteredContainers.length, 1);
      expect(provider.filteredContainers.first.displayName, 'web-server');
    });

    test('filteredContainers should correctly filter by state', () async {
      final containers = [
        const DockerContainer(id: '1', image: 'nginx', state: 'running', names: ['/web-server'], created: 12345),
        const DockerContainer(id: '2', image: 'redis', state: 'exited', names: ['/cache-db'], created: 12345),
      ];

      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockContainerService.getContainers()).thenAnswer((_) async => Result.success(containers));

      await provider.fetchContainers();
      
      provider.selectedFilter = 'Running';
      expect(provider.filteredContainers.length, 1);
      expect(provider.filteredContainers.first.state, 'running');

      provider.selectedFilter = 'Exited';
      expect(provider.filteredContainers.length, 1);
      expect(provider.filteredContainers.first.state, 'exited');
    });

    test('startContainer should call service and refresh list on success', () async {
      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockContainerService.startContainer('1')).thenAnswer((_) async => Result.success(true));
      when(mockContainerService.getContainers()).thenAnswer((_) async => Result.success([]));

      final result = await provider.startContainer('1');

      expect(result, true);
      verify(mockContainerService.startContainer('1')).called(1);
      verify(mockContainerService.getContainers()).called(1);
    });

    test('stopContainer should return false on service failure', () async {
      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockContainerService.stopContainer('1')).thenAnswer((_) async => Result.failure(AppError(message: 'Fail')));

      final result = await provider.stopContainer('1');

      expect(result, false);
      verify(mockContainerService.stopContainer('1')).called(1);
    });
  });
}
