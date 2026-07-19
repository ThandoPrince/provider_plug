import 'package:flutter/foundation.dart';

import 'package:flutter_application_2/common/models/models/client_models/client_ratings_model.dart';

import 'package:flutter_application_2/common/services/get_client_ratings_api.dart';

class ClientRatingsController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  double? averageRating;
  int? totalReviews;

  List<ClientRatingModel> ratings = [];

  Future<bool> fetchClientRatings(int clientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response =
          await FetchClientRatingsApi.fetchClientRatings(clientId);

      if (response['success'] == true) {
        ratings = response['data'] as List<ClientRatingModel>;
        averageRating =
            (response['averageRating'] as num?)?.toDouble();
        totalReviews = response['totalReviews'] as int?;

        isLoading = false;
        notifyListeners();
        return true;
      }

      errorMessage = response['message']?.toString();
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    ratings.clear();
    averageRating = null;
    totalReviews = null;
    errorMessage = null;
    notifyListeners();
  }
}