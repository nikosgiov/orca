import 'package:flutter/material.dart';
import '../../providers/create_network_provider.dart';
import '../../utils/validators.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key, required this.provider});
  final CreateNetworkProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.nameController,
            decoration: const InputDecoration(
              labelText: 'Network Name',
              hintText: 'my-network',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(Icons.wifi),
            ),
            onChanged: provider.setNetworkName,
            validator:
                Validators.validateImageName, // Reuse image name validation
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedDriver,
            decoration: const InputDecoration(
              labelText: 'Driver',
              prefixIcon: Icon(Icons.settings),
            ),
            items: const [
              DropdownMenuItem(value: 'bridge', child: Text('Bridge')),
              DropdownMenuItem(value: 'host', child: Text('Host')),
              DropdownMenuItem(value: 'overlay', child: Text('Overlay')),
              DropdownMenuItem(value: 'macvlan', child: Text('Macvlan')),
              DropdownMenuItem(value: 'ipvlan', child: Text('IPvlan')),
            ],
            onChanged: provider.setDriver,
          ),
        ],
      ),
    );
  }
}
