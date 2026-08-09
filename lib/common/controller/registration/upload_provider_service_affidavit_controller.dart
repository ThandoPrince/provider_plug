
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/upload_provider_service_affidavit_api.dart';

class UploadProviderServiceAffidavitController
    extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Map<String, dynamic>? get response => _response;

  Future<bool> uploadAffidavit({
    required int providerServiceId,
    required File affidavit,
  }) async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _response = null;

    notifyListeners();

    try {
      _response =
          await UploadProviderServiceAffidavitApi
              .uploadAffidavit(
        providerServiceId: providerServiceId,
        affidavit: affidavit,
      );

      final success =
          _response?["success"] == true;

      if (!success) {
        _errorMessage =
            _response?["message"] ??
            "Unable to upload affidavit.";
      }

      return success;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

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

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}

