import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/core/utils/result.dart';
import 'package:docker_controller/models/log_level.dart';
import 'package:docker_controller/providers/logs_notifications_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks.mocks.dart';
import '../test_helpers.dart';

void main() {
  late LogsNotificationsProvider provider;
  late MockAuthProvider mockAuthProvider;
  late MockNotificationService mockNotificationService;
  late MockContainerService mockContainerService;

  setUp(() async {
    registerTestDummies();
    SharedPreferences.setMockInitialValues({});
    
    mockAuthProvider = MockAuthProvider();
    mockNotificationService = MockNotificationService();
    mockContainerService = MockContainerService();

    await getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<ContainerService>(mockContainerService);

    when(mockNotificationService.onNotificationReceived)
        .thenAnswer((_) => const Stream.empty());
    when(mockAuthProvider.connectionConfig).thenReturn(null);

    provider = LogsNotificationsProvider(mockAuthProvider);
  });

  group('LogsNotificationsProvider Refactor Tests', () {
    test('initial values should be typed and correct', () {
      expect(provider.selectedLogLevel, LogLevel.all);
      expect(provider.logs, isEmpty);
      expect(provider.notifications, isEmpty);
    });

    test('fetchLogs should parse logs into LogEntry models', () async {
      when(mockAuthProvider.connectionConfig).thenReturn(null); // Just for test
      
      const mockLogs = 'line 1\nERROR: something failed\nWARN: careful';
      when(mockContainerService.getContainerLogs(any))
          .thenAnswer((_) async => Result.success(mockLogs));

      // We need a config to satisfy the check
      when(mockAuthProvider.connectionConfig).thenReturn(null); 
    });
  });
}
