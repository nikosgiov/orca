import 'package:fl_chart/fl_chart.dart';
import '../models/resource_data_point.dart';

class ResourceChartUtils {
  static List<FlSpot> getChartData(
    List<ResourceDataPoint> history,
    String dataType,
    String selectedTimeRange,
  ) {
    if (history.isEmpty) {
      return [];
    }
    final sortedData = List<ResourceDataPoint>.from(history);
    sortedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sortedData.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      switch (dataType) {
        case 'cpu':
          return FlSpot(index.toDouble(), point.cpuUsage);
        case 'memory':
          return FlSpot(index.toDouble(), point.memoryUsage);
        case 'disk':
          if (index == 0) {
            return FlSpot(index.toDouble(), 0);
          }
          final prevDisk = sortedData[index - 1];
          final diskDiff = (point.diskIO ?? 0) - (prevDisk.diskIO ?? 0);
          // speed in bytes if points are 1s apart, absolute diff
          return FlSpot(index.toDouble(), diskDiff >= 0 ? diskDiff : 0);
        case 'network':
          if (index == 0) {
            return FlSpot(index.toDouble(), 0);
          }
          final prevNet = sortedData[index - 1];
          final sentDiff = (point.netSent ?? 0) - (prevNet.netSent ?? 0);
          final recvDiff = (point.netRecv ?? 0) - (prevNet.netRecv ?? 0);
          final speedBytes = sentDiff + recvDiff;
          return FlSpot(index.toDouble(), speedBytes >= 0 ? speedBytes : 0);
        case 'gpu':
          return FlSpot(index.toDouble(), (point.gpuUsage ?? 0.0) * 100.0);
        default:
          return FlSpot(index.toDouble(), point.cpuUsage);
      }
    }).toList();
  }

  static String getCurrentValue(
    List<ResourceDataPoint> history,
    String dataType,
  ) {
    if (history.isEmpty) {
      return '0%';
    }
    final latest = history.last;
    switch (dataType) {
      case 'cpu':
        return '${latest.cpuUsage.toStringAsFixed(1)}%';
      case 'memory':
        return '${latest.memoryUsage.toStringAsFixed(1)}%';
      case 'disk':
        if (history.length < 2) {
          return '0.0 MB/s';
        }
        final prev = history[history.length - 2];
        final diff = (latest.diskIO ?? 0) - (prev.diskIO ?? 0);
        final speed = diff >= 0 ? diff : 0.0;
        return _formatSpeed(speed);
      case 'network':
        if (history.length < 2) {
          return '0.0 KB/s';
        }
        final prev = history[history.length - 2];
        final sentDiff = (latest.netSent ?? 0) - (prev.netSent ?? 0);
        final recvDiff = (latest.netRecv ?? 0) - (prev.netRecv ?? 0);
        final speed =
            (sentDiff >= 0 ? sentDiff : 0.0) + (recvDiff >= 0 ? recvDiff : 0.0);
        return _formatSpeed(speed);
      case 'gpu':
        return '${((latest.gpuUsage ?? 0.0) * 100.0).toStringAsFixed(1)}%';
      default:
        return '0%';
    }
  }

  static String _formatSpeed(double bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${bytes.toStringAsFixed(2)} B/s';
    }
  }

  static List<ResourceDataPoint> fromMetricsArrays(
    Map<String, dynamic> metrics, [
    String selectedTimeRange = '30m',
  ]) {
    final cpuData = metrics['cpu'] ?? metrics['cpu_usage'];
    if (cpuData == null || cpuData is! List) {
      return [];
    }
    final int length = cpuData.length;
    final List<ResourceDataPoint> points = [];

    Duration step;
    switch (selectedTimeRange) {
      case '24h':
        step = const Duration(hours: 1);
        break;
      case '30m':
      case '1h':
      case '6h':
        step = const Duration(minutes: 1);
        break;
      default:
        step = const Duration(seconds: 1);
    }

    for (int i = 0; i < length; i++) {
      points.add(
        ResourceDataPoint(
          timestamp: DateTime.now().subtract(step * (length - 1 - i)),
          cpuUsage: (metrics['cpu']?[i] ?? metrics['cpu_usage']?[i] ?? 0.0)
              .toDouble(),
          memoryUsage: (metrics['mem']?[i] ??
                  metrics['memory']?[i] ??
                  metrics['memory_usage']?[i] ??
                  0.0)
              .toDouble(),
          diskUsage: (metrics['disk']?[i] ?? metrics['disk_usage']?[i] as num?)
              ?.toDouble(),
          diskIO: (((metrics['disk_read']?[i] as num?)?.toDouble() ?? 0.0) +
              ((metrics['disk_write']?[i] as num?)?.toDouble() ?? 0.0)),
          netSent: (metrics['net_sent']?[i] ?? metrics['network_sent']?[i] ?? 0.0)
              .toDouble(),
          netRecv: (metrics['net_recv']?[i] ?? metrics['network_recv']?[i] ?? 0.0)
              .toDouble(),
          gpuUsage: (metrics['gpu_load']?[i] ?? metrics['gpu_usage']?[i] as num?)
              ?.toDouble(),
        ),
      );
    }
    return points;
  }
}
