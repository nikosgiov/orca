import 'package:docker_controller/constants/app_gradients.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.position = const Offset(0, 0),
    this.scale = 1,
  });
  final Widget child;
  final Offset position;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned(
            left: -640,
            top: -400,
            width: 2900,
            height: 1800,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.contain,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
