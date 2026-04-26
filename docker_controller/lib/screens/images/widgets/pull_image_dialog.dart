import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/images_provider.dart';
import '../../../utils/validators.dart';

class PullImageDialog {
  static void show(BuildContext context, ImagesProvider imagesProvider) {
    final nameController = TextEditingController();
    final tagController = TextEditingController(text: 'latest');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pull Image'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Image Name',
                  hintText: 'e.g., nginx, postgres, redis',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: Validators.validateImageName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  hintText: 'e.g., latest, 13, alpine',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateTag,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Pull'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pulling $name:$tag... This may take a while.'),
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
          content: Text('Successfully pulled $result'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Failed to pull image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
