import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'local_notification_service.dart';

/// It should be always on top
///Receive message when app is in background solution for on message
Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint("Notification Data ${message.data.entries.toList().toString()}");
  debugPrint("Notification Data ${message.notification.toString()}");

  LocalNotificationService.display(message);
}

class PushNotificationHelper {
  static PushNotificationHelper? _instance;

  PushNotificationHelper._();

  static PushNotificationHelper get instance =>
      _instance ??= PushNotificationHelper._();

  onInit() {
    getFcmToken();
    _notificationSettings();
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    FirebaseMessaging.instance.getInitialMessage();
    LocalNotificationService.initialize();
    foregronudMethod();
    backgroundBtCloseMethod();
    backgroundOpenedMethod();
  }

  ///gives you the message on which user taps
  ///and it opened the app from terminated state
  void backgroundBtCloseMethod() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      _routeSetUp(message);
    });
  }

  ///forground work
  void foregronudMethod() {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.data);
      debugPrint(
          "Notification Data ${message.data.entries.toList().toString()}");
      debugPrint("Notification Data ${message.notification.toString()}");

      LocalNotificationService.display(message);
    });
  }

  /// App is in background but not destroyed or cleared from memory
  ///When the app is in background but opened
  ///   Also handle any interaction when the app is in the background via a
  /// Stream listener
  void backgroundOpenedMethod() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _routeSetUp(message);
    });
  }

  void _routeSetUp(RemoteMessage? message) {
    final body = message?.data['body'];
    if (body != null) {
      final json = jsonDecode(body);
      if (json != null && json['notification_type'] != null) {
        var typeId = json['type_id'];
        switch (json['notification_type']) {
          case "order":
            if (typeId != null && typeId is int) {}
            break;
        }
      }
    }
  }

  //For Android 13 we need enable this settings manually
  void _notificationSettings() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}

Future<String?> getFcmToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN ::$token");
  return token;
}
