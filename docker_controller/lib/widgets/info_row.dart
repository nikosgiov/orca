import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isMultiline = false,
  });
  final String label;
  final String value;
  final IconData? icon;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    if (isMultiline) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                ],
                Text(label.toUpperCase(), style: AppTextStyles.infoLabel),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.infoValue.copyWith(height: 1.4),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 8),
          ],
          Text(label.toUpperCase(), style: AppTextStyles.infoLabel),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.infoValue,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
