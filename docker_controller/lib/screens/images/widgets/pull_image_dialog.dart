import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/images_provider.dart';
import '../../../utils/validators.dart';

class PullImageDialog {
  static void show(BuildContext context, ImagesProvider imagesProvider) {
    final nameController = TextEditingController();
    final tagController = TextEditingController(text: 'latest');
    final formKey = GlobalKey<FormState>();

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pullImage),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.imageName,
                  hintText: 'e.g., nginx, postgres, redis',
                  border: const OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (val) => Validators.validateImageName(
                  val,
                  requiredError: l10n.imageNameRequired,
                  invalidError: l10n.imageNameInvalid,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagController,
                decoration: InputDecoration(
                  labelText: l10n.tagLabel,
                  hintText: 'e.g., latest, 13, alpine',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => Validators.validateTag(
                  val,
                  requiredError: l10n.tagRequired,
                  invalidError: l10n.tagInvalid,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                _pullImage(
                  context,
                  imagesProvider,
                  nameController.text,
                  tagController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
            ),
            child: Text(l10n.pull),
          ),
        ],
      ),
    );
  }

  static Future<void> _pullImage(
    BuildContext context,
    ImagesProvider provider,
    String name,
    String tag,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pullingImage(name, tag)),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
    final (success, result) = await provider.pullImage(name, tag);
    if (!context.mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pullSuccess(result ?? name)),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? l10n.pullFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
