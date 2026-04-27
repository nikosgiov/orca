import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/create_volume_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:docker_controller/widgets/step_navigation_buttons.dart';
import 'package:docker_controller/widgets/step_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import 'widgets/advanced_options_step.dart';
import 'widgets/basic_info_step.dart';
import 'widgets/review_step.dart';

class CreateVolumeScreen extends StatelessWidget {
  const CreateVolumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ChangeNotifierProvider(
          create: (_) => CreateVolumeProvider(authProvider),
          child: const _CreateVolumeScreenBody(),
        );
      },
    );
  }
}

class _CreateVolumeScreenBody extends StatelessWidget {
  const _CreateVolumeScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateVolumeProvider>(context);
    return AppBackground(
      position: const Offset(-80, 100),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: AppLocalizations.of(context)!.createVolumeTitle,
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
                  AppLocalizations.of(context)!.basicInfo,
                  AppLocalizations.of(context)!.advancedOptions,
                  AppLocalizations.of(context)!.review,
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
                          totalSteps: 3,
                          onPrevious: provider.previousStep,
                          onNextOrCreate:
                              provider.currentStep == 2
                                  ? () async {
                                      final volumeName = await provider
                                          .createVolume(context);
                                      if (volumeName != null) {
                                        if (!context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)!.volumeCreatedSuccessfully(volumeName),
                                            ),
                                            backgroundColor: const Color(
                                              0xFF10B981,
                                            ),
                                          ),
                                        );
                                        if (!context.mounted) {
                                          return;
                                        }
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

  Widget _buildCurrentStep(CreateVolumeProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return BasicInfoStep(provider: provider);
      case 1:
        return AdvancedOptionsStep(provider: provider);
      case 2:
        return ReviewStep(provider: provider);
      default:
        return const SizedBox();
    }
  }
}
