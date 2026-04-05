import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import 'docker_service.dart';

class ImageService {
  static const String _logPrefix = 'myapp';

  static Future<List<Map<String, dynamic>>?> getImages(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/images/json');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        developer.log('$_logPrefix: Successfully fetched ${data.length} images', name: 'ImageService');
        return data.cast<Map<String, dynamic>>();
      } else {
        developer.log('$_logPrefix: Failed to fetch images - Status: ${response.statusCode}', name: 'ImageService');
        throw Exception('HTTP ${response.statusCode}: Failed to fetch images: ${response.body}');
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching images: $e', name: 'ImageService');
      rethrow; // Re-throw the exception so it can be caught by calling methods
    }
  }

  static Future<bool> pullImage(ConnectionConfig config, String imageName, String tag) async {
    try {
      final fullImageName = '$imageName:$tag';
      final response = await DockerService.makePostRequest(
        config,
        '/images/create?fromImage=${Uri.encodeComponent(imageName)}&tag=${Uri.encodeComponent(tag)}',
      );
      if (response.statusCode == 200) {
        developer.log('$_logPrefix: Successfully pulled image $fullImageName', name: 'ImageService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to pull image $fullImageName - Status: ${response.statusCode}, Body: ${response.body}', name: 'ImageService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error pulling image $imageName:$tag: $e', name: 'ImageService');
      return false;
    }
  }

  static Future<bool> imageExists(ConnectionConfig config, String imageName, String tag) async {
    try {
      final fullImageName = '$imageName:$tag';
      final response = await DockerService.makeRequest(config, '/images/$fullImageName/json');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> ensureImageExists(ConnectionConfig config, String imageName, String tag) async {
    final exists = await imageExists(config, imageName, tag);
    if (exists) {
      developer.log('$_logPrefix: Image $imageName:$tag already exists locally', name: 'ImageService');
      return true;
    }
    developer.log('$_logPrefix: Image $imageName:$tag not found locally, attempting to pull...', name: 'ImageService');
    return await pullImage(config, imageName, tag);
  }

  static Future<bool> removeImage(ConnectionConfig config, String imageId) async {
    try {
      final response = await DockerService.makeDeleteRequest(config, '/images/$imageId');
      if (response.statusCode == 200) {
        developer.log('$_logPrefix: Successfully removed image $imageId', name: 'ImageService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to remove image $imageId - Status: ${response.statusCode}, Body: ${response.body}', name: 'ImageService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error removing image $imageId: $e', name: 'ImageService');
      return false;
    }
  }
} 