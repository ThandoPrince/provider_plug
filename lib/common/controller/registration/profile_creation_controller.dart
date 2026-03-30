import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/profile_creation_api.dart';

class SPProfileCreationController extends ChangeNotifier {
  final SPProfileCreationApiHelper _apiHelper = SPProfileCreationApiHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  Future<bool> patchProfile({
    required String email,
    required String fullName,
    required String gender,
    required String idNumber,
    required String dob,
    String? spDescription,
    required File? profileImage, 
  }) async {
    // Basic safety check
    if (profileImage == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        "full_name": fullName,
        "gender": gender,
        "id_number": idNumber,
        "dob": dob,
        "sp_description": spDescription ?? "",
      };

      final response = await _apiHelper.patchSPProfile(
        email: email,
        data: data,
        profileImage: profileImage,
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
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Connection error. Please try again.";
      notifyListeners();
      return false;
    }
  }

}