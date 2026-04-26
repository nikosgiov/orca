import 'dart:developer' as developer;

import '../models/docker_image.dart';
import 'docker_service.dart';

class ImageService {
  ImageService(this._dockerService);

  final DockerService _dockerService;
  static const String _logPrefix = 'orca';

  Future<List<DockerImage>> getImages() async {
    try {
      final response = await _dockerService.get<List<dynamic>>('/images/json');
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((item) => DockerImage.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch images: ${response.statusCode}');
    } catch (e) {
      developer.log(
        '$_logPrefix: Error fetching images: $e',
        name: 'ImageService',
      );
      rethrow;
    }
  }

  Future<bool> pullImage(String imageName, String tag) async {
    try {
      final response = await _dockerService.post(
        '/images/create',
        queryParameters: {'fromImage': imageName, 'tag': tag},
      );
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error pulling image $imageName:$tag: $e',
        name: 'ImageService',
      );
      return false;
    }
  }

  Future<bool> imageExists(String imageName, String tag) async {
    try {
      final fullImageName = '$imageName:$tag';
      final response = await _dockerService.get('/images/$fullImageName/json');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> ensureImageExists(String imageName, String tag) async {
    final exists = await imageExists(imageName, tag);
    if (exists) {
      return true;
    }
    return await pullImage(imageName, tag);
  }

  Future<bool> removeImage(String imageId) async {
    try {
      final response = await _dockerService.delete('/images/$imageId');
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        '$_logPrefix: Error removing image $imageId: $e',
        name: 'ImageService',
      );
      return false;
    }
  }
}
