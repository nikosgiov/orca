import 'package:flutter/material.dart';
import '../../providers/create_container_provider.dart';
import '../../widgets/dynamic_config_list.dart';

class AdvancedConfigStep extends StatelessWidget {
  const AdvancedConfigStep({super.key, required this.provider});
  final CreateContainerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DynamicConfigList(
            title: 'Port Mappings',
            items: provider.portMappings,
            label1: 'Host Port',
            label2: 'Container Port',
            icon: Icons.link,
            onAdd: provider.addPortMapping,
            onUpdate: provider.updatePortMapping,
            onRemove: provider.removePortMapping,
          ),
          const SizedBox(height: 16),
          DynamicConfigList(
            title: 'Volume Mappings',
            items: provider.volumeMappings,
            label1: 'Host Path',
            label2: 'Container Path',
            icon: Icons.folder,
            onAdd: provider.addVolumeMapping,
            onUpdate: provider.updateVolumeMapping,
            onRemove: provider.removeVolumeMapping,
          ),
          const SizedBox(height: 16),
          DynamicConfigList(
            title: 'Environment Variables',
            items: provider.environmentVars,
            label1: 'Variable Name',
            label2: 'Value',
            icon: Icons.settings,
            onAdd: provider.addEnvironmentVar,
            onUpdate: provider.updateEnvironmentVar,
            onRemove: provider.removeEnvironmentVar,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.networkMode,
            decoration: const InputDecoration(
              labelText: 'Network Mode',
              prefixIcon: Icon(Icons.wifi),
            ),
            items: const [
              DropdownMenuItem(value: 'bridge', child: Text('Bridge')),
              DropdownMenuItem(value: 'host', child: Text('Host')),
              DropdownMenuItem(value: 'none', child: Text('None')),
            ],
            onChanged: provider.setNetworkMode,
          ),
        ],
      ),
    );
  }
}
