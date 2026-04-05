import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/compose_provider.dart';
import '../services/compose_service.dart';
import '../models/compose_project.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_strings.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComposeProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(120, -100),
      scale: 1.5,
      child: Scaffold(
      backgroundColor: Colors.transparent, // Let gradient show through
      appBar: AppGradientTopBar(title: AppStrings.composeTitle),
      body: Consumer<ComposeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null && provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: AppTextStyles.body, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadProjects,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.layers_clear, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 16),
                  Text('No Compose Projects Found', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    'Ensure labels com.docker.compose.project exist on containers.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadProjects,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadProjects,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 80),
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                return _ProjectCard(
                  project: provider.projects[index],
                  provider: provider,
                );
              },
            ),
          );
        },
      ),
    ),
   );
  }
}

class _ProjectCard extends StatelessWidget {
  final ComposeProject project;
  final ComposeProvider provider;

  const _ProjectCard({required this.project, required this.provider});

  @override
  Widget build(BuildContext context) {
    final runningCount = project.runningCount;
    final totalCount = project.totalCount;
    final isPartiallyRunning = runningCount > 0 && runningCount < totalCount;
    final isFullyRunning = runningCount == totalCount && totalCount > 0;

    final statusColor = isFullyRunning
        ? AppColors.successGreen
        : isPartiallyRunning
            ? const Color(0xFFFBBF24) // Yellowish
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
          // Header
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
                  child: const Icon(Icons.layers_outlined, color: AppColors.primary, size: 24),
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
                        project.workingDir.isEmpty ? 'Directory unknown' : project.workingDir,
                        style: AppTextStyles.caption.copyWith(fontFamily: 'monospace'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
          
          // Container list preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '$runningCount / $totalCount containers active',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.glassBorder),
          
          // Actions
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
                        color: AppColors.successGreen,
                        onPressed: () => provider.runCommand(project.name, project.workingDir, 'up -d'),
                      ),
                      _ActionButton(
                        label: 'Down',
                        icon: Icons.stop,
                        color: AppColors.errorRed,
                        onPressed: () => provider.runCommand(project.name, project.workingDir, 'down'),
                      ),
                      _ActionButton(
                        label: 'Build',
                        icon: Icons.build,
                        color: AppColors.primary,
                        onPressed: () => provider.runCommand(project.name, project.workingDir, 'build'),
                      ),
                      _ActionButton(
                        label: 'Logs',
                        icon: Icons.list_alt,
                        color: Colors.white,
                        onPressed: () => _showLogsModal(context, project.name),
                      ),
                      // removed Unregister Action

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
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text('Running command...', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            logs.isNotEmpty ? logs.last : '...',
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF4ADE80), // green
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
        // Use a stateful builder to stream logs without keeping the provider attached inside listview builder
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
                        Text('Logs: $projectName', style: AppTextStyles.heading2),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        )
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
                      child: FutureBuilder(
                        // Just run command logs once strictly for streaming into this view,
                        // or we could use the provider's command output.
                        // Let's trigger a `docker compose logs --tail=200` here instantly.
                        future: ComposeService.runCommandStream(
                          parentContext.read<ComposeProvider>().appProvider.connectionConfig!,
                          projectName,
                          project.workingDir,
                          'logs --tail=200 -f',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Center(child: Text('Error fetching logs', style: AppTextStyles.caption));
                          }
                          
                          // Stream it into a state list
                          return _LogStreamViewer(streamResponse: snapshot.data!);
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
  final http.StreamedResponse streamResponse;
  const _LogStreamViewer({required this.streamResponse});
  @override
  State<_LogStreamViewer> createState() => _LogStreamViewerState();
}

class _LogStreamViewerState extends State<_LogStreamViewer> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    widget.streamResponse.stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        if (!mounted) return;
        try {
            final data = jsonDecode(line);
            if (data['type'] == 'stdout' || data['type'] == 'stderr') {
               setState(() => _logs.add(data['data'].toString()));
            }
        } catch (_) {
            setState(() => _logs.add(line));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_logs.isEmpty) return const Text('Waiting for logs...', style: TextStyle(color: Colors.white54, fontFamily: 'monospace'));
    return ListView.builder(
      reverse: true, // Auto-scroll to bottom approach (items reversed)
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        // reversed so index 0 is the last item
        return Text(
          _logs[_logs.length - 1 - index],
          style: const TextStyle(
            color: Color(0xFF4ADE80),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onPressed});

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
