import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/services/delete_provider_qualification_api.dart';


class DeleteProviderQualificationController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> deleteQualification({
    required int qualificationId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DeleteProviderQualificationApi.deleteQualification(
        qualificationId: qualificationId,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = "Failed to delete qualification.";
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