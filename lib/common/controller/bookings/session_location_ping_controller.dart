import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';
import '../../services/post_session_location_ping_api.dart';

enum PingPostState {
  idle,
  posting,
  success,
  error,
}

class SessionLocationPingController extends ChangeNotifier {
  PingPostState _state = PingPostState.idle;
  PingPostState get state => _state;

  String? errorMessage;

  SessionLocationPingModel? _lastPing;
  SessionLocationPingModel? get lastPing => _lastPing;

  bool get isPosting => _state == PingPostState.posting;

  /* ---------------- Public API ---------------- */

  Future<void> postPing({
    required int sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    _setState(PingPostState.posting);

    try {
      final ping = await SessionLocationPingApi.postPing(
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      _lastPing = ping;
      _setState(PingPostState.success);
    } catch (e, stack) {
      errorMessage = e.toString();
      _setState(PingPostState.error);

      if (kDebugMode) {
        debugPrint('❌ SessionLocationPing failed');
        debugPrint(errorMessage);
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  /* ---------------- Derived UI helpers ---------------- */

  bool get isInsideGeofence =>
      _lastPing?.insideGeofence ?? true;

  double? get distanceMeters =>
      _lastPing?.distanceFromSiteMeters;

  DateTime? get lastPingTime =>
      _lastPing?.createdAt;

  /* ---------------- Internal ---------------- */

  void _setState(PingPostState newState) {
    _state = newState;
    notifyListeners();
  }

  void reset() {
    _state = PingPostState.idle;
    errorMessage = null;
    _lastPing = null;
    notifyListeners();
  }
}
