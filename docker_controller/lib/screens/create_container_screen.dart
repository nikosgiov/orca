import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/create_container_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:docker_controller/widgets/step_navigation_buttons.dart';
import 'package:docker_controller/widgets/step_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'create_container/advanced_config_step.dart';
import 'create_container/basic_config_step.dart';
import 'create_container/image_step.dart';
import 'create_container/review_step.dart';

class CreateContainerScreen extends StatelessWidget {
  const CreateContainerScreen({super.key, this.preSelectedImage});
  final String? preSelectedImage;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ChangeNotifierProvider(
          create: (_) => CreateContainerProvider(
            authProvider,
            preSelectedImage: preSelectedImage,
          ),
          child: const _CreateContainerScreenBody(),
        );
      },
    );
  }
}

class _CreateContainerScreenBody extends StatelessWidget {
  const _CreateContainerScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateContainerProvider>(context);
    return AppBackground(
      position: const Offset(80, 100),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: AppLocalizations.of(context)!.createContainerTitle,
          leftWidget: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: Column(
          children: [
            // Horizontal Progress Bar
            Padding(
              padding: AppPaddings.card,
              child: StepProgressBar(
                stepTitles: [
                  AppLocalizations.of(context)!.selectImage,
                  AppLocalizations.of(context)!.basicConfig,
                  AppLocalizations.of(context)!.advancedConfig,
                  AppLocalizations.of(context)!.reviewCreate,
                ],
                currentStep: provider.currentStep,
                width: 320,
                backgroundColor: AppColors.slate400,
                fillColor: AppColors.primary,
                titleStyle: AppTextStyles.heading2,
              ),
            ),
            // Form Content
            Expanded(
              child: Form(
                key: provider.formKey,
                child: Padding(
                  padding: AppPaddings.screen,
                  child: Column(
                    children: [
                      Expanded(child: _buildCurrentStep(provider)),
                      const SizedBox(height: 24),
                      SafeArea(
                        bottom: true,
                        child: StepNavigationButtons(
                          currentStep: provider.currentStep,
                          totalSteps: 4,
                          onPrevious: provider.previousStep,
                          onNextOrCreate:
                              provider.currentStep == 3
                              ? () async {
                                  final containerId = await provider
                                      .createContainer(context);
                                  if (containerId != null) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.startAfterCreate
                                              ? AppLocalizations.of(context)!.containerStartedSuccessfully(containerId.substring(0, 12))
                                              : AppLocalizations.of(context)!.containerCreatedSuccessfully(containerId.substring(0, 12)),
                                        ),
                                        backgroundColor: const Color(0xFF10B981),
                                      ),
                                    );
                                    context.pop();
                                  }
                                }
                              : () {
                                  if (provider.formKey.currentState
                                          ?.validate() ??
                                      false) {
                                    provider.nextStep();
                                  }
                                },
                          isCreating: provider.isCreating,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(CreateContainerProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return ImageStep(provider: provider);
      case 1:
        return BasicConfigStep(provider: provider);
      case 2:
        return AdvancedConfigStep(provider: provider);
      case 3:
        return ReviewStep(provider: provider);
      default:
        return const SizedBox();
    }
  }
}
