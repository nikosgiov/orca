import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firebase_background_handler.dart';

class FCMService {
  FCMService();

  FirebaseMessaging? get _messaging {
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      final messaging = _messaging;
      if (messaging == null) {
        return null;
      }

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        return await messaging.getToken();
      }
    } catch (e) {
      debugPrint('FCMService: Error getting token: $e');
    }
    return null;
  }

  void configureHandlers({
    required Function(RemoteMessage) onMessage,
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  Future<void> deleteToken() async {
    await _messaging?.deleteToken();
  }
}
