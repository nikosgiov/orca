import 'package:flutter/material.dart';
import '../../providers/create_network_provider.dart';
import '../../utils/validators.dart';

class BasicInfoStep extends StatelessWidget {
  final CreateNetworkProvider provider;

  const BasicInfoStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.nameController,
            decoration: InputDecoration(
              labelText: 'Network Name',
              hintText: 'my-network',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.wifi),
            ),
            onChanged: provider.setNetworkName,
            validator: Validators.validateImageName, // Reuse image name validation
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedDriver,
            decoration: InputDecoration(
              labelText: 'Driver',
              prefixIcon: const Icon(Icons.settings),
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
