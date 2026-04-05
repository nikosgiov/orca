import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../widgets/animated_orca.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Unrestricted Lifecycle Control',
      subtitle: 'Start, Stop, and Recreate containers instantly. Pull, delete, and inspect image repositories natively dashboards setup streamline.',
    ),
    OnboardingPageData(
      title: 'Docker Compose Orchestration',
      subtitle: 'Execute entire multi-container clusters together using Docker Compose configurations setups transparently streamline layouts.',
    ),
    OnboardingPageData(
      title: 'Native Analytics & Node Metrics',
      subtitle: 'Stream real-time datasets detailing continuous CPU datasets limit allocations, Memory leaks analytics and I/O rates.',
    ),
    OnboardingPageData(
      title: 'Interactive Exec TTY Terminals',
      subtitle: 'Spawn live interactive secure shell sessions directly inside container workspaces dashboards streamline frames transparent setup correctly.',
    ),
    OnboardingPageData(
      title: 'Step 1: Run Backend',
      subtitle: 'To talk to Docker daemon, run our secure container server configuration.',
      description: '1. git clone github.com/nikosgiov/orca\n2. Follow the README instructions to configure Firebase and start the orca-server.\n3. Ensure your exposed port is accessible.',
    ),
    OnboardingPageData(
      title: 'Step 2: Connect!',
      subtitle: 'Connect your mobile app securely to your server in seconds.',
      description: 'Enter your Server IP:PORT in the connection screen. Supports Basic auth or TLS securely environments transparent.',
    ),
  ];

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
    int currentIndex = _currentPageValue.round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildContinuousAnimatedGraphic(),
            SafeArea(
              child: Column(
                children: [
              // Top Bar: Dash Indicators and Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dash indicators
                    Row(
                      children: List.generate(_pages.length, (index) {
                        double width = 8.0;
                        if (index == currentIndex) width = 24.0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          height: 4,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: index == currentIndex
                                ? Colors.white
                                : Colors.white24,
                          ),
                        );
                      }),
                    ),
                    // Skip Button
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Skip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              // PageView for Text content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    // Continuous Fading Translation for text items on scroll offset
                    double delta = index - _currentPageValue;
                    double opacity = (1 - delta.abs()).clamp(0.0, 1.0);

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
                ),
              ),

              // Bottom Action Button
              Padding(
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
                    onPressed: () {
                      if (_pageController.hasClients && _currentPageValue < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _skipOnboarding();
                      }
                    },
                    child: Text(
                      currentIndex == _pages.length - 1 ? 'Start setup' : 'Continue',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
    context.read<AppProvider>().setFirstRunComplete();
  }

  Widget _buildAnimatedBackground() {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseImageSize = screenSize.width * 1.8;

    final List<Offset> positions = [
      const Offset(-1050, -100), // Page 0
      const Offset(850, 700),   // Page 1
      const Offset(-100, 600),     // Page 2
      const Offset(0, 150),  // Page 3
      const Offset(0, -800),  // Page 4
    ];

    final List<double> scales = [
      4, // Page 0
      4, // Page 1
      2.5, // Page 2
      1.5, // Page 3
      3, // Page 4
    ];
    // ------------------------------------------

    int index = _currentPageValue.floor();
    int nextIndex = (index + 1) < positions.length ? index + 1 : index;
    double t = _currentPageValue - index;

    if (index >= positions.length) index = positions.length - 1;
    if (nextIndex >= positions.length) nextIndex = positions.length - 1;

    Offset currentPos = Offset.lerp(positions[index], positions[nextIndex], t) ?? positions[index];
    double currentScale = scales[index] + (scales[nextIndex] - scales[index]) * t;
    double currentSize = baseImageSize * currentScale;

    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

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
    double t = _currentPageValue.clamp(0.0, 1.0);
    double scale = 1.0 - (0.65 * t);
    double baseSize = 250.0;
    double currentSize = baseSize * scale;
    double centerX = screenSize.width / 2;
    double centerY = screenSize.height / 2 - 180;
    double targetLeft = 24.0;
    double targetTop = MediaQuery.of(context).padding.top + 60.0;
    double left = (centerX - (baseSize / 2)) * (1.0 - t) + targetLeft * t;
    double top = (centerY - (baseSize / 2)) * (1.0 - t) + targetTop * t;

    return Positioned(
      left: left,
      top: top,
      width: currentSize,
      height: currentSize,
      child: IgnorePointer(
        child: AnimatedOrca(page: _currentPageValue),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String? description;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.description,
  });
}
