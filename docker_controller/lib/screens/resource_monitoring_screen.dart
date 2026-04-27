import 'dart:async' as dart_async;

import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/resource_data_point.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/resource_monitoring_provider.dart';
import 'package:docker_controller/providers/settings_provider.dart';
import 'package:docker_controller/utils/data_formatting_utils.dart';
import 'package:docker_controller/utils/resource_chart_utils.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_loading_indicator.dart';
import 'package:docker_controller/widgets/resource_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class ResourceMonitoringScreen extends StatelessWidget {
  const ResourceMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final connectionConfig = authProvider.connectionConfig;
    
    return AppBackground(
      position: const Offset(-80, 200),
      scale: 1.5,
      child: connectionConfig == null
          ? const _NotConnectedView()
          : const _ResourceMonitoringScreenBody(),
    );
  }
}

class _NotConnectedView extends StatelessWidget {
  const _NotConnectedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(AppLocalizations.of(context)!.notConnectedToDocker),
      ),
    );
  }
}

class _ResourceMonitoringScreenBody extends StatefulWidget {
  const _ResourceMonitoringScreenBody();

  @override
  State<_ResourceMonitoringScreenBody> createState() =>
      _ResourceMonitoringScreenBodyState();
}

class _ResourceMonitoringScreenBodyState
    extends State<_ResourceMonitoringScreenBody> {
  dart_async.Timer? _autoRefreshTimer;
  int? _lastInterval;

  @override
  void initState() {
    super.initState();
    _initialFetch();
  }

  void _initialFetch() {
    final provider = context.read<ResourceMonitoringProvider>();
    if (provider.state is AppInitial) {
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
    final settings = context.watch<SettingsProvider>();
    _setupAutoRefresh(settings);
    _syncTimeRange(settings);
  }

  void _syncTimeRange(SettingsProvider settings) {
    final provider = context.read<ResourceMonitoringProvider>();
    if (provider.selectedTimeRange != settings.selectedTimeRange) {
      Future.microtask(() {
        provider.selectedTimeRange = settings.selectedTimeRange;
        provider.refreshData();
      });
    }
  }

  void _setupAutoRefresh(SettingsProvider settings) {
    if (!settings.autoRefresh) {
      _autoRefreshTimer?.cancel();
      return;
    }

    if (_lastInterval == settings.refreshInterval && _autoRefreshTimer != null) {
      return;
    }

    _lastInterval = settings.refreshInterval;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = dart_async.Timer.periodic(
      Duration(seconds: settings.refreshInterval),
      (_) {
        if (mounted) {
          context.read<ResourceMonitoringProvider>().refreshData();
        }
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourceMonitoringProvider>();
    final state = provider.state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _AmbientGlowOrbs(),
          Column(
            children: [
              _TimeframeHeader(provider: provider),
              Expanded(
                child: _buildContent(context, provider, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResourceMonitoringProvider provider,
    AppState state,
  ) {
    return switch (state) {
      AppInitial() || AppLoading() when !provider.isRefreshing => 
        AppLoadingIndicator(message: AppLocalizations.of(context)!.loadingResourceData),
      AppStateError(:final failure) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(failure.localizedMessage(AppLocalizations.of(context)!), style: AppTextStyles.body, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refreshData(),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      _ => _MetricsList(provider: provider),
    };
  }
}

class _MetricsList extends StatelessWidget {
  const _MetricsList({required this.provider});
  final ResourceMonitoringProvider provider;

  @override
  Widget build(BuildContext context) {
    final metrics = provider.metrics;
    if (metrics == null) {
      return const SizedBox.shrink();
    }

    final dataPoints = metrics.history;

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundMid,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          children: [
            _buildChart(
              AppLocalizations.of(context)!.cpuUsage,
              Icons.memory,
              AppColors.primary,
              ResourceMetricType.cpu,
              dataPoints,
              provider.selectedTimeRange,
              (val) => '${val.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),
            _buildChart(
              AppLocalizations.of(context)!.memoryUsage,
              Icons.storage,
              const Color(0xFFC084FC),
              ResourceMetricType.memory,
              dataPoints,
              provider.selectedTimeRange,
              (val) => '${val.toStringAsFixed(1)} GB',
            ),
            if (dataPoints.isNotEmpty && dataPoints.any((p) => p.gpuUsage != null)) ...[
              const SizedBox(height: 16),
              _buildChart(
                AppLocalizations.of(context)!.gpuUsage,
                Icons.bolt,
                const Color(0xFF10B981),
                ResourceMetricType.gpu,
                dataPoints,
                provider.selectedTimeRange,
                (val) => '${val.toStringAsFixed(1)}%',
              ),
            ],
            const SizedBox(height: 16),
            _buildChart(
              AppLocalizations.of(context)!.networkIO,
              Icons.wifi,
              AppColors.success,
              ResourceMetricType.network,
              dataPoints,
              provider.selectedTimeRange,
              DataFormattingUtils.formatNetworkSpeed,
            ),
            const SizedBox(height: 16),
            _buildChart(
              AppLocalizations.of(context)!.diskIO,
              Icons.storage_outlined,
              const Color(0xFFFBBF24),
              ResourceMetricType.disk,
              dataPoints,
              provider.selectedTimeRange,
              DataFormattingUtils.formatNetworkSpeed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    String title,
    IconData icon,
    Color color,
    ResourceMetricType metricType,
    List<ResourceDataPoint> dataPoints,
    String timeRange,
    String Function(double) formatter,
  ) {
    final spots = ResourceChartUtils.getChartData(dataPoints, metricType.name, timeRange);
    final value = spots.isNotEmpty ? formatter(spots.last.y) : 'N/A';

    return ResourceChartCard(
      title: title,
      currentValue: value,
      icon: icon,
      color: color,
      metricType: metricType,
      data: spots,
      dataPoints: dataPoints,
    );
  }
}

class _TimeframeHeader extends StatelessWidget {
  const _TimeframeHeader({required this.provider});
  final ResourceMonitoringProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.timeframe,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          _TimeframeDropdown(provider: provider),
        ],
      ),
    );
  }
}

class _TimeframeDropdown extends StatelessWidget {
  const _TimeframeDropdown({required this.provider});
  final ResourceMonitoringProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();
    final options = {
      '30m': l10n.minutesCount(30),
      '1h': l10n.hoursCount(1),
      '6h': l10n.hoursCount(6),
      '24h': l10n.hoursCount(24),
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
          dropdownColor: AppColors.backgroundMid,
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
          items: options.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AmbientGlowOrbs extends StatelessWidget {
  const _AmbientGlowOrbs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: _GlowOrb(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: _GlowOrb(color: const Color(0xFF8B5CF6).withValues(alpha: 0.18)),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
