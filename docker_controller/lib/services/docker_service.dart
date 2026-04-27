
import 'package:dio/dio.dart';


import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';

class DockerService {
  DockerService(this._dio);

  final Dio _dio;

  /// Performs a GET request to the Docker daemon.
  Future<Result<Response<T>, AppError>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _handleRequest(() => _dio.get<T>(path, queryParameters: queryParameters, options: options));
  }

  /// Performs a POST request to the Docker daemon.
  Future<Result<Response<T>, AppError>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _handleRequest(() => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  /// Performs a DELETE request to the Docker daemon.
  Future<Result<Response<T>, AppError>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _handleRequest(() => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'];
        if (message != null) {
          return message.toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
    }
    return e.message ?? 'Unknown network error';
  }

  String? _getErrorKey(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'errorTimeout';
      case DioExceptionType.connectionError:
        return 'errorConnection';
      default:
        break;
    }

    if (e.response?.statusCode != null) {
      switch (e.response!.statusCode) {
        case 401: return 'errorUnauthorized';
        case 403: return 'errorForbidden';
        case 404: return 'errorNotFound';
        case 500: return 'errorInternal';
      }
    }
    return 'errorUnknown';
  }

  Future<Result<Response<T>, AppError>> _handleRequest<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return Success(response);
    } on DioException catch (e, st) {
      return Failure(AppError(
        message: _getErrorMessage(e),
        l10nKey: _getErrorKey(e),
        error: e,
        stackTrace: st,
        type: e.type.toString(),
      ));
    } catch (e, st) {
      return Failure(AppError(
        message: e.toString(),
        l10nKey: 'errorUnknown',
        error: e,
        stackTrace: st,
      ));
    }
  }
}
