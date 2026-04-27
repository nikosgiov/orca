import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_delays.dart';
import 'package:docker_controller/constants/app_dimensions.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

/// An animated progress bar that shows the current step in a multi-step wizard.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.stepTitles,
    required this.currentStep,
    this.backgroundColor = AppColors.slate400,
    this.fillColor = AppColors.primary,
    this.height = AppDimensions.progressBarHeight,
    this.width = 300,
    this.titleStyle,
    this.progressStyle,
  });
  final List<String> stepTitles;
  final int currentStep;
  final Color backgroundColor;
  final Color fillColor;
  final double height;
  final double width;
  final TextStyle? titleStyle;
  final TextStyle? progressStyle;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / stepTitles.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepTitles[currentStep],
          style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: width,
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: backgroundColor,
                ),
              ),
              AnimatedContainer(
                duration: AppDelays.animationDuration,
                height: height,
                width: width * progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: fillColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${currentStep + 1} of ${stepTitles.length}',
          style: progressStyle ?? AppTextStyles.stepLabel,
        ),
      ],
    );
  }
}
