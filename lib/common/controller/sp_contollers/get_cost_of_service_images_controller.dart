import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/cost_of_service_image_model.dart';
import 'package:flutter_application_2/common/services/get_cost_of_service_images_api.dart';

class GetCostOfServiceImagesController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  List<CostOfServiceImageModel> _images = [];

  // Tracks which costOfServiceId the current _images list belongs to.
  int? _loadedForCostId;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<CostOfServiceImageModel> get images => _images;

  bool isCachedFor(int costOfServiceId) => _loadedForCostId == costOfServiceId;

  Future<void> fetchImages(
    int costOfServiceId, {
    bool force = false,
  }) async {
    if (!force && isCachedFor(costOfServiceId)) {
      debugPrint(
        "⏭️ Skipping fetch — images already cached for cost id: $costOfServiceId",
      );
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _images = await GetCostOfServiceImagesApi.fetchImages(costOfServiceId);

      _loadedForCostId = costOfServiceId;

      debugPrint("FETCH IMAGES CALLED: $costOfServiceId");
    } catch (e) {
      _error = e.toString();
      _images = [];
      // Don't mark as loaded on failure — a retry should hit the network again.
      _loadedForCostId = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _images = [];
    _error = null;
    _loadedForCostId = null;
    notifyListeners();
  }
}