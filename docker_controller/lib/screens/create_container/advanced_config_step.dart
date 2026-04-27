import 'package:docker_controller/providers/create_container_provider.dart';
import 'package:docker_controller/utils/validators.dart';
import 'package:docker_controller/widgets/dynamic_config_list.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AdvancedConfigStep extends StatelessWidget {
  const AdvancedConfigStep({super.key, required this.provider});
  final CreateContainerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DynamicConfigList(
            title: AppLocalizations.of(context)!.portMappings,
            items: provider.portMappings,
            label1: AppLocalizations.of(context)!.hostPort,
            label2: AppLocalizations.of(context)!.containerPort,
            icon: Icons.link,
            onAdd: provider.addPortMapping,
            onUpdate: provider.updatePortMapping,
            onRemove: provider.removePortMapping,
            validator1: (val) => Validators.validatePort(
              val,
              requiredError: AppLocalizations.of(context)!.portRequired,
              invalidError: AppLocalizations.of(context)!.portInvalid,
            ),
            validator2: (val) => Validators.validatePort(
              val,
              requiredError: AppLocalizations.of(context)!.portRequired,
              invalidError: AppLocalizations.of(context)!.portInvalid,
            ),
          ),
          const SizedBox(height: 16),
          DynamicConfigList(
            title: AppLocalizations.of(context)!.volumeMappings,
            items: provider.volumeMappings,
            label1: AppLocalizations.of(context)!.hostPath,
            label2: AppLocalizations.of(context)!.containerPath,
            icon: Icons.folder,
            onAdd: provider.addVolumeMapping,
            onUpdate: provider.updateVolumeMapping,
            onRemove: provider.removeVolumeMapping,
          ),
          const SizedBox(height: 16),
          DynamicConfigList(
            title: AppLocalizations.of(context)!.envVarsLabel,
            items: provider.environmentVars,
            label1: AppLocalizations.of(context)!.variableName,
            label2: AppLocalizations.of(context)!.value,
            icon: Icons.settings,
            onAdd: provider.addEnvironmentVar,
            onUpdate: provider.updateEnvironmentVar,
            onRemove: provider.removeEnvironmentVar,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.networkMode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.networkModeLabel,
              prefixIcon: const Icon(Icons.wifi),
            ),
            items: [
              DropdownMenuItem(value: 'bridge', child: Text(AppLocalizations.of(context)!.networkBridge)),
              DropdownMenuItem(value: 'host', child: Text(AppLocalizations.of(context)!.networkHost)),
              DropdownMenuItem(value: 'none', child: Text(AppLocalizations.of(context)!.networkNone)),
            ],
            onChanged: provider.setNetworkMode,
          ),
        ],
      ),
    );
  }
}
