import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/docker_network.dart';
import '../providers/auth_provider.dart';
import '../providers/volumes_networks_provider.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/info_row.dart';

/// ─── Networks Screen ─────────────────────────────────────────────────────────
/// Dedicated screen for Docker networks (split from volumes_networks_screen).
class NetworksScreen extends StatelessWidget {
  const NetworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolumesNetworksProvider(),
      child: const _NetworksScreenBody(),
    );
  }
}

class _NetworksScreenBody extends StatefulWidget {
  const _NetworksScreenBody();
  @override
  State<_NetworksScreenBody> createState() => _NetworksScreenBodyState();
}

class _NetworksScreenBodyState extends State<_NetworksScreenBody> {
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
          title: 'Networks',
          leftWidget: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('createNetwork'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body: RefreshIndicator(
          onRefresh: () async => provider.refreshData(),
          color: AppColors.primary,
          backgroundColor: const Color(0xFF1A0B3B),
          child: provider.isLoadingNetworks
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : provider.networks.isEmpty
              ? const Center(
                  child: Text(
                    'No networks found',
                    style: AppTextStyles.caption,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: provider.networks.length,
                  itemBuilder: (context, index) {
                    final network = provider.networks[index];
                    return _NetworkCard(network: network, provider: provider);
                  },
                ),
        ),
      ),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.network, required this.provider});
  final DockerNetwork network;
  final VolumesNetworksProvider provider;

  @override
  Widget build(BuildContext ctx) {
    final name = network.name;
    final driver = network.driver;
    final scope = network.scope;
    final subnet = _extractSubnet(network);
    final containers = _extractContainers(network);

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
                  Icons.account_tree_outlined,
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
                    Text(
                      '$driver · ${AppStrings.labelScope}: $scope',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: AppStrings.labelSubnet,
            value: subnet,
            icon: Icons.network_check_outlined,
          ),
          InfoRow(
            label: AppStrings.labelContainers,
            value: containers,
            icon: Icons.dns_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PillBtn(
                  label: 'INSPECT',
                  color: AppColors.primary,
                  onPressed: () => _inspect(ctx, network, provider),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PillBtn(
                  label: 'REMOVE',
                  color: AppColors.error,
                  onPressed: () => _remove(ctx, name, provider),
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
    DockerNetwork network,
    VolumesNetworksProvider provider,
  ) async {
    final idOrName = network.id;
    unawaited(showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading...'),
          ],
        ),
      ),
    ));
    final details = await provider.inspectNetwork(idOrName.toString());
    if (!ctx.mounted) {
      return;
    }
    Navigator.pop(ctx);
    if (details == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch network details'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final name = details.name;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Network: $name'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InspectRow(label: 'Name', value: details.name),
                _InspectRow(label: 'Driver', value: details.driver),
                _InspectRow(label: 'Scope', value: details.scope),
                _InspectRow(label: 'Created', value: details.created ?? ''),
                _InspectRow(label: 'Subnet', value: _extractSubnet(details)),
                _InspectRow(
                  label: 'Containers',
                  value: _extractContainers(details),
                ),
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

  void _remove(
    BuildContext ctx,
    String name,
    VolumesNetworksProvider provider,
  ) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Remove Network'),
        content: Text('Remove network "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              final ok = await provider.removeNetwork(name);
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

  static String _extractSubnet(DockerNetwork network) {
    final ipam = network.ipam;
    if (ipam != null &&
        ipam['Config'] is List &&
        (ipam['Config'] as List).isNotEmpty) {
      final config = ipam['Config'][0];
      if (config is Map && config['Subnet'] != null) {
        return config['Subnet'].toString();
      }
    }
    return 'N/A';
  }

  static String _extractContainers(DockerNetwork network) {
    final containersMap = network.containers;
    if (containersMap != null && containersMap.isNotEmpty) {
      final names = containersMap.values
          .map((c) => c is Map && c['Name'] != null ? c['Name'].toString() : '')
          .where((n) => n.isNotEmpty)
          .join(', ');
      if (names.isNotEmpty) {
        return names;
      }
    }
    return 'No containers attached';
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
