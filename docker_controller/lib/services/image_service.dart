import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'docker_service.dart';

class ImageService {
  ImageService(this._dockerService);

  final DockerService _dockerService;

  Future<Result<List<DockerImage>, AppError>> getImages() async {
    final result = await _dockerService.get<List<dynamic>>('/images/json');
    return result.fold(
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          final images = response.data!
              .map((item) => DockerImage.fromJson(item as Map<String, dynamic>))
              .toList();
          return Success(images);
        }
        return Failure(AppError(message: 'Failed to fetch images: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> pullImage(String imageName, String tag) async {
    final result = await _dockerService.post(
      '/images/create',
      queryParameters: {'fromImage': imageName, 'tag': tag},
    );
    return result.fold(
      (response) {
        if (response.statusCode == 200) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to pull image: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }

  Future<Result<bool, AppError>> imageExists(String imageName, String tag) async {
    final fullImageName = '$imageName:$tag';
    final result = await _dockerService.get('/images/$fullImageName/json');
    return result.fold(
      (response) => Success(response.statusCode == 200),
      (_) => const Success(false),
    );
  }

  Future<bool> ensureImageExists(String imageName, String tag) async {
    final existsResult = await imageExists(imageName, tag);
    final exists = existsResult.fold((val) => val, (_) => false);
    if (exists) {
      return true;
    }
    
    final pullResult = await pullImage(imageName, tag);
    return pullResult.fold((val) => val, (_) => false);
  }

  Future<Result<bool, AppError>> removeImage(String imageId) async {
    final result = await _dockerService.delete('/images/$imageId');
    return result.fold(
      (response) {
        if (response.statusCode == 200) {
          return const Success(true);
        }
        return Failure(AppError(message: 'Failed to remove image: ${response.statusCode}'));
      },
      (failure) => Failure(failure),
    );
  }
}
