import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/sp_details_model.dart';
import 'package:flutter_application_2/common/services/sp_profile_by_email_api.dart';
import 'package:intl/intl.dart';

class SpProfileCtrl with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  ServiceProviderModel? _spProfile;
  List<ServiceProviderModel>? _spProfiles;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ServiceProviderModel? get spProfile => _spProfile;
  List<ServiceProviderModel>? get spProfiles => _spProfiles;

  Future<void> fetchSPByEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _spProfile = await SpProfileByEmailApi.fetchSpProfileByEmail();
    } catch (e) {
      _errorMessage = e.toString();
      _spProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSps() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _spProfiles = await SpProfileByEmailApi.fetchSpProfile();
    } catch (e) {
      _errorMessage = e.toString();
      _spProfiles = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the logged-in provider profile.
  Future<void> refresh() async {
    await fetchSPByEmail();
  }

  /// Refresh the provider list.
  Future<void> refreshProviders() async {
    await fetchSps();
  }

  /// Update the current provider locally without making an API call.
  void updateProfile(ServiceProviderModel profile) {
    _spProfile = profile;
    notifyListeners();
  }

  String get formattedDob {
    if (_spProfile?.dob == null) return '';
    return DateFormat("dd MMM yyyy").format(_spProfile!.dob!);
  }

  String get formattedRating {
    final rating = _spProfile?.rating ?? 0.0;
    return rating.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> get formattedSpProfiles {
    if (_spProfiles == null) return [];

    return _spProfiles!.map((sp) {
      return {
        "fullName": sp.fullName,
        "email": sp.spProfile.emailAddress,
        "dob": sp.dob != null
            ? DateFormat("dd MMM yyyy").format(sp.dob!)
            : "",
        "rating": sp.rating.toStringAsFixed(2),
        "mobile": sp.mobileNumber,
        "profileImage": sp.fullProfileImageUrl,
        "location": sp.location?.formattedAddress ?? "",
      };
    }).toList();
  }
}