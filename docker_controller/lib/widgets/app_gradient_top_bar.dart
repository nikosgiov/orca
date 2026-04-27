import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/logs_notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


/// Transparent, backdrop-blurred app bar matching code.html sticky header.
class AppGradientTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppGradientTopBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.leftWidget,
    this.rightWidget,
    this.height = 64,
    this.padding,
  });
  final String title;
  final Widget? titleWidget;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final double height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      // transparent – background gradient is on the Scaffold body/wrapper
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                // Left: icon or back button
                leftWidget ??
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                // Title
                Expanded(
                  child:
                      titleWidget ??
                      Text(
                        title,
                        style: AppTextStyles.topBarTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                // Right actions
                rightWidget ?? const Row(children: [_NotificationBtn()]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 24); // +inset
}

class _NotificationBtn extends StatelessWidget {
  const _NotificationBtn();

  @override
  Widget build(BuildContext context) {
    bool hasUnread = false;
    try {
      hasUnread = context
          .watch<LogsNotificationsProvider>()
          .hasUnreadNotifications;
    } catch (_) {
      // Provider not found on this branch
    }

    final String location = GoRouterState.of(context).matchedLocation;
    final bool isOnNotifications = location == '/logs-notifications';

    if (isOnNotifications) {
      return const SizedBox(width: 36); // Keep spacing but hide icon
    }

    return GestureDetector(
      onTap: () => context.pushNamed('logsNotifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
