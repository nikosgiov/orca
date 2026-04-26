import 'package:flutter/material.dart';
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
            decoration: const InputDecoration(
              labelText: 'Volume Name',
              hintText: 'my-volume',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(Icons.folder),
            ),
            onChanged: provider.setVolumeName,
            validator: Validators.validateImageName, // Reuse image name validation
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedDriver,
            decoration: const InputDecoration(
              labelText: 'Driver',
              prefixIcon: Icon(Icons.settings),
            ),
            items: const [
              DropdownMenuItem(value: 'local', child: Text('Local')),
              DropdownMenuItem(value: 'nfs', child: Text('NFS')),
              DropdownMenuItem(value: 'cifs', child: Text('CIFS')),
              DropdownMenuItem(value: 'tmpfs', child: Text('Tmpfs')),
            ],
            onChanged: provider.setDriver,
          ),
        ],
      ),
    );
  }
}
