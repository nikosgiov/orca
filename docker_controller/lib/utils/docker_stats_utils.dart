import 'dart:developer' as developer;

class DockerStatsUtils {
  static const String _logPrefix = 'DockerStatsUtils';

  /// Calculates the CPU usage percentage from a raw Docker stats map.
  static double calculateCpuUsage(Map<String, dynamic> stats) {
    try {
      final cpuStats = stats['cpu_stats'] as Map<String, dynamic>?;
      final preCpuStats = stats['precpu_stats'] as Map<String, dynamic>?;

      if (cpuStats == null || preCpuStats == null) {
        return 0.0;
      }

      final cpuUsageMap = cpuStats['cpu_usage'] as Map<String, dynamic>?;
      final preCpuUsageMap = preCpuStats['cpu_usage'] as Map<String, dynamic>?;

      final totalUsage = (cpuUsageMap?['total_usage'] ?? 0) as num;
      final preTotalUsage = (preCpuUsageMap?['total_usage'] ?? 0) as num;

      final systemCpuUsage = cpuStats['system_cpu_usage'] as num?;
      final preSystemCpuUsage = preCpuStats['system_cpu_usage'] as num?;

      if (systemCpuUsage == null || preSystemCpuUsage == null) {
        return 0.0;
      }

      final cpuDelta = (totalUsage - preTotalUsage).toDouble();
      final systemDelta = (systemCpuUsage - preSystemCpuUsage).toDouble();

      if (systemDelta > 0 && cpuDelta > 0) {
        final onlineCpus = (cpuStats['online_cpus'] ?? 1) as num;
        return (cpuDelta / systemDelta) * onlineCpus * 100.0;
      }
      return 0.0;
    } catch (e) {
      developer.log('Error calculating CPU usage: $e', name: _logPrefix);
      return 0.0;
    }
  }

  /// Calculates the memory usage percentage from a raw Docker stats map.
  static double calculateMemoryUsage(Map<String, dynamic> stats) {
    try {
      final memoryStats = stats['memory_stats'] as Map<String, dynamic>?;
      if (memoryStats == null) {
        return 0.0;
      }

      final memoryUsage = (memoryStats['usage'] ?? 0) as num;
      final memoryLimit = (memoryStats['limit'] ?? 1) as num;

      if (memoryLimit > 0) {
        return (memoryUsage / memoryLimit) * 100.0;
      }
      return 0.0;
    } catch (e) {
      developer.log('Error calculating memory usage: $e', name: _logPrefix);
      return 0.0;
    }
  }

  /// Calculates the disk I/O in MiB from a raw Docker stats map.
  static double calculateDiskIO(Map<String, dynamic> stats) {
    try {
      final blkioStats = stats['blkio_stats'] as Map<String, dynamic>?;
      if (blkioStats == null) {
        return 0.0;
      }

      final ioServiceBytes =
          blkioStats['io_service_bytes_recursive'] as List<dynamic>?;
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
        return totalIO / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      developer.log('Error calculating disk I/O: $e', name: _logPrefix);
      return 0.0;
    }
  }

  /// Calculates the network I/O in MiB from a raw Docker stats map.
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
        return totalBytes / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      developer.log('Error calculating network I/O: $e', name: _logPrefix);
      return 0.0;
    }
  }
}
