import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/services/upload_cost_of_service_images_api.dart';

class UploadCostOfServiceImagesController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> uploadImages({
    required int costId,
    required List<File> images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UploadCostOfServiceImagesApi.uploadImages(
        costId: costId,
        images: images,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = "Failed to upload service images.";
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