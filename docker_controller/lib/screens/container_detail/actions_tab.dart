import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/container_detail_provider.dart';
import '../exec_terminal_screen.dart';

class ActionsTab extends StatelessWidget {
  final ContainerDetailProvider provider;
  const ActionsTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final state = provider.containerInfo?['State']?['Status']?.toString() ?? 'unknown';
    final isRunning = state == 'running';
    final isPaused = state == 'paused';
    final isStopped = state == 'stopped' || state == 'exited';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          _ContainerStatusCard(state: state),
          const SizedBox(height: 16),

          if (isStopped || isPaused)
            ContainerActionButton(
              label: 'Start Container',
              icon: Icons.play_arrow,
              color: AppColors.successGreen,
              onPressed: () => _handleAction(context, provider.startContainer, 'start'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: 'Stop Container',
              icon: Icons.stop,
              color: AppColors.errorRed,
              onPressed: () => _handleAction(context, provider.stopContainer, 'stop'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: 'Pause Container',
              icon: Icons.pause,
              color: const Color(0xFFFBBF24),
              onPressed: () => _handleAction(context, provider.pauseContainer, 'pause'),
            ),
          if (isPaused)
            ContainerActionButton(
              label: 'Resume Container',
              icon: Icons.play_arrow,
              color: AppColors.successGreen,
              onPressed: () => _handleAction(context, provider.resumeContainer, 'resume'),
            ),
          if (isRunning || isStopped)
            ContainerActionButton(
              label: 'Restart Container',
              icon: Icons.refresh,
              color: AppColors.primary,
              onPressed: () => _handleAction(context, provider.restartContainer, 'restart'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: 'Open Terminal',
              icon: Icons.terminal,
              color: const Color(0xFF10B981), // Emerald green
              onPressed: () {
                if (provider.appProvider.connectionConfig != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExecTerminalScreen(
                        config: provider.appProvider.connectionConfig!,
                        containerId: provider.containerId,
                        containerName: provider.containerName,
                      ),
                    ),
                  );
                }
              },
            ),
          if (isRunning)
            ContainerActionButton(
              label: 'Kill Container',
              icon: Icons.close,
              color: AppColors.errorRed,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Kill Container'),
                    content: Text('Are you sure you want to kill "${provider.containerName}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                        child: const Text('Kill'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  if (!context.mounted) return;
                  final (success, errorMsg) = await provider.killContainer();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'Killed ${provider.containerName}' : errorMsg ?? 'Failed'),
                    backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
                  ));
                }
              },
            ),
          const SizedBox(height: 8),
          ContainerActionButton(
            label: 'Rename Container',
            icon: Icons.edit_outlined,
            color: AppColors.primary,
            onPressed: () async {
              final controller = TextEditingController(text: provider.containerName);
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rename Container'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enter new name:'),
                      const SizedBox(height: 16),
                      TextField(
                        autofocus: true,
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'New Name', hintText: 'container-name'),
                        onSubmitted: (v) { if (v.trim().isNotEmpty) Navigator.pop(context, v.trim()); },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        final n = controller.text.trim();
                        if (n.isNotEmpty) Navigator.pop(context, n);
                      },
                      child: const Text('Rename'),
                    ),
                  ],
                ),
              );
              if (newName == null || newName.trim().isEmpty) return;
              if (newName.trim() == provider.containerName) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Name is already the same'),
                  backgroundColor: Colors.orange,
                ));
                return;
              }
              if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]*$').hasMatch(newName.trim())) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Invalid name. Use only letters, numbers, dots, underscores, hyphens.'),
                  backgroundColor: Color(0xFFEF4444),
                ));
                return;
              }
              if (!context.mounted) return;
              final (success, errorMsg) = await provider.renameContainer(newName.trim());
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success ? 'Renamed to ${newName.trim()}' : errorMsg ?? 'Failed to rename'),
                backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
              ));
              if (success) Navigator.pop(context);
            },
          ),
          ContainerActionButton(
            label: 'Remove Container',
            icon: Icons.delete_outline,
            color: AppColors.errorRed,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Container'),
                  content: Text('Remove "${provider.containerName}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                if (!context.mounted) return;
                final (success, errorMsg) = await provider.removeContainer();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Removed ${provider.containerName}' : errorMsg ?? 'Failed to remove'),
                  backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
                ));
                if (success) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, Future<(bool, String?)> Function() action, String actionName) async {
    final (success, errorMsg) = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Successfully ${actionName}ed container' : errorMsg ?? 'Failed to $actionName'),
      backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
    ));
  }
}

// ── Status card (glass) ────────────────────────────────────────────────────────

class _ContainerStatusCard extends StatelessWidget {
  final String state;
  const _ContainerStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isRunning = state == 'running';
    final isPaused = state == 'paused';
    final color = isRunning
        ? AppColors.successGreen
        : isPaused
            ? const Color(0xFFFBBF24)
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRunning ? Icons.play_circle_outline : isPaused ? Icons.pause_circle_outline : Icons.stop_circle_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STATUS', style: AppTextStyles.sectionLabel),
              const SizedBox(height: 2),
              Text(
                state.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action button (glass pill) ────────────────────────────────────────────────

class ContainerActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ContainerActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
