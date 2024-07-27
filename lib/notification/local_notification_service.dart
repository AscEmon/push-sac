import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android:
                AndroidInitializationSettings("@mipmap/transparent_othership"),
            iOS: IOSInitializationSettings());

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? body) async {
      if (body != null) {
        final json = jsonDecode(body);
        print(json.toString());
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {
      // final sound = "notification_sound.wav";
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "sbac",
          "sbac Channel",
          importance: Importance.max,
          priority: Priority.high,
          color: Color.fromARGB(255, 0, 0, 0),
          enableLights: false,
          playSound: true,
          enableVibration: false,
          showWhen: false,
          // sound: RawResourceAndroidNotificationSound(sound.split('.').first),
        ),

        //we need to create Resouces folder in
        //runner then put the wav file in there
        iOS: IOSNotificationDetails(presentSound: true),
      );

      String title = "";
      String body = "";
      print(message.toString());
      print(message.notification);
      print(message.data);
      if (message.notification != null) {
        title = message.notification?.title ?? "";
        body = message.notification?.body ?? "";
      } else {
        final responseBody = jsonDecode(message.data['body']);
        title = responseBody['title'] ?? "";
        body = responseBody['body'];
      }

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: message.data.isEmpty ? null : message.data['body'],
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
