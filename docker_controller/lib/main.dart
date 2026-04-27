
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'services/connection_storage_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await setupLocator();

  final config = await getIt<ConnectionStorageService>().loadConnectionConfig();
  if (config != null && config.firebaseConfig != null) {
    await getIt<FirebaseService>().initialize(config.firebaseConfig!);
  }

  runApp(const DockerControllerApp());
}
