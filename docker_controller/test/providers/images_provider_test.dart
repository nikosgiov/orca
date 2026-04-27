import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/providers/images_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late ImagesProvider imagesProvider;
  late MockAuthProvider mockAuthProvider;
  late MockImageService mockImageService;

  setUp(() {
    registerTestDummies();
    mockAuthProvider = MockAuthProvider();
    mockImageService = MockImageService();
    imagesProvider = ImagesProvider(mockAuthProvider, imageService: mockImageService);
  });

  group('ImagesProvider', () {
    test('initial state should be AppInitial', () {
      expect(imagesProvider.state, isA<AppInitial>());
    });

    test('fetchImages should transition to AppSuccess on success', () async {
      final mockImages = [
        const DockerImage(id: '1', repoTags: ['nginx:latest'], size: 100, created: 0),
      ];

      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockImageService.getImages()).thenAnswer((_) async => Result.success(mockImages));

      final future = imagesProvider.fetchImages();

      expect(imagesProvider.state, isA<AppLoading>());
      await future;
      expect(imagesProvider.state, isA<AppSuccess<List<DockerImage>>>());
      expect(imagesProvider.images, mockImages);
    });

    test('fetchImages should transition to AppStateError on failure', () async {
      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockImageService.getImages()).thenAnswer((_) async => Result.failure(AppError(message: 'Failed')));

      await imagesProvider.fetchImages();

      expect(imagesProvider.state, isA<AppStateError>());
    });

    test('removeImage should call service and refresh on success', () async {
      const image = DockerImage(id: '1', repoTags: ['nginx:latest'], size: 100, created: 0);

      when(mockAuthProvider.isConnected).thenReturn(true);
      when(mockImageService.removeImage('1')).thenAnswer((_) async => Result.success(true));
      when(mockImageService.getImages()).thenAnswer((_) async => Result.success([]));

      final (success, _) = await imagesProvider.removeImage(image);

      expect(success, isTrue);
      verify(mockImageService.removeImage('1')).called(1);
      verify(mockImageService.getImages()).called(1);
    });
  });
}
