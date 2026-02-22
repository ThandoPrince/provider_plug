import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/services/sp_login_api.dart';


class SPLoginController extends ChangeNotifier {
  final SPLoginApi _api = SPLoginApi();

  bool isLoading = false;
  String? errorMessage;

  /// Login function
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _api.login(email: email, password: password);

    isLoading = false;

    if (result["success"] == true) {
      // Save email to secure storage
      final authController = AuthSessionController.instance;
      await authController.setSession(email);

      notifyListeners();
      return true;
    } else {
      errorMessage = result["message"] ?? "Login failed";
      notifyListeners();
      return false;
    }
  }
}