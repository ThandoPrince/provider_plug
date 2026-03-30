import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_application_2/common/services/fetch_approved_services_api.dart';

class FetchApprovedServicesController extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _errorMessage; 

 
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

 
  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();

    try {
      _services = await FetchApprovedServicesApi.fetchApprovedServices();
    } catch (e) {
      
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint("Service fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> refreshServices() async {
    _services = [];
    await loadServices();
  }
}