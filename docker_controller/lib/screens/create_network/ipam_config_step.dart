import 'package:flutter/material.dart';
import '../../providers/create_network_provider.dart';

class IpamConfigStep extends StatelessWidget {
  final CreateNetworkProvider provider;

  const IpamConfigStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.subnetController,
            decoration: InputDecoration(
              labelText: 'Subnet (optional)',
              hintText: '172.20.0.0/16',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.network_check),
            ),
            onChanged: provider.setSubnet,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.gatewayController,
            decoration: InputDecoration(
              labelText: 'Gateway (optional)',
              hintText: '172.20.0.1',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.router),
            ),
            onChanged: provider.setGateway,
          ),
        ],
      ),
    );
  }
}
