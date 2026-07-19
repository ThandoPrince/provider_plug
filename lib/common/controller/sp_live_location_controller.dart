import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/sp_live_location_post_model.dart';
import 'package:flutter_application_2/common/services/provider_booking_socket_service.dart';
import 'package:flutter_application_2/common/services/sp_live_location_post_api.dart';
import 'package:geolocator/geolocator.dart';

class SpLiveLocationPostController extends ChangeNotifier {
  final ProviderBookingSocketService _socketService;

  SpLiveLocationPostController(this._socketService) {
  debugPrint("📍 SpLiveLocationPostController initialized");

  _socketService.onConnected = () {
    debugPrint("🟢 WebSocket connected");

    if (_isTracking && _currentProviderId != null) {
      debugPrint(
        "📡 Restarting location upload after reconnect "
        "(provider=$_currentProviderId)",
      );

      _sendLocation(_currentProviderId!);
    }
  };
}


  Timer? _timer;

  bool _isTracking = false;
  bool _isSending = false;
  bool _disposed = false;

  int? _currentProviderId;

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;
  int? get currentProviderId => _currentProviderId;

  /// Sync tracking with provider status
  Future<void> syncTrackingWithStatus({
    required int providerId,
    required bool isOnline,
  }) async {
    if (isOnline) {
      if (_isTracking && _currentProviderId == providerId) return;
      await startTracking(providerId: providerId);
    } else {
      if (!_isTracking) return;
      stopTracking();
    }
  }

  /// Start tracking
  Future<void> startTracking({
    required int providerId,
    int intervalSeconds = 30,
  }) async {
    debugPrint(
    "🚀 ENTER startTracking(providerId=$providerId, disposed=$_disposed)",
  );

    if (_disposed) return;

    _timer?.cancel();
    _timer = null;

    final isSameProvider = _currentProviderId == providerId;

    if (_isTracking && isSameProvider) {
      _setupTimer(providerId, intervalSeconds);
      return;
    }

    if (_isTracking && !isSameProvider) {
      stopTracking();
    }

    _currentProviderId = providerId;
    _isTracking = true;
    _notify();

    _setupTimer(providerId, intervalSeconds);

    await _sendLocation(providerId);
  }

  void _setupTimer(int providerId, int intervalSeconds) {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (!_isTracking ||
          _disposed ||
          _currentProviderId != providerId) {
        _timer?.cancel();
        return;
      }

      _sendLocation(providerId);
    });
  }

  /// Stop tracking
  void stopTracking({bool notify = true}) {
  _timer?.cancel();
  _timer = null;

  _isTracking = false;
  _currentProviderId = null;

  if (notify) {
    _notify();
  }
}

  /// Send live location
  Future<void> _sendLocation(int providerId) async {
  debugPrint("📍 _sendLocation ENTER");

  if (_disposed || _isSending) {
    debugPrint(
      "❌ Returning (_disposed=$_disposed, _isSending=$_isSending)",
    );
    return;
  }

  _isSending = true;
  debugPrint("📍 _isSending = true");
  _notify();

  try {
    debugPrint("📍 Checking permission");
    final hasPermission = await _ensurePermission();

    debugPrint("📍 Permission = $hasPermission");

    if (!hasPermission || _disposed || !_isTracking) {
      debugPrint(
        "❌ Aborting (permission=$hasPermission, disposed=$_disposed, tracking=$_isTracking)",
      );
      return;
    }

    debugPrint("📍 Getting last known position");

    Position? position = await Geolocator.getLastKnownPosition();

    debugPrint("📍 Last known = $position");

    position ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    debugPrint(
      "📍 Current position = ${position.latitude}, ${position.longitude}",
    );

    debugPrint("📡 Sending to websocket");

    await _socketService.sendLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    debugPrint("✅ Websocket send finished");
  } catch (e, stack) {
    debugPrint("❌ _sendLocation exception");
    debugPrint("$e");
    debugPrint("$stack");
  } finally {
    _isSending = false;
    debugPrint("📍 _isSending = false");
    _notify();
  }
}

  /// Check location permissions
  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return false;

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _disposed = true;
    super.dispose();
  }
}