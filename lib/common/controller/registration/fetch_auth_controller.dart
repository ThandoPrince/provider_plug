import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/sp_profile_model.dart';
import 'package:flutter_application_2/common/services/fetch_auth_api.dart';



class FetchAuthController extends ChangeNotifier {
  static final FetchAuthController _instance =
      FetchAuthController._internal();
  factory FetchAuthController() => _instance;
  static FetchAuthController get instance => _instance;

  FetchAuthController._internal();

  final FetchAuthApi _api = FetchAuthApi();

  SPProfileModel? _profile;
  SPProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> fetchProfile(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchSPProfile(email);

      if (result['success'] == true) {
        _profile = result['data'] as SPProfileModel;
        return true;
      } else {
        _error = result['message']?.toString() ?? 'Failed to fetch profile';
        return false;
      }
    } catch (e) {
      _error = 'Failed to fetch profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}