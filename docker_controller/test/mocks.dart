import 'package:dio/dio.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/auth_service.dart';
import 'package:docker_controller/services/connection_storage_service.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/dio_client.dart';
import 'package:docker_controller/services/docker_service.dart';
import 'package:docker_controller/services/firebase_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/services/preferences_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  ContainerService,
  AuthProvider,
  SharedPreferences,
  AuthService,
  SystemService,
  DioClient,
  NotificationService,
  ImageService,
  DockerService,
  VolumeService,
  NetworkService,
  Dio,
  ConnectionStorageService,
  PreferencesService,
  FirebaseService,
])
void main() {}
