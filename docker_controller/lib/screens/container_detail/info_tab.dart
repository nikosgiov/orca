import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/providers/container_detail_provider.dart';
import 'package:docker_controller/utils/container_format_utils.dart';
import 'package:docker_controller/widgets/info_card.dart';
import 'package:docker_controller/widgets/info_row.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key, required this.provider});
  final ContainerDetailProvider provider;
  @override
  Widget build(BuildContext context) {
    final info = provider.containerInfo;
    if (info == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noContainerInfo));
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
            title: AppLocalizations.of(context)!.basicInformation,
            children: [
              InfoRow(
                label: AppLocalizations.of(context)!.containerId,
                value: provider.containerId.substring(0, 12),
                icon: Icons.fingerprint,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.name,
                value: provider.containerName,
                icon: Icons.label,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.image,
                value: config['Image']?.toString() ?? AppLocalizations.of(context)!.unknown,
                icon: Icons.image,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.status,
                value: state['Status']?.toString() ?? AppLocalizations.of(context)!.unknown,
                icon: Icons.circle,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.created,
                value: ContainerFormatUtils.formatDate(info.created.toString()),
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (networkSettings['Ports'] != null)
            InfoCard(
              title: AppLocalizations.of(context)!.ports,
              children: [
                ...ContainerFormatUtils.formatPorts(
                  networkSettings['Ports'],
                ).map(
                  (port) => InfoRow(
                    label: AppLocalizations.of(context)!.port,
                    value: port,
                    icon: Icons.link,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (hostConfig['Binds'] != null)
            InfoCard(
              title: AppLocalizations.of(context)!.volumes,
              children: [
                ...(hostConfig['Binds'] as List? ?? []).map(
                  (volume) => InfoRow(
                    label: AppLocalizations.of(context)!.volume,
                    value: volume.toString(),
                    icon: Icons.folder,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (config['Env'] != null)
            InfoCard(
              title: AppLocalizations.of(context)!.envVars,
              children: [
                ...(config['Env'] as List? ?? []).map(
                  (env) => InfoRow(
                    label: AppLocalizations.of(context)!.env,
                    value: env.toString(),
                    icon: Icons.settings,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (networkSettings['Networks'] != null)
            InfoCard(
              title: AppLocalizations.of(context)!.networks,
              children: [
                ...(networkSettings['Networks'] as Map? ?? {}).keys.map(
                  (network) => InfoRow(
                    label: AppLocalizations.of(context)!.network,
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
