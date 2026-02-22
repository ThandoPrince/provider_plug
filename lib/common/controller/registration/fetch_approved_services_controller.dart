import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_application_2/common/services/fetch_approved_services_api.dart';


class FetchApprovedServicesController extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      _services = await FetchApprovedServicesApi.fetchApprovedServices();
    } catch (e) {
      debugPrint("Service fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}