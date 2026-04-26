import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/auth_service.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/dio_client.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/services/system_service.dart';
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
])
void main() {}
