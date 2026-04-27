import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late ImageService imageService;
  late MockDockerService mockDockerService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    imageService = ImageService(mockDockerService);
  });

  group('ImageService', () {
    test('getImages returns list of images on success', () async {
      final mockResponse = [
        {
          'Id': 'sha256:123',
          'RepoTags': ['nginx:latest'],
          'Size': 1000,
          'Created': 1600000000,
        },
        {
          'Id': 'sha256:456',
          'RepoTags': ['alpine:latest'],
          'Size': 500,
          'Created': 1600000001,
        },
      ];

      when(mockDockerService.get<List<dynamic>>('/images/json'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/images/json'),
              )));

      final result = await imageService.getImages();

      expect(result.isSuccess, isTrue);
      final images = result.valueOrNull!;
      expect(images.length, 2);
      expect(images[0].repoTags, contains('nginx:latest'));
      expect(images[1].repoTags, contains('alpine:latest'));
    });

    test('getImages returns failure on failure', () async {
      when(mockDockerService.get<List<dynamic>>('/images/json'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: '/images/json'),
              )));

      final result = await imageService.getImages();
      expect(result.isFailure, isTrue);
    });

    test('pullImage returns success on success', () async {
      when(mockDockerService.post(
        '/images/create',
        queryParameters: {'fromImage': 'nginx', 'tag': 'latest'},
      )).thenAnswer((_) async => Result.success(Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: '/images/create'),
          )));

      final result = await imageService.pullImage('nginx', 'latest');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('imageExists returns true if image is found', () async {
      when(mockDockerService.get('/images/nginx:latest/json'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: '/images/nginx:latest/json'),
              )));

      final result = await imageService.imageExists('nginx', 'latest');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('imageExists returns false if image is not found', () async {
      when(mockDockerService.get('/images/nginx:latest/json'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 404,
                requestOptions: RequestOptions(path: '/images/nginx:latest/json'),
              )));

      final result = await imageService.imageExists('nginx', 'latest');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isFalse);
    });

    test('removeImage returns success on success', () async {
      when(mockDockerService.delete('/images/sha256:123'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: '/images/sha256:123'),
              )));

      final result = await imageService.removeImage('sha256:123');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });
  });
}
