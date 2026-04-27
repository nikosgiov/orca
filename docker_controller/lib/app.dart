import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'constants/app_themes.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_config_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/compose_provider.dart';
import 'providers/containers_provider.dart';
import 'providers/images_provider.dart';
import 'providers/logs_notifications_provider.dart';
import 'providers/resource_monitoring_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/system_info_provider.dart';
import 'providers/system_stats_provider.dart';
import 'providers/volumes_networks_provider.dart';
import 'router/app_router.dart';

/// The root widget of the Docker Controller application.
class DockerControllerApp extends StatelessWidget {
  const DockerControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, SystemStatsProvider>(
          create: (context) => SystemStatsProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, previous) {
            final provider = previous ?? SystemStatsProvider(auth);
            if (auth.isConnected && provider.systemInfo == null && !provider.isLoading) {
              provider.refreshAll();
            }
            return provider;
          },
        ),

        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => VolumesNetworksProvider()),

        // Secondary providers depending on Auth/Stats
        ChangeNotifierProxyProvider<AuthProvider, LogsNotificationsProvider>(
          create: (context) => LogsNotificationsProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, previous) {
            final provider = previous ?? LogsNotificationsProvider(auth);
            provider.updateConnectionConfig(auth.connectionConfig);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ResourceMonitoringProvider>(
          create: (_) => ResourceMonitoringProvider(null),
          update: (_, auth, previous) {
            final provider = previous ?? ResourceMonitoringProvider(null);
            provider.updateConnectionConfig(auth.connectionConfig);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ImagesProvider>(
          create: (context) => ImagesProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, previous) => previous ?? ImagesProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ContainersProvider>(
          create: (context) => ContainersProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, previous) => previous ?? ContainersProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ComposeProvider>(
          create: (context) => ComposeProvider(authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, previous) => previous ?? ComposeProvider(authProvider: auth),
        ),
        ChangeNotifierProvider(create: (_) => SystemInfoProvider()),
      ],
      child: const _AppRouterWrapper(),
    );
  }
}

class _AppRouterWrapper extends StatefulWidget {
  const _AppRouterWrapper();

  @override
  State<_AppRouterWrapper> createState() => _AppRouterWrapperState();
}

class _AppRouterWrapperState extends State<_AppRouterWrapper> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(
      context.read<AuthProvider>(),
      context.read<AppConfigProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfigProvider>(
      builder: (context, config, child) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.darkTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: config.themeMode,
          routerConfig: _router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
