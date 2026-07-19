import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/toggle_provider_active_api.dart';

class ProviderActiveController extends ChangeNotifier {
  static final ProviderActiveController _instance =
      ProviderActiveController._internal();

  factory ProviderActiveController() => _instance;

  static ProviderActiveController get instance => _instance;

  ProviderActiveController._internal();

  bool _isActive = true;
  bool get isActive => _isActive;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  void setInitialStatus(bool value) {
    _isActive = value;
    notifyListeners();
  }

  Future<bool> toggleActive() async {
    _isLoading = true;
    notifyListeners();

    final result = await ToggleProviderActiveApi.toggleProviderActive();

    if (result["success"] == true) {
      _isActive = result["is_active"] ?? _isActive;
      _message = result["message"];
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _message = result["message"];
    _isLoading = false;
    notifyListeners();
    return false;
  }
}