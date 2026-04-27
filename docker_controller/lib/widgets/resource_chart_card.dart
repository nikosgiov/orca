import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/resource_data_point.dart';
import 'package:docker_controller/utils/data_formatting_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_card.dart';

enum ResourceMetricType { cpu, memory, gpu, network, disk }

class ResourceChartCard extends StatelessWidget {

  const ResourceChartCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.icon,
    required this.color,
    required this.metricType,
    required this.data,
    required this.dataPoints,
  });
  final String title;
  final String currentValue;
  final IconData icon;
  final Color color;
  final ResourceMetricType metricType;
  final List<FlSpot> data;
  final List<ResourceDataPoint> dataPoints;

  @override
  Widget build(BuildContext context) {
    final isNetwork = metricType == ResourceMetricType.network;
    final isDisk = metricType == ResourceMetricType.disk;
    final isSpeed = isNetwork || isDisk;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.heading2)),
              Text(
                currentValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noDataAvailable,
                      style: AppTextStyles.caption,
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((barSpot) {
                              final index = barSpot.x.toInt();
                              if (index < 0 || index >= dataPoints.length) {
                                return null;
                              }
                              final y = barSpot.y;
                              String tooltipText;
                              if (isSpeed) {
                                tooltipText = DataFormattingUtils.formatNetworkSpeed(y);
                              } else if (metricType == ResourceMetricType.cpu ||
                                  metricType == ResourceMetricType.gpu) {
                                tooltipText = DataFormattingUtils.formatPercentage(y);
                              } else if (metricType == ResourceMetricType.memory) {
                                tooltipText = '${y.toStringAsFixed(1)} GB';
                              } else {
                                tooltipText = y.toStringAsFixed(1);
                              }
                              return LineTooltipItem(
                                tooltipText,
                                TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: !isSpeed,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: AppColors.glassBorder,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: data.length > 10
                                ? (data.length / 4).ceil().toDouble()
                                : 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= dataPoints.length) {
                                return const Text('');
                              }

                              final totalPoints = dataPoints.length;
                              final showTimeLabel = index == 0 ||
                                  index == (totalPoints ~/ 2) ||
                                  index == (totalPoints - 1);

                              if (!showTimeLabel) {
                                return const Text('');
                              }

                              final time = dataPoints[index].timestamp;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                                child: Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: isSpeed
                            ? AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      DataFormattingUtils.formatNetworkSpeedCompact(value),
                                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                                    );
                                  },
                                ),
                              )
                            : AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}%',
                                      style: AppTextStyles.caption,
                                    );
                                  },
                                ),
                              ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: !isSpeed,
                            color: color.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
