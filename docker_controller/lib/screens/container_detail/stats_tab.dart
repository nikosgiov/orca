import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/container_detail_provider.dart';
import 'package:docker_controller/utils/docker_stats_utils.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key, required this.provider});
  final ContainerDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.containerStats == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noStatsAvailable, style: AppTextStyles.caption),
      );
    }
    final cpuUsage = DockerStatsUtils.calculateCpuUsage(provider.containerStats!);
    final memoryUsage = DockerStatsUtils.calculateMemoryUsage(
      provider.containerStats!,
    );
    final diskIO = DockerStatsUtils.calculateDiskIO(provider.containerStats!);
    final networkIO = DockerStatsUtils.calculateNetworkIO(
      provider.containerStats!,
    );

    return SingleChildScrollView(
      padding: AppPaddings.tabContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassStatCard(
            title: AppLocalizations.of(context)!.cpuUsage,
            value: '${cpuUsage.toStringAsFixed(1)}%',
            icon: Icons.memory,
            color: const Color(0xFF60A5FA),
            fraction: (cpuUsage / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 12),
          _GlassStatCard(
            title: AppLocalizations.of(context)!.memoryUsage,
            value: '${memoryUsage.toStringAsFixed(1)}%',
            icon: Icons.storage,
            color: const Color(0xFFC084FC),
            fraction: (memoryUsage / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 12),
          _GlassStatCard(
            title: AppLocalizations.of(context)!.networkIO,
            value: '${networkIO.toStringAsFixed(2)} MB/s',
            icon: Icons.wifi,
            color: const Color(0xFF34D399),
            fraction: (networkIO / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 12),
          _GlassStatCard(
            title: AppLocalizations.of(context)!.diskIO,
            value: '${diskIO.toStringAsFixed(2)} MB/s',
            icon: Icons.storage_outlined,
            color: const Color(0xFFFBBF24),
            fraction: (diskIO / 100).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.fraction,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTextStyles.sectionLabel,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            // Progress bar
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep SimpleStatsCard as alias for backward compat if anything uses it
class SimpleStatsCard extends StatelessWidget {
  const SimpleStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => _GlassStatCard(
    title: title,
    value: value,
    icon: icon,
    color: color,
    fraction: 0,
  );
}
