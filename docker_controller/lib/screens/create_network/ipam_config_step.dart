import 'package:docker_controller/providers/create_network_provider.dart';
import 'package:flutter/material.dart';

class IpamConfigStep extends StatelessWidget {
  const IpamConfigStep({super.key, required this.provider});
  final CreateNetworkProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.subnetController,
            decoration: const InputDecoration(
              labelText: 'Subnet (optional)',
              hintText: '172.20.0.0/16',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(Icons.network_check),
            ),
            onChanged: provider.setSubnet,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.gatewayController,
            decoration: const InputDecoration(
              labelText: 'Gateway (optional)',
              hintText: '172.20.0.1',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(Icons.router),
            ),
            onChanged: provider.setGateway,
          ),
        ],
      ),
    );
  }
}
