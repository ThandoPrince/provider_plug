import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/storage.dart';

String getInitialRoute() {
  final isFirstTime =
      Storage().getBool('isFirstTimeProvider') ?? true;

  final auth = AuthSessionController.instance;

  if (kDebugMode) {
    print("========== INITIAL ROUTE CHECK ==========");
    print("isFirstTimeProvider: $isFirstTime");
    print("AuthSessionController.isLoggedIn: ${auth.isLoggedIn}");
  }

  if (isFirstTime) {
    if (kDebugMode) {
      print("Initial route: /onboarding");
    }
    return '/onboarding';
  }

  if (auth.isLoggedIn) {
    if (kDebugMode) {
      print("Initial route: /entrypoint");
    }
    return '/entrypoint';
  }

  if (kDebugMode) {
    print("Initial route: /login");
  }

  return '/login';
}