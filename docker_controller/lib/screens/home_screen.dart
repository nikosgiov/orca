import 'package:flutter/material.dart';
import 'dart:async' as dart_async;
import '../widgets/app_background.dart';
import '../providers/settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/resource_data_point.dart';
import '../providers/app_provider.dart';
import '../utils/resource_chart_utils.dart';
import '../utils/system_info_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/app_gradient_top_bar.dart';
import 'connection_screen.dart';
import 'system_info_screen.dart';
import 'volumes_screen.dart';
import 'networks_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../utils/app_transitions.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToContainers;
  final VoidCallback? onNavigateToImages;

  const HomeScreen({
    super.key,
    this.onNavigateToContainers,
    this.onNavigateToImages,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _logPrefix = 'myapp';
  late AnimationController _animController;
  bool _isRefreshing = false;
  
  // Auto-refresh state
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
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (appProvider.isConnected &&
          (appProvider.systemInfo == null ||
              appProvider.resourceStats == null ||
              appProvider.systemMetrics == null)) {
        _refreshData();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final settings = Provider.of<SettingsProvider>(context);
      _setupAutoRefresh(settings);
    } catch (_) {
      // SettingsProvider not found on this branch
    }
  }

  void _setupAutoRefresh(SettingsProvider settings) {
    if (_lastAutoRefresh == settings.autoRefresh &&
        _lastInterval == settings.refreshInterval) {
      return; // Statics did not change
    }
    _lastAutoRefresh = settings.autoRefresh;
    _lastInterval = settings.refreshInterval;

    _autoRefreshTimer?.cancel();
    if (settings.autoRefresh) {
      _autoRefreshTimer = dart_async.Timer.periodic(
        Duration(seconds: settings.refreshInterval),
        (_) {
          if (mounted) _refreshData();
        },
      );
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (!appProvider.isConnected) return;
    _isRefreshing = true;
    developer.log('$_logPrefix: Refreshing home screen data', name: 'HomeScreen');
    try {
      await appProvider.fetchSystemData();
      await appProvider.fetchContainersAndResourceStats();
      await appProvider.fetchSystemMetrics();
    } catch (error) {
      developer.log('$_logPrefix: Error refreshing data: $error', name: 'HomeScreen');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
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
      appBar: AppGradientTopBar(title: AppStrings.dashboardTitle),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (!appProvider.isConnected) {
            return _buildNotConnectedView(appProvider);
          }
          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1A0B3B),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'System Node'),
                  const SizedBox(height: 12),
                  _buildSystemNodeCard(appProvider),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const _SectionLabel(label: 'Live Telemetry'),
                      const Spacer(),
                      Text(
                        'UPDATED: JUST NOW',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTelemetryRow(appProvider),
                  const SizedBox(height: 24),
                  _buildStatusAndInfraColumns(appProvider),
                ],
              ),
            ),
          );
        },
      ),
    ),
   );
  }

  // ── System Node Card ──────────────────────────────────────────────────────

  Widget _buildSystemNodeCard(AppProvider appProvider) {
    final hostname = SystemInfoUtils.getHostname(appProvider.systemInfo);
    final os = SystemInfoUtils.getOsInfo(appProvider.systemInfo);
    final dockerVer = SystemInfoUtils.getDockerVersion(appProvider.systemInfo);
    final arch = SystemInfoUtils.getCpuInfo(appProvider.systemInfo);
    final ram = SystemInfoUtils.getMemoryInfo(appProvider.systemInfo);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner (full-width, fixed height, rounded top) ──────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0), // dark blue
                    Color(0xFF6A1B9A), // purple
                    Color(0xFFC62828), // magenta-red
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle grid / noise texture overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                        itemCount: 80,
                        itemBuilder: (_, __) => Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Center icon + label
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.storage_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hostname.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 9,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Info section ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appProvider.connectionConfig?.uri ?? 'Unknown',
                        style: AppTextStyles.heading1.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(label: 'Online', color: AppColors.successGreen),
                  ],
                ),
                const SizedBox(height: 20),
                // ── 2×2 info grid ────────────────────────────────────────
                _InfoGrid2Col(items: [
                  _InfoPair(label: 'OS / Kernel', value: os),
                  _InfoPair(label: 'Docker Version', value: dockerVer),
                  _InfoPair(label: 'Architecture', value: arch),
                  _InfoPair(label: 'System RAM', value: ram),
                ]),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Inspect Node',
                    onPressed: () => Navigator.push(
                      context,
                      AppTransitions.focalZoom(const SystemInfoScreen()),
                    ),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Telemetry Row ─────────────────────────────────────────────────────────

  Widget _buildTelemetryRow(AppProvider appProvider) {
    final metrics = appProvider.systemMetrics;
    final metricsArrays =
        metrics != null ? metrics['metrics'] as Map<String, dynamic>? : null;
    final dataPoints = metricsArrays != null
        ? ResourceChartUtils.fromMetricsArrays(metricsArrays)
        : <ResourceDataPoint>[];
    final latest = dataPoints.isNotEmpty ? dataPoints.last : null;

    final cpuPct = latest?.cpuUsage ?? 0.0;
    final memGB = latest?.memoryUsage ?? 0.0;
    final diskPct = latest?.diskUsage ?? 0.0;
    final gpuPct = latest?.gpuUsage;
    final hasGpu = (appProvider.systemInfo?['gpu']?['name'] != null && appProvider.systemInfo?['gpu']?['name'] != 'N/A') || gpuPct != null;

    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _GaugeCard(
            label: 'CPU Usage',
            displayValue: '${cpuPct.toStringAsFixed(0)}%',
            fraction: cpuPct / 100.0,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 12),
          _GaugeCard(
            label: 'Memory',
            displayValue: '${memGB.toStringAsFixed(1)}GB',
            fraction: (memGB / 16.0).clamp(0.0, 1.0),
            color: const Color(0xFFC084FC),
          ),
          const SizedBox(width: 12),
          _GaugeCard(
            label: 'Disk Space',
            displayValue: '${diskPct.toStringAsFixed(0)}%',
            fraction: (diskPct / 100.0).clamp(0.0, 1.0),
            color: const Color(0xFFF472B6),
          ),
          if (hasGpu) ...[
            const SizedBox(width: 12),
            _GaugeCard(
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

  // ── Containers Status + Infrastructure column layout ──────────────────────

  Widget _buildStatusAndInfraColumns(AppProvider appProvider) {
    final resourceStats = appProvider.resourceStats;
    final running = resourceStats?['running'] ?? 0;
    final stopped = resourceStats?['stopped'] ?? 0;
    final exited = resourceStats?['exited'] ?? 0;
    final volCount = appProvider.volumeCount;
    final netCount = appProvider.networkCount;

    return Column(
      children: [
        _buildContainerStatusCard(running, stopped, exited),
        const SizedBox(height: 16),
        _buildInfraCard(volCount, netCount),
      ],
    );
  }

  Widget _buildContainerStatusCard(int running, int stopped, int exited) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Containers Status'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatusOrb(count: running, label: 'Running', color: const Color(0xFF22D3EE)),
              _StatusOrb(count: stopped, label: 'Stopped', color: const Color(0xFFFBBF24)),
              _StatusOrb(count: exited, label: 'Exited', color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfraCard(int volCount, int netCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Infrastructure'),
          const SizedBox(height: 12),
          _InfraListItem(
            icon: Icons.storage,
            label: 'Volumes',
            badge: volCount == 0 ? '--' : '$volCount Active',
            iconColor: const Color(0xFF60A5FA),
            onTap: () => Navigator.push(
              context,
              AppTransitions.focalZoom(const VolumesScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _InfraListItem(
            icon: Icons.account_tree_outlined,
            label: 'Networks',
            badge: netCount == 0 ? '--' : '$netCount Managed',
            iconColor: const Color(0xFF60A5FA),
            onTap: () => Navigator.push(
              context,
              AppTransitions.focalZoom(const NetworksScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ── Not Connected ─────────────────────────────────────────────────────────

  Widget _buildNotConnectedView(AppProvider appProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.cloud_off, size: 48, color: AppColors.errorRed),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.connectionLost, style: AppTextStyles.heading1.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Text(AppStrings.connectionLostDesc, style: AppTextStyles.caption, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            if (appProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(appProvider.error!.message,
                          style: AppTextStyles.caption.copyWith(color: AppColors.errorRed)),
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
                    onPressed: () => appProvider.testAndReconnect(),
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: AppStrings.settingsTitle,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ConnectionScreen()),
                      );
                    },
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

// ─── Shared sub-widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: AppTextStyles.sectionLabel,
      );
}

// ─── Status badge (pill) ──────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── 2-column info grid (inside the node card) ────────────────────────────────

class _InfoGrid2Col extends StatelessWidget {
  final List<_InfoPair> items;
  const _InfoGrid2Col({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <List<_InfoPair>>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(items.sublist(i, (i + 2).clamp(0, items.length)));
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: row.asMap().entries.expand((entry) {
              final index = entry.key;
              final pair = entry.value;
              return [
                if (index > 0) const SizedBox(width: 24), // Gap between columns
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair.label.toUpperCase(),
                        style: AppTextStyles.sectionLabel,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pair.value,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),

                    ],
                  ),
                ),
              ];
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}


class _InfoPair {
  final String label;
  final String value;
  const _InfoPair({required this.label, required this.value});
}

// ─── Gauge card ───────────────────────────────────────────────────────────────

class _GaugeCard extends StatelessWidget {
  final String label;
  final String displayValue;
  final double fraction;
  final Color color;

  const _GaugeCard({
    required this.label,
    required this.displayValue,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer dim ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.18), width: 3),
                  ),
                ),
                // Inner liquid fill
                ClipOval(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction.clamp(0.0, 1.0),
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color.withValues(alpha: 0.45),
                              color.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Glow ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12),
                    ],
                  ),
                ),
                // Value text
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    shadows: [Shadow(color: color, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(label.toUpperCase(), style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

// ─── Status orb ───────────────────────────────────────────────────────────────

class _StatusOrb extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusOrb({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              ClipOval(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: count > 0 ? 0.65 : 0.05,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.0),
        ),
      ],
    );
  }
}

// ─── Infrastructure list item ─────────────────────────────────────────────────

class _InfraListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final Color iconColor;
  final VoidCallback? onTap;

  const _InfraListItem({
    required this.icon,
    required this.label,
    required this.badge,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassOverlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text(
              badge,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500, letterSpacing: 0.5),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}