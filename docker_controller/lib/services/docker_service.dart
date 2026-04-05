import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/connection_config.dart';

class DockerService {
  static const String _logPrefix = 'myapp';

  // Container statistics
  static Future<List<Map<String, dynamic>>?> getContainers(ConnectionConfig config) async {
    try {
      final response = await makeRequest(config, '/containers/json?all=true');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        developer.log('$_logPrefix: Successfully fetched ${data.length} containers', name: 'DockerService');
        return data.cast<Map<String, dynamic>>();
      } else {
        developer.log('$_logPrefix: Failed to fetch containers - Status: ${response.statusCode}', name: 'DockerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching containers: $e', name: 'DockerService');
      return null;
    }
  }

  // Container statistics for resource usage
  static Future<Map<String, dynamic>?> getContainerStats(ConnectionConfig config, String containerId) async {
    try {
      final response = await makeRequest(config, '/containers/$containerId/stats?stream=false');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('$_logPrefix: Successfully fetched stats for container $containerId', name: 'DockerService');
        return data;
      } else {
        developer.log('$_logPrefix: Failed to fetch stats for container $containerId - Status: ${response.statusCode}', name: 'DockerService');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching container stats: $e', name: 'DockerService');
      return null;
    }
  }

  // Helper method to make HTTP requests
  static Future<http.Response> makeRequest(ConnectionConfig config, String endpoint) async {
    final protocol = config.useTls ? 'https://' : 'http://';
    final uri = Uri.parse('$protocol${config.uri}$endpoint');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authentication headers
    if (config.authType == AuthType.basic && config.token != null) {
      headers['Authorization'] = 'Bearer ${config.token}';
    }
    // No auth header for AuthType.none

    developer.log('$_logPrefix: Making request to $uri', name: 'DockerService');
    
    return await http.get(uri, headers: headers);
  }

  // Helper method to calculate CPU usage percentage
  static double calculateCpuUsage(Map<String, dynamic> stats) {
    try {
      final cpuStats = stats['cpu_stats'] as Map<String, dynamic>?;
      final preCpuStats = stats['precpu_stats'] as Map<String, dynamic>?;

      if (cpuStats == null || preCpuStats == null) return 0.0;

      final cpuUsageMap = cpuStats['cpu_usage'] as Map<String, dynamic>?;
      final preCpuUsageMap = preCpuStats['cpu_usage'] as Map<String, dynamic>?;

      final totalUsage = (cpuUsageMap?['total_usage'] ?? 0) as num;
      final preTotalUsage = (preCpuUsageMap?['total_usage'] ?? 0) as num;

      final systemCpuUsage = cpuStats['system_cpu_usage'] as num?;
      final preSystemCpuUsage = preCpuStats['system_cpu_usage'] as num?;

      if (systemCpuUsage == null || preSystemCpuUsage == null) return 0.0;

      final cpuDelta = totalUsage - preTotalUsage;
      final systemDelta = systemCpuUsage - preSystemCpuUsage;
      
      if (systemDelta > 0 && cpuDelta > 0) {
        final onlineCpus = (cpuStats['online_cpus'] ?? 1) as num;
        return (cpuDelta / systemDelta) * onlineCpus * 100.0;
      }
      return 0.0;
    } catch (e) {
      developer.log('$_logPrefix: Error calculating CPU usage: $e', name: 'DockerService');
      return 0.0;
    }
  }

  // Helper method to calculate memory usage percentage
  static double calculateMemoryUsage(Map<String, dynamic> stats) {
    try {
      final memoryStats = stats['memory_stats'] as Map<String, dynamic>?;
      if (memoryStats == null) return 0.0;

      final memoryUsage = (memoryStats['usage'] ?? 0) as num;
      final memoryLimit = (memoryStats['limit'] ?? 1) as num;
      
      if (memoryLimit > 0) {
        return (memoryUsage / memoryLimit) * 100.0;
      }
      return 0.0;
    } catch (e) {
      developer.log('$_logPrefix: Error calculating memory usage: $e', name: 'DockerService');
      return 0.0;
    }
  }

  // Helper method to calculate disk I/O
  static double calculateDiskIO(Map<String, dynamic> stats) {
    try {
      final blkioStats = stats['blkio_stats'] as Map<String, dynamic>?;
      if (blkioStats == null) return 0.0;
      
      final ioServiceBytes = blkioStats['io_service_bytes_recursive'] as List<dynamic>?;
      if (ioServiceBytes != null) {
        double totalIO = 0.0;
        for (final io in ioServiceBytes) {
          if (io is Map<String, dynamic>) {
            final op = io['op']?.toString();
            if (op == 'Read' || op == 'Write') {
              totalIO += ((io['value'] ?? 0) as num).toDouble();
            }
          }
        }
        // Convert to MB/s (assuming accumulation, not true rate without tracking time delta)
        return totalIO / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      developer.log('$_logPrefix: Error calculating disk I/O: $e', name: 'DockerService');
      return 0.0;
    }
  }

  // Helper method to calculate network I/O
  static double calculateNetworkIO(Map<String, dynamic> stats) {
    try {
      final networks = stats['networks'] as Map<String, dynamic>?;
      if (networks != null) {
        double totalBytes = 0.0;
        for (final network in networks.values) {
          if (network is Map<String, dynamic>) {
            totalBytes += ((network['rx_bytes'] ?? 0) as num).toDouble();
            totalBytes += ((network['tx_bytes'] ?? 0) as num).toDouble();
          }
        }
        // Convert to MB
        return totalBytes / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      developer.log('$_logPrefix: Error calculating network I/O: $e', name: 'DockerService');
      return 0.0;
    }
  }

  // Helper method to make POST requests
  static Future<http.Response> makePostRequest(ConnectionConfig config, String endpoint, {String? body}) async {
    final protocol = config.useTls ? 'https://' : 'http://';
    final uri = Uri.parse('$protocol${config.uri}$endpoint');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authentication headers
    if (config.authType == AuthType.basic && config.token != null) {
      headers['Authorization'] = 'Bearer ${config.token}';
    }
    // No auth header for AuthType.none

    developer.log('$_logPrefix: Making POST request to $uri', name: 'DockerService');
    
    return await http.post(uri, headers: headers, body: body);
  }

  // Helper method to make DELETE requests
  static Future<http.Response> makeDeleteRequest(ConnectionConfig config, String endpoint) async {
    final protocol = config.useTls ? 'https://' : 'http://';
    final uri = Uri.parse('$protocol${config.uri}$endpoint');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authentication headers
    if (config.authType == AuthType.basic && config.token != null) {
      headers['Authorization'] = 'Bearer ${config.token}';
    }
    // No auth header for AuthType.none

    developer.log('$_logPrefix: Making DELETE request to $uri', name: 'DockerService');
    
    return await http.delete(uri, headers: headers);
  }

}