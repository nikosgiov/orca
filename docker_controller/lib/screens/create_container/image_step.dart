import 'package:flutter/material.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../providers/create_container_provider.dart';
import '../../utils/validators.dart';

class ImageStep extends StatelessWidget {
  final CreateContainerProvider provider;

  const ImageStep({super.key, required this.provider});

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
            initialValue: provider.isManualEdit ? null : (provider.selectedImage.isNotEmpty ? provider.selectedImage : null),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.selectImage,
              prefixIcon: const Icon(Icons.image),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(AppStrings.customImage),
              ),
              ...provider.availableImages.map((image) {
                return DropdownMenuItem(
                  value: image,
                  child: Text(image, overflow: TextOverflow.ellipsis, maxLines: 1),
                );
              }),
            ],
            onChanged: provider.isLoadingImages ? null : provider.setSelectedImage,
          ),
          if (provider.isLoadingImages)
            const Padding(
              padding: AppPaddings.loadingImagesPadding,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(AppStrings.loadingImages),
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
                    labelText: AppStrings.imageName,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(Icons.image),
                  ),
                  onChanged: provider.setImageName,
                  validator: Validators.validateImageName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: provider.tagController,
                  decoration: InputDecoration(
                    labelText: 'Tag',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: provider.setImageTag,
                  validator: Validators.validateTag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
