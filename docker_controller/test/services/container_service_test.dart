import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late ContainerService containerService;
  late MockDockerService mockDockerService;
  late MockImageService mockImageService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    mockImageService = MockImageService();
    containerService = ContainerService(
      dockerService: mockDockerService,
      imageService: mockImageService,
    );
  });

  group('ContainerService', () {
    test('getContainers returns list of containers on success', () async {
      // Arrange
      final containersData = [
        {
          'Id': '123',
          'Names': ['/test-container'],
          'Image': 'test-image',
          'State': 'running',
          'Status': 'Up 1 hour',
          'Created': 1600000000,
        }
      ];
      
      when(mockDockerService.get<List<dynamic>>('/containers/json?all=true'))
          .thenAnswer((_) async => Result.success(Response(
                data: containersData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              )));

      // Act
      final result = await containerService.getContainers();

      // Assert
      expect(result.isSuccess, true);
      final containers = result.valueOrNull!;
      expect(containers.length, 1);
      expect(containers[0].id, '123');
      expect(containers[0].displayName, 'test-container');
    });

    test('startContainer returns success on success', () async {
      // Arrange
      when(mockDockerService.post('/containers/123/start'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: ''),
              )));

      // Act
      final result = await containerService.startContainer('123');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, true);
    });

    test('stopContainer returns success on success', () async {
      // Arrange
      when(mockDockerService.post('/containers/123/stop'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: ''),
              )));

      // Act
      final result = await containerService.stopContainer('123');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, true);
    });
  });
}
