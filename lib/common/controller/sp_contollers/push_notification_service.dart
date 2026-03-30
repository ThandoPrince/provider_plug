import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:huawei_push/huawei_push.dart' as hms;



class PushNotificationService {
  static final PushNotificationService instance =
      PushNotificationService._internal();

  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<hms.RemoteMessage>? _huaweiMessageSub;
  StreamSubscription<dynamic>? _huaweiOpenSub;
  StreamSubscription<fcm.RemoteMessage>? _firebaseMessageSub;
  StreamSubscription<fcm.RemoteMessage>? _firebaseOpenSub;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'plug_provider_high_importance',
    'Plug Provider Notifications',
    description:
        'Notifications for provider bookings, negotiations and updates',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await _initializeLocalNotifications();

    if (useHuaweiPush) {
      await _initializeHuawei();
    } else {
      await _initializeFirebase();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("Local notification tapped: ${response.payload}");
        }

        if (response.payload == null || response.payload!.isEmpty) return;

        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          _handleNotification(data);
        } catch (e) {
          if (kDebugMode) {
            print("Failed to decode local notification payload: $e");
          }
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// ---------------- HUAWEI ----------------
  Future<void> _initializeHuawei() async {
    if (kDebugMode) {
      print("Initializing Huawei Push listener for provider app");
    }

    await _huaweiMessageSub?.cancel();
    await _huaweiOpenSub?.cancel();

    _huaweiMessageSub = hms.Push.onMessageReceivedStream.listen((
      hms.RemoteMessage message,
    ) async {
      if (kDebugMode) {
        print("Huawei notification received:");
        print("message.data: ${message.data}");
        print("message.notification?.title: ${message.notification?.title}");
        print("message.notification?.body: ${message.notification?.body}");
      }

      final Map<String, dynamic> parsedData = _parseHuaweiData(message.data);

      final String title =
          message.notification?.title ??
          parsedData['title']?.toString() ??
          'Plug Provider';

      final String body =
          message.notification?.body ??
          parsedData['body']?.toString() ??
          'New update';

      await _showLocalNotification(
        title: title,
        body: body,
        payload: parsedData,
      );

      _handleNotification(parsedData);
    });

    _huaweiOpenSub = hms.Push.onNotificationOpenedApp.listen((dynamic data) {
      if (kDebugMode) {
        print("Huawei notification opened:");
        print(data);
      }

      if (data == null) return;

      try {
        final dataStr = data is String ? data : data.toString();
        if (dataStr.isEmpty) return;

        final parsed = jsonDecode(dataStr) as Map<String, dynamic>;
        _handleNotification(parsed);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to decode Huawei open payload: $e");
        }
      }
    });
  }

  /// ---------------- FIREBASE ----------------
  Future<void> _initializeFirebase() async {
    if (kDebugMode) {
      print("Initializing Firebase Push listener for provider app");
    }

    await _firebaseMessageSub?.cancel();
    await _firebaseOpenSub?.cancel();

    _firebaseMessageSub = fcm.FirebaseMessaging.onMessage.listen((
      fcm.RemoteMessage message,
    ) async {
      if (kDebugMode) {
        print("Firebase notification received:");
        print(message.data);
      }

      final String title =
          message.notification?.title ??
          message.data['title']?.toString() ??
          'Plug Provider';

      final String body =
          message.notification?.body ??
          message.data['body']?.toString() ??
          'New update';

      await _showLocalNotification(
        title: title,
        body: body,
        payload: message.data,
      );

      _handleNotification(message.data);
    });

    _firebaseOpenSub = fcm.FirebaseMessaging.onMessageOpenedApp.listen((
      fcm.RemoteMessage message,
    ) {
      if (kDebugMode) {
        print("Firebase notification opened:");
        print(message.data);
      }

      _handleNotification(message.data);
    });
  }

  /// ---------------- LOCAL NOTIFICATION DISPLAY ----------------
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'plug_provider_high_importance',
      'Plug Provider Notifications',
      channelDescription:
          'Notifications for provider bookings, negotiations and updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(payload),
    );
  }

  /// ---------------- HELPERS ----------------
  Map<String, dynamic> _parseHuaweiData(dynamic rawData) {
    if (rawData == null) return {};

    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to decode Huawei data string: $e");
        }
      }
    }

    return {};
  }

  /// ---------------- HANDLER ----------------
  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type']?.toString();

    if (kDebugMode) {
      print("Notification type: $type");
      print("Notification payload: $data");
    }

    switch (type) {
      case "new_booking_invite":
        if (kDebugMode) {
          print("New booking invite received");
        }
        break;

      case "negotiation_started":
        if (kDebugMode) {
          print("Negotiation started notification received");
        }
        break;

      case "negotiation_accepted":
        if (kDebugMode) {
          print("Negotiation accepted notification received");
        }
        break;

      case "booking_cancelled":
        if (kDebugMode) {
          print("Booking cancelled notification received");
        }
        break;

      case "session_started":
        if (kDebugMode) {
          print("Session started notification received");
        }
        break;

      case "session_completed":
        if (kDebugMode) {
          print("Session completed notification received");
        }
        break;

      case "test":
        if (kDebugMode) {
          print("Test notification received");
        }
        break;

      default:
        if (kDebugMode) {
          print("Unknown notification type");
        }
    }
  }

  Future<void> dispose() async {
    await _huaweiMessageSub?.cancel();
    await _huaweiOpenSub?.cancel();
    await _firebaseMessageSub?.cancel();
    await _firebaseOpenSub?.cancel();
  }
}
