import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/services/cost_of_service_api.dart';

import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CostOfServiceController extends ChangeNotifier {
  final CostOfServiceApi api = CostOfServiceApi();

  bool isLoading = false;
  String? errorMessage;
  double? updatedCost;
  int? costId;

  StreamSubscription<String>? _huaweiTokenSubscription;
  StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  Future<bool> updateServiceCost({
    required String notes,
   
    required int serviceId,
    required double cost,
    String? token,
    List<File> images = const [],
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

     

      final response = await CostOfServiceApi.updateServiceCost(
     
        serviceId: serviceId,
        cost: cost,
     
        notes: notes,
      );

      final costData = response["cost_of_service"] as Map<String, dynamic>?;

      if (costData == null) {
        throw Exception("Cost of service data was not returned.");
      }

      costId = costData["id"] as int?;
      updatedCost = double.tryParse(costData["base_price"]?.toString() ?? "");

      if (costId == null) {
        throw Exception("Cost ID was not returned.");
      }

      if (images.isNotEmpty) {
        await CostOfServiceApi.uploadServiceImages(
          costId: costId!,
          images: images,
          
        );
      }

      
      

      

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAndSendPushToken(String email) async {
    if (!Platform.isAndroid) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    try {
      if (useHuaweiPush) {
        if (kDebugMode) {
          print("Huawei device detected → using Huawei Push");
        }

        await _huaweiTokenSubscription?.cancel();

        _huaweiTokenSubscription = Push.getTokenStream.listen(
          (String token) async {
            if (token.isEmpty) return;

            final result = await CostOfServiceApi.updatePushToken(
              email: email,
              token: token,
              provider: 'huawei',
              deviceType: deviceInfo['deviceType'],
              deviceName: deviceInfo['deviceName'],
              osVersion: deviceInfo['osVersion'],
              appVersion: appVersion,
            );

            if (kDebugMode) {
              print("Huawei token post result: $result");
            }
          },
          onError: (e) {
            if (kDebugMode) {
              print("Huawei token stream error: $e");
            }
          },
        );

        Push.getToken("HCM");
        return;
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        final result = await CostOfServiceApi.updatePushToken(
          email: email,
          token: token,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode) {
          print("Firebase token post result: $result");
        }
      }

      await _firebaseTokenRefreshSubscription?.cancel();
      _firebaseTokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final result = await CostOfServiceApi.updatePushToken(
          email: email,
          token: newToken,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode) {
          print("Firebase refreshed token result: $result");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Push token error after cost update: $e");
      }
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
      if (kDebugMode) {
        print("Device info error: $e");
      }
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
      if (kDebugMode) {
        print("App version error: $e");
      }
      return '';
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();
    super.dispose();
  }
}