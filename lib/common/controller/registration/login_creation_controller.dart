import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/provider_login_response_model.dart';
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

    if (response["success"] == true) {
      try {
        final outerMap = response["data"] as Map<String, dynamic>;
        
        // Fix: Extract the targeted payload block containing user credentials and JWT parameters
        final payloadData = outerMap["data"] as Map<String, dynamic>;

        final model = ProviderLoginResponseModel.fromJson(payloadData);

        if (kDebugMode) {
          print("🌐 PARSED STATUS: Registration success validation passed.");
          print("🎯 USER ID: ${model.id}");
          print("🔑 ACCESS TOKEN: ${model.accessToken?.substring(0, 15)}...");
        }

        await AuthSessionController.instance.setSession(
          id: model.id ?? 0,
          email: model.email ?? '',
          accessToken: model.accessToken ?? '',
          refreshToken: model.refreshToken ?? '',
        );

        _errorMessage = null;
        notifyListeners();
        return true;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print("❌ SERIALIZATION EXCEPTION: $e\n$stackTrace");
        }
        _errorMessage = "Application error during registration parsing.";
        notifyListeners();
        return false;
      }
    } else {
      _errorMessage = response["message"] ?? "An unexpected authentication problem occurred.";
      notifyListeners();
      return false;
    }
  }
}