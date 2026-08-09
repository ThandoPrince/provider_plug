
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/address_id_creation_api.dart';

class SPAddressDocumentController extends ChangeNotifier {
  final SPAddressDocumentApiHelper _apiHelper =
      SPAddressDocumentApiHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> addAddressAndDocument({
    required Map<String, dynamic> address,
    required String idType,
    File? frontFile,
    File? backFile,
    File? livenessVideo,
  }) async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ----------------------------------------------------------
      // Validate files before starting the upload
      // ----------------------------------------------------------

      if (frontFile != null && !await frontFile.exists()) {
        _errorMessage = "Front ID file could not be found.";
        return false;
      }

      if (backFile != null && !await backFile.exists()) {
        _errorMessage = "Back ID file could not be found.";
        return false;
      }

      if (livenessVideo != null &&
          !await livenessVideo.exists()) {
        _errorMessage = "Liveness video could not be found.";
        return false;
      }

      // ----------------------------------------------------------
      // Debug information
      // ----------------------------------------------------------

      if (kDebugMode && livenessVideo != null) {
        debugPrint("========== LIVENESS ==========");
        debugPrint("Path: ${livenessVideo.path}");
        debugPrint(
          "Exists: ${await livenessVideo.exists()}",
        );
        debugPrint(
          "Length: ${await livenessVideo.length()} bytes",
        );
        debugPrint("==============================");
      }

      // ----------------------------------------------------------
      // Upload
      // ----------------------------------------------------------

      final response =
          await SPAddressDocumentApiHelper.addAddressDocument(
        address: address,
        idType: idType,
        frontFile: frontFile,
        backFile: backFile,
        livenessVideo: livenessVideo,
      );

      // ----------------------------------------------------------
      // Success
      // ----------------------------------------------------------

      if (response["success"] == true) {
        _errorMessage = null;
        return true;
      }

      // ----------------------------------------------------------
      // Backend validation / application error
      // ----------------------------------------------------------

      _errorMessage = _extractErrorMessage(
        response,
        idType: idType,
      );

      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          "SP address/document upload failed: $e",
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      _errorMessage =
          "Unable to complete verification. Please try again.";

      return false;
    } finally {
      _isLoading = false;

      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  String _extractErrorMessage(
    Map<String, dynamic> response, {
    required String idType,
  }) {
    final dynamic errors = response["errors"];

    if (errors is Map) {
      // non_field_errors
      final nonFieldErrors = errors["non_field_errors"];

      if (nonFieldErrors is List &&
          nonFieldErrors.isNotEmpty) {
        return nonFieldErrors.first.toString();
      }

      // Address errors
      final addressErrors = errors["address"];

      if (addressErrors is Map &&
          addressErrors.isNotEmpty) {
        final firstValue = addressErrors.values.first;

        if (firstValue is List &&
            firstValue.isNotEmpty) {
          return "Address: ${firstValue.first}";
        }

        return "Address: $firstValue";
      }

      // Front ID
      final frontErrors = errors["front_file"];

      if (frontErrors is List &&
          frontErrors.isNotEmpty) {
        return "Front ID: ${frontErrors.first}";
      }

      // Back ID
      final backErrors = errors["back_file"];

      if (backErrors is List &&
          backErrors.isNotEmpty &&
          idType.toLowerCase() == "card") {
        return "Back ID: ${backErrors.first}";
      }

      // Liveness
      final livenessErrors = errors["liveness_video"];

      if (livenessErrors is List &&
          livenessErrors.isNotEmpty) {
        return "Liveness verification: ${livenessErrors.first}";
      }
    }

    return response["message"]?.toString() ??
        "Submission failed. Please try again.";
  }

  void clearError() {
    _errorMessage = null;

    if (hasListeners) {
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;

    if (hasListeners) {
      notifyListeners();
    }
  }
}

