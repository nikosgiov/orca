import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/create_container_provider.dart';

class BasicConfigStep extends StatelessWidget {
  const BasicConfigStep({super.key, required this.provider});
  final CreateContainerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.nameController,
            decoration: const InputDecoration(
              labelText: 'Container Name',
              hintText: 'my-container',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(Icons.label),
            ),
            onChanged: provider.setContainerName,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Interactive'),
                  subtitle: const Text(
                    'Keep STDIN open',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  value: provider.interactive,
                  activeColor: AppColors.secondary,
                  onChanged: (value) => provider.setInteractive(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('TTY'),
                  subtitle: const Text(
                    'Allocate pseudo-TTY',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  value: provider.tty,
                  activeColor: AppColors.secondary,
                  onChanged: (value) => provider.setTty(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Text('Auto Remove'),
            subtitle: const Text(
              'Remove container when it exits',
              style: TextStyle(color: AppColors.textMuted),
            ),
            value: provider.autoRemove,
            activeColor: AppColors.secondary,
            onChanged: (value) => provider.setAutoRemove(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Start After Create'),
            subtitle: const Text(
              'Automatically start the container after creation',
              style: TextStyle(color: AppColors.textMuted),
            ),
            value: provider.startAfterCreate,
            activeColor: AppColors.secondary,
            onChanged: (value) => provider.setStartAfterCreate(value ?? true),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
