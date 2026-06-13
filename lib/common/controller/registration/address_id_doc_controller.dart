import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/address_id_creation_api.dart';

class SPAddressDocumentController extends ChangeNotifier {
  final SPAddressDocumentApiHelper _apiHelper = SPAddressDocumentApiHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> addAddressAndDocument({
    required String email,
    required Map<String, dynamic> address,
    required String idType,
    File? frontFile,
    File? backFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await SPAddressDocumentApiHelper.addAddressDocument(
      email: email,
      address: address,
      idType: idType,
      frontFile: frontFile,
      backFile: backFile, // just pass null if Greenbook
    );

    _isLoading = false;

    if (response["success"] == true) {
      notifyListeners();
      return true;
    } else {
      final dynamic errors = response["errors"];

      if (errors != null && errors is Map) {
        if (errors['non_field_errors'] != null) {
          _errorMessage = errors['non_field_errors'][0].toString();
        } else if (errors['address'] != null && errors['address'] is Map) {
          final addressErrors = errors['address'] as Map;
          _errorMessage = "Address: ${addressErrors.values.first[0]}";
        } else if (errors['front_file'] != null) {
          _errorMessage = "Front ID: ${errors['front_file'][0]}";
        } else if (errors['back_file'] != null && idType.toLowerCase() == 'card') {
          _errorMessage = "Back ID: ${errors['back_file'][0]}";
        } else {
          _errorMessage =
              response["message"] ?? "Submission failed. Please check your data.";
        }
      } else {
        _errorMessage = response["message"] ?? "Unknown server error";
      }

      notifyListeners();
      return false;
    }
  }
}