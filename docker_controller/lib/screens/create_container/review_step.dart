import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/providers/create_container_provider.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key, required this.provider});
  final CreateContainerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewCard(AppLocalizations.of(context)!.imageLabel, provider.selectedImage, Icons.image),
          _buildReviewCard(AppLocalizations.of(context)!.nameLabel, provider.containerName, Icons.label),
          _buildReviewCard(AppLocalizations.of(context)!.networkLabel, provider.networkMode, Icons.wifi),
          if (provider.portMappings.isNotEmpty)
            _buildReviewCard(
              AppLocalizations.of(context)!.portsLabel,
              provider.portMappings
                  .map((p) => '${p['host']}:${p['container']}')
                  .join(', '),
              Icons.link,
            ),
          if (provider.volumeMappings.isNotEmpty)
            _buildReviewCard(
              AppLocalizations.of(context)!.volumesLabel,
              provider.volumeMappings
                  .map((v) => '${v['host']}:${v['container']}')
                  .join(', '),
              Icons.folder,
            ),
          if (provider.environmentVars.isNotEmpty)
            _buildReviewCard(
              AppLocalizations.of(context)!.environmentLabel,
              provider.environmentVars
                  .map((e) => '${e['name']}=${e['value']}')
                  .join(', '),
              Icons.settings,
            ),
          _buildReviewCard(
            AppLocalizations.of(context)!.optionsLabel,
            [
              if (provider.interactive) AppLocalizations.of(context)!.interactive,
              if (provider.tty) AppLocalizations.of(context)!.tty,
              if (provider.autoRemove) AppLocalizations.of(context)!.autoRemoveLabel,
              if (provider.startAfterCreate) AppLocalizations.of(context)!.startAfterCreateLabel,
            ].join(', '),
            Icons.settings,
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
