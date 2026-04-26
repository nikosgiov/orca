// lib/services/firebase_background_handler.dart

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// This needs to be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  // await Firebase.initializeApp();

  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');

  if (message.notification != null) {
    // FCM already shows a notification automatically on Android when in background
    // if the message contains a notification payload.
    return;
  }

  // Show local notification
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_ic_notification');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final BigPictureStyleInformation bigPictureStyle = BigPictureStyleInformation(
    const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    contentTitle: message.notification?.title ?? 'Notification',
    summaryText: message.notification?.body ?? '',
  );

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'docker_controller_channel',
        'Docker Controller Notifications',
        channelDescription: 'Notifications from Docker Controller app',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF24267D), // AppColors.primary
        styleInformation: bigPictureStyle,
      );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    message.notification?.title ?? 'Notification',
    message.notification?.body ?? '',
    platformChannelSpecifics,
    payload: jsonEncode(message.data),
  );
}
