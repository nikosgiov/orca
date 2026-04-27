import 'package:dio/dio.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/models/docker_network.dart';
import 'package:docker_controller/models/docker_volume.dart';
import 'package:mockito/mockito.dart';

void registerTestDummies() {
  provideDummy<Result<List<DockerContainer>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<List<DockerImage>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<List<DockerVolume>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<List<DockerNetwork>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<DockerNetwork, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<bool, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<String, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<Map<String, dynamic>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<Response<Map<String, dynamic>>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<Response<List<dynamic>>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
  provideDummy<Result<Response<dynamic>, AppError>>(
    Result.failure(AppError(message: 'dummy')),
  );
}
