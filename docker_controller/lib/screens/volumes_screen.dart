import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/docker_volume.dart';
import '../providers/auth_provider.dart';
import '../providers/volumes_networks_provider.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/info_row.dart';

/// ─── Volumes Screen ──────────────────────────────────────────────────────────
class VolumesScreen extends StatelessWidget {
  const VolumesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolumesNetworksProvider(),
      child: const _VolumesScreenBody(),
    );
  }
}

class _VolumesScreenBody extends StatefulWidget {
  const _VolumesScreenBody();
  @override
  State<_VolumesScreenBody> createState() => _VolumesScreenBodyState();
}

class _VolumesScreenBodyState extends State<_VolumesScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VolumesNetworksProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.connectionConfig != null) {
        provider.setConnectionConfig(authProvider.connectionConfig!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VolumesNetworksProvider>(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: 'Volumes',
          leftWidget: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('createVolume'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body: RefreshIndicator(
          onRefresh: () async => provider.refreshData(),
          color: AppColors.primary,
          backgroundColor: const Color(0xFF1A0B3B),
          child: provider.isLoadingVolumes
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : provider.volumes.isEmpty
              ? const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No volumes found',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: provider.volumes.length,
                  itemBuilder: (context, index) {
                    final volume = provider.volumes[index];
                    return _VolumeCard(
                      volume: volume,
                      provider: provider,
                      context: context,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({
    required this.volume,
    required this.provider,
    required this.context,
  });
  final DockerVolume volume;
  final VolumesNetworksProvider provider;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final name = volume.name;
    final driver = volume.driver;
    final mountpoint = volume.mountpoint;
    final createdAt = volume.createdAt ?? 'Unknown';
    final scope = volume.scope;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppPaddings.card,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storage,
                  color: Color(0xFF60A5FA),
                  size: 20,
                ),
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
                    Text('Driver: $driver', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: AppStrings.labelMountPoint,
            value: mountpoint,
            icon: Icons.folder_outlined,
          ),
          InfoRow(
            label: 'Created',
            value: createdAt,
            icon: Icons.schedule_outlined,
          ),
          InfoRow(
            label: 'Scope',
            value: scope,
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PillBtn(
                  label: 'INSPECT',
                  color: AppColors.primary,
                  onPressed: () =>
                      _inspect(ctx, name, driver, mountpoint, createdAt, scope),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PillBtn(
                  label: 'REMOVE',
                  color: AppColors.error,
                  onPressed: () => _remove(ctx, name),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _inspect(
    BuildContext ctx,
    String name,
    String driver,
    String mountpoint,
    String createdAt,
    String scope,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Volume: $name'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InspectRow(label: 'Name', value: name),
                _InspectRow(label: 'Driver', value: driver),
                _InspectRow(label: 'Mount Point', value: mountpoint),
                _InspectRow(label: 'Created', value: createdAt),
                _InspectRow(label: 'Scope', value: scope),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _remove(BuildContext ctx, String name) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Remove Volume'),
        content: Text('Remove volume "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              final ok = await provider.removeVolume(name);
              if (!ctx.mounted) {
                return;
              }
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Removed $name' : 'Failed to remove $name',
                  ),
                  backgroundColor: ok
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Shared glass pill button ──────────────────────────────────────────────────

class _PillBtn extends StatelessWidget {
  const _PillBtn({required this.label, required this.color, this.onPressed});
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── Inspect row: label stacked above value so long text can wrap ──────────────

class _InspectRow extends StatelessWidget {
  const _InspectRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFF1F5F9),
              height: 1.4,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
