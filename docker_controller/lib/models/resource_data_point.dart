import 'package:fl_chart/fl_chart.dart';

class ResourceDataPoint {
  ResourceDataPoint({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    this.gpuUsage,
    this.diskIO,
    this.diskUsage,
    this.netSent,
    this.netRecv,
  });

  factory ResourceDataPoint.fromJson(Map<String, dynamic> json) {
    return ResourceDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      cpuUsage: json['cpuUsage']?.toDouble() ?? 0.0,
      memoryUsage: json['memoryUsage']?.toDouble() ?? 0.0,
      gpuUsage: json['gpuUsage']?.toDouble(),
      diskIO: json['diskIO']?.toDouble(),
      diskUsage: json['diskUsage']?.toDouble(),
      netSent: json['netSent']?.toDouble(),
      netRecv: json['netRecv']?.toDouble(),
    );
  }
  final DateTime timestamp;
  final double cpuUsage;
  final double memoryUsage;
  final double? gpuUsage;
  final double? diskIO;
  final double? diskUsage;
  final double? netSent;
  final double? netRecv;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'gpuUsage': gpuUsage,
      'diskIO': diskIO,
      'diskUsage': diskUsage,
      'netSent': netSent,
      'netRecv': netRecv,
    };
  }

  // Convert to FlSpot for charts
  FlSpot toFlSpot(int index) {
    return FlSpot(index.toDouble(), cpuUsage);
  }

  FlSpot toMemoryFlSpot(int index) {
    return FlSpot(index.toDouble(), memoryUsage);
  }
}
