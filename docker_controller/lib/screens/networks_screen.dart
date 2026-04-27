import 'dart:async';

import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_network.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/volumes_networks_provider.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:docker_controller/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/extensions/context_extensions.dart';
import '../l10n/app_localizations.dart';

/// ─── Networks Screen ─────────────────────────────────────────────────────────
/// Dedicated screen for Docker networks (split from volumes_networks_screen).
class NetworksScreen extends StatelessWidget {
  const NetworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NetworksScreenBody();
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
          title: context.l10n.networksTitle,
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
          child: switch (provider.networksState) {
            AppInitial() || AppLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            AppStateError(:final failure) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(failure.localizedMessage(context.l10n), style: AppTextStyles.body, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.refreshData(),
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            AppSuccess(data: final networks) => networks.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.l10n.noNetworksFound,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: networks.length,
                    itemBuilder: (context, index) {
                      final network = networks[index];
                      return _NetworkCard(network: network, provider: provider);
                    },
                  ),
          },
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
    final subnet = _extractSubnet(network, ctx.l10n);
    final containers = _extractContainers(network, ctx.l10n);

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
                      '$driver · ${ctx.l10n.labelScope}: $scope',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: ctx.l10n.labelSubnet,
            value: subnet,
            icon: Icons.network_check_outlined,
          ),
          InfoRow(
            label: ctx.l10n.labelContainers,
            value: containers,
            icon: Icons.dns_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PillBtn(
                  label: ctx.l10n.actionInspect.toUpperCase(),
                  color: AppColors.primary,
                  onPressed: () => _inspect(ctx, network, provider),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PillBtn(
                  label: ctx.l10n.actionRemove.toUpperCase(),
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
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(ctx.l10n.loading),
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
        SnackBar(
          content: Text(ctx.l10n.failedToFetchNetworkDetails),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final name = details.name;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('${ctx.l10n.network}: $name'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InspectRow(label: ctx.l10n.name, value: details.name),
                _InspectRow(label: ctx.l10n.labelDriver, value: details.driver),
                _InspectRow(label: ctx.l10n.labelScope, value: details.scope),
                _InspectRow(label: ctx.l10n.labelCreated, value: details.created ?? ''),
                _InspectRow(label: ctx.l10n.labelSubnet, value: _extractSubnet(details, ctx.l10n)),
                _InspectRow(
                  label: ctx.l10n.labelContainers,
                  value: _extractContainers(details, ctx.l10n),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.close),
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
    final l10n = ctx.l10n;
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: Text(l10n.actionRemove),
        content: Text(l10n.removeNetworkConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(l10n.cancel),
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
                    ok ? l10n.removedNetwork(name) : l10n.failedToRemoveNetwork(name),
                  ),
                  backgroundColor: ok
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.actionRemove),
          ),
        ],
      ),
    );
  }

  String _extractSubnet(DockerNetwork network, AppLocalizations l10n) {
    final ipam = network.ipam;
    if (ipam != null &&
        ipam['Config'] is List &&
        (ipam['Config'] as List).isNotEmpty) {
      final config = ipam['Config'][0];
      if (config is Map && config['Subnet'] != null) {
        return config['Subnet'].toString();
      }
    }
    return l10n.notAvailable;
  }

  String _extractContainers(DockerNetwork network, AppLocalizations l10n) {
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
    return l10n.none;
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
