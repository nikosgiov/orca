import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_dimensions.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Prev / Next (or Create) navigation button pair for multi-step wizards.
class StepNavigationButtons extends StatelessWidget {
  const StepNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onPrevious,
    required this.onNextOrCreate,
    this.isCreating = false,
  });
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback onNextOrCreate;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.inputBorderRadius);
    return Row(
      children: [
        if (currentStep > 0) ...[
          Expanded(
            child: Container(
              height: AppDimensions.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.white),
              ),
              child: TextButton(
                onPressed: isCreating ? null : onPrevious,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: Text(AppLocalizations.of(context)!.previous),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Container(
            height: AppDimensions.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: AppGradients.primaryHorizontal,
            ),
            child: TextButton(
              onPressed: isCreating ? null : onNextOrCreate,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: radius),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: AppDimensions.buttonSpinnerSize,
                      height: AppDimensions.buttonSpinnerSize,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: AppDimensions.buttonSpinnerStrokeWidth,
                      ),
                    )
                  : Text(
                      currentStep == totalSteps - 1
                          ? AppLocalizations.of(context)!.create
                          : AppLocalizations.of(context)!.next,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
