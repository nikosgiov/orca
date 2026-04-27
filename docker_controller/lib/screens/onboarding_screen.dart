import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:docker_controller/providers/app_config_provider.dart';
import 'package:docker_controller/widgets/animated_orca.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;

  List<OnboardingPageData> get _pages {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingPageData(
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
      ),
      OnboardingPageData(
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      OnboardingPageData(
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
      OnboardingPageData(
        title: l10n.onboardingTitle4,
        subtitle: l10n.onboardingSubtitle4,
      ),
      OnboardingPageData(
        title: l10n.onboardingTitle5,
        subtitle: l10n.onboardingSubtitle5,
        description: l10n.onboardingDesc5,
      ),
      OnboardingPageData(
        title: l10n.onboardingTitle6,
        subtitle: l10n.onboardingSubtitle6,
        description: l10n.onboardingDesc6,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPageValue = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildContinuousAnimatedGraphic(),
            SafeArea(
              child: Column(
                children: [
                  _OnboardingTopBar(
                    pageCount: _pages.length,
                    currentIndex: _currentPageValue.round(),
                    onSkip: _skipOnboarding,
                  ),
                  Expanded(
                    child: _OnboardingPageView(
                      controller: _pageController,
                      pages: _pages,
                      currentPageValue: _currentPageValue,
                    ),
                  ),
                  _OnboardingBottomAction(
                    isLastPage: _currentPageValue.round() == _pages.length - 1,
                    onContinue: () {
                      if (_pageController.hasClients &&
                          _currentPageValue < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _skipOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _skipOnboarding() {
    context.read<AppConfigProvider>().setFirstRunComplete();
  }

  Widget _buildAnimatedBackground() {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseImageSize = screenSize.width * 1.8;

    final List<Offset> positions = [
      const Offset(-1050, -100), // Page 0
      const Offset(850, 700), // Page 1
      const Offset(-100, 600), // Page 2
      const Offset(0, 150), // Page 3
      const Offset(0, -800), // Page 4
      const Offset(0, -800), // Page 5
    ];

    final List<double> scales = [
      4, // Page 0
      4, // Page 1
      2.5, // Page 2
      1.5, // Page 3
      3, // Page 4
      3, // Page 5
    ];

    int index = _currentPageValue.floor();
    int nextIndex = (index + 1) < positions.length ? index + 1 : index;
    final double t = _currentPageValue - index;

    if (index >= positions.length) {
      index = positions.length - 1;
    }
    if (nextIndex >= positions.length) {
      nextIndex = positions.length - 1;
    }

    final Offset currentPos =
        Offset.lerp(positions[index], positions[nextIndex], t) ??
        positions[index];
    final double currentScale =
        scales[index] + (scales[nextIndex] - scales[index]) * t;
    final double currentSize = baseImageSize * currentScale;

    final double screenCenterX = screenSize.width / 2;
    final double screenCenterY = screenSize.height / 2;

    return Positioned(
      left: screenCenterX + currentPos.dx - (currentSize / 2),
      top: screenCenterY + currentPos.dy - (currentSize / 2),
      width: currentSize,
      height: currentSize,
      child: Image.asset(
        'assets/images/onboarding/blur_bg.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContinuousAnimatedGraphic() {
    final Size screenSize = MediaQuery.of(context).size;
    final double t = _currentPageValue.clamp(0.0, 1.0);
    final double scale = 1.0 - (0.65 * t);
    const double baseSize = 250.0;
    final double currentSize = baseSize * scale;
    final double centerX = screenSize.width / 2;
    final double centerY = screenSize.height / 2 - 180;
    const double targetLeft = 24.0;
    final double targetTop = MediaQuery.of(context).padding.top + 60.0;
    final double left = (centerX - (baseSize / 2)) * (1.0 - t) + targetLeft * t;
    final double top = (centerY - (baseSize / 2)) * (1.0 - t) + targetTop * t;

    return Positioned(
      left: left,
      top: top,
      width: currentSize,
      height: currentSize,
      child: IgnorePointer(child: AnimatedOrca(page: _currentPageValue)),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.pageCount,
    required this.currentIndex,
    required this.onSkip,
  });

  final int pageCount;
  final int currentIndex;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(pageCount, (index) {
              double width = 8.0;
              if (index == currentIndex) {
                width = 24.0;
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                height: 4,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: index == currentIndex ? Colors.white : Colors.white24,
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: onSkip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.skip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.controller,
    required this.pages,
    required this.currentPageValue,
  });

  final PageController controller;
  final List<OnboardingPageData> pages;
  final double currentPageValue;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        final double delta = index - currentPageValue;
        final double opacity = (1 - delta.abs()).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(delta * 120, 0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (index == 0)
                            SizedBox(
                              height: (MediaQuery.of(context).size.height / 2 - 180),
                            )
                          else
                            const SizedBox(height: 40),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (page.description != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x11FFFFFF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                page.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingBottomAction extends StatelessWidget {
  const _OnboardingBottomAction({
    required this.isLastPage,
    required this.onContinue,
  });

  final bool isLastPage;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 4,
          ),
          onPressed: onContinue,
          child: Text(
            isLastPage
                ? AppLocalizations.of(context)!.startSetup
                : AppLocalizations.of(context)!.continueLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.description,
  });
  final String title;
  final String subtitle;
  final String? description;
}
