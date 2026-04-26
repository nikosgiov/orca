import 'dart:async' as dart_async;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/system_stats_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/home/container_status_card.dart';
import '../widgets/home/home_widgets.dart';
import '../widgets/home/infrastructure_card.dart';
import '../widgets/home/system_node_card.dart';
import '../widgets/home/telemetry_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToContainers,
    this.onNavigateToImages,
  });
  final VoidCallback? onNavigateToContainers;
  final VoidCallback? onNavigateToImages;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  dart_async.Timer? _autoRefreshTimer;
  bool? _lastAutoRefresh;
  int? _lastInterval;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
      final statsProvider = context.read<SystemStatsProvider>();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isConnected && statsProvider.systemInfo == null) {
        statsProvider.refreshAll();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final settings = Provider.of<SettingsProvider>(context);
      _setupAutoRefresh(settings);
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
            context.read<SystemStatsProvider>().refreshAll();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(-40, 200),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppGradientTopBar(title: AppStrings.dashboardTitle),
        body: Consumer2<AuthProvider, SystemStatsProvider>(
          builder: (context, auth, stats, child) {
            if (!auth.isConnected) {
              return _buildNotConnectedView(auth);
            }
            return RefreshIndicator(
              onRefresh: stats.refreshAll,
              color: AppColors.primary,
              backgroundColor: const Color(0xFF1A0B3B),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel(label: 'System Node'),
                    const SizedBox(height: 12),
                    SystemNodeCard(
                      systemInfo: stats.systemInfo,
                      connectionUri: auth.connectionConfig?.uri,
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        SectionLabel(label: 'Live Telemetry'),
                        Spacer(),
                        Text(
                          'UPDATED: JUST NOW',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TelemetryRow(
                      systemMetrics: stats.systemMetrics,
                      systemInfo: stats.systemInfo,
                    ),
                    const SizedBox(height: 24),
                    ContainerStatusCard(
                      running: stats.resourceStats?['running'] ?? 0,
                      stopped: stats.resourceStats?['stopped'] ?? 0,
                      exited: stats.resourceStats?['exited'] ?? 0,
                    ),
                    const SizedBox(height: 16),
                    InfrastructureCard(
                      volCount: stats.volumeCount,
                      netCount: stats.networkCount,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotConnectedView(AuthProvider auth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.cloud_off,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.connectionLost,
              style: AppTextStyles.heading1.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.connectionLostDesc,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (auth.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.error!.message,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.reconnect,
                    onPressed: () {
                      final config = auth.connectionConfig;
                      if (config != null) {
                        auth.connect(config, persist: true);
                      }
                    },
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: AppStrings.settingsTitle,
                    onPressed: () => context.goNamed('connection'),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
