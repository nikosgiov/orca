import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../models/app_state.dart';
import '../../providers/images_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_gradient_top_bar.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_search_bar.dart';
import 'widgets/image_card.dart';
import 'widgets/pull_image_dialog.dart';

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
        final imagesProvider = Provider.of<ImagesProvider>(
          context,
          listen: false,
        );
        if (imagesProvider.state is AppInitial) {
          imagesProvider.fetchImages();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context);

    return AppBackground(
      position: const Offset(-80, 150),
      scale: 1.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppGradientTopBar(title: AppStrings.imagesTitle),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: AppSearchBar(
                value: imagesProvider.searchQuery,
                onChanged: (value) => imagesProvider.searchQuery = value,
                hintText: AppStrings.searchImagesHint,
              ),
            ),
            Expanded(
              child: switch (imagesProvider.state) {
                AppInitial() => const SizedBox.shrink(),
                AppLoading() => const AppLoadingIndicator(
                  message: 'Loading images...',
                ),
                AppSuccess(:final data) =>
                  data.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.image_not_supported_outlined,
                          title: AppStrings.noImagesFound,
                          message: AppStrings.pullFirstImage,
                        )
                      : RefreshIndicator(
                          onRefresh: imagesProvider.refreshImages,
                          color: AppColors.primary,
                          backgroundColor: const Color(0xFF1A0B3B),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                            itemCount: imagesProvider.filteredImages.length,
                            itemBuilder: (context, index) {
                              return ImageCard(
                                image: imagesProvider.filteredImages[index],
                              );
                            },
                          ),
                        ),
                AppError(:final message) => AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error',
                  message: message,
                ),
              },
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 140),
          child: FloatingActionButton(
            heroTag: null,
            onPressed: () => PullImageDialog.show(context, imagesProvider),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.download, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
