import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/settings_card_header.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.notificationService,
    required this.onRegister,
    required this.onUnregister,
  });

  final NotificationService notificationService;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;

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
            title: 'Notification Status',
            icon: Icons.notifications,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                notificationService.isInitialized
                    ? Icons.check_circle
                    : Icons.error,
                color: notificationService.isInitialized
                    ? AppColors.success
                    : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notificationService.isInitialized
                      ? 'Notifications initialized'
                      : 'Notifications not initialized',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (notificationService.deviceToken != null) ...[
            const SizedBox(height: 8),
            Text(
              'Device Token: ${notificationService.deviceToken!.substring(0, 20)}...',
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: onRegister,
                  label: 'Register',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  onPressed: onUnregister,
                  label: 'Unregister',
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
