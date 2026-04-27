import 'package:docker_controller/providers/app_config_provider.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/compose/compose_screen.dart';
import '../screens/connection_screen.dart';
import '../screens/container_detail_screen.dart';
import '../screens/containers_screen.dart';
import '../screens/create_container_screen.dart';
import '../screens/create_network_screen.dart';
import '../screens/home_screen.dart';
import '../screens/images/images_screen.dart';
import '../screens/main_screen.dart';
import '../screens/networks_screen.dart';
import '../screens/notification_settings/notification_settings_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/resource_monitoring_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/system_info_screen.dart';
import '../screens/volumes/create_volume_screen.dart';
import '../screens/volumes_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String connection = '/connection';
  static const String dashboard = '/dashboard';
  static const String containers = '/containers';
  static const String images = '/images';
  static const String monitor = '/monitor';
  static const String compose = '/compose';
  static const String settings = '/settings';
  static const String createContainer = '/create-container';
  static const String containerDetail = '/container/:id';
  static const String systemInfo = '/system-info';
  static const String volumes = '/volumes';
  static const String networks = '/networks';
  static const String createVolume = '/create-volume';
  static const String createNetwork = '/create-network';
  static const String notificationSettings = '/notification-settings';

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static Page<dynamic> _focalZoomPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginScale = 0.85;
        const endScale = 1.0;
        const curve = Curves.easeInOutBack;

        final scaleAnimation = Tween<double>(
          begin: beginScale,
          end: endScale,
        ).animate(CurvedAnimation(parent: animation, curve: curve));
        final opacityAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  static GoRouter router(
    AuthProvider authProvider,
    AppConfigProvider configProvider,
  ) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: dashboard,
      refreshListenable: Listenable.merge([authProvider, configProvider]),
      redirect: (context, state) {
        final isInitializing = configProvider.isInitializing;
        final isFirstRun = configProvider.isFirstRun;
        final isConnected = authProvider.isConnected;

        if (isInitializing) {
          return null;
        }

        final bool loggingIn = state.matchedLocation == connection;
        final bool onOnboarding = state.matchedLocation == onboarding;

        if (isFirstRun) {
          if (onOnboarding) {
            return null;
          }
          return onboarding;
        }

        if (!isConnected) {
          if (loggingIn) {
            return null;
          }
          return connection;
        }

        if (loggingIn || onOnboarding) {
          return dashboard;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: onboarding,
          name: 'onboarding',
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const OnboardingScreen()),
        ),
        GoRoute(
          path: connection,
          name: 'connection',
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const ConnectionScreen()),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScreenWrapper(child: child);
          },
          routes: [
            GoRoute(
              path: dashboard,
              name: 'dashboard',
              pageBuilder: (context, state) => NoTransitionPage(
                child: HomeScreen(
                  onNavigateToContainers: () => context.go(containers),
                  onNavigateToImages: () => context.go(images),
                ),
              ),
            ),
            GoRoute(
              path: containers,
              name: 'containers',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ContainersScreen()),
            ),
            GoRoute(
              path: images,
              name: 'images',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ImagesScreen()),
            ),
            GoRoute(
              path: monitor,
              name: 'monitor',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ResourceMonitoringScreen()),
            ),
            GoRoute(
              path: compose,
              name: 'compose',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ComposeScreen()),
            ),
            GoRoute(
              path: settings,
              name: 'settings',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
            ),
          ],
        ),
        GoRoute(
          path: createContainer,
          name: 'createContainer',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final preSelectedImage = state.uri.queryParameters['image'];
            return _focalZoomPage(
              state: state,
              child: CreateContainerScreen(preSelectedImage: preSelectedImage),
            );
          },
        ),
        GoRoute(
          path: containerDetail,
          name: 'containerDetail',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            final name = state.uri.queryParameters['name'] ?? 'Container';
            return _focalZoomPage(
              state: state,
              child: ContainerDetailScreen(
                containerId: id,
                containerName: name,
              ),
            );
          },
        ),
        GoRoute(
          path: systemInfo,
          name: 'systemInfo',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const SystemInfoScreen()),
        ),
        GoRoute(
          path: volumes,
          name: 'volumes',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const VolumesScreen()),
        ),
        GoRoute(
          path: networks,
          name: 'networks',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const NetworksScreen()),
        ),
        GoRoute(
          path: createVolume,
          name: 'createVolume',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const CreateVolumeScreen()),
        ),
        GoRoute(
          path: createNetwork,
          name: 'createNetwork',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              _focalZoomPage(state: state, child: const CreateNetworkScreen()),
        ),
        GoRoute(
          path: notificationSettings,
          name: 'notificationSettings',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => _focalZoomPage(
            state: state,
            child: const NotificationSettingsScreen(),
          ),
        ),
      ],
    );
  }
}

// Wrapper for MainScreen to support ShellRoute
class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRouter.dashboard)) {
      return 0;
    }
    if (location.startsWith(AppRouter.containers)) {
      return 1;
    }
    if (location.startsWith(AppRouter.images)) {
      return 2;
    }
    if (location.startsWith(AppRouter.monitor)) {
      return 3;
    }
    if (location.startsWith(AppRouter.compose)) {
      return 4;
    }
    if (location.startsWith(AppRouter.settings)) {
      return 5;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.dashboard);
        break;
      case 1:
        context.go(AppRouter.containers);
        break;
      case 2:
        context.go(AppRouter.images);
        break;
      case 3:
        context.go(AppRouter.monitor);
        break;
      case 4:
        context.go(AppRouter.compose);
        break;
      case 5:
        context.go(AppRouter.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      currentIndex: _calculateSelectedIndex(context),
      onTabChanged: (index) => _onItemTapped(index, context),
      child: widget.child,
    );
  }
}
