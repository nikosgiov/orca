import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import 'create_container_screen.dart';
import 'package:flutter/services.dart';
import '../utils/app_transitions.dart';

import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../widgets/app_card.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/app_loading_indicator.dart';
import '../constants/app_strings.dart';
import '../providers/images_provider.dart';
import '../utils/image_format_utils.dart';
import '../utils/validators.dart';

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
        if (imagesProvider.images == null) {
          imagesProvider.fetchImages();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context);
    final filteredImages = imagesProvider.filteredImages;
    final searchQuery = imagesProvider.searchQuery;
    final isLoading = imagesProvider.isLoading;

    return AppBackground(
      position: const Offset(-80, 150),
      scale: 1.6,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppGradientTopBar(
        title: AppStrings.imagesTitle,
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: AppSearchBar(
              value: searchQuery,
              onChanged: (value) {
                imagesProvider.searchQuery = value;
              },
              hintText: AppStrings.searchImagesHint,
            ),
          ),
          // Images List
          Expanded(
            child: isLoading
                ? const AppLoadingIndicator(
                    message: 'Loading images...',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await imagesProvider.refreshImages();
                    },
                    color: AppColors.primary,
                    backgroundColor: const Color(0xFF1A0B3B),
                    child: filteredImages.isEmpty
                        ? const CustomScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: AppEmptyState(
                                    icon: Icons.image_outlined,
                                    title: AppStrings.noImagesFound,
                                    message: AppStrings.pullFirstImage,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                            itemCount: filteredImages.length,
                            itemBuilder: (context, index) {
                              final image = filteredImages[index];
                              return _ImageCard(image: image);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            _showPullImageDialog(context, imagesProvider);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.download, color: AppColors.white),
        ),
      ),
    ),
   );
  }

  void _showPullImageDialog(BuildContext context, ImagesProvider imagesProvider) {
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
                _pullImage(context, imagesProvider, nameController.text, tagController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBlue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Pull'),
          ),
        ],
      ),
    );
  }

  Future<void> _pullImage(BuildContext context, ImagesProvider provider, String name, String tag) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pulling $name:$tag... This may take a while.'),
        backgroundColor: AppColors.secondaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
    final (success, result) = await provider.pullImage(name, tag);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully pulled $result'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Failed to pull image'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}

class _ImageCard extends StatelessWidget {
  final Map<String, dynamic> image;
  const _ImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
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
                    colors: [AppColors.primaryCyan, AppColors.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ImageFormatUtils.getImageDisplayName(image),
                      style: AppTextStyles.heading2,
                    ),
                    Text(
                      image['Id']?.toString().substring(0, 12) ?? AppStrings.statusUnknown,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleImageAction(context, imagesProvider, value, image);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'run',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: AppColors.primaryCyan),
                        const SizedBox(width: 8),
                        Text(AppStrings.actionRunContainer),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'inspect',
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppColors.secondaryBlue),
                        const SizedBox(width: 8),
                        Text(AppStrings.actionInspect),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.errorRed),
                        const SizedBox(width: 8),
                        Text(AppStrings.actionRemove),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(label: AppStrings.labelSize, value: ImageFormatUtils.formatSize(image['Size']), icon: Icons.storage),
          InfoRow(label: AppStrings.labelCreated, value: ImageFormatUtils.formatCreatedDate(image['Created']), icon: Icons.schedule),
          InfoRow(label: AppStrings.labelDigest, value: ImageFormatUtils.getImageDigest(image), icon: Icons.fingerprint),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassPillBtn(
                  label: AppStrings.actionRunContainer,
                  color: AppColors.primary,
                  onPressed: () => _runContainer(context, imagesProvider, image),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassPillBtn(
                  label: AppStrings.actionRemove,
                  color: AppColors.errorRed,
                  onPressed: () => _removeImage(context, imagesProvider, image),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleImageAction(BuildContext context, ImagesProvider imagesProvider, String action, Map<String, dynamic> image) {
    switch (action) {
      case 'run':
        _runContainer(context, imagesProvider, image);
        break;
      case 'inspect':
        _inspectImage(context, image);
        break;
      case 'remove':
        _removeImage(context, imagesProvider, image);
        break;
    }
  }

  Future<void> _removeImage(BuildContext context, ImagesProvider provider, Map<String, dynamic> image) async {
    final imageName = ImageFormatUtils.getImageDisplayName(image);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Image'),
        content: Text('Are you sure you want to remove $imageName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final (success, result) = await provider.removeImage(image);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully removed $result'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Failed to remove image'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _runContainer(BuildContext context, ImagesProvider imagesProvider, Map<String, dynamic> image) {
    final imageName = ImageFormatUtils.getImageDisplayName(image);
    Navigator.push(
      context,
      AppTransitions.focalZoom(
        CreateContainerScreen(
          preSelectedImage: imageName,
        ),
      ),
    );

  }

  void _inspectImage(BuildContext context, Map<String, dynamic> image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.actionInspect),
          content: SizedBox(
            width: 400,
            child: ListView(
              shrinkWrap: true,
              children: [
                InfoRow(label: AppStrings.labelId, value: image['Id']?.toString().substring(0, 20) ?? AppStrings.statusUnknown, icon: Icons.fingerprint),
                InfoRow(label: AppStrings.labelRepoTags, value: (image['RepoTags'] as List?)?.join(', ') ?? 'None', icon: Icons.tag),
                InfoRow(label: AppStrings.labelRepoDigests, value: (image['RepoDigests'] as List?)?.join(', ') ?? 'None', icon: Icons.fingerprint),
                InfoRow(label: AppStrings.labelSize, value: ImageFormatUtils.formatSize(image['Size']), icon: Icons.storage),
                InfoRow(label: AppStrings.labelCreated, value: ImageFormatUtils.formatCreatedDate(image['Created']), icon: Icons.schedule),
                if (image['Labels'] != null && (image['Labels'] as Map).isNotEmpty)
                  InfoRow(label: AppStrings.labelLabels, value: (image['Labels'] as Map).entries.map((e) => '${e.key}: ${e.value}').join('\n'), icon: Icons.label),
                if (image['ParentId'] != null && image['ParentId'] != '')
                  InfoRow(label: AppStrings.labelParentId, value: image['ParentId'].toString(), icon: Icons.link),
                if (image['Comment'] != null && image['Comment'] != '')
                  InfoRow(label: AppStrings.labelComment, value: image['Comment'].toString(), icon: Icons.comment),
                if (image['Os'] != null)
                  InfoRow(label: AppStrings.labelOs, value: image['Os'].toString(), icon: Icons.computer),
                if (image['Architecture'] != null)
                  InfoRow(label: AppStrings.labelArchitecture, value: image['Architecture'].toString(), icon: Icons.architecture),
                if (image['VirtualSize'] != null)
                  InfoRow(label: AppStrings.labelVirtualSize, value: ImageFormatUtils.formatSize(image['VirtualSize']), icon: Icons.storage),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(AppStrings.copiedRawJson),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () {
                    final jsonStr = image.toString();
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.copiedRawJson)),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.close),
            ),
          ],
        );
      },
    );
  }
}

// ── Glass pill button (matches containers screen style) ───────────────────────

class _GlassPillBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _GlassPillBtn({required this.label, required this.color, this.onPressed});

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
