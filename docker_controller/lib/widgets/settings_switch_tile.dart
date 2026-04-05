import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}