import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_application_2/common/services/sp_update_profile_api.dart';

class ProviderProfileController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Map<String, dynamic>? get response => _response;

  Future<bool> updateProfile({
    File? profileImage,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;

    notifyListeners();

    try {
      _response = await ProviderProfileApi.updateProfile(
        profileImage: profileImage,
        description: description,
      );

      return _response?["success"] == true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearResponse() {
    _response = null;
    notifyListeners();
  }
}