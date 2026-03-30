import 'package:flutter/material.dart';
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
    required String mobileNumber
  }) async {
    _isLoading = true;
    _errorMessage = null; // Clear old errors
    notifyListeners();

    final response = await _apiHelper.registration(
      email: email.toLowerCase(),
      password: password,
      mobileNumber: mobileNumber,
    );

    _isLoading = false;

    if (response["success"]) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }
}