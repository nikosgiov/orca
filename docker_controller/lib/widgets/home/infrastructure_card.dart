import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import 'home_widgets.dart';

class InfrastructureCard extends StatelessWidget {
  const InfrastructureCard({
    super.key,
    required this.volCount,
    required this.netCount,
  });
  final int volCount;
  final int netCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'Infrastructure'),
          const SizedBox(height: 12),
          InfraListItem(
            icon: Icons.storage,
            label: 'Volumes',
            badge: volCount == 0 ? '--' : '$volCount Active',
            iconColor: const Color(0xFF60A5FA),
            onTap: () => context.pushNamed('volumes'),
          ),
          const SizedBox(height: 8),
          InfraListItem(
            icon: Icons.account_tree_outlined,
            label: 'Networks',
            badge: netCount == 0 ? '--' : '$netCount Managed',
            iconColor: const Color(0xFF60A5FA),
            onTap: () => context.pushNamed('networks'),
          ),
        ],
      ),
    );
  }
}
