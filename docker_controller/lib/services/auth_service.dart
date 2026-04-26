import 'package:dio/dio.dart';


class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['token'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
