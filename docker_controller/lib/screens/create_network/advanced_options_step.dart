import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/create_network_provider.dart';
import '../../utils/validators.dart';

class AdvancedOptionsStep extends StatelessWidget {
  final CreateNetworkProvider provider;

  const AdvancedOptionsStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Driver Options Section
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: AppColors.secondaryBlue),
                      const SizedBox(width: 8),
                      const Text('Driver Options', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addOption,
                        icon: const Icon(Icons.add, color: AppColors.secondaryBlue),
                        tooltip: 'Add option',
                      ),
                    ],
                  ),
                ),
                if (provider.options.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No options added', style: TextStyle(color: Colors.grey)),
                  ),
                ...provider.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Key',
                            ),
                            onChanged: (value) => provider.updateOption(index, value, option['value'] ?? ''),
                            validator: Validators.validateDriverOptionKey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Value',
                            ),
                            onChanged: (value) => provider.updateOption(index, option['key'] ?? '', value),
                            validator: Validators.validateDriverOptionValue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.removeOption(index),
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Labels Section
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.label, color: AppColors.secondaryBlue),
                      const SizedBox(width: 8),
                      const Text('Labels', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addLabel,
                        icon: const Icon(Icons.add, color: AppColors.secondaryBlue),
                        tooltip: 'Add label',
                      ),
                    ],
                  ),
                ),
                if (provider.labels.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No labels added', style: TextStyle(color: Colors.grey)),
                  ),
                ...provider.labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Key',
                            ),
                            onChanged: (value) => provider.updateLabel(index, value, label['value'] ?? ''),
                            validator: Validators.validateLabelKey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Value',
                            ),
                            onChanged: (value) => provider.updateLabel(index, label['key'] ?? '', value),
                            validator: Validators.validateLabelValue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.removeLabel(index),
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
