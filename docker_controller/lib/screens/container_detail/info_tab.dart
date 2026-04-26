import 'package:flutter/material.dart';

import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../providers/container_detail_provider.dart';
import '../../utils/container_format_utils.dart';
import '../../widgets/info_card.dart';
import '../../widgets/info_row.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key, required this.provider});
  final ContainerDetailProvider provider;
  @override
  Widget build(BuildContext context) {
    final info = provider.containerInfo;
    if (info == null) {
      return const Center(child: Text(AppStrings.noContainerInfo));
    }
    final config = info.config ?? {};
    final hostConfig = info.hostConfig ?? {};
    final networkSettings = info.networkSettings ?? {};
    final state = info.state is Map ? info.state as Map<String, dynamic> : {};
    return SingleChildScrollView(
      padding: AppPaddings.tabContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: AppStrings.basicInformation,
            children: [
              InfoRow(
                label: AppStrings.containerId,
                value: provider.containerId.substring(0, 12),
                icon: Icons.fingerprint,
              ),
              InfoRow(
                label: AppStrings.name,
                value: provider.containerName,
                icon: Icons.label,
              ),
              InfoRow(
                label: AppStrings.image,
                value: config['Image']?.toString() ?? 'Unknown',
                icon: Icons.image,
              ),
              InfoRow(
                label: AppStrings.status,
                value: state['Status']?.toString() ?? 'Unknown',
                icon: Icons.circle,
              ),
              InfoRow(
                label: AppStrings.created,
                value: ContainerFormatUtils.formatDate(info.created.toString()),
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (networkSettings['Ports'] != null)
            InfoCard(
              title: AppStrings.ports,
              children: [
                ...ContainerFormatUtils.formatPorts(
                  networkSettings['Ports'],
                ).map(
                  (port) => InfoRow(
                    label: AppStrings.port,
                    value: port,
                    icon: Icons.link,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (hostConfig['Binds'] != null)
            InfoCard(
              title: AppStrings.volumes,
              children: [
                ...(hostConfig['Binds'] as List? ?? []).map(
                  (volume) => InfoRow(
                    label: AppStrings.volume,
                    value: volume.toString(),
                    icon: Icons.folder,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (config['Env'] != null)
            InfoCard(
              title: AppStrings.envVars,
              children: [
                ...(config['Env'] as List? ?? []).map(
                  (env) => InfoRow(
                    label: AppStrings.env,
                    value: env.toString(),
                    icon: Icons.settings,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (networkSettings['Networks'] != null)
            InfoCard(
              title: AppStrings.networks,
              children: [
                ...(networkSettings['Networks'] as Map? ?? {}).keys.map(
                  (network) => InfoRow(
                    label: AppStrings.network,
                    value: network.toString(),
                    icon: Icons.wifi,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
