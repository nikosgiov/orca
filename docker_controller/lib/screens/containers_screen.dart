import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import '../providers/app_provider.dart';
import '../providers/containers_provider.dart';
import 'container_detail_screen.dart';
import 'create_container_screen.dart';
import '../utils/app_transitions.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../constants/app_strings.dart';

class ContainersScreen extends StatefulWidget {
  const ContainersScreen({super.key});

  @override
  State<ContainersScreen> createState() => _ContainersScreenState();
}

class _ContainersScreenState extends State<ContainersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final containersProvider =
            Provider.of<ContainersProvider>(context, listen: false);
        if (containersProvider.containers == null) {
          containersProvider.fetchContainers();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final containersProvider = Provider.of<ContainersProvider>(context);
    final filteredContainers = containersProvider.filteredContainers;
    final isLoading = containersProvider.isLoading;

    return AppBackground(
      position: const Offset(100, -50),
      scale: 1.5,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppGradientTopBar(title: AppStrings.containersTitle),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.push(
              context,
              AppTransitions.focalZoom(const CreateContainerScreen()),
            ).then((_) {
              if (appProvider.isConnected) {
                containersProvider.refreshContainers();
              }
            });
          },
          backgroundColor: AppColors.primary.withValues(alpha: 0.85),
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search + filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                AppSearchBar(
                  value: containersProvider.searchQuery,
                  onChanged: (v) => containersProvider.searchQuery = v,
                  hintText: AppStrings.searchContainersHint,
                ),
                const SizedBox(height: 10),
                AppFilterChips(
                  options: containersProvider.filterOptions,
                  selected: containersProvider.selectedFilter,
                  onSelected: (f) => containersProvider.selectedFilter = f,
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: isLoading
                ? const AppLoadingIndicator(message: 'Loading containers...')
                : filteredContainers.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.inbox_outlined,
                        title: AppStrings.noContainersFound,
                        message: AppStrings.createFirstContainer,
                      )
                    : RefreshIndicator(
                        onRefresh: containersProvider.refreshContainers,
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFF1A0B3B),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                          itemCount: filteredContainers.length,
                          itemBuilder: (context, index) {
                            return _ContainerCard(
                                container: filteredContainers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    ),
   );
  }
}

// ─── Container Card ───────────────────────────────────────────────────────────

class _ContainerCard extends StatelessWidget {
  final Map<String, dynamic> container;
  const _ContainerCard({required this.container});

  @override
  Widget build(BuildContext context) {
    final containersProvider =
        Provider.of<ContainersProvider>(context, listen: false);
    final containerId = container['Id'] as String? ?? '';
    final names = container['Names'] as List? ?? [];
    final name = names.isNotEmpty
        ? names.first.toString().replaceFirst('/', '')
        : 'Unknown';
    final image = container['Image'] as String? ?? 'Unknown';
    final state = container['State'] as String? ?? 'unknown';
    final created = container['Created'] as int? ?? 0;
    final ports = container['Ports'] as List? ?? [];

    Color statusColor;
    IconData statusIcon;
    String displayStatus;

    switch (state) {
      case 'running':
        statusColor = AppColors.successGreen;
        statusIcon = Icons.play_circle_filled;
        displayStatus = AppStrings.statusRunning;
        break;
      case 'stopped':
        statusColor = AppColors.errorRed;
        statusIcon = Icons.stop_circle;
        displayStatus = AppStrings.statusStopped;
        break;
      case 'exited':
        statusColor = AppColors.warningYellow;
        statusIcon = Icons.error;
        displayStatus = AppStrings.statusExited;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.help;
        displayStatus = AppStrings.statusUnknown;
    }

    String uptime = AppStrings.statusUnknown;
    if (created > 0) {
      final diff = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(created * 1000));
      if (diff.inDays > 0) {
        uptime = '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        uptime = '${diff.inHours}h';
      } else {
        uptime = '${diff.inMinutes}m';
      }
    }

    String portDisplay = AppStrings.noPorts;
    if (ports.isNotEmpty) {
      final portStrings = ports
          .map((p) {
            final pub = p['PublicPort'];
            final priv = p['PrivatePort'];
            if (pub != null && priv != null) return '$pub:$priv';
            if (priv != null) return priv.toString();
            return '';
          })
          .where((p) => p.isNotEmpty)
          .toList();
      if (portStrings.isNotEmpty) portDisplay = portStrings.join(', ');
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
          // Header row
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
                    Text(name,
                        style: AppTextStyles.heading2,
                        overflow: TextOverflow.ellipsis),
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
          // Info rows
          _CardInfoRow(icon: Icons.image_rounded, label: 'Image', value: image),
          _CardInfoRow(icon: Icons.link_rounded, label: 'Ports', value: portDisplay),
          _CardInfoRow(icon: Icons.schedule_rounded, label: 'Uptime', value: uptime),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _GlassActionButton(
                  label: state == 'running' ? AppStrings.actionStop : AppStrings.actionStart,
                  color: state == 'running' ? AppColors.errorRed : AppColors.successGreen,
                  onPressed: () async {
                    final success = state == 'running'
                        ? await containersProvider.stopContainer(containerId)
                        : await containersProvider.startContainer(containerId);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Done' : 'Failed'),
                      backgroundColor: success
                          ? (state == 'running' ? AppColors.errorRed : AppColors.successGreen)
                          : AppColors.errorRed,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassActionButton(
                  label: AppStrings.actionDetails,
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      AppTransitions.focalZoom(
                        ContainerDetailScreen(
                          containerId: containerId,
                          containerName: name,
                        ),
                      ),
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
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

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
  final IconData icon;
  final String label;
  final String value;
  const _CardInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90, // Fixed width for alignment
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
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _GlassActionButton(
      {required this.label, required this.color, required this.onPressed});

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
