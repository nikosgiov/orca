import 'package:flutter/material.dart';
import 'info_card.dart';

class AppInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AppInfoCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      children: children,
    );
  }
} 