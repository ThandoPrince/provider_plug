import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/update_session_status_api.dart';

class SessionStatusController extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<bool> endSession({
    required String status,
    required int sessionId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      await UpdateSessionStatusApi.updateSessionStatus(
        sessionId: sessionId,
        status: status,
        
        checkoutLocation: {
          "lat": latitude,
          "lng": longitude,
          "accuracy": accuracy,
        },
      );

      // If no exception → success
      return true;
    } catch (e) {
      debugPrint('End session failed: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
