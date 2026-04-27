import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late NetworkService networkService;
  late MockDockerService mockDockerService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    networkService = NetworkService(mockDockerService);
  });

  group('NetworkService', () {
    test('getNetworks returns list of networks on success', () async {
      final mockResponse = [
        {
          'Id': 'net1',
          'Name': 'network1',
          'Driver': 'bridge',
          'Scope': 'local',
          'Internal': false,
          'EnableIPv6': false,
        },
        {
          'Id': 'net2',
          'Name': 'network2',
          'Driver': 'overlay',
          'Scope': 'swarm',
          'Internal': true,
          'EnableIPv6': true,
        },
      ];

      when(mockDockerService.get<List<dynamic>>('/networks'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/networks'),
              )));

      final result = await networkService.getNetworks();

      expect(result.isSuccess, isTrue);
      final networks = result.valueOrNull!;
      expect(networks.length, 2);
      expect(networks[0].name, 'network1');
      expect(networks[0].internal, isFalse);
      expect(networks[1].name, 'network2');
      expect(networks[1].internal, isTrue);
    });

    test('createNetwork returns true on 201 created', () async {
      when(mockDockerService.post(
        '/networks/create',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Result.success(Response(
            statusCode: 201,
            requestOptions: RequestOptions(path: '/networks/create'),
          )));

      final result = await networkService.createNetwork('my_net');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('removeNetwork returns true on 204 no content', () async {
      when(mockDockerService.delete('/networks/my_net'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: '/networks/my_net'),
              )));

      final result = await networkService.removeNetwork('my_net');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('inspectNetwork returns network details on success', () async {
      final mockResponse = {
        'Id': 'net1',
        'Name': 'network1',
        'Driver': 'bridge',
        'Scope': 'local',
        'Internal': false,
        'EnableIPv6': false,
      };

      when(mockDockerService.get<Map<String, dynamic>>('/networks/net1'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/networks/net1'),
              )));

      final result = await networkService.inspectNetwork('net1');

      expect(result.isSuccess, isTrue);
      final network = result.valueOrNull!;
      expect(network.id, 'net1');
      expect(network.name, 'network1');
    });
  });
}
