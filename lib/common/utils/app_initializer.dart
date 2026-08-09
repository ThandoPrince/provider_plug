import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/push_notification_service.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:permission_handler/permission_handler.dart';

class AppInitializer {
  static Future<void> initializeCore() async {
    await GetStorage.init();
    await AuthSessionController.instance.loadSession();
    final envFile = kReleaseMode ? ".env.production" : ".env.development";
    await dotenv.load(fileName: envFile);
  }

  static Future<void> initializeDeferred() async {
    if (Platform.isAndroid) {
  try {
    final availability = await HmsApiAvailability()
        .isHMSAvailable()
        .timeout(const Duration(seconds: 3));
    useHuaweiPush = availability == 0;
  } catch (_) {
    useHuaweiPush = false;
  }
}

    if (!useHuaweiPush) {
      try {
        await Firebase.initializeApp().timeout(const Duration(seconds: 10));
        fcm.FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
        await fcm.FirebaseMessaging.instance
            .requestPermission(alert: true, badge: true, sound: true)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Firebase init failed: $e');
      }
    }

    if (Platform.isAndroid) {
      try {
        await Permission.notification.request().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Notification permission failed: $e');
      }
    }

    try {
      await PushNotificationService.instance
          .initialize()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Push service init failed: $e');
    }
  }
}