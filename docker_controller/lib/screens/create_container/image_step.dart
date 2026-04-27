import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/providers/create_container_provider.dart';
import 'package:docker_controller/utils/validators.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ImageStep extends StatelessWidget {
  const ImageStep({super.key, required this.provider});
  final CreateContainerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (provider.error != null)
            Container(
              width: double.infinity,
              padding: AppPaddings.errorMessageMargin,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!.message,
                      style: const TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.loadImages,
                    icon: const Icon(Icons.refresh, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
          DropdownButtonFormField<String>(
            initialValue: provider.isManualEdit
                ? null
                : (provider.selectedImage.isNotEmpty
                      ? provider.selectedImage
                      : null),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.selectImage,
              prefixIcon: const Icon(Icons.image),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(AppLocalizations.of(context)!.customImage),
              ),
              ...provider.availableImages.map((image) {
                return DropdownMenuItem(
                  value: image,
                  child: Text(
                    image,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }),
            ],
            onChanged: provider.isLoadingImages
                ? null
                : provider.setSelectedImage,
          ),
          if (provider.isLoadingImages)
            Padding(
              padding: AppPaddings.loadingImagesPadding,
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.loadingImages),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: provider.imageController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.imageName,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(Icons.image),
                  ),
                  onChanged: provider.setImageName,
                  validator: (val) => Validators.validateImageName(
                    val,
                    requiredError: AppLocalizations.of(context)!.imageNameRequired,
                    invalidError: AppLocalizations.of(context)!.imageNameInvalid,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: provider.tagController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tagLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: provider.setImageTag,
                  validator: (val) => Validators.validateTag(
                    val,
                    requiredError: AppLocalizations.of(context)!.tagRequired,
                    invalidError: AppLocalizations.of(context)!.tagInvalid,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
