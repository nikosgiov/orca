import 'package:docker_controller/models/resource_data_point.dart';
import 'package:docker_controller/utils/resource_chart_utils.dart';
import 'package:flutter/material.dart';

import 'home_widgets.dart';

class TelemetryRow extends StatelessWidget {
  const TelemetryRow({
    super.key,
    required this.systemMetrics,
    required this.systemInfo,
  });
  final Map<String, dynamic>? systemMetrics;
  final Map<String, dynamic>? systemInfo;

  @override
  Widget build(BuildContext context) {
    final metricsArrays = systemMetrics != null
        ? systemMetrics!['metrics'] as Map<String, dynamic>?
        : null;
    final dataPoints = metricsArrays != null
        ? ResourceChartUtils.fromMetricsArrays(metricsArrays)
        : <ResourceDataPoint>[];
    final latest = dataPoints.isNotEmpty ? dataPoints.last : null;

    final cpuPct = latest?.cpuUsage ?? 0.0;
    final memGB = latest?.memoryUsage ?? 0.0;
    final diskPct = latest?.diskUsage ?? 0.0;
    final gpuPct = latest?.gpuUsage;
    final hasGpu =
        (systemInfo?['gpu']?['name'] != null &&
            systemInfo?['gpu']?['name'] != 'N/A') ||
        gpuPct != null;

    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GaugeCard(
            label: 'CPU Usage',
            displayValue: '${cpuPct.toStringAsFixed(0)}%',
            fraction: cpuPct / 100.0,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 12),
          GaugeCard(
            label: 'Memory',
            displayValue: '${memGB.toStringAsFixed(1)}GB',
            fraction: (memGB / 16.0).clamp(0.0, 1.0),
            color: const Color(0xFFC084FC),
          ),
          const SizedBox(width: 12),
          GaugeCard(
            label: 'Disk Space',
            displayValue: '${diskPct.toStringAsFixed(0)}%',
            fraction: (diskPct / 100.0).clamp(0.0, 1.0),
            color: const Color(0xFFF472B6),
          ),
          if (hasGpu) ...[
            const SizedBox(width: 12),
            GaugeCard(
              label: 'GPU Usage',
              displayValue: '${((gpuPct ?? 0.0) * 100.0).toStringAsFixed(0)}%',
              fraction: (gpuPct ?? 0.0).clamp(0.0, 1.0),
              color: const Color(0xFF10B981),
            ),
          ],
        ],
      ),
    );
  }
}
