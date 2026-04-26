import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/docker_container.dart';
import '../providers/containers_provider.dart';

class ContainerCard extends StatelessWidget {
  const ContainerCard({super.key, required this.container});
  final DockerContainer container;

  @override
  Widget build(BuildContext context) {
    final containersProvider = Provider.of<ContainersProvider>(
      context,
      listen: false,
    );

    final containerId = container.id;
    final name = container.displayName;
    final image = container.image;
    final state = container.state;
    final uptime = container.uptime;
    final portDisplay = container.ports.isEmpty
        ? AppStrings.noPorts
        : container.portDisplay;

    Color statusColor;
    IconData statusIcon;
    String displayStatus;

    switch (state) {
      case 'running':
        statusColor = AppColors.success;
        statusIcon = Icons.play_circle_filled;
        displayStatus = AppStrings.statusRunning;
        break;
      case 'stopped':
        statusColor = AppColors.error;
        statusIcon = Icons.stop_circle;
        displayStatus = AppStrings.statusStopped;
        break;
      case 'exited':
        statusColor = AppColors.warning;
        statusIcon = Icons.error;
        displayStatus = AppStrings.statusExited;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.help;
        displayStatus = AppStrings.statusUnknown;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.heading2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      containerId.length >= 12
                          ? containerId.substring(0, 12)
                          : containerId,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _StatusPill(label: displayStatus, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _CardInfoRow(icon: Icons.image_rounded, label: 'Image', value: image),
          _CardInfoRow(
            icon: Icons.link_rounded,
            label: 'Ports',
            value: portDisplay,
          ),
          _CardInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Uptime',
            value: uptime,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassActionButton(
                  label: state == 'running'
                      ? AppStrings.actionStop
                      : AppStrings.actionStart,
                  color: state == 'running'
                      ? AppColors.error
                      : AppColors.success,
                  onPressed: () async {
                    final success = state == 'running'
                        ? await containersProvider.stopContainer(containerId)
                        : await containersProvider.startContainer(containerId);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Done' : 'Failed'),
                        backgroundColor: success
                            ? (state == 'running'
                                  ? AppColors.error
                                  : AppColors.success)
                            : AppColors.error,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassActionButton(
                  label: AppStrings.actionDetails,
                  color: AppColors.primary,
                  onPressed: () {
                    context.pushNamed(
                      'containerDetail',
                      pathParameters: {'id': containerId},
                      queryParameters: {'name': name},
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _CardInfoRow extends StatelessWidget {
  const _CardInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
