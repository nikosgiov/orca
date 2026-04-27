import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/result.dart';
import '../../../models/app_error.dart';
import '../../../models/compose_project.dart';
import '../../../providers/compose_provider.dart';
import '../../../services/compose_service.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.provider});
  final ComposeProject project;
  final ComposeProvider provider;

  @override
  Widget build(BuildContext context) {
    final runningCount = project.runningCount;
    final totalCount = project.totalCount;
    final isPartiallyRunning = runningCount > 0 && runningCount < totalCount;
    final isFullyRunning = runningCount == totalCount && totalCount > 0;

    final statusColor = isFullyRunning
        ? AppColors.success
        : isPartiallyRunning
        ? const Color(0xFFFBBF24)
        : AppColors.textMuted;

    final statusText = isFullyRunning
        ? 'Running'
        : isPartiallyRunning
        ? 'Partial'
        : 'Stopped';
    final isBusy = provider.isProjectCommandRunning(project.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.heading2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.workingDir.isEmpty
                            ? 'Directory unknown'
                            : project.workingDir,
                        style: AppTextStyles.caption.copyWith(
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.glassBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '$runningCount / $totalCount containers active',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(height: 1, color: AppColors.glassBorder),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isBusy
                ? _buildProgressLogs(project.name)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        label: 'Up -d',
                        icon: Icons.play_arrow,
                        color: AppColors.success,
                        onPressed: () => provider.runCommand(
                          project.name,
                          project.workingDir,
                          'up -d',
                        ),
                      ),
                      _ActionButton(
                        label: 'Down',
                        icon: Icons.stop,
                        color: AppColors.error,
                        onPressed: () => provider.runCommand(
                          project.name,
                          project.workingDir,
                          'down',
                        ),
                      ),
                      _ActionButton(
                        label: 'Build',
                        icon: Icons.build,
                        color: AppColors.primary,
                        onPressed: () => provider.runCommand(
                          project.name,
                          project.workingDir,
                          'build',
                        ),
                      ),
                      _ActionButton(
                        label: 'Logs',
                        icon: Icons.list_alt,
                        color: Colors.white,
                        onPressed: () => _showLogsModal(context, project.name),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLogs(String projectName) {
    final logs = provider.getLogsForProject(projectName);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Running command...',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            logs.isNotEmpty ? logs.last : '...',
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF4ADE80),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showLogsModal(BuildContext parentContext, String projectName) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Logs: $projectName',
                          style: AppTextStyles.heading2,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.glassBorder),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FutureBuilder<Result<Stream<List<int>>, AppError>>(
                        future: getIt<ComposeService>().runCommandStream(
                          projectName,
                          project.workingDir,
                          'logs --tail=200 -f',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Text('Error fetching logs', style: AppTextStyles.caption),
                            );
                          }

                          return snapshot.data!.fold(
                            (stream) => _LogStreamViewer(logStream: stream),
                            (failure) => Center(
                              child: Text(
                                'Error: ${failure.message}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LogStreamViewer extends StatefulWidget {
  const _LogStreamViewer({required this.logStream});
  final Stream<List<int>> logStream;
  @override
  State<_LogStreamViewer> createState() => _LogStreamViewerState();
}

class _LogStreamViewerState extends State<_LogStreamViewer> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    widget.logStream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (!mounted) {
            return;
          }
          try {
            final data = jsonDecode(line);
            if (data['type'] == 'stdout' || data['type'] == 'stderr') {
              setState(() => _logs.add(data['data'].toString()));
            }
          } catch (_) {
            setState(() => _logs.add(line));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_logs.isEmpty) {
      return const Text(
        'Waiting for logs...',
        style: TextStyle(color: Colors.white54, fontFamily: 'monospace'),
      );
    }
    return ListView.builder(
      reverse: true,
      itemCount: _logs.length,
      itemBuilder: (context, index) => Text(
        _logs[_logs.length - 1 - index],
        style: const TextStyle(
          color: Color(0xFF4ADE80),
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
