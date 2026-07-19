import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/ratings_model.dart';
import 'package:flutter_application_2/common/services/completed_services_api.dart';


class ProviderRatingsController extends ChangeNotifier {
  final ProviderCompletedServicesApi api = ProviderCompletedServicesApi();

  List<RatingModel> _ratings = [];
  bool _isLoading = false;

  List<RatingModel> get ratings => _ratings;
  bool get isLoading => _isLoading;

  Future<void> fetchRatings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ratings = await ProviderCompletedServicesApi.fetchRatingsByProviderEmail();
    } catch (e) {
      debugPrint("Error fetching provider ratings: $e");
      _ratings = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}