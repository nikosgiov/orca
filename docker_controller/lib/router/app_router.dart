import 'package:docker_controller/providers/app_config_provider.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/screens/logs_notifications/logs_notifications_screen.dart';
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScreenWrapper(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
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
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: containers,
                  name: 'containers',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ContainersScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: images,
                  name: 'images',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ImagesScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: monitor,
                  name: 'monitor',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ResourceMonitoringScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: compose,
                  name: 'compose',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ComposeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: settings,
                  name: 'settings',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: SettingsScreen()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/logs-notifications',
          name: 'logsNotifications',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => _focalZoomPage(
            state: state,
            child: const LogsNotificationsScreen(),
          ),
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

// Wrapper for MainScreen to support StatefulShellRoute
class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      currentIndex: navigationShell.currentIndex,
      onTabChanged: _onItemTapped,
      child: navigationShell,
    );
  }
}
