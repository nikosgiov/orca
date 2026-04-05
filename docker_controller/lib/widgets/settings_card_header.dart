import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Section header for settings cards with gradient icon and label.
class SettingsCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;

  const SettingsCardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title.toUpperCase(), style: AppTextStyles.sectionLabel),
      ],
    );
  }
}