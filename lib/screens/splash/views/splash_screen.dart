import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/push_notification_service.dart';
import 'package:flutter_application_2/common/storage.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:permission_handler/permission_handler.dart';

bool useHuaweiPush = false;

/// Firebase background handler
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(fcm.RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("📩 Firebase background notification received");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasStarted = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    if (!_hasStarted) {
      _hasStarted = true;
      _bootstrap();
    }
  }

  

  Future<void> _bootstrap() async {
  try {
    await _initializeApp();

    if (!mounted) return;

    final bool isFirstTime =
        Storage().getBool('isFirstTimeProvider') ?? true;

    debugPrint('Splash -> isFirstTimeProvider = $isFirstTime');

    final auth = AuthSessionController.instance;

    // Load saved tokens from secure storage
    await auth.loadSession();

    if (!mounted) return;

    if (isFirstTime) {
      context.go('/onboarding');
    } else if (auth.isLoggedIn) {
      auth.markLoggedIn();
      context.go('/entrypoint');
    } else {
      context.go('/login');
    }
  } catch (e, st) {
    debugPrint("❌ Splash initialization failed: $e\n$st");

    if (!mounted) return;

    setState(() {
      _errorMessage = "Initialization failed.\nCheck logs for details.";
    });
  }
} 

  Future<void> _initializeApp() async {

    await GetStorage.init();


    await AuthSessionController.instance.loadSession();


    final bool envLoaded = await _safeLoadEnv();
    if (!envLoaded) {
      throw Exception("Environment loading failed");
    }


    final bool hereSdkInitialized = await _safeInitializeHERESDK();
    if (!hereSdkInitialized) {
      throw Exception("HERE SDK initialization failed");
    }


    await _detectHuaweiPushEnvironment();

    if (!useHuaweiPush) {

      await _initializeFirebase();

      fcm.FirebaseMessaging.onBackgroundMessage(
        firebaseBackgroundHandler,
      );


      await _requestFirebasePermission();
    }


    await _requestNotificationPermission();


    await PushNotificationService.instance.initialize();

   
  }

  Future<void> _detectHuaweiPushEnvironment() async {
    if (!Platform.isAndroid) {
      useHuaweiPush = false;
      return;
    }

    try {
      final int availability = await HmsApiAvailability().isHMSAvailable();

      if (availability == 0) {
        useHuaweiPush = true;
        if (kDebugMode) {
          print("✅ HMS available → using Huawei Push");
        }
      } else {
        useHuaweiPush = false;
        if (kDebugMode) {
          print("ℹ️ HMS unavailable ($availability) → using Firebase");
        }
      }
    } catch (e) {
      useHuaweiPush = false;
      if (kDebugMode) {
        print("⚠️ HMS detection failed: $e");
      }
    }
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      if (kDebugMode) {
        print("✅ Firebase initialized");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Firebase init failed: $e");
      }
      rethrow;
    }
  }

  Future<void> _requestFirebasePermission() async {
    try {
      final settings = await fcm.FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print("🔔 FCM permission status: ${settings.authorizationStatus}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ FCM permission request failed: $e");
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final status = await Permission.notification.request();
      if (kDebugMode) {
        print("🔔 Android notification permission: $status");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Notification permission request failed: $e");
      }
    }
  }

  Future<bool> _safeLoadEnv() async {
    final envFile = kReleaseMode ? ".env.production" : ".env.development";

    try {
      await dotenv.load(fileName: envFile);
      debugPrint("✅ Environment loaded from $envFile");
      return true;
    } catch (e, st) {
      debugPrint("⚠️ Could not load $envFile: $e\n$st");
      return false;
    }
  }

  Future<bool> _safeInitializeHERESDK() async {
    final String hereAccessKeyID = dotenv.env['HEREACCESSKEYID'] ?? '';
    final String hereKeySecret = dotenv.env['HEREKEYSECRET'] ?? '';

    try {
      SdkContext.init(IsolateOrigin.main);

      final authMode = AuthenticationMode.withKeySecret(
        hereAccessKeyID,
        hereKeySecret,
      );

      final sdkOptions = SDKOptions.withAuthenticationMode(authMode);

      await SDKNativeEngine.makeSharedInstance(sdkOptions);

      debugPrint("✅ HERE SDK initialized successfully");
      return true;
    } catch (e, st) {
      debugPrint("❌ HERE SDK initialization failed: $e\n$st");
      return false;
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100.h,
              child: Image.asset('assets/icons/plug_icon.png'),
            ),
            SizedBox(height: 20.h),
          
          
          ],
        ),
      ),
    );
  }
}