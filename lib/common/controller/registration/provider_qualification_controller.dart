import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/provider_qualification_api.dart';

class ProviderQualificationController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Map<String, dynamic>? get response => _response;

  Future<bool> uploadQualification({
    required int providerServiceId,
    required File document,
    required String documentType,
    required String title,
    String issuingBody = "",
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;

    notifyListeners();

    try {
      _response = await ProviderQualificationApi.uploadQualification(
        providerServiceId: providerServiceId,
        document: document,
        documentType: documentType,
        title: title,
        issuingBody: issuingBody,
        issueDate: issueDate,
        expiryDate: expiryDate,
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
}