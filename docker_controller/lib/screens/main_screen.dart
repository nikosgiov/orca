import 'dart:ui' as ui;

import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// The main layout shell of the application, including the floating navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.child,
  });
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppGradientTopBar(
          title: _getTitle(context),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        ),
        bottomNavigationBar: _FloatingNavBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTabChanged,
        ),
      ),
    );
  }

  String _getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.currentIndex) {
      case 0:
        return l10n.dashboardTitle;
      case 1:
        return l10n.containersTitle;
      case 2:
        return l10n.imagesTitle;
      case 3:
        return l10n.resourceMonitoringTitle;
      case 4:
        return l10n.composeTitle;
      case 5:
        return l10n.settingsTitle;
      default:
        return '';
    }
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(Icons.grid_view_rounded, AppLocalizations.of(context)!.navDash),
      _NavItem(Icons.view_in_ar_rounded, AppLocalizations.of(context)!.navContainers),
      _NavItem(Icons.layers_rounded, AppLocalizations.of(context)!.navImages),
      _NavItem(Icons.analytics_rounded, AppLocalizations.of(context)!.navMonitor),
      _NavItem(Icons.account_tree_rounded, AppLocalizations.of(context)!.navCompose),
      _NavItem(Icons.settings_rounded, AppLocalizations.of(context)!.navConfig),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x22FFFFFF),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(navItems.length, (i) {
                  return Expanded(
                    child: _NavItemWidget(
                      item: navItems[i],
                      isActive: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textMuted.withValues(alpha: 0.55),
                ),
                if (isActive)
                  Positioned(
                    bottom: -5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.55),
                letterSpacing: 0.4,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
