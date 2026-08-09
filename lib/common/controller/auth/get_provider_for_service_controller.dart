import 'package:flutter/material.dart';

import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';

import 'package:flutter_application_2/common/services/get_provider_for_service_api.dart';

class GetProviderForServiceController extends ChangeNotifier {
  static final GetProviderForServiceController _instance =
      GetProviderForServiceController._internal();

  factory GetProviderForServiceController() => _instance;

  static GetProviderForServiceController get instance => _instance;

  GetProviderForServiceController._internal();


  List<ProviderServiceModel> _services = [];
  List<ProviderServiceModel> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _count = 0;
  int get count => _count;

  Future<bool> fetchProviderServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await GetProviderForServiceApi.fetchProviderServices();

      if (result['success'] == true) {
        _services = (result['data'] as List<ProviderServiceModel>? ?? []);
        _count = result['count'] as int? ?? _services.length;
        return true;
      } else {
        _services = [];
        _count = 0;
        _error = result['message']?.toString() ??
            'Failed to fetch provider services';
        return false;
      }
    } catch (e) {
      _services = [];
      _count = 0;
      _error = 'Failed to fetch provider services: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ProviderServiceModel? get firstService {
    if (_services.isEmpty) return null;
    return _services.first;
  }

  ProviderServiceModel? get primaryService {
    try {
      return _services.firstWhere((item) => item.isPrimary == true);
    } catch (_) {
      return null;
    }
  }

  ProviderServiceModel? get firstServiceWithoutCost {
    try {
      return _services.firstWhere((item) => item.costOfService == null);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _services = [];
    _count = 0;
    _error = null;
    notifyListeners();
  }
}