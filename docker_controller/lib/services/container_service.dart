import 'dart:convert';
import 'dart:developer' as developer;
import '../models/connection_config.dart';
import 'docker_service.dart'; // For makeRequest and helpers
import 'image_service.dart';

class ContainerService {
  static const String _logPrefix = 'myapp';

  // Get all containers
  static Future<List<Map<String, dynamic>>?> getContainers(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/containers/json?all=true');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        developer.log('$_logPrefix: Successfully fetched ${data.length} containers', name: 'ContainerService');
        return data.cast<Map<String, dynamic>>();
      } else {
        developer.log('$_logPrefix: Failed to fetch containers - Status: ${response.statusCode}', name: 'ContainerService');
        throw Exception('HTTP ${response.statusCode}: Failed to fetch containers: ${response.body}');
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching containers: $e', name: 'ContainerService');
      rethrow; // Re-throw the exception so it can be caught by calling methods
    }
  }

  // Get info for a specific container
  static Future<Map<String, dynamic>?> getContainerInfo(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makeRequest(config, '/containers/$containerId/json');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('$_logPrefix: Successfully fetched info for container $containerId', name: 'ContainerService');
        return data as Map<String, dynamic>?;
      } else {
        developer.log('$_logPrefix: Failed to fetch info for container $containerId - Status: ${response.statusCode}', name: 'ContainerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching container info: $e', name: 'ContainerService');
      return null;
    }
  }

  // Get stats for a specific container
  static Future<Map<String, dynamic>?> getContainerStats(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makeRequest(config, '/containers/$containerId/stats?stream=false');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('$_logPrefix: Successfully fetched stats for container $containerId', name: 'ContainerService');
        return data;
      } else {
        developer.log('$_logPrefix: Failed to fetch stats for container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching container stats: $e', name: 'ContainerService');
      return null;
    }
  }

  static Future<String?> getContainerLogs(ConnectionConfig config, String containerId, {int tail = 200, String? since}) async {
    try {
      String endpoint = '/containers/$containerId/logs?stdout=true&stderr=true';
      if (tail > 0) {
        endpoint += '&tail=$tail';
      } else {
        endpoint += '&tail=all';
      }
      if (since != null) {
        endpoint += '&since=$since';
      }
      final response = await DockerService.makeRequest(config, endpoint);
      if (response.statusCode == 200) {
        developer.log('$_logPrefix: Successfully fetched logs for container $containerId', name: 'ContainerService');
        return response.body;
      } else {
        developer.log('$_logPrefix: Failed to fetch logs for container $containerId - Status: ${response.statusCode}', name: 'ContainerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching container logs: $e', name: 'ContainerService');
      return null;
    }
  }

  static Future<bool> startContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/start');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully started container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to start container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error starting container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> stopContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/stop');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully stopped container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to stop container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error stopping container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> pauseContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/pause');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully paused container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to pause container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error pausing container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> resumeContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/unpause');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully resumed container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to resume container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error resuming container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> restartContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/restart');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully restarted container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to restart container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error restarting container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> killContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/kill');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully killed container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to kill container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error killing container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> removeContainer(ConnectionConfig config, String containerId) async {
    try {
      final response = await DockerService.makeDeleteRequest(config, '/containers/$containerId');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully removed container $containerId', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to remove container $containerId - Status: \\${response.statusCode}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error removing container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<bool> renameContainer(ConnectionConfig config, String containerId, String newName) async {
    try {
      final encodedName = Uri.encodeComponent(newName);
      final response = await DockerService.makePostRequest(config, '/containers/$containerId/rename?name=$encodedName');
      if (response.statusCode == 204) {
        developer.log('$_logPrefix: Successfully renamed container $containerId to $newName', name: 'ContainerService');
        return true;
      } else {
        developer.log('$_logPrefix: Failed to rename container $containerId - Status: \\${response.statusCode}, Body: ${response.body}', name: 'ContainerService');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error renaming container $containerId: $e', name: 'ContainerService');
      return false;
    }
  }

  static Future<String?> createContainer(ConnectionConfig config, Map<String, dynamic> containerConfig) async {
    try {
      // Extract name from config if present
      String? containerName;
      if (containerConfig.containsKey('name')) {
        containerName = containerConfig['name'] as String?;
        containerConfig.remove('name'); // Remove from body, will be passed as query param
      }

      // Extract image name and ensure it exists
      final imageName = containerConfig['Image'] as String?;
      if (imageName != null) {
        // Parse image name and tag
        String image, tag;
        if (imageName.contains(':')) {
          final parts = imageName.split(':');
          image = parts[0];
          tag = parts[1];
        } else {
          image = imageName;
          tag = 'latest';
        }

        // Ensure image exists (pull if necessary)
        final imageExists = await ImageService.ensureImageExists(config, image, tag);
        if (!imageExists) {
          developer.log('$_logPrefix: Failed to ensure image exists: $imageName', name: 'ContainerService');
          return null;
        }
      }

      // Build the endpoint URL with name as query parameter
      String endpoint = '/containers/create';
      if (containerName != null && containerName.isNotEmpty) {
        endpoint += '?name=${Uri.encodeComponent(containerName)}';
      }

      final response = await DockerService.makePostRequest(
        config, 
        endpoint,
        body: json.encode(containerConfig),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final containerId = data['Id'] as String?;
        developer.log('$_logPrefix: Successfully created container $containerId with name: $containerName', name: 'ContainerService');
        return containerId;
      } else {
        developer.log('$_logPrefix: Failed to create container - Status: ${response.statusCode}, Body: ${response.body}', name: 'ContainerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error creating container: $e', name: 'ContainerService');
      return null;
    }
  }

  static Future<String?> createAndStartContainer(ConnectionConfig config, Map<String, dynamic> containerConfig) async {
    try {
      // First create the container
      final containerId = await createContainer(config, containerConfig);
      
      if (containerId != null) {
        // Then start the container
        final started = await startContainer(config, containerId);
        if (started) {
          developer.log('$_logPrefix: Successfully created and started container $containerId', name: 'ContainerService');
          return containerId;
        }
      }
      return null;
    } catch (e) {
      developer.log('$_logPrefix: Error creating and starting container: $e', name: 'ContainerService');
      return null;
    }
  }

  // Add more container-related methods here as needed
} 