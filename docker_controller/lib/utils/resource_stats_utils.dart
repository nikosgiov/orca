import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/services/container_service.dart';
import 'docker_stats_utils.dart';

class ResourceStatsUtils {
  static Map<String, dynamic> calculateBasicResourceStats(
    Map<String, dynamic>? resourceStats,
  ) {
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
    Map<String, dynamic>? resourceStats, [
    dynamic _,
  ]) async {
    if (resourceStats == null) {
      return {};
    }

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
          final result = await getIt<ContainerService>().getContainerStats(entry.key);
          return result.fold(
            (stats) => {
              'cpu': DockerStatsUtils.calculateCpuUsage(stats),
              'memory': DockerStatsUtils.calculateMemoryUsage(stats),
            },
            (_) => null,
          );
        }),
      );
      for (final result in batchResults) {
        if (result != null) {
          totalCpu += result['cpu'] ?? 0.0;
          totalMemory += result['memory'] ?? 0.0;
          activeCount++;
        }
      }
    }

    if (activeCount > 0) {
      return {
        'cpu': totalCpu / activeCount,
        'memory': totalMemory / activeCount,
        'running': resourceStats['running'],
        'stopped': resourceStats['stopped'],
        'exited': resourceStats['exited'],
      };
    }
    return resourceStats;
  }

  static Map<String, dynamic> calculateBasicResourceStatsFromContainers(
    List<DockerContainer>? containers,
  ) {
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
      final state = container.stateDisplay;
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
