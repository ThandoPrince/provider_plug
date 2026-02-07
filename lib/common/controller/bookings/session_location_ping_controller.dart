import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import '../../services/post_session_location_ping_api.dart';

enum PingPostState {
  idle,
  posting,
  success,
  error,
}

class SessionLocationPingController extends ChangeNotifier {
  /* ---------------- State ---------------- */
  PingPostState _state = PingPostState.idle;
  PingPostState get state => _state;

  String? errorMessage;

  SessionLocationPingModel? _lastPing;
  SessionLocationPingModel? get lastPing => _lastPing;

  bool get isPosting => _state == PingPostState.posting;

  /* ---------------- Geofence Config (Static) ---------------- */
  static const double geofenceRadius = 50; // meters
 // replace with actual

  /* ---------------- Public API ---------------- */

  /// Post a ping and update UI immediately
  Future<void> postPing({
    required int sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    SessionModel? session,
    required double siteLatitude,
    required double siteLongitude,
  }) async {
    _setState(PingPostState.posting);

    // 1️⃣ Compute distance locally for immediate UI feedback
    final distance = Geolocator.distanceBetween(
  latitude,
  longitude,
  siteLatitude,
  siteLongitude,
);
    final inside = distance <= geofenceRadius;

    // 2️⃣ Update lastPing immediately for live UI
    _lastPing = SessionLocationPingModel(
      session: session,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      distanceFromSiteMeters: distance,
      insideGeofence: inside,
      createdAt: DateTime.now(),
    );
    notifyListeners();

    // 3️⃣ Post to backend asynchronously
    try {
      await SessionLocationPingApi.postPing(
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );
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

  bool get isInsideGeofence => _lastPing?.insideGeofence ?? false;
  bool get isOutsideGeofence => !isInsideGeofence;

  double? get distanceMeters => _lastPing?.distanceFromSiteMeters;
  DateTime? get lastPingTime => _lastPing?.createdAt;

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
