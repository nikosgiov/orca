import 'package:flutter/material.dart';
import 'info_card.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return InfoCard(title: title, children: children);
  }
}
