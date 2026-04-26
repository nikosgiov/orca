import 'package:get_it/get_it.dart';

import '../../services/auth_service.dart';
import '../../services/compose_service.dart';
import '../../services/container_service.dart';
import '../../services/dio_client.dart';
import '../../services/docker_service.dart';
import '../../services/fcm_service.dart';
import '../../services/image_service.dart';
import '../../services/local_notification_service.dart';
import '../../services/network_service.dart';
import '../../services/notification_service.dart';
import '../../services/notification_storage_service.dart';
import '../../services/system_service.dart';
import '../../services/volume_service.dart';

final getIt = GetIt.instance;

/// Setup the service locator for dependency injection.
Future<void> setupLocator() async {
  // 1. Foundation & Networking
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  
  // 2. Base Services (depending on DioClient)
  getIt.registerLazySingleton<DockerService>(
    () => DockerService(getIt<DioClient>().dio),
  );

  // 3. Specialized Services (depending on DockerService)
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<DioClient>().dio),
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
    () => NotificationStorageService(),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      getIt<DockerService>(),
      getIt<FCMService>(),
      getIt<LocalNotificationService>(),
      getIt<NotificationStorageService>(),
    ),
  );
}
