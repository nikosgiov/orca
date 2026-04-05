import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../constants/app_strings.dart';
import '../providers/volumes_networks_provider.dart';
import '../widgets/info_row.dart';
import '../providers/app_provider.dart';
import '../screens/create_volume_screen.dart';
import '../screens/create_network_screen.dart';

class VolumesNetworksScreen extends StatelessWidget {
  const VolumesNetworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolumesNetworksProvider(),
      child: const _VolumesNetworksScreenBody(),
    );
  }
}

class _VolumesNetworksScreenBody extends StatefulWidget {
  const _VolumesNetworksScreenBody();

  @override
  State<_VolumesNetworksScreenBody> createState() => _VolumesNetworksScreenBodyState();
}

class _VolumesNetworksScreenBodyState extends State<_VolumesNetworksScreenBody> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = Provider.of<VolumesNetworksProvider>(context, listen: false);
    provider.setTabController(_tabController);
    // Pass connectionConfig from AppProvider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.connectionConfig != null) {
      provider.setConnectionConfig(appProvider.connectionConfig!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VolumesNetworksProvider>(context);
    return AppBackground(
      position: const Offset(100, 100),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppGradientTopBar(
        title: AppStrings.volumesNetworksTitle,
        leftWidget: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),

      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryCyan,
              labelColor: AppColors.primaryCyan,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.folder), text: AppStrings.dockerVolumes),
                Tab(icon: Icon(Icons.wifi), text: AppStrings.dockerNetworks),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVolumesTab(provider),
                _buildNetworksTab(provider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateVolumeScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateNetworkScreen()),
            );
          }
        },
        backgroundColor: AppColors.secondaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    ),
   );
  }

  Widget _buildVolumesTab(VolumesNetworksProvider provider) {
    return Column(
      children: [
        // Volumes list (removed header card)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.refreshData();
            },
            color: AppColors.secondaryBlue,
            backgroundColor: AppColors.backgroundColor,
            child: ListView.builder(
              padding: AppPaddings.screen,
              itemCount: provider.volumes.length,
              itemBuilder: (context, index) {
                final volume = provider.volumes[index];
                return _buildVolumeCard(provider, volume);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworksTab(VolumesNetworksProvider provider) {
    return Column(
      children: [
        // Networks list (removed header card)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.refreshData();
            },
            color: AppColors.secondaryBlue,
            backgroundColor: AppColors.backgroundColor,
            child: ListView.builder(
              padding: AppPaddings.screen,
              itemCount: provider.networks.length,
              itemBuilder: (context, index) {
                final network = provider.networks[index];
                return _buildNetworkCard(provider, network);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeCard(VolumesNetworksProvider provider, Map<String, dynamic> volume) {
    // Extract fields with correct Docker API keys
    final name = volume['Name']?.toString() ?? 'Unknown';
    final driver = volume['Driver']?.toString() ?? 'Unknown';
    final mountpoint = volume['Mountpoint']?.toString() ?? 'N/A';
    final createdAt = volume['CreatedAt']?.toString() ?? 'Unknown';
    final scope = volume['Scope']?.toString() ?? 'Unknown';

    return AppCard(
      margin: AppPaddings.volumeCardMargin,
      padding: AppPaddings.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppPaddings.volumeIconPadding,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryCyan, AppColors.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.heading2,
                    ),
                    Text(
                      '${AppStrings.labelDriver}: $driver',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(label: AppStrings.labelMountPoint, value: mountpoint, icon: Icons.folder),
          InfoRow(label: 'Created', value: createdAt, icon: Icons.schedule),
          InfoRow(label: 'Scope', value: scope, icon: Icons.visibility),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  AppStrings.actionInspect,
                  Icons.info,
                  AppColors.secondaryBlue,
                  () => _inspectVolume(volume),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  AppStrings.actionRemove,
                  Icons.delete,
                  AppColors.errorRed,
                  () => _removeVolume(provider, volume),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(VolumesNetworksProvider provider, Map<String, dynamic> network) {
    // Extract fields with correct Docker API keys
    final name = network['Name']?.toString() ?? 'Unknown';
    final driver = network['Driver']?.toString() ?? 'Unknown';
    final scope = network['Scope']?.toString() ?? 'Unknown';


    final subnet = _extractSubnet(network);
    final containers = _extractContainers(network);

    return AppCard(
      margin: AppPaddings.networkCardMargin,
      padding: AppPaddings.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppPaddings.networkIconPadding,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryCyan, AppColors.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.heading2,
                    ),
                    Text(
                      '$driver • ${AppStrings.labelScope}: $scope',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(label: AppStrings.labelSubnet, value: subnet, icon: Icons.network_check),
          InfoRow(label: AppStrings.labelContainers, value: containers, icon: Icons.dns),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  AppStrings.actionInspect,
                  Icons.info,
                  AppColors.secondaryBlue,
                  () => _inspectNetwork(provider, network),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  AppStrings.actionRemove,
                  Icons.delete,
                  AppColors.errorRed,
                  () => _removeNetwork(provider, network),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      color: color,
      textColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  void _inspectVolume(Map<String, dynamic> volume) {
    final name = volume['Name']?.toString() ?? 'Unknown';
    final driver = volume['Driver']?.toString() ?? 'Unknown';
    final mountpoint = volume['Mountpoint']?.toString() ?? 'N/A';
    final createdAt = volume['CreatedAt']?.toString() ?? 'Unknown';
    final scope = volume['Scope']?.toString() ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Volume: $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: 'Name', value: name),
            InfoRow(label: 'Driver', value: driver),
            InfoRow(label: 'Mount Point', value: mountpoint),
            InfoRow(label: 'Created', value: createdAt),
            InfoRow(label: 'Scope', value: scope),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _removeVolume(VolumesNetworksProvider provider, Map<String, dynamic> volume) {
    final volumeName = volume['Name']?.toString() ?? 'Unknown';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Volume'),
        content: Text('Are you sure you want to remove volume "$volumeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.removeVolume(volumeName);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed volume $volumeName'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove volume $volumeName'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _inspectNetwork(VolumesNetworksProvider provider, Map<String, dynamic> network) async {
    final idOrName = network['Id'] ?? network['Name'];
    if (idOrName == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading network details...'),
          ],
        ),
      ),
    );

    final details = await provider.inspectNetwork(idOrName.toString());
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog
    
    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch network details'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final name = details['Name']?.toString() ?? 'Unknown';
    final driver = details['Driver']?.toString() ?? 'Unknown';
    final scope = details['Scope']?.toString() ?? 'Unknown';
    final created = details['Created']?.toString() ?? 'Unknown';

    final subnet = _extractSubnet(details);
    final containers = _extractContainers(details);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Network: $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: 'Name', value: name),
            InfoRow(label: 'Driver', value: driver),
            InfoRow(label: 'Scope', value: scope),
            InfoRow(label: 'Created', value: created),
            InfoRow(label: 'Subnet', value: subnet),
            InfoRow(label: 'Containers', value: containers),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _removeNetwork(VolumesNetworksProvider provider, Map<String, dynamic> network) {
    final networkName = network['Name']?.toString() ?? 'Unknown';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Network'),
        content: Text('Are you sure you want to remove network "$networkName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.removeNetwork(networkName);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed network $networkName'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove network $networkName'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _extractSubnet(Map<String, dynamic> network) {
    final ipam = network['IPAM'];
    if (ipam is Map && ipam['Config'] is List && (ipam['Config'] as List).isNotEmpty) {
      final config = ipam['Config'][0];
      if (config is Map && config['Subnet'] != null) {
        return config['Subnet'].toString();
      }
    }
    return 'N/A';
  }

  static String _extractContainers(Map<String, dynamic> network) {
    final containersMap = network['Containers'];
    if (containersMap is Map && containersMap.isNotEmpty) {
      final names = containersMap.values
          .map((c) => c is Map && c['Name'] != null ? c['Name'].toString() : '')
          .where((n) => n.isNotEmpty)
          .join(', ');
      if (names.isNotEmpty) return names;
    }
    return 'No containers attached';
  }
}