import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late SystemService systemService;
  late MockDockerService mockDockerService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    systemService = SystemService(mockDockerService);
  });

  group('SystemService', () {
    test('getSystemInfo returns data on 200', () async {
      final mockResponse = {'ID': 'daemon-id', 'Containers': 5};

      when(mockDockerService.get<Map<String, dynamic>>('/info'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/info'),
              )));

      final result = await systemService.getSystemInfo();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!['ID'], 'daemon-id');
    });

    test('testConnection returns true on 200', () async {
      when(mockDockerService.get('/version'))
          .thenAnswer((_) async => Result.success(Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: '/version'),
              )));

      final result = await systemService.testConnection();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('getFirebaseConfig returns config on 200', () async {
      final mockResponse = {'apiKey': 'xyz'};

      when(mockDockerService.get<Map<String, dynamic>>('/config/firebase'))
          .thenAnswer((_) async => Result.success(Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/config/firebase'),
              )));

      final result = await systemService.getFirebaseConfig();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!['apiKey'], 'xyz');
    });

    test('getSystemMetrics returns metrics on 200', () async {
      final mockResponse = {'cpu_usage': 10.5};

      when(mockDockerService.get<Map<String, dynamic>>(
        '/system/metrics',
        queryParameters: {'window': '30m'},
      )).thenAnswer((_) async => Result.success(Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/system/metrics'),
          )));

      final result = await systemService.getSystemMetrics();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!['cpu_usage'], 10.5);
    });
  });
}
