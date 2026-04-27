import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/create_volume_provider.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key, required this.provider});
  final CreateVolumeProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewCard('Name', provider.nameController.text, Icons.folder),
          _buildReviewCard('Driver', provider.selectedDriver, Icons.settings),
          if (provider.driverOptions.isNotEmpty)
            _buildReviewCard(
              'Driver Options',
              provider.driverOptions
                  .map((o) => '${o['key']}=${o['value']}')
                  .join(', '),
              Icons.settings,
            ),
          if (provider.labels.isNotEmpty)
            _buildReviewCard(
              'Labels',
              provider.labels
                  .map((l) => '${l['key']}=${l['value']}')
                  .join(', '),
              Icons.label,
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
