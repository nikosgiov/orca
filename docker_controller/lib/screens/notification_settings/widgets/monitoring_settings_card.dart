import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/settings_card_header.dart';
import '../../../widgets/settings_switch_tile.dart';

class MonitoringSettingsCard extends StatelessWidget {
  const MonitoringSettingsCard({
    super.key,
    required this.dockerMonitoringEnabled,
    required this.resourceMonitoringEnabled,
    required this.onDockerMonitoringChanged,
    required this.onResourceMonitoringChanged,
  });

  final bool dockerMonitoringEnabled;
  final bool resourceMonitoringEnabled;
  final ValueChanged<bool> onDockerMonitoringChanged;
  final ValueChanged<bool> onResourceMonitoringChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            title: 'Monitoring Settings',
            icon: Icons.monitor,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: 'Docker Monitoring',
            subtitle: 'Receive notifications for container and image changes',
            value: dockerMonitoringEnabled,
            onChanged: onDockerMonitoringChanged,
          ),
          SettingsSwitchTile(
            title: 'Resource Monitoring',
            subtitle: 'Receive notifications for high resource usage',
            value: resourceMonitoringEnabled,
            onChanged: onResourceMonitoringChanged,
          ),
        ],
      ),
    );
  }
}
