import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_paddings.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/docker_image.dart';
import '../../../providers/images_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/info_row.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({super.key, required this.image});
  final DockerImage image;

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    final imageName = image.displayName;
    final imageId = image.id;
    final displayId = imageId.length >= 12 ? imageId.substring(0, 12) : imageId;

    return AppCard(
      margin: AppPaddings.imageCardMargin,
      padding: AppPaddings.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppPaddings.imageIconPadding,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(imageName, style: AppTextStyles.heading2),
                    Text(displayId, style: AppTextStyles.caption),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleImageAction(context, imagesProvider, value, image),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'run',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(AppStrings.actionRunContainer),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'inspect',
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Text(AppStrings.actionInspect),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(AppStrings.actionRemove),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: AppColors.slate400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: AppStrings.labelSize,
            value: image.displaySize,
            icon: Icons.storage,
          ),
          InfoRow(
            label: AppStrings.labelCreated,
            value: image.displayCreated,
            icon: Icons.schedule,
          ),
          InfoRow(
            label: AppStrings.labelDigest,
            value: image.displayDigest,
            icon: Icons.fingerprint,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassPillBtn(
                  label: AppStrings.actionRunContainer,
                  color: AppColors.primary,
                  onPressed: () => _runContainer(context, image),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassPillBtn(
                  label: AppStrings.actionRemove,
                  color: AppColors.error,
                  onPressed: () => _removeImage(context, imagesProvider, image),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleImageAction(
    BuildContext context,
    ImagesProvider imagesProvider,
    String action,
    DockerImage image,
  ) {
    switch (action) {
      case 'run':
        _runContainer(context, image);
        break;
      case 'inspect':
        _inspectImage(context, image);
        break;
      case 'remove':
        _removeImage(context, imagesProvider, image);
        break;
    }
  }

  Future<void> _removeImage(
    BuildContext context,
    ImagesProvider provider,
    DockerImage image,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Image'),
        content: Text('Are you sure you want to remove ${image.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final (success, result) = await provider.removeImage(image);
    if (!context.mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully removed $result'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Failed to remove image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _runContainer(BuildContext context, DockerImage image) {
    context.pushNamed(
      'createContainer',
      queryParameters: {'image': image.displayName},
    );
  }

  void _inspectImage(BuildContext context, DockerImage image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.actionInspect),
          content: SizedBox(
            width: 400,
            child: ListView(
              shrinkWrap: true,
              children: [
                InfoRow(
                  label: AppStrings.labelId,
                  value: image.id,
                  icon: Icons.fingerprint,
                ),
                InfoRow(
                  label: AppStrings.labelRepoTags,
                  value: image.repoTags.join(', '),
                  icon: Icons.tag,
                ),
                InfoRow(
                  label: AppStrings.labelRepoDigests,
                  value: image.repoDigests.join(', '),
                  icon: Icons.fingerprint,
                ),
                InfoRow(
                  label: AppStrings.labelSize,
                  value: image.displaySize,
                  icon: Icons.storage,
                ),
                InfoRow(
                  label: AppStrings.labelCreated,
                  value: image.displayCreated,
                  icon: Icons.schedule,
                ),
                if (image.labels.isNotEmpty)
                  InfoRow(
                    label: AppStrings.labelLabels,
                    value: image.labels.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    icon: Icons.label,
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text(AppStrings.copiedRawJson),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () {
                    final jsonStr = image.toJson().toString();
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.copiedRawJson)),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.close),
            ),
          ],
        );
      },
    );
  }
}

class _GlassPillBtn extends StatelessWidget {
  const _GlassPillBtn({
    required this.label,
    required this.color,
    this.onPressed,
  });
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
      ),
    );
  }
}
