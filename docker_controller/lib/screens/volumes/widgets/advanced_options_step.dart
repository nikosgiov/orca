import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/create_volume_provider.dart';
import '../../../utils/validators.dart';

class AdvancedOptionsStep extends StatelessWidget {
  const AdvancedOptionsStep({super.key, required this.provider});
  final CreateVolumeProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      const Icon(
                        Icons.settings,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.driverOptions,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addDriverOption,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.secondary,
                        ),
                        tooltip: l10n.addOption,
                      ),
                    ],
                  ),
                ),
                if (provider.driverOptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noOptionsAdded,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ...provider.driverOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: l10n.keyLabel),
                            onChanged: (value) => provider.updateDriverOption(
                              index,
                              value,
                              option['value'] ?? '',
                            ),
                            validator: (val) => Validators.validateDriverOptionKey(
                              val,
                              requiredError: l10n.driverOptionKeyRequired,
                              invalidError: l10n.driverOptionKeyInvalid,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.valueLabel,
                            ),
                            onChanged: (value) => provider.updateDriverOption(
                              index,
                              option['key'] ?? '',
                              value,
                            ),
                            validator: (val) => Validators.validateDriverOptionValue(
                              val,
                              requiredError: l10n.driverOptionValueRequired,
                              noTabsError: l10n.driverOptionValueNoTabs,
                              tooLongError: l10n.driverOptionValueTooLong,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.removeDriverOption(index),
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
                      const Icon(Icons.label, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.labels,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addLabel,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.secondary,
                        ),
                        tooltip: l10n.addLabel,
                      ),
                    ],
                  ),
                ),
                if (provider.labels.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noLabelsAdded,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ...provider.labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: l10n.keyLabel),
                            onChanged: (value) => provider.updateLabel(
                              index,
                              value,
                              label['value'] ?? '',
                            ),
                            validator: (val) => Validators.validateLabelKey(
                              val,
                              requiredError: l10n.labelKeyRequired,
                              invalidError: l10n.labelKeyInvalid,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.valueLabel,
                            ),
                            onChanged: (value) => provider.updateLabel(
                              index,
                              label['key'] ?? '',
                              value,
                            ),
                            validator: (val) => Validators.validateLabelValue(
                              val,
                              requiredError: l10n.labelValueRequired,
                              noTabsError: l10n.labelValueNoTabs,
                              tooLongError: l10n.labelValueTooLong,
                            ),
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
