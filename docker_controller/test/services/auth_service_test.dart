import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late AuthService authService;
  late MockDockerService mockDockerService;

  setUp(() {
    registerTestDummies();
    mockDockerService = MockDockerService();
    authService = AuthService(mockDockerService);
  });

  group('AuthService', () {
    test('login returns token on success', () async {
      // Arrange
      final responseData = {'token': 'test-token'};
      when(mockDockerService.post<Map<String, dynamic>>(
        '/login',
        data: {'username': 'user', 'password': 'pass'},
      )).thenAnswer((_) async => Result.success(Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/login'),
          )));

      // Act
      final result = await authService.login('user', 'pass');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, 'test-token');
    });

    test('login returns failure on failure status code', () async {
      // Arrange
      when(mockDockerService.post<Map<String, dynamic>>(
        '/login',
        data: {'username': 'user', 'password': 'pass'},
      )).thenAnswer((_) async => Result.success(Response(
            data: null,
            statusCode: 401,
            requestOptions: RequestOptions(path: '/login'),
          )));

      // Act
      final result = await authService.login('user', 'pass');

      // Assert
      expect(result.isFailure, true);
    });

    test('login returns failure on exception', () async {
      // Arrange
      when(mockDockerService.post<Map<String, dynamic>>(
        '/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Result.failure(AppError(message: 'Network Error')));

      // Act
      final result = await authService.login('user', 'pass');

      // Assert
      expect(result.isFailure, true);
    });
  });
}
