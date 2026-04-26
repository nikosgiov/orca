import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'home_widgets.dart';

class ContainerStatusCard extends StatelessWidget {
  const ContainerStatusCard({
    super.key,
    required this.running,
    required this.stopped,
    required this.exited,
  });
  final int running;
  final int stopped;
  final int exited;

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
          const SectionLabel(label: 'Containers Status'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatusOrb(
                count: running,
                label: 'Running',
                color: const Color(0xFF22D3EE),
              ),
              StatusOrb(
                count: stopped,
                label: 'Stopped',
                color: const Color(0xFFFBBF24),
              ),
              StatusOrb(
                count: exited,
                label: 'Exited',
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
