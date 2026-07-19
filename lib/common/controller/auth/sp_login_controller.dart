import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/provider_login_response_model.dart';
import 'package:flutter_application_2/common/services/sp_login_api.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SPLoginController extends ChangeNotifier {
  final SPLoginApi _api = SPLoginApi();


  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  ProviderLoginResponseModel? _user;
  ProviderLoginResponseModel? get user => _user;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<String>? _huaweiTokenSubscription;
  StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      final result = await _api.login(
        email: normalizedEmail,
        password: password,
      );

      if (result != null && result.data != null) {
        _user = result;
        
        final String freshAccessToken = result.data!.accessToken;

        await AuthSessionController.instance.setSession(
          id: result.data!.id,
        
          accessToken: freshAccessToken,
          refreshToken: result.data!.refreshToken,
        );

        // Explicitly cascade the working access token to prevent 401 log events
        await _fetchAndSendPushToken(normalizedEmail, freshAccessToken);

        return true;
      } else {
        _errorMessage = "Login failed";
        return false;
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAndSendPushToken(String email, String dynamicAuthToken) async {
    if (!Platform.isAndroid) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    try {
      if (useHuaweiPush) {
        if (kDebugMode) print("Huawei device detected → using Huawei Push");

        await _huaweiTokenSubscription?.cancel();
        _huaweiTokenSubscription = Push.getTokenStream.listen(
          (String token) async {
            if (token.isEmpty) return;

            final result = await _api.updatePushToken(
              email: email,
              token: token,
              provider: 'huawei',
              authToken: dynamicAuthToken,
              deviceType: deviceInfo['deviceType'],
              deviceName: deviceInfo['deviceName'],
              osVersion: deviceInfo['osVersion'],
              appVersion: appVersion,
            );

            if (kDebugMode && result['statusCode'] != 200 && result['statusCode'] != 201) {
              print("Huawei registration failed: ${result['statusCode']} -> ${result['data']}");
            }
          },
          onError: (e) {
            if (kDebugMode) print("Huawei token stream error: $e");
          },
        );

        Push.getToken("HCM");
        return;
      }

      if (kDebugMode) print("Google device detected → using Firebase");

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        final result = await _api.updatePushToken(
          email: email,
          token: token,
          provider: 'firebase',
          authToken: dynamicAuthToken,
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode && result['statusCode'] != 200 && result['statusCode'] != 201) {
          print("Firebase registration failed: ${result['statusCode']} -> ${result['data']}");
        }
      }

      // Handle hot token rotations dynamically
      await _firebaseTokenRefreshSubscription?.cancel();
      _firebaseTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        // Fallback to active runtime configuration string if session has run long
        final activeToken = AuthSessionController.instance.accessToken ?? dynamicAuthToken;
        
        await _api.updatePushToken(
          email: email,
          token: newToken,
          provider: 'firebase',
          authToken: activeToken,
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );
      });
    } catch (e) {
      if (kDebugMode) print("Push token parsing error context: $e");
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    String deviceName = '';
    String osVersion = '';

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.model;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = iosInfo.name;
        osVersion = iosInfo.systemVersion;
      }
    } catch (e) {
      if (kDebugMode) print("Device info error: $e");
    }

    return {
      'deviceType': deviceType,
      'deviceName': deviceName,
      'osVersion': osVersion,
    };
  }

  Future<String> _getAppVersion() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();
    super.dispose();
  }
}