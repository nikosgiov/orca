import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  final String _logPrefix = 'FirebaseService';

  /// Initializes Firebase with the provided configuration map.
  /// Does nothing if Firebase is already initialized.
  Future<void> initialize(Map<String, dynamic> config) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: config['apiKey'] ?? '',
            appId: config['appId'] ?? '',
            messagingSenderId: config['messagingSenderId'] ?? '',
            projectId: config['projectId'] ?? '',
            storageBucket: config['storageBucket'] ?? '',
          ),
        );
        developer.log('Firebase initialized successfully', name: _logPrefix);
      }
    } catch (e) {
      developer.log(
        'Firebase initialization error: $e',
        name: _logPrefix,
        error: e,
      );
    }
  }

  /// Safely stops Firebase services. 
  /// Note: We don't delete the default app instance as it causes errors in Flutter.
  Future<void> terminate() async {
    try {
      // Clear or stop any global listeners if we had them.
      developer.log('Firebase services marked for termination', name: _logPrefix);
    } catch (e) {
      developer.log(
        'Firebase termination error: $e',
        name: _logPrefix,
        error: e,
      );
    }
  }
}
