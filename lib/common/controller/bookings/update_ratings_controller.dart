import 'package:flutter/material.dart';

import 'package:flutter_application_2/common/services/update_ratings_api.dart';

class RatingController extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<bool> submitRating({
    required String sessionId,
    required String providerEmail,
    required int score,
    String? review,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final success = await PatchRatingApi.patchRating(
        sessionId: sessionId,
        providerEmail: providerEmail,
        score: score,
        review: review,
      );
      return success;
    } catch (e) {
      debugPrint("❌ Error submitting rating: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
