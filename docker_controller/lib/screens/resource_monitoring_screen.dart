import 'package:flutter/material.dart';
import 'dart:async' as dart_async;
import '../widgets/app_background.dart';
import '../providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/resource_monitoring_provider.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../constants/app_strings.dart';
import '../utils/resource_chart_utils.dart';
import '../widgets/app_loading_indicator.dart';
import '../models/resource_data_point.dart';

class ResourceMonitoringScreen extends StatelessWidget {
  const ResourceMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final connectionConfig = appProvider.connectionConfig;
    return AppBackground(
      position: const Offset(-80, 200),
      scale: 1.5,
      child: connectionConfig == null
          ? Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppGradientTopBar(
                title: AppStrings.resourceMonitoringTitle,
              ),
              body: const Center(
                child: Text('Not connected to Docker. Please connect first.'),
              ),
            )
          : const _ResourceMonitoringScreenBody(),
    );
  }
}

class _ResourceMonitoringScreenBody extends StatefulWidget {
  const _ResourceMonitoringScreenBody();

  @override
  State<_ResourceMonitoringScreenBody> createState() => _ResourceMonitoringScreenBodyState();
}

class _ResourceMonitoringScreenBodyState extends State<_ResourceMonitoringScreenBody> {
  dart_async.Timer? _autoRefreshTimer;
  bool? _lastAutoRefresh;
  int? _lastInterval;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ResourceMonitoringProvider>(context, listen: false);
    if (provider.metrics.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider.fetchData();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final settings = Provider.of<SettingsProvider>(context);
      _setupAutoRefresh(settings);

      final provider = Provider.of<ResourceMonitoringProvider>(context, listen: false);
      if (provider.selectedTimeRange != settings.selectedTimeRange) {
        Future.microtask(() {
          provider.selectedTimeRange = settings.selectedTimeRange;
          provider.refreshData();
        });
      }
    } catch (_) {}
  }

  void _setupAutoRefresh(SettingsProvider settings) {
    if (_lastAutoRefresh == settings.autoRefresh &&
        _lastInterval == settings.refreshInterval) {
      return;
    }
    _lastAutoRefresh = settings.autoRefresh;
    _lastInterval = settings.refreshInterval;

    _autoRefreshTimer?.cancel();
    if (settings.autoRefresh) {
      _autoRefreshTimer = dart_async.Timer.periodic(
        Duration(seconds: settings.refreshInterval),
        (_) {
          if (mounted) {
            final provider = Provider.of<ResourceMonitoringProvider>(context, listen: false);
            provider.refreshData();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceMonitoringProvider>(context);
    final metrics = provider.metrics;
    final dataPoints = (metrics['metrics'] != null)
        ? ResourceChartUtils.fromMetricsArrays(metrics['metrics'] as Map<String, dynamic>, provider.selectedTimeRange)
        : <ResourceDataPoint>[];
    final selectedTimeRange = provider.selectedTimeRange;
    // CPU
    final cpuSpots = ResourceChartUtils.getChartData(dataPoints, 'cpu', selectedTimeRange);
    final cpuValue = cpuSpots.isNotEmpty ? '${cpuSpots.last.y.toStringAsFixed(1)}%' : 'N/A';
    // Memory
    final memSpots = ResourceChartUtils.getChartData(dataPoints, 'memory', selectedTimeRange);
    final memValue = memSpots.isNotEmpty ? '${memSpots.last.y.toStringAsFixed(1)} GB' : 'N/A';
    // Disk
    final diskSpots = ResourceChartUtils.getChartData(dataPoints, 'disk', selectedTimeRange);
    final diskValue = diskSpots.isNotEmpty ? _formatNetworkSpeed(diskSpots.last.y) : 'N/A';
    // Network
    final networkSpots = ResourceChartUtils.getChartData(dataPoints, 'network', selectedTimeRange);
    final networkValue = networkSpots.isNotEmpty ? _formatNetworkSpeed(networkSpots.last.y) : 'N/A';
    // GPU
    final gpuSpots = ResourceChartUtils.getChartData(dataPoints, 'gpu', selectedTimeRange);
    final gpuValue = gpuSpots.isNotEmpty ? '${gpuSpots.last.y.toStringAsFixed(1)}%' : 'N/A';
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppGradientTopBar(
        title: AppStrings.resourceMonitoringTitle,
      ),
      body: Stack(
        children: [
          // ── Ambient glow orbs ─────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3A7BD5).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Timeframe',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildTimeframeDropdown(context),
                  ],
                ),
              ),
              Expanded(
                child: provider.isRefreshing
                    ? const AppLoadingIndicator(message: 'Loading resource data...')
                    : RefreshIndicator(
                        onRefresh: () async => provider.refreshData(),
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFF1A0B3B),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          child: Column(
                            children: [
                              _buildResourceChart(AppStrings.cpuUsage, cpuValue, Icons.memory, AppColors.primary, cpuSpots, dataPoints),
                              const SizedBox(height: 16),
                              _buildResourceChart(AppStrings.memoryUsage, memValue, Icons.storage, const Color(0xFFC084FC), memSpots, dataPoints),
                              if (dataPoints.isNotEmpty && dataPoints.any((p) => p.gpuUsage != null)) ...[
                                const SizedBox(height: 16),
                                _buildResourceChart('GPU Usage', gpuValue, Icons.bolt, const Color(0xFF10B981), gpuSpots, dataPoints),
                              ],
                              const SizedBox(height: 16),
                              _buildResourceChart(AppStrings.networkIO, networkValue, Icons.wifi, AppColors.successGreen, networkSpots, dataPoints),
                              const SizedBox(height: 16),
                              _buildResourceChart(AppStrings.diskIO, diskValue, Icons.storage_outlined, const Color(0xFFFBBF24), diskSpots, dataPoints),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChart(String title, String currentValue, IconData icon, Color color, List<FlSpot> data, List<ResourceDataPoint> dataPoints) {
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
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading2,
                ),
              ),
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
                              if (index < 0 || index >= dataPoints.length) return null;
                              final y = barSpot.y;
                              String tooltipText;
                              if (isSpeed) {
                                tooltipText = _formatNetworkSpeed(y);
                              } else if (title == AppStrings.cpuUsage || title == 'GPU Usage') {
                                tooltipText = '${y.toStringAsFixed(1)}%';
                              } else if (title == AppStrings.memoryUsage) {
                                tooltipText = '${y.toStringAsFixed(1)} GB';
                              } else {
                                tooltipText = y.toStringAsFixed(1);
                              }
                              return LineTooltipItem(
                                tooltipText,
                                TextStyle(color: color, fontWeight: FontWeight.bold),
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
                          return FlLine(
                            color: AppColors.glassBorder,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: data.length > 10 ? (data.length / 4).ceil().toDouble() : 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= dataPoints.length) return const Text('');

                              // Only show time labels for first, middle, and last points
                              final totalPoints = dataPoints.length;
                              final showTimeLabel = index == 0 ||
                                  index == (totalPoints ~/ 2) ||
                                  index == (totalPoints - 1);

                              if (!showTimeLabel) return const Text('');

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
                                    _formatNetworkSpeedCompact(value),
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

  /// Formats a speed value (in Bytes/s) to a human-readable string.
  static String _formatNetworkSpeed(double bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${bytes.toStringAsFixed(1)} B/s';
    }
  }

  /// Formats a speed value into compact notation (e.g., 1.5M).
  static String _formatNetworkSpeedCompact(double bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}G';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}M';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}K';
    } else {
      return '${bytes.toStringAsFixed(0)}B';
    }
  }

  Widget _buildTimeframeDropdown(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final provider = Provider.of<ResourceMonitoringProvider>(context, listen: false);

    final options = {
      '30m': '30 Minutes',
      '1h': '1 Hour',
      '6h': '6 Hours',
      '24h': '24 Hours',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedTimeRange,
          dropdownColor: const Color(0xFF1A0B3B),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: AppTextStyles.caption,
          isDense: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              settings.setSelectedTimeRange(newValue);
              provider.selectedTimeRange = newValue;
              provider.refreshData();
            }
          },
          items: options.entries.map<DropdownMenuItem<String>>((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}