import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/resource_data_point.dart';
import '../utils/data_formatting_utils.dart';
import 'app_card.dart';

class ResourceChartCard extends StatelessWidget {

  const ResourceChartCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.icon,
    required this.color,
    required this.data,
    required this.dataPoints,
  });
  final String title;
  final String currentValue;
  final IconData icon;
  final Color color;
  final List<FlSpot> data;
  final List<ResourceDataPoint> dataPoints;

  @override
  Widget build(BuildContext context) {
    final isNetwork = title == AppStrings.networkIO;
    final isDisk = title == AppStrings.diskIO;
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
                ? const Center(
                    child: Text(
                      AppStrings.noDataAvailable,
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
                              } else if (title == AppStrings.cpuUsage ||
                                  title == 'GPU Usage') {
                                tooltipText = DataFormattingUtils.formatPercentage(y);
                              } else if (title == AppStrings.memoryUsage) {
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
