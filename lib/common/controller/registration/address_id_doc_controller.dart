import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/address_id_creation_api.dart';


class SPAddressDocumentController extends ChangeNotifier {
  final SPAddressDocumentApiHelper _apiHelper = SPAddressDocumentApiHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Post address + optional document
  Future<bool> addAddressAndDocument({
    required String email,
    required Map<String, dynamic> address,
    File? documentFile,
    String? documentName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiHelper.addAddressDocument(
      email: email,
      address: address,
      documentFile: documentFile,
      documentName: documentName,
    );

    _isLoading = false;

    if (response["success"] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"] ?? "Unknown error";
      notifyListeners();
      return false;
    }
  }
}