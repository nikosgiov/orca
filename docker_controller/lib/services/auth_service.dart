import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'docker_service.dart';

class AuthService {
  AuthService(this._dockerService);

  final DockerService _dockerService;

  Future<Result<String, AppError>> login(String username, String password) async {
    final result = await _dockerService.post<Map<String, dynamic>>(
      '/login',
      data: {'username': username, 'password': password},
    );

    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final token = response.data!['token'] as String?;
          if (token != null) {
            return Success(token);
          }
        }
        return Failure(AppError(message: 'Login failed: Invalid response from server'));
      },
      (failure) => Failure(failure),
    );
  }
}
