import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class MessagingServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  void request() async {
    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
  }

  Future<bool> isNotificationPermissionDisable() async {
    PermissionStatus permissionStatus = await Permission.notification.status;
    if (permissionStatus.isDenied) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initialize() async {
    log("NotificationService Initialize");
    RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (remoteMessage != null) {
      handleNotification(remoteMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      handleNotification(event);
    });
    FirebaseMessaging.onMessage.listen((event) {
      log("NotificationService notification onMessage:${event.data} ");
      log("NotificationService notification onMessage:${event.from} ");
      log("NotificationService notification onMessage:${event.messageType} ");
      log("NotificationService notification onMessage:${event.messageId} ");
    });
  }

  Future<String?> getNotificationToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void handleNotification(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    log("handleNotification data:$data");
  }
}
