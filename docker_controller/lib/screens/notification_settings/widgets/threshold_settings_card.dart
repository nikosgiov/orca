import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/settings_card_header.dart';

class ThresholdSettingsCard extends StatelessWidget {
  const ThresholdSettingsCard({
    super.key,
    required this.formKey,
    required this.cpuController,
    required this.memoryController,
    required this.gpuLoadController,
    required this.gpuMemoryController,
    required this.onUpdate,
    required this.percentValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cpuController;
  final TextEditingController memoryController;
  final TextEditingController gpuLoadController;
  final TextEditingController gpuMemoryController;
  final VoidCallback onUpdate;
  final String? Function(String?) percentValidator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            title: 'Resource Thresholds',
            icon: Icons.tune,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          Form(
            key: formKey,
            child: Column(
              children: [
                _DarkInputField(
                  controller: cpuController,
                  label: 'CPU Threshold (%)',
                  validator: percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: memoryController,
                  label: 'Memory Threshold (%)',
                  validator: percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: gpuLoadController,
                  label: 'GPU Load Threshold (%)',
                  validator: percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: gpuMemoryController,
                  label: 'GPU Memory Threshold (%)',
                  validator: percentValidator,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: onUpdate,
                    label: 'Update Thresholds',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkInputField extends StatelessWidget {
  const _DarkInputField({
    required this.controller,
    required this.label,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.glassOverlay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
