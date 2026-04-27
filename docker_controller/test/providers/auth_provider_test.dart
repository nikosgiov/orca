import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/auth_service.dart';
import 'package:docker_controller/services/connection_storage_service.dart';
import 'package:docker_controller/services/dio_client.dart';
import 'package:docker_controller/services/firebase_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/services/preferences_service.dart';
import 'package:docker_controller/services/system_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;
  late MockAuthService mockAuthService;
  late MockSystemService mockSystemService;
  late MockDioClient mockDioClient;
  late MockNotificationService mockNotificationService;
  late MockConnectionStorageService mockConnectionStorageService;
  late MockPreferencesService mockPreferencesService;
  late MockFirebaseService mockFirebaseService;

  setUp(() async {
    registerTestDummies();
    mockAuthService = MockAuthService();
    mockSystemService = MockSystemService();
    mockDioClient = MockDioClient();
    mockNotificationService = MockNotificationService();
    mockConnectionStorageService = MockConnectionStorageService();
    mockPreferencesService = MockPreferencesService();
    mockFirebaseService = MockFirebaseService();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<SystemService>(mockSystemService);
    getIt.registerSingleton<DioClient>(mockDioClient);
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<ConnectionStorageService>(mockConnectionStorageService);
    getIt.registerSingleton<PreferencesService>(mockPreferencesService);
    getIt.registerSingleton<FirebaseService>(mockFirebaseService);
    
    SharedPreferences.setMockInitialValues({});

    when(mockPreferencesService.getBool(any, defaultValue: anyNamed('defaultValue'))).thenReturn(true);

    when(mockConnectionStorageService.loadConnectionConfig()).thenAnswer((_) async => null);
    when(mockConnectionStorageService.loadConnectionHistory()).thenAnswer((_) async => []);

    authProvider = AuthProvider();
    await authProvider.init();
  });

  group('AuthProvider', () {
    test('Initial state should be disconnected', () {
      expect(authProvider.isConnected, false);
      expect(authProvider.isConnecting, false);
    });

    test('connect should set isConnected to true on success (None Auth)', () async {
      const config = ConnectionConfig(uri: 'localhost', authType: AuthType.none);

      when(mockSystemService.testConnection()).thenAnswer((_) async => Result.success(true));
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => Result.success(<String, dynamic>{}));
      when(mockSystemService.getFirebaseConfig()).thenAnswer((_) async => Result.success(<String, dynamic>{}));
      when(mockNotificationService.initialize()).thenAnswer((_) async => {});

      await authProvider.connect(config);

      expect(authProvider.isConnected, true);
      expect(authProvider.error, isNull);
      verify(mockDioClient.updateConfig(any)).called(greaterThan(0));
    });

    test('connect should fail if system info is null', () async {
      const config = ConnectionConfig(uri: 'localhost', authType: AuthType.none);

      when(mockSystemService.testConnection()).thenAnswer((_) async => Result.success(true));
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => Result.failure(AppError(message: 'denied')));

      await authProvider.connect(config);

      expect(authProvider.isConnected, false);
      expect(authProvider.error!.message, contains('denied'));
    });

    test('connect should persist config if persist is true', () async {
      const config = ConnectionConfig(uri: 'localhost', authType: AuthType.none);

      when(mockSystemService.testConnection()).thenAnswer((_) async => Result.success(true));
      when(mockSystemService.getSystemInfo()).thenAnswer((_) async => Result.success(<String, dynamic>{}));
      when(mockSystemService.getFirebaseConfig()).thenAnswer((_) async => Result.success(<String, dynamic>{}));
      when(mockNotificationService.initialize()).thenAnswer((_) async => {});

      await authProvider.connect(config, persist: true);

      verify(mockConnectionStorageService.saveConnectionConfig(any)).called(1);
    });

    test('should logout automatically after max consecutive failures', () async {
      const config = ConnectionConfig(uri: 'localhost', authType: AuthType.none);
      
      // Simulate 2 failures
      when(mockSystemService.testConnection()).thenAnswer((_) async => Result.failure(AppError(message: 'fail')));
      
      await authProvider.connect(config);
      await authProvider.connect(config);
      
      expect(authProvider.isConnected, false);
      // Not yet logged out (cleared state) because max is 3
      
      // 3rd failure
      await authProvider.connect(config);
      
      expect(authProvider.isConnected, false);
      verify(mockConnectionStorageService.deleteConnectionConfig()).called(1);
      expect(authProvider.error!.message, contains('multiple times'));
    });

    test('should handle connection timeout', () {
      // Use fakeAsync to control time
      fakeAsync((async) {
        const config = ConnectionConfig(uri: 'localhost', authType: AuthType.none);
        
        when(mockSystemService.testConnection()).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 10));
          return Result.success(true);
        });

        authProvider.connect(config);
        
        // Advance time by 6 seconds to trigger the 5s timeout
        async.elapse(const Duration(seconds: 6));
        
        expect(authProvider.isConnected, false);
        expect(authProvider.error!.message, contains('timed out'));
      });
    });

    test('logout should clear state and services', () async {
      when(mockNotificationService.unregisterFromNotifications()).thenAnswer((_) async => {});
      when(mockNotificationService.dispose()).thenAnswer((_) async => {});
      when(mockFirebaseService.terminate()).thenAnswer((_) async => {});
      when(mockConnectionStorageService.deleteConnectionConfig()).thenAnswer((_) async => {});

      await authProvider.logout();

      expect(authProvider.isConnected, false);
      expect(authProvider.connectionConfig, isNull);
      verify(mockNotificationService.unregisterFromNotifications()).called(1);
      verify(mockFirebaseService.terminate()).called(1);
    });
  });
}
