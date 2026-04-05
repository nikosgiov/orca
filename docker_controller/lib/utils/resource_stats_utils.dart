import '../services/container_service.dart';
import '../services/docker_service.dart';

class ResourceStatsUtils {
  static Map<String, dynamic> calculateBasicResourceStats(Map<String, dynamic>? resourceStats) {
    if (resourceStats == null) {
      return {
        'cpu': 0.0,
        'memory': 0.0,
        'running': 0,
        'stopped': 0,
        'exited': 0,
      };
    }
    int running = 0;
    int stopped = 0;
    int exited = 0;
    for (final container in resourceStats.entries) {
      final state = container.value as String? ?? '';
      switch (state) {
        case 'running':
          running++;
          break;
        case 'stopped':
          stopped++;
          break;
        case 'exited':
          exited++;
          break;
      }
    }
    return {
      'cpu': 0.0,
      'memory': 0.0,
      'running': running,
      'stopped': stopped,
      'exited': exited,
    };
  }

  static Future<Map<String, dynamic>> refreshDetailedStats(
    Map<String, dynamic>? resourceStats,
    dynamic connectionConfig,
  ) async {
    if (connectionConfig == null || resourceStats == null) return resourceStats ?? {};
    double totalCpu = 0.0;
    double totalMemory = 0.0;
    int activeCount = 0;
    final runningContainers = resourceStats.entries.where((entry) {
      final state = entry.value as String? ?? '';
      return state == 'running';
    }).toList();
    const int maxConcurrent = 3;
    for (int i = 0; i < runningContainers.length; i += maxConcurrent) {
      final batch = runningContainers.skip(i).take(maxConcurrent);
      final batchResults = await Future.wait(
        batch.map((entry) async {
          final containerId = entry.key as String?;
          if (containerId != null) {
            try {
              final stats = await ContainerService.getContainerStats(connectionConfig, containerId)
                  .timeout(const Duration(seconds: 2));
              if (stats != null) {
                return {
                  'cpu': DockerService.calculateCpuUsage(stats),
                  'memory': DockerService.calculateMemoryUsage(stats),
                };
              }
            } catch (_) {}
          }
          return null;
        }),
      );
      for (final result in batchResults) {
        if (result != null) {
          final cpu = result['cpu'] ?? 0.0;
          final memory = result['memory'] ?? 0.0;
          totalCpu += cpu;
          totalMemory += memory;
          activeCount++;
        }
      }
    }
    if (activeCount > 0) {
      final avgCpu = totalCpu / activeCount;
      final avgMemory = totalMemory / activeCount;
      return {
        'cpu': avgCpu,
        'memory': avgMemory,
        'running': resourceStats['running'],
        'stopped': resourceStats['stopped'],
        'exited': resourceStats['exited'],
      };
    }
    return resourceStats;
  }

  static Map<String, dynamic> calculateBasicResourceStatsFromContainers(List<Map<String, dynamic>>? containers) {
    if (containers == null || containers.isEmpty) {
      return {
        'cpu': 0.0,
        'memory': 0.0,
        'running': 0,
        'stopped': 0,
        'exited': 0,
      };
    }
    int running = 0;
    int stopped = 0;
    int exited = 0;
    for (final container in containers) {
      final state = container['State'] as String? ?? '';
      switch (state) {
        case 'running':
          running++;
          break;
        case 'stopped':
          stopped++;
          break;
        case 'exited':
          exited++;
          break;
      }
    }
    return {
      'cpu': 0.0,
      'memory': 0.0,
      'running': running,
      'stopped': stopped,
      'exited': exited,
    };
  }
} 