import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/container_detail_provider.dart';
import 'package:docker_controller/widgets/container_action_button.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../exec_terminal_screen.dart';

class ActionsTab extends StatelessWidget {
  const ActionsTab({super.key, required this.provider});
  final ContainerDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final state = provider.containerInfo?.stateDisplay ?? 'unknown';
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
              label: AppLocalizations.of(context)!.startContainer,
              icon: Icons.play_arrow,
              color: AppColors.success,
              onPressed: () =>
                  _handleAction(context, provider.startContainer, 'start'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: AppLocalizations.of(context)!.stopContainer,
              icon: Icons.stop,
              color: AppColors.error,
              onPressed: () =>
                  _handleAction(context, provider.stopContainer, 'stop'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: AppLocalizations.of(context)!.pauseContainer,
              icon: Icons.pause,
              color: const Color(0xFFFBBF24),
              onPressed: () =>
                  _handleAction(context, provider.pauseContainer, 'pause'),
            ),
          if (isPaused)
            ContainerActionButton(
              label: AppLocalizations.of(context)!.resumeContainer,
              icon: Icons.play_arrow,
              color: AppColors.success,
              onPressed: () =>
                  _handleAction(context, provider.resumeContainer, 'resume'),
            ),
          if (isRunning || isStopped)
            ContainerActionButton(
              label: AppLocalizations.of(context)!.restartContainer,
              icon: Icons.refresh,
              color: AppColors.primary,
              onPressed: () =>
                  _handleAction(context, provider.restartContainer, 'restart'),
            ),
          if (isRunning)
            ContainerActionButton(
              label: AppLocalizations.of(context)!.openTerminal,
              icon: Icons.terminal,
              color: const Color(0xFF10B981), // Emerald green
              onPressed: () {
                if (provider.authProvider.connectionConfig != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExecTerminalScreen(
                        config: provider.authProvider.connectionConfig!,
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
              label: AppLocalizations.of(context)!.killContainer,
              icon: Icons.close,
              color: AppColors.error,
              onPressed: () async {
                final l10n = AppLocalizations.of(context)!;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.killConfirmTitle),
                    content: Text(
                      l10n.killConfirmMessage(provider.containerName),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(l10n.killContainer),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  if (!context.mounted) {
                    return;
                  }
                  final (success, errorMsg) = await provider.killContainer();
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? l10n.killedContainer(provider.containerName)
                            : errorMsg ?? l10n.failed,
                      ),
                      backgroundColor: success
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 8),
          ContainerActionButton(
            label: AppLocalizations.of(context)!.renameContainer,
            icon: Icons.edit_outlined,
            color: AppColors.primary,
            onPressed: () async {
              final l10n = AppLocalizations.of(context)!;
              final controller = TextEditingController(
                text: provider.containerName,
              );
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.renameConfirmTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.enterNewName),
                      const SizedBox(height: 16),
                      TextField(
                        autofocus: true,
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: l10n.newName,
                          hintText: 'container-name',
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            Navigator.pop(context, v.trim());
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final n = controller.text.trim();
                        if (n.isNotEmpty) {
                          Navigator.pop(context, n);
                        }
                      },
                      child: Text(l10n.renameContainer),
                    ),
                  ],
                ),
              );
              if (newName == null || newName.trim().isEmpty) {
                return;
              }
              final (success, errorMsg) = await provider.renameContainer(
                newName.trim(),
              );
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? l10n.renamedTo(newName.trim())
                        : errorMsg ?? l10n.failedToRename,
                  ),
                  backgroundColor: success
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
              if (success) {
                Navigator.pop(context);
              }
            },
          ),
          ContainerActionButton(
            label: AppLocalizations.of(context)!.removeContainer,
            icon: Icons.delete_outline,
            color: AppColors.error,
            onPressed: () async {
              final l10n = AppLocalizations.of(context)!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.removeConfirmTitle),
                  content: Text(
                    l10n.removeConfirmMessage(provider.containerName),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(l10n.removeContainer),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                if (!context.mounted) {
                  return;
                }
                final (success, errorMsg) = await provider.removeContainer();
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? l10n.removedContainer(provider.containerName)
                          : errorMsg ?? l10n.failedToRemove,
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.error,
                  ),
                );
                if (success) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Future<(bool, String?)> Function() action,
    String actionName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final (success, errorMsg) = await action();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.actionSuccess(actionName)
              : errorMsg ?? l10n.actionFailed(actionName),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}

// ── Status card (glass) ────────────────────────────────────────────────────────

class _ContainerStatusCard extends StatelessWidget {
  const _ContainerStatusCard({required this.state});
  final String state;

  @override
  Widget build(BuildContext context) {
    final isRunning = state == 'running';
    final isPaused = state == 'paused';
    final color = isRunning
        ? AppColors.success
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
              isRunning
                  ? Icons.play_circle_outline
                  : isPaused
                  ? Icons.pause_circle_outline
                  : Icons.stop_circle_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.statusLabel, style: AppTextStyles.sectionLabel),
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

