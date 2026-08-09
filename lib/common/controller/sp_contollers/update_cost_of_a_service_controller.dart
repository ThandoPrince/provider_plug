import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/services/update_provider_cost_of_service_api.dart';


class UpdateCostOfAServiceController
    extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> updateServiceCost({
    required int costId,
    required double cost,
    required String notes,
    List<File> images = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await CostOfServiceApi.updateServiceCost(
        costId: costId,
        cost: cost,
        notes: notes,
      );

      if (images.isNotEmpty) {
        await CostOfServiceApi.uploadServiceImages(
          costId: costId,
          images: images,
        );
      }

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          "Failed to update service information.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadServiceImages({
    required int costId,
    required List<File> images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await CostOfServiceApi.uploadServiceImages(
        costId: costId,
        images: images,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          "Failed to upload service images.";
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