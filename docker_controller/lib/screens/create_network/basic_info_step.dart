import 'package:docker_controller/providers/create_network_provider.dart';
import 'package:docker_controller/utils/validators.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.networkName,
              hintText: 'my-network',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.wifi),
            ),
            onChanged: provider.setNetworkName,
            validator: (val) => Validators.validateImageName(
              val,
              requiredError: AppLocalizations.of(context)!.networkNameRequired,
              invalidError: AppLocalizations.of(context)!.networkNameInvalid,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedDriver,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.driverLabel,
              prefixIcon: const Icon(Icons.settings),
            ),
            items: [
              DropdownMenuItem(value: 'bridge', child: Text(AppLocalizations.of(context)!.networkBridge)),
              DropdownMenuItem(value: 'host', child: Text(AppLocalizations.of(context)!.networkHost)),
              DropdownMenuItem(value: 'overlay', child: Text(AppLocalizations.of(context)!.networkOverlay)),
              DropdownMenuItem(value: 'macvlan', child: Text(AppLocalizations.of(context)!.networkMacvlan)),
              DropdownMenuItem(value: 'ipvlan', child: Text(AppLocalizations.of(context)!.networkIpvlan)),
            ],
            onChanged: provider.setDriver,
          ),
        ],
      ),
    );
  }
}
