import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late VolumeService volumeService;
  late MockDockerService mockDockerService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    volumeService = VolumeService(mockDockerService);
  });

  group('VolumeService', () {
    test('getVolumes returns list of volumes on success', () async {
      final mockResponse = {
        'Volumes': [
          {
            'Name': 'volume1',
            'Driver': 'local',
            'Mountpoint': '/var/lib/docker/volumes/volume1/_data',
            'CreatedAt': '2020-01-01T00:00:00Z',
            'Scope': 'local',
          },
          {
            'Name': 'volume2',
            'Driver': 'local',
            'Mountpoint': '/var/lib/docker/volumes/volume2/_data',
            'CreatedAt': '2020-01-01T00:00:01Z',
            'Scope': 'local',
          },
        ],
      };

      when(mockDockerService.get<Map<String, dynamic>>('/volumes'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/volumes'),
              )));

      final result = await volumeService.getVolumes();

      expect(result.isSuccess, isTrue);
      final volumes = result.valueOrNull!;
      expect(volumes.length, 2);
      expect(volumes[0].name, 'volume1');
      expect(volumes[1].name, 'volume2');
    });

    test('createVolume returns true on 201 created', () async {
      when(mockDockerService.post(
        '/volumes/create',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Result.success(Response(
            statusCode: 201,
            requestOptions: RequestOptions(path: '/volumes/create'),
          )));

      final result = await volumeService.createVolume('my_volume');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('removeVolume returns true on 204 no content', () async {
      when(mockDockerService.delete('/volumes/my_volume'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: '/volumes/my_volume'),
              )));

      final result = await volumeService.removeVolume('my_volume');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('removeVolume returns failure on failure', () async {
      when(mockDockerService.delete('/volumes/my_volume'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 404,
                requestOptions: RequestOptions(path: '/volumes/my_volume'),
              )));

      final result = await volumeService.removeVolume('my_volume');

      expect(result.isFailure, isTrue);
    });
  });
}
