import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/provider_qualification_model.dart';
import 'package:flutter_application_2/common/services/get_provider_qualification_api.dart';

class GetProviderQualificationController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  List<ProviderQualificationModel> _qualifications = [];

  // Tracks which providerServiceId the current _qualifications list belongs to.
  int? _loadedForServiceId;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<ProviderQualificationModel> get qualifications => _qualifications;

  /// True if we already have a successful, non-empty-or-confirmed-empty
  /// fetch cached for this exact service id.
  bool isCachedFor(int providerServiceId) =>
      _loadedForServiceId == providerServiceId;

  Future<void> fetchQualification(
    int providerServiceId, {
    bool force = false,
  }) async {
    // Skip the network call entirely if we already loaded this service
    // and the caller isn't explicitly asking for a fresh copy.
    if (!force && isCachedFor(providerServiceId)) {
      debugPrint(
        "⏭️ Skipping fetch — qualifications already cached for service: $providerServiceId",
      );
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint(
        "📥 Fetching qualifications for service: $providerServiceId",
      );

      _qualifications =
          await GetProviderQualificationApi.fetchQualification(
        providerServiceId,
      );

      _loadedForServiceId = providerServiceId;

      debugPrint(
        "✅ Qualifications fetched: ${_qualifications.length}",
      );

      for (final q in _qualifications) {
        debugPrint(
          "• ID: ${q.id} | Title: ${q.title} | Type: ${q.documentType}",
        );
      }
    } catch (e, stack) {
      debugPrint("❌ fetchQualification ERROR");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      _error = e.toString();
      _qualifications = [];
      // Don't mark as loaded on failure — a retry should hit the network again.
      _loadedForServiceId = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _qualifications = [];
    _error = null;
    _loadedForServiceId = null;
    notifyListeners();
  }
}