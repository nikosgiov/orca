
import 'package:flutter/material.dart';

class AppTransitions {
  /// Radial Reveal Page Route – Expands a circular mask from a point.
  static Route radialReveal({num? centerOffset, required Widget page}) {
    // centerOffset could be anything, but we'll use screen center if not provided.
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final offset = centerOffset != null
                ? const Offset(0, 0) // Placeholder
                : Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2,
                  );
            return ClipPath(
              clipper: _CircularRevealClipper(
                fraction: animation.value,
                centerOffset: offset,
              ),
              child: child,
            );
          },
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  /// Focal Zoom Page Route – Smooth zoom & fade effect.
  static Route focalZoom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginScale = 0.85;
        const endScale = 1.0;
        const curve = Curves.easeInOutBack;

        final scaleAnimation = Tween<double>(begin: beginScale, end: endScale)
            .animate(CurvedAnimation(parent: animation, curve: curve));
        final opacityAnimation = CurvedAnimation(parent: animation, curve: Curves.easeIn);

        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset centerOffset;

  _CircularRevealClipper({required this.fraction, required this.centerOffset});

  @override
  Path getClip(Size size) {
    final path = Path();
    final maxRadius = _getMaxRadius(size, centerOffset);
    final radius = maxRadius * fraction;
    path.addOval(Rect.fromCircle(center: centerOffset, radius: radius));
    return path;
  }

  double _getMaxRadius(Size size, Offset center) {
    final w = size.width;
    final h = size.height;
    final d1 = center.distance;
    final d2 = (center - Offset(w, 0)).distance;
    final d3 = (center - Offset(0, h)).distance;
    final d4 = (center - Offset(w, h)).distance;
    return [d1, d2, d3, d4].reduce((a, b) => a > b ? a : b);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

/// A replacement for IndexedStack that animates transitions with a 3D Cube effect.
/// A replacement for IndexedStack that animates transitions with a Fade effect.
class AnimatedFadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedFadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedFadeIndexedStack> createState() => _AnimatedFadeIndexedStackState();
}

class _AnimatedFadeIndexedStackState extends State<AnimatedFadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _prevIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _prevIndex = _currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant AnimatedFadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _currentIndex) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      setState(() {
        _prevIndex = _currentIndex;
        _currentIndex = widget.index;
      });
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        return Stack(
          children: widget.children.asMap().entries.map((entry) {
            final index = entry.key;
            final itemChild = entry.value;

            // Idle state: just show the active one
            // Use _controller.isAnimating check to prevent skipping animation on frame 1
            final isIdle = !_controller.isAnimating && value == 1.0;

            if (isIdle || _prevIndex == _currentIndex) {
              return Visibility(
                visible: index == _currentIndex,
                maintainState: true,
                child: itemChild,
              );
            }

            // Transitioning state
            if (index == _prevIndex) {
              // Fade out old
              return Opacity(
                opacity: (1.0 - value).clamp(0.0, 1.0),
                child: Visibility(
                  visible: true,
                  maintainState: true,
                  child: itemChild,
                ),
              );
            }

            if (index == _currentIndex) {
              // Fade in new
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Visibility(
                  visible: true,
                  maintainState: true,
                  child: itemChild,
                ),
              );
            }

            // Hide other children while preserving state
            return Visibility(
              visible: false,
              maintainState: true,
              child: itemChild,
            );
          }).toList(),
        );
      },
    );
  }
}

