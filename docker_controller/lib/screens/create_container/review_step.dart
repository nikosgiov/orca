import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/create_container_provider.dart';

class ReviewStep extends StatelessWidget {
  final CreateContainerProvider provider;

  const ReviewStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewCard('Image', provider.selectedImage, Icons.image),
          _buildReviewCard('Name', provider.containerName, Icons.label),
          _buildReviewCard('Network', provider.networkMode, Icons.wifi),
          if (provider.portMappings.isNotEmpty)
            _buildReviewCard('Ports', provider.portMappings.map((p) => '${p['host']}:${p['container']}').join(', '), Icons.link),
          if (provider.volumeMappings.isNotEmpty)
            _buildReviewCard('Volumes', provider.volumeMappings.map((v) => '${v['host']}:${v['container']}').join(', '), Icons.folder),
          if (provider.environmentVars.isNotEmpty)
            _buildReviewCard('Environment', provider.environmentVars.map((e) => '${e['name']}=${e['value']}').join(', '), Icons.settings),
          _buildReviewCard('Options', [
            if (provider.interactive) 'Interactive',
            if (provider.tty) 'TTY',
            if (provider.autoRemove) 'Auto Remove',
            if (provider.startAfterCreate) 'Start After Create',
          ].join(', '), Icons.settings),
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
          Icon(icon, color: AppColors.secondaryBlue, size: 20),
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
