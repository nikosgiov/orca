import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

import 'constants/app_colors.dart';
import 'constants/app_gradients.dart';
import 'constants/app_strings.dart';
import 'constants/app_themes.dart';
import 'providers/app_provider.dart';
import 'screens/connection_screen.dart';
import 'services/connection_storage_service.dart';


import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/containers_screen.dart';
import 'screens/images_screen.dart';
import 'screens/resource_monitoring_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/connection_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/volumes_networks_provider.dart';
import 'providers/logs_notifications_provider.dart';
import 'providers/resource_monitoring_provider.dart';
import 'providers/images_provider.dart';
import 'providers/containers_provider.dart';
import 'providers/system_info_provider.dart';
import 'providers/compose_provider.dart';
import 'screens/compose_screen.dart';
import 'utils/app_transitions.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final config = await ConnectionStorageService.loadConnectionConfig();
  if (config != null && config.firebaseConfig != null) {
    try {
      final fConfig = config.firebaseConfig!;
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: fConfig['apiKey'] ?? '',
          appId: fConfig['appId'] ?? '',
          messagingSenderId: fConfig['messagingSenderId'] ?? '',
          projectId: fConfig['projectId'] ?? '',
          storageBucket: fConfig['storageBucket'] ?? '',
        ),
      );
    } catch (e) {
      // Failed to initialize with saved config, likely invalid or old
      developer.log('Failed to initialize Firebase with saved options: $e', name: 'main');
    }
  }
  // Else branch with fallback removed





  runApp(const DockerControllerApp());
}


class DockerControllerApp extends StatelessWidget {
  const DockerControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => VolumesNetworksProvider()),
        ChangeNotifierProxyProvider<AppProvider, LogsNotificationsProvider>(
          create: (context) => LogsNotificationsProvider(context.read<AppProvider>()),
          update: (_, appProvider, previous) {
            final provider = previous ?? LogsNotificationsProvider(appProvider);
            provider.updateConnectionConfig(appProvider.connectionConfig);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AppProvider, ResourceMonitoringProvider>(
          create: (_) => ResourceMonitoringProvider(null),
          update: (_, appProvider, previous) {
            final provider = previous ?? ResourceMonitoringProvider(null);
            provider.updateConnectionConfig(appProvider.connectionConfig);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AppProvider, ImagesProvider>(
          create: (context) => ImagesProvider(context.read<AppProvider>()),
          update: (_, appProvider, previous) =>
              previous ?? ImagesProvider(appProvider),
        ),
        ChangeNotifierProxyProvider<AppProvider, ContainersProvider>(
          create: (context) => ContainersProvider(context.read<AppProvider>()),
          update: (_, appProvider, previous) =>
              previous ?? ContainersProvider(appProvider),
        ),
        ChangeNotifierProxyProvider<AppProvider, ComposeProvider>(
          create: (context) => ComposeProvider(appProvider: context.read<AppProvider>()),
          update: (_, appProvider, previous) =>
              previous ?? ComposeProvider(appProvider: appProvider),
        ),
        ChangeNotifierProvider(create: (_) => SystemInfoProvider()),
      ],
      child: Selector<AppProvider, (bool, bool, bool, ThemeMode)>(
        selector: (_, p) => (p.isInitializing, p.isFirstRun, p.isConnected, p.themeMode),
        builder: (context, data, child) {
          final (isInitializing, isFirstRun, isConnected, _) = data;
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.darkTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: ThemeMode.dark,
            navigatorKey: _navigatorKey,
            home: isInitializing
                ? _buildSplash()
                : isFirstRun
                    ? const OnboardingScreen()
                    : isConnected
                        ? const MainScreen()
                        : const ConnectionScreen(),
          );
        },
      ),
    );
  }

  Widget _buildSplash() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.background,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 48, height: 48),
              SizedBox(height: 20),
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Loading...', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav items ───────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(Icons.grid_view_rounded, 'Dash'),
  _NavItem(Icons.view_in_ar_rounded, 'Containers'),
  _NavItem(Icons.layers_rounded, 'Images'),
  _NavItem(Icons.analytics_rounded, 'Monitor'),
  _NavItem(Icons.account_tree_rounded, 'Compose'),
  _NavItem(Icons.settings_rounded, 'Config'),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToContainers: () => _changeTab(1),
        onNavigateToImages: () => _changeTab(2),
      ),
      const ContainersScreen(),
      const ImagesScreen(),
      const ResourceMonitoringScreen(),
      const ComposeScreen(),
      const SettingsScreen(),
    ];
  }

  void _changeTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full-screen background gradient – painted here once for all screens.
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: AnimatedFadeIndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // Floating pill nav bar, identical to code.html <nav>.
        bottomNavigationBar: _FloatingNavBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}

// ─── Floating pill nav bar ────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                // Frosted glass: lighter now that blur provides depth
                color: const Color(0x22FFFFFF),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_navItems.length, (i) {
                  return Expanded(
                    child: _NavItemWidget(
                      item: _navItems[i],
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

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

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
                  color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.55),
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
                color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.55),
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
