import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_paddings.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_text_styles.dart';
import '../../../providers/logs_notifications_provider.dart';
import '../../../widgets/app_button.dart';
import 'notification_item.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key, required this.provider});
  final LogsNotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final notifications = provider.notifications;
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: AppPaddings.card,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              const Text(
                AppStrings.notificationsTab,
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              AppButton(
                label: AppStrings.markAllRead,
                onPressed: () => _markAllAsRead(context, provider),
                color: AppColors.primary,
                textColor: AppColors.white,
                outlined: false,
                padding: AppPaddings.headerButtonPadding,
              ),
            ],
          ),
        ),
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationItem(
                notification: notification,
                provider: provider,
              );
            },
          ),
        ),
      ],
    );
  }

  void _markAllAsRead(
    BuildContext context,
    LogsNotificationsProvider provider,
  ) {
    provider.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
