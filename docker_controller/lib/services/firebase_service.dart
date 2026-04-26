import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static const String _logPrefix = 'FirebaseService';

  /// Initializes Firebase with the provided configuration map.
  /// Does nothing if Firebase is already initialized.
  static Future<void> initialize(Map<String, dynamic> config) async {
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

  /// Deletes the default Firebase app if it exists.
  static Future<void> terminate() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await Firebase.app().delete();
        developer.log('Firebase terminated successfully', name: _logPrefix);
      }
    } catch (e) {
      developer.log(
        'Firebase termination error: $e',
        name: _logPrefix,
        error: e,
      );
    }
  }
}
