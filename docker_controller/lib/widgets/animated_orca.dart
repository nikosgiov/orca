import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedOrca extends StatefulWidget {
  const AnimatedOrca({super.key, required this.page});
  final double page;

  @override
  State<AnimatedOrca> createState() => _AnimatedOrcaState();
}

class _AnimatedOrcaState extends State<AnimatedOrca>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _orcaAnimation;
  final List<Animation<double>> _squareAnimations = [];

  // Origins from SVG transforms
  final List<Alignment> _squareOrigins = [
    const Alignment(-0.0985, 0.5059), // sq1
    const Alignment(0.1105, 0.5048), // sq2
    const Alignment(0.3192, 0.5060), // sq3
    const Alignment(0.3191, 0.3277), // sq4
    const Alignment(0.5303, 0.5063), // sq5
    const Alignment(0.5302, 0.3281), // sq6
    const Alignment(0.5301, 0.1543), // sq7
    const Alignment(0.7396, 0.5060), // sq8
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Curves
    const emergeCurve = Cubic(0.2, 0.8, 0.3, 1.0);
    const revealCurve = Cubic(0.2, 0.8, 0.2, 1.0);

    // Orca Animation (delay 400ms is 0.125 position of 3200ms)
    _orcaAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(400 / 3200, 1.0, curve: emergeCurve),
    );

    // Square Animations
    final delays = [800, 1000, 1200, 1400, 1600, 1800, 2000, 2200];
    for (int i = 0; i < delays.length; i++) {
      final double start = delays[i] / 3200.0;
      double end = (delays[i] + 800) / 3200.0;
      // Clamp end just in case
      if (end > 1.0) {
        end = 1.0;
      }
      _squareAnimations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: revealCurve),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedOrca oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page == 0.0 && oldWidget.page != 0.0) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double scale = width / 1024.0;

        return SizedBox(
          width: width,
          height: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Squares
              for (int i = 0; i < 8; i++)
                AnimatedBuilder(
                  animation: _squareAnimations[i],
                  builder: (context, child) {
                    final t = _squareAnimations[i].value;
                    final scaleVal = 0.6 + (0.4 * t); // Scale from 0.6 to 1.0
                    return Opacity(
                      opacity: t,
                      child: Transform(
                        alignment: _squareOrigins[i],
                        transform: Matrix4.diagonal3Values(
                          scaleVal,
                          scaleVal,
                          1.0,
                        ),
                        child: SvgPicture.asset(
                          'assets/images/onboarding/sq${i + 1}.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

              // Orca
              ClipRect(
                clipper: WaterlineClipper(scale),
                child: AnimatedBuilder(
                  animation: _orcaAnimation,
                  builder: (context, child) {
                    final t = _orcaAnimation.value;

                    // TranslateY: 800 -> 0
                    final double translateY = 800.0 * (1.0 - t) * scale;
                    // Rotate: -180deg -> 0deg (-pi to 0)
                    final double rotate = -math.pi * (1.0 - t);

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.translationValues(0.0, translateY, 0.0)
                        ..rotateZ(rotate),
                      child: child,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/onboarding/orca_only.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaterlineClipper extends CustomClipper<Rect> {
  WaterlineClipper(this.scale);
  final double scale;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, 870.0 * scale);
  }

  @override
  bool shouldReclip(covariant WaterlineClipper oldClipper) {
    return oldClipper.scale != scale;
  }
}
