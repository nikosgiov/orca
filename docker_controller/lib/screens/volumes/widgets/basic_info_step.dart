import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/create_volume_provider.dart';
import '../../../utils/validators.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key, required this.provider});
  final CreateVolumeProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.volumeName,
              hintText: 'my-volume',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.folder),
            ),
            onChanged: provider.setVolumeName,
            validator: (val) => Validators.validateImageName(
              val,
              requiredError: AppLocalizations.of(context)!.volumeNameRequired,
              invalidError: AppLocalizations.of(context)!.volumeNameInvalid,
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
              DropdownMenuItem(value: 'local', child: Text(AppLocalizations.of(context)!.driverLocal)),
              DropdownMenuItem(value: 'nfs', child: Text(AppLocalizations.of(context)!.driverNfs)),
              DropdownMenuItem(value: 'cifs', child: Text(AppLocalizations.of(context)!.driverCifs)),
              DropdownMenuItem(value: 'tmpfs', child: Text(AppLocalizations.of(context)!.driverTmpfs)),
            ],
            onChanged: provider.setDriver,
          ),
        ],
      ),
    );
  }
}
