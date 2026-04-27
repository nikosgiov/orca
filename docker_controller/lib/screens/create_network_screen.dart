import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/create_network_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:docker_controller/widgets/step_navigation_buttons.dart';
import 'package:docker_controller/widgets/step_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'create_network/advanced_options_step.dart';
import 'create_network/basic_info_step.dart';
import 'create_network/ipam_config_step.dart';
import 'create_network/network_review_step.dart';

class CreateNetworkScreen extends StatelessWidget {
  const CreateNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ChangeNotifierProvider(
          create: (_) => CreateNetworkProvider(authProvider),
          child: const _CreateNetworkScreenBody(),
        );
      },
    );
  }
}

class _CreateNetworkScreenBody extends StatelessWidget {
  const _CreateNetworkScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateNetworkProvider>(context);
    return AppBackground(
      position: const Offset(40, -100),
      scale: 1.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: AppLocalizations.of(context)!.createNetworkTitle,
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
                  AppLocalizations.of(context)!.ipamConfig,
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
                          totalSteps: 4,
                          onPrevious: provider.previousStep,
                          onNextOrCreate:
                              provider.currentStep == 3
                              ? () async {
                                  final (success, result) = await provider
                                      .createNetwork();
                                  if (success) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)!.networkCreatedSuccessfully(result ?? ''),
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
                                  } else if (result != null) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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

  Widget _buildCurrentStep(CreateNetworkProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return BasicInfoStep(provider: provider);
      case 1:
        return IpamConfigStep(provider: provider);
      case 2:
        return AdvancedOptionsStep(provider: provider);
      case 3:
        return NetworkReviewStep(provider: provider);
      default:
        return const SizedBox();
    }
  }
}
