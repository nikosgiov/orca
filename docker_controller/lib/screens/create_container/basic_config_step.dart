import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/providers/create_container_provider.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.containerNameLabel,
              hintText: AppLocalizations.of(context)!.containerNameHint,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.label),
            ),
            onChanged: provider.setContainerName,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.interactive),
                  subtitle: Text(
                    AppLocalizations.of(context)!.keepStdinOpen,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  value: provider.interactive,
                  activeColor: AppColors.secondary,
                  onChanged: (value) => provider.setInteractive(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.tty),
                  subtitle: Text(
                    AppLocalizations.of(context)!.allocatePseudoTty,
                    style: const TextStyle(color: AppColors.textMuted),
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
            title: Text(AppLocalizations.of(context)!.autoRemoveLabel),
            subtitle: Text(
              AppLocalizations.of(context)!.removeOnExit,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            value: provider.autoRemove,
            activeColor: AppColors.secondary,
            onChanged: (value) => provider.setAutoRemove(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text(AppLocalizations.of(context)!.startAfterCreateLabel),
            subtitle: Text(
              AppLocalizations.of(context)!.startAfterCreateSubtitle,
              style: const TextStyle(color: AppColors.textMuted),
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
