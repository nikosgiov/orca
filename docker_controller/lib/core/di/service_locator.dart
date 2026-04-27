import 'package:docker_controller/services/auth_service.dart';
import 'package:docker_controller/services/compose_service.dart';
import 'package:docker_controller/services/connection_storage_service.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/dio_client.dart';
import 'package:docker_controller/services/docker_service.dart';
import 'package:docker_controller/services/fcm_service.dart';
import 'package:docker_controller/services/firebase_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/local_notification_service.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/services/notification_storage_service.dart';
import 'package:docker_controller/services/preferences_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Setup the service locator for dependency injection.
Future<void> setupLocator() async {
  // 1. Foundation & Networking
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<PreferencesService>(() => PreferencesService(sharedPrefs));
  
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<ConnectionStorageService>(
    () => ConnectionStorageService(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  
  // 2. Base Services (depending on DioClient)
  getIt.registerLazySingleton<DockerService>(
    () => DockerService(getIt<DioClient>().dio),
  );

  // 3. Specialized Services (depending on DockerService)
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<DockerService>()),
  );
  getIt.registerLazySingleton<SystemService>(
    () => SystemService(getIt<DockerService>()),
  );
  getIt.registerLazySingleton<ImageService>(
    () => ImageService(getIt<DockerService>()),
  );
  getIt.registerLazySingleton<NetworkService>(
    () => NetworkService(getIt<DockerService>()),
  );
  getIt.registerLazySingleton<VolumeService>(
    () => VolumeService(getIt<DockerService>()),
  );
  getIt.registerLazySingleton<ComposeService>(
    () => ComposeService(getIt<DockerService>()),
  );
  
  getIt.registerLazySingleton<ContainerService>(
    () => ContainerService(
      dockerService: getIt<DockerService>(),
      imageService: getIt<ImageService>(),
    ),
  );

  // 4. Utility & Notification Services
  getIt.registerLazySingleton<FCMService>(() => FCMService());
  getIt.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );
  getIt.registerLazySingleton<NotificationStorageService>(
    () => NotificationStorageService(getIt<PreferencesService>()),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      getIt<DockerService>(),
      getIt<FCMService>(),
      getIt<LocalNotificationService>(),
      getIt<NotificationStorageService>(),
    ),
  );

  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
}
