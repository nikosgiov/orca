import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'package:docker_controller/models/connection_config.dart';

class DioClient {
  DioClient() {
    _dio.interceptors.add(_authInterceptor);
    _dio.interceptors.add(_loggingInterceptor);
  }

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  ConnectionConfig? _config;

  Dio get dio => _dio;

  void updateConfig(ConnectionConfig config) {
    _config = config;
    final protocol = config.useTls ? 'https://' : 'http://';
    _dio.options.baseUrl = '$protocol${config.uri}';
  }

  late final Interceptor _authInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) {
      final config = _config;
      if (config != null && config.token != null && config.token!.isNotEmpty) {
        // We use Bearer token even if authType is 'basic' because the backend 
        // returns a JWT after a password-based login.
        options.headers['Authorization'] = 'Bearer ${config.token}';
      }
      return handler.next(options);
    },
  );

  late final Interceptor _loggingInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) {
      developer.log(
        'Dio: Request [${options.method}] ${options.path}',
        name: 'DioClient',
      );
      return handler.next(options);
    },
    onResponse: (response, handler) {
      developer.log(
        'Dio: Response [${response.statusCode}] ${response.requestOptions.path}',
        name: 'DioClient',
      );
      return handler.next(response);
    },
    onError: (error, handler) {
      developer.log(
        'Dio: Error [${error.response?.statusCode}] ${error.message}',
        name: 'DioClient',
      );
      if (error.response?.data != null) {
        developer.log(
          'Dio: Error Response Body: ${error.response?.data}',
          name: 'DioClient',
        );
      }
      return handler.next(error);
    },
  );
}
