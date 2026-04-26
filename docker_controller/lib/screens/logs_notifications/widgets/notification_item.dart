import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/app_notification.dart';
import '../../../models/notification_type.dart';
import '../../../providers/logs_notifications_provider.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.provider,
  });

  final AppNotification notification;
  final LogsNotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case NotificationType.success:
        typeColor = AppColors.success;
        typeIcon = Icons.check_circle;
        break;
      case NotificationType.warning:
        typeColor = AppColors.warning;
        typeIcon = Icons.warning;
        break;
      case NotificationType.error:
        typeColor = AppColors.error;
        typeIcon = Icons.error;
        break;
      case NotificationType.info:
        typeColor = AppColors.primary;
        typeIcon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.read
            ? AppColors.glassBg
            : typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.read
              ? AppColors.glassBorder
              : typeColor.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(typeIcon, color: typeColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.read
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timestamp,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A0B3B),
              onSelected: (action) {
                if (action == 'mark_read') {
                  provider.markNotificationAsRead(notification);
                } else if (action == 'delete') {
                  _deleteNotification(context, provider, notification);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      const Icon(Icons.done, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        notification.read ? 'Mark Unread' : 'Mark Read',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNotification(
    BuildContext context,
    LogsNotificationsProvider provider,
    AppNotification notification,
  ) {
    provider.deleteNotification(notification);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
