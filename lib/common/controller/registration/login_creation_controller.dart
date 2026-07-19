import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/registrastion_response_model.dart';
import 'package:flutter_application_2/common/services/auth_creation_api.dart';

class LoginCreationController extends ChangeNotifier {
  final AuthCreationApiHelper _apiHelper = AuthCreationApiHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> register({
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiHelper.registration(
      email: email.trim().toLowerCase(),
      password: password,
      mobileNumber: mobileNumber.trim(),
    );

    _isLoading = false;

    if (kDebugMode) {
      print("============== RESPONSE ==============");
      print(response);
      print("======================================");
    }

    if (response["success"] == true) {
      try {
        final Map<String, dynamic> apiResponse =
            Map<String, dynamic>.from(response["data"]);

        final Map<String, dynamic> payload =
            Map<String, dynamic>.from(apiResponse["data"]);

        if (kDebugMode) {
          print("============== PAYLOAD ==============");
          print(payload);
          print("=====================================");
        }

        final login = ProviderLoginData.fromJson(payload);

        if (kDebugMode) {
          print("🌐 Registration parsed successfully");
          print("🎯 USER ID: ${login.id}");
          print("📧 EMAIL: ${login.email}");
          print(
            "🔑 ACCESS TOKEN: ${login.accessToken.substring(0, 20)}...",
          );
          print(
            "🔄 REFRESH TOKEN: ${login.refreshToken.substring(0, 20)}...",
          );
        }

        await AuthSessionController.instance.setSession(
          id: login.id,
          
          accessToken: login.accessToken,
          refreshToken: login.refreshToken,
        );

        if (kDebugMode) {
          print("============== SAVED SESSION ==============");
          print("ID: ${AuthSessionController.instance.id}");
        
          print(
            "ACCESS: ${AuthSessionController.instance.accessToken}",
          );
          print(
            "REFRESH: ${AuthSessionController.instance.refreshToken}",
          );
          print("===========================================");
        }

        _errorMessage = null;
        notifyListeners();
        return true;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print("❌ REGISTRATION PARSE ERROR");
          print(e);
          print(stackTrace);
        }

        _errorMessage =
            "Application error during registration parsing.";
        notifyListeners();
        return false;
      }
    }

    _errorMessage =
        response["message"] ??
        "An unexpected authentication problem occurred.";

    notifyListeners();
    return false;
  }
}